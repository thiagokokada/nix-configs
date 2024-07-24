// Group all windows in the current workspace, or ungroup
package main

import (
	"fmt"

	"github.com/thiagokokada/hyprland-go"
)

func must1[T any](v T, err error) T {
	must(err)
	return v
}

func must(err error) {
	if err != nil {
		panic(err)
	}
}

func main() {
	client := hyprland.MustClient()

	aWindow := must1(client.ActiveWindow())
	if len(aWindow.Grouped) > 0 {
		client.Dispatch(
			// If we are already in a group, ungroup
			"togglegroup",
			// Make the current window as master (when using master layout)
			"layoutmsg swapwithmaster master",
		)
	} else {
		aWorkspace := must1(client.ActiveWorkspace())
		clients := must1(client.Clients())

		// Grab all windows in the active workspace
		var windows []string
		for _, c := range clients {
			if c.Workspace.Id == aWorkspace.Id {
				windows = append(windows, c.Address)
			}
		}

		// Start by creating a new group
		must1(client.Dispatch("togglegroup"))
		for _, w := range windows {
			var cmdbuf []string
			// Move each window inside the group
			// Once is not enough in case of very "deep" layouts,
			// so we run this multiple times to try to make sure it
			// will work
			// For master layouts we also call swapwithmaster, this
			// makes the switch more reliable
			// FIXME: this workaround could be fixed if hyprland
			// supported moving windows based on address and not
			// only positions
			for i := 0; i < 2; i++ {
				cmdbuf = append(cmdbuf, fmt.Sprintf("focuswindow address:%s", w))
				cmdbuf = append(cmdbuf, "layoutmsg swapwithmaster auto")
				cmdbuf = append(cmdbuf, "moveintogroup l")
				cmdbuf = append(cmdbuf, "moveintogroup r")
				cmdbuf = append(cmdbuf, "moveintogroup u")
				cmdbuf = append(cmdbuf, "moveintogroup d")
			}
			must1(client.Dispatch(cmdbuf...))
		}
		must1(client.Dispatch(
			// Focus in the active window at the end
			fmt.Sprintf("focuswindow address:%s", aWindow.Address),
			// Workaround window sometimes being stretch
			"fullscreen",
			"fullscreen",
		))
	}
}
