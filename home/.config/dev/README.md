# dev

`dev <project>` opens a remote development session for a project on the server.

Defaults:

- Client machines SSH to `server-ssh-alias`.
- Server projects live under `~/Projects`.
- Herdr sessions are named `dev-<project>`.

Project configs live in `~/.config/dev/projects/<project>.conf` and are trusted shell snippets.

Example:

```bash
PROJECT_PATH="~/Projects/example"
DEV_SESSION="dev-example"

DEV_BOOTSTRAP_ONCE=(
  "mise install"
  "pnpm install"
)

DEV_BOOTSTRAP=(
  "git status --short"
)
```

Use Herdr inside the session to create tabs, panes, opencode, servers, and tests. Herdr persists those panes, so project layout setup is usually a one-time action per session.

Useful environment overrides:

```bash
DEV_SERVER_HOST="server-ssh-alias"
DEV_PROJECT_ROOT="~/Projects"
DEV_SERVER_MARKER_HOSTS="actual-server-hostname"
```
