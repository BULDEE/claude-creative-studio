#!/usr/bin/env bash
# Embedded Direction Preview Server
# Zero-dependency HTTP server for visual direction comparison in Phase 1.
# Serves a self-contained HTML file on a random port.
# Usage: preview-server.sh start <html-file>
#        preview-server.sh stop

set -euo pipefail

PIDFILE="/tmp/creative-studio-preview.pid"

case "${1:-}" in
  start)
    HTML_FILE="${2:?Usage: preview-server.sh start <html-file>}"

    if [[ ! -f "$HTML_FILE" ]]; then
      echo '{"error":"File not found: '"$HTML_FILE"'"}' >&2
      exit 1
    fi

    # Kill any previous instance
    if [[ -f "$PIDFILE" ]]; then
      kill "$(cat "$PIDFILE")" 2>/dev/null || true
      rm -f "$PIDFILE"
    fi

    # Find a free port
    PORT=$(python3 -c "import socket; s=socket.socket(); s.bind(('',0)); print(s.getsockname()[1]); s.close()")

    # Serve the directory containing the HTML file
    SERVE_DIR="$(dirname "$HTML_FILE")"
    FILENAME="$(basename "$HTML_FILE")"

    cd "$SERVE_DIR" && python3 -m http.server "$PORT" --bind 127.0.0.1 &>/dev/null &
    echo $! > "$PIDFILE"

    URL="http://localhost:${PORT}/${FILENAME}"
    echo "{\"type\":\"server-started\",\"port\":${PORT},\"url\":\"${URL}\",\"pid\":$(cat "$PIDFILE")}"
    ;;

  stop)
    if [[ -f "$PIDFILE" ]]; then
      kill "$(cat "$PIDFILE")" 2>/dev/null || true
      rm -f "$PIDFILE"
      echo '{"type":"server-stopped"}'
    else
      echo '{"type":"no-server-running"}'
    fi
    ;;

  *)
    echo "Usage: preview-server.sh {start <html-file>|stop}" >&2
    exit 1
    ;;
esac
