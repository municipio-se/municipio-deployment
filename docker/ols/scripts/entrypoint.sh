#!/bin/bash
set -euo pipefail

readonly LSWS_CTRL=/usr/local/lsws/bin/lswsctrl
readonly LSWS_PID=/tmp/lshttpd/lshttpd.pid
readonly LSWS_LOGS=/usr/local/lsws/logs

# Conf hydration, sizing, ini and Tideways settings. See configure-runtime.sh.
# Municipio's setup.py has already run it moments before and says so with
# OLS_HBG_CONFIGURED, so it isn't applied (and logged) twice.
if [ "${OLS_HBG_CONFIGURED:-}" != 1 ]; then
  /usr/local/bin/ols-hbg-configure
fi

# Stream the server's logs to the container's output, so `docker logs` and
# Kubernetes show them: error.log (server messages, and PHP errors and
# warnings, tagged [STDERR]), stderr.log and the site's access log. -F keeps
# following the files when OpenLiteSpeed rotates them, and picks up files
# that don't exist yet; -n 0 skips lines from before this start.
tail -n 0 -q -F \
  "$LSWS_LOGS/error.log" \
  "$LSWS_LOGS/stderr.log" \
  "$LSWS_LOGS/localhost.access.log" 2>/dev/null &
readonly LOG_TAIL_PID=$!

stop_log_tail() {
  # Give tail a moment to print OpenLiteSpeed's last lines.
  sleep 0.5
  kill "$LOG_TAIL_PID" 2>/dev/null || true
}

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
# After a signal, wait for OpenLiteSpeed to finish stopping before ending the
# log stream.
while [ -f "$LSWS_PID" ] && kill -0 "$(cat "$LSWS_PID" 2>/dev/null)" 2>/dev/null; do
  sleep 0.2
done
stop_log_tail
