# getcwd.yazi

Ask a running Yazi instance for the current directory of its active tab.
The plugin reads Yazi's internal state when the request arrives, so it works
after navigating or switching tabs without exiting Yazi.

Verified with Yazi and `ya` 26.1.22.

## Install

From this directory:

```sh
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/yazi/plugins/getcwd.yazi"
cp main.lua "${XDG_CONFIG_HOME:-$HOME/.config}/yazi/plugins/getcwd.yazi/main.lua"
```

Add this to your Yazi `init.lua`, then restart Yazi:

```lua
require("getcwd"):setup()
```

## Query from an external shell

Start Yazi with a globally unique numeric ID (123456 is only an example):

```sh
yazi --client-id 123456
```

In another terminal, with `ya`, `jq`, and `zsh` installed:

```sh
zsh examples/getcwd.zsh 123456
```

This prints the cwd as a string on stdout and exits. For example:

```text
/home/nic/Work/yazi-getcwd
```

From a Yazi subshell, you can pass `"$YAZI_ID"` instead. Use an absolute
path to the script if your shell is in another directory. Query failure or
a five-second timeout returns a nonzero exit code and a diagnostic on stderr.

## Message protocol

Subscribe to `return-active-cwd` on an external DDS connection, then send:

```sh
ya pub-to <yazi-instance-id> get-active-cwd --json '{"client_id": <listener-dds-id>}'
```

The placeholders above must be replaced with numeric IDs. The reply is
addressed only to that listener and has a JSON body with a string `cwd`:

```json
{"cwd":"/path/to/active/directory"}
```

Requests with a missing, nonnumeric, nonpositive, or fractional `client_id`
are ignored. In particular, `0` is rejected because it would broadcast the reply.

The listener ID is a DDS connection ID, not the shell PID or the ID of the
short-lived `ya pub-to` process. The example subscribes to a unique marker
and uses the `hey` handshake's peer list to discover its own listener ID
before sending the request. It checks the reply's receiver and sender, and
closes the subscription when finished.

Yazi's Lua publish API is `ps.pub_to`, rather than `ya.pub_to`. See the
[plugin API](https://yazi-rs.github.io/docs/plugins/utils/#pub_toreceiver-kind-value)
and [DDS documentation](https://yazi-rs.github.io/docs/dds/) for details.

The cwd is obtained with `tostring(cx.active.current.cwd)`; for a virtual
or remote directory, this may be a URL instead of a local filesystem path.
