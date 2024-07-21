// Group all windows in the current workspace, or ungroup
package main

import (
	"fmt"
	"os"

	client "github.com/thiagokokada/hyprland-ipc-client/v3"
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
	c := client.MustClient(os.Getenv("HYPRLAND_INSTANCE_SIGNATURE"))
	awindow := must1(c.ActiveWindow())
	batchArgs := client.NewByteQueue()
	// https://github.com/labi-le/hyprland-ipc-client/issues/7
	batchArgs.Add([]byte("noop;"))

	if len(awindow.Grouped) > 0 {
		// If we are already in a group, ungroup
		batchArgs.Add([]byte("dispatch togglegroup;"))
		// Make the current window as master (when using master layout)
		batchArgs.Add([]byte("dispatch layoutmsg swapwithmaster master;"))
	} else {
		aworkspace := must1(c.ActiveWorkspace())
		clients := must1(c.Clients())

		// Grab all windows in the active workspace
		var windows []string
		for _, c := range clients {
			if c.Workspace.Id == aworkspace.Id {
				windows = append(windows, c.Address)
			}
		}

		// Start by creating a new group
		batchArgs.Add([]byte("dispatch togglegroup;"))
		for _, w := range windows {
			// Move each window inside the group
			// Once is not enough in case of very "deep" layouts,
			// so we run this multiple times to try to make sure it
			// will work
			// For master layouts we also call swapwithmaster, this
			// makes the switch more reliable
			for i := 0; i < 1; i++ {
				batchArgs.Add([]byte(fmt.Sprintf("dispatch focuswindow address:%s;", w)))
				batchArgs.Add([]byte("dispatch layoutmsg swapwithmaster auto;"))
				batchArgs.Add([]byte("dispatch moveintogroup l;"))
				batchArgs.Add([]byte("dispatch moveintogroup r;"))
				batchArgs.Add([]byte("dispatch moveintogroup u;"))
				batchArgs.Add([]byte("dispatch moveintogroup d;"))
			}
		}
		// Focus in the active window at the end
		batchArgs.Add([]byte(fmt.Sprintf("dispatch focuswindow address:%s;", awindow.Address)))
	}
	fmt.Printf("# of Commands: %d\n", batchArgs.Len())
	// Run in batch for performance
	response := must1(c.Dispatch(batchArgs))
	fmt.Printf("Response: %s\n", response)
}
