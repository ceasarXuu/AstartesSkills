# Remote Terminal Reconnect Design

## Goal

When the network drops, the client should reconnect to the previous remote
terminal session and continue rendering output.

## State Model

- `connected`: websocket is open and terminal output is streaming.
- `reconnecting`: websocket closed unexpectedly, client is trying again.
- `closed`: user closed the terminal tab.

## Flow

1. On websocket close, move to `reconnecting`.
2. Retry every two seconds until the socket opens.
3. On success, move to `connected`.
4. If the user closes the tab, move to `closed`.

## Notes

- The client keeps the previous terminal id in memory.
- The server resumes the terminal when the id is sent again.
- The UI shows a spinner while reconnecting.

