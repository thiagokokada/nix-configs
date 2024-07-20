// Call either movefocus or changegroupactive, depending on the conditions
package main

import (
	"encoding/json"
	"os"
	"os/exec"
)

type activewindow struct {
	Address string   `json:"address"`
	Grouped []string `json:"grouped"`
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

func main() {
	movement := os.Args[1]
	cmd := exec.Command("hyprctl", "activewindow", "-j")
	output := must1(cmd.Output())

	var window activewindow
	must0(json.Unmarshal(output, &window))

	// If we are not in a group, just call movefocus
	if len(window.Grouped) == 0 {
		cmd = exec.Command("hyprctl", "dispatch", "movefocus", movement)
	} else {
		// We are in a group
		switch movement {
		case "l":
			// Trying to move to left, if we are in the first
			// window in the group, move out of it. Otherwise, move
			// backwards inside the group
			if window.Address == window.Grouped[0] {
				cmd = exec.Command("hyprctl", "dispatch", "movefocus", "l")
			} else {
				cmd = exec.Command("hyprctl", "dispatch", "changegroupactive", "b")
			}
		case "r":
			// Trying to move to right, if we are in the last
			// window in the group, move out of it. Otherwise, move
			// forward inside the group
			if window.Address == window.Grouped[len(window.Grouped)-1] {
				cmd = exec.Command("hyprctl", "dispatch", "movefocus", "r")
			} else {
				cmd = exec.Command("hyprctl", "dispatch", "changegroupactive", "f")
			}
		}
	}
	must0(cmd.Start())
	os.Exit(0)
}
