// Group all windows in the current workspace, or ungroup
package main

import (
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"strings"
)

type activewindow struct {
	Address string   `json:"address"`
	Grouped []string `json:"grouped"`
}

type activeworkspace struct {
	Id int64 `json:"id"`
}

type client struct {
	Address   string    `json:"address"`
	Workspace workspace `json:"workspace"`
}

type workspace struct {
	Id int64 `json:"id"`
}

func must1[T any](v T, err error) T {
	must0(err)
	return v
}

func must0(err error) {
	if err != nil {
		panic(err)
	}
}

func mustCmdAndUnmarshal(v any, name string, arg ...string) {
	cmd := exec.Command(name, arg...)
	output := must1(cmd.Output())
	must0(json.Unmarshal(output, v))
}

func main() {
	var awindow activewindow
	mustCmdAndUnmarshal(&awindow, "hyprctl", "activewindow", "-j")

	batch_args := []string{}

	if len(awindow.Grouped) > 0 {
		// If we are already in a group, ungroup
		batch_args = append(batch_args, "dispatch togglegroup")
		// Make the current window as master (when using master layout)
		batch_args = append(batch_args, "dispatch layoutmsg swapwithmaster master")
	} else {
		var aworkspace activeworkspace
		mustCmdAndUnmarshal(&aworkspace, "hyprctl", "activeworkspace", "-j")

		var clients []client
		mustCmdAndUnmarshal(&clients, "hyprctl", "clients", "-j")

		// Grab all windows in the active workspace
		var windows []string
		for _, c := range clients {
			if c.Workspace.Id == aworkspace.Id {
				windows = append(windows, c.Address)
			}
		}

		// Start by creating a new group
		batch_args = append(batch_args, "dispatch togglegroup")
		for _, w := range windows {
			// Move each window inside the group
			// Once is not enough in case of very "deep" layouts,
			// so we run this multiple times to try to make sure it
			// will work
			for i := 0; i < 2; i++ {
				batch_args = append(batch_args, "dispatch focuswindow address:"+w)
				batch_args = append(batch_args, "dispatch moveintogroup l")
				batch_args = append(batch_args, "dispatch moveintogroup r")
				batch_args = append(batch_args, "dispatch moveintogroup u")
				batch_args = append(batch_args, "dispatch moveintogroup d")
			}
		}
		// Focus in the active window at the end
		batch_args = append(batch_args, "dispatch focuswindow address:"+awindow.Address)
	}

	// Print commands for debugging
	if os.Getenv("DEBUG") != "" {
		fmt.Println(strings.Join(batch_args, "\n"))
	}

	// Run in batch for performance
	cmd := exec.Command("hyprctl", "dispatch", "--batch", strings.Join(batch_args, ";"))
	must0(cmd.Start())
	os.Exit(0)
}
