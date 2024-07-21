// Group all windows in the current workspace, or ungroup
package main

import (
	"fmt"
	"os"

	client "github.com/labi-le/hyprland-ipc-client/v3"
)

// Thanks to limitations to hyprland-ipc-client, we will dispatch if the number
// of commands in queue is equal or bigger to this constant
// https://github.com/labi-le/hyprland-ipc-client/issues/7#issuecomment-2241632277
const MAX_COMMANDS = 30

var (
	q *client.ByteQueue
	c *client.IPCClient
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

func mustDispatch() {
	if q.Len() > 0 {
		// Will dispatch multiple commands (i.e.: batch mode) for
		// performance
		fmt.Printf("# of Commands: %d\n", q.Len())
		response := must1(c.Dispatch(q))
		fmt.Printf("Response: %s\n", response)
	}
}

func mustAddOrDispatch(v string) {
	if q.Len() > MAX_COMMANDS {
		fmt.Println("Queue is full, calling dispatch")
		mustDispatch()
		q = client.NewByteQueue()
	}
	q.Add(client.UnsafeBytes(v))
}

func init() {
	c = client.MustClient(os.Getenv("HYPRLAND_INSTANCE_SIGNATURE"))
	q = client.NewByteQueue()
}

func main() {
	// Dispatch remaining commands at the end
	defer mustDispatch()

	aWindow := must1(c.ActiveWindow())
	if len(aWindow.Grouped) > 0 {
		// If we are already in a group, ungroup
		mustAddOrDispatch("togglegroup")
		// Make the current window as master (when using master layout)
		mustAddOrDispatch("layoutmsg swapwithmaster master")
	} else {
		aWorkspace := must1(c.ActiveWorkspace())
		clients := must1(c.Clients())

		// Grab all windows in the active workspace
		var windows []string
		for _, c := range clients {
			if c.Workspace.Id == aWorkspace.Id {
				windows = append(windows, c.Address)
			}
		}

		// Start by creating a new group
		mustAddOrDispatch("togglegroup")
		for _, w := range windows {
			// Move each window inside the group
			// Once is not enough in case of very "deep" layouts,
			// so we run this multiple times to try to make sure it
			// will work
			// For master layouts we also call swapwithmaster, this
			// makes the switch more reliable
			for i := 0; i < 2; i++ {
				mustAddOrDispatch(fmt.Sprintf("focuswindow address:%s", w))
				mustAddOrDispatch("layoutmsg swapwithmaster auto")
				mustAddOrDispatch("moveintogroup l")
				mustAddOrDispatch("moveintogroup r")
				mustAddOrDispatch("moveintogroup u")
				mustAddOrDispatch("moveintogroup d")
			}
		}
		// Focus in the active window at the end
		mustAddOrDispatch(fmt.Sprintf("focuswindow address:%s", aWindow.Address))
	}
}
