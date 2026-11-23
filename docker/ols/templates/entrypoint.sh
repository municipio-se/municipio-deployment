#!/bin/bash
set -euo pipefail

readonly LSWS_CTRL=/usr/local/lsws/bin/lswsctrl
readonly LSWS_PID=/tmp/lshttpd/lshttpd.pid

# Conf hydration, runtime tuning, PHP extensions, ini settings and lsphp env
# from environment variables. See templates/configure.sh.
/usr/local/bin/ols-hbg-configure

shutdown() {
  "$LSWS_CTRL" stop >/dev/null 2>&1 || true
}
trap shutdown TERM INT

"$LSWS_CTRL" start

# Run any extra command passed via `docker run`. Usually empty.
if [ "$#" -gt 0 ]; then
  "$@"
fi

# lswsctrl returns once lshttpd has forked; the daemon writes its pid file
# shortly after, so give it up to ~2s to appear before declaring failure.
for _ in $(seq 1 20); do
  [ -f "$LSWS_PID" ] && break
  sleep 0.1
done
if [ ! -f "$LSWS_PID" ]; then
  echo "OpenLiteSpeed pid file missing at $LSWS_PID" >&2
  exit 1
fi

# Block until the OLS daemon exits, or until SIGTERM/SIGINT triggers shutdown.
# `tail --pid` returns when the watched pid is gone; running it in the
# background means signals interrupt our `wait` so the trap fires promptly.
tail --pid="$(cat "$LSWS_PID")" -f /dev/null &
wait $! || true
