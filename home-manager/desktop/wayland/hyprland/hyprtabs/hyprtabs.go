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
	client.Validate = false

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
			// Move each window inside the group
			// Once is not enough in case of very "deep" layouts,
			// so we run this multiple times to try to make sure it
			// will work
			// For master layouts we also call swapwithmaster, this
			// makes the switch more reliable
			for i := 0; i < 2; i++ {
				must1(client.Dispatch(
					fmt.Sprintf("focuswindow address:%s", w),
					"layoutmsg swapwithmaster auto",
					"moveintogroup l",
					"moveintogroup r",
					"moveintogroup u",
					"moveintogroup d",
				))
			}
		}
		// Focus in the active window at the end
		must1(client.Dispatch(fmt.Sprintf("focuswindow address:%s", aWindow.Address)))
	}
}
