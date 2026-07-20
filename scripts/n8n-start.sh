#!/bin/sh
set -eu

WORKFLOWS_DIR="/files/workflows"
CREDS_DIR="/files/credentials"
CREDS_MARKER_FILE="/home/node/.n8n/.credentials-imported"
WORKFLOWS_MARKER_FILE="/home/node/.n8n/.workflows-imported"
GENERATED_CREDS_DIR="/tmp/n8n-generated-credentials"
OPENAI_MARKER_FILE="/home/node/.n8n/.openai-credential-imported.hash"

if [ -n "${OPENAI_API_KEY:-}" ]; then
  mkdir -p "$GENERATED_CREDS_DIR"

  OPENAI_CREDENTIAL_HASH="$(printf '%s' "$OPENAI_API_KEY" | sha256sum | awk '{print $1}')"
  PREVIOUS_OPENAI_CREDENTIAL_HASH=""

  if [ -f "$OPENAI_MARKER_FILE" ]; then
    PREVIOUS_OPENAI_CREDENTIAL_HASH="$(cat "$OPENAI_MARKER_FILE")"
  fi

  if [ "$OPENAI_CREDENTIAL_HASH" != "$PREVIOUS_OPENAI_CREDENTIAL_HASH" ]; then
    cat > "$GENERATED_CREDS_DIR/openai-desk.json" <<EOF
{"id":"desk-openai-credential","name":"Desk OpenAI","type":"openAiApi","data":{"apiKey":"$OPENAI_API_KEY"}}
EOF

    n8n import:credentials --separate --input="$GENERATED_CREDS_DIR"
    printf '%s' "$OPENAI_CREDENTIAL_HASH" > "$OPENAI_MARKER_FILE"
  fi
fi

if [ ! -f "$CREDS_MARKER_FILE" ]; then
  if [ -d "$CREDS_DIR" ] && find "$CREDS_DIR" -maxdepth 1 -name '*.json' | grep -q .; then
    n8n import:credentials --separate --input="$CREDS_DIR"
  fi

  touch "$CREDS_MARKER_FILE"
fi

if [ "${N8N_AUTO_IMPORT_WORKFLOWS:-false}" = "true" ]; then
  if [ ! -f "$WORKFLOWS_MARKER_FILE" ]; then
    if [ -d "$WORKFLOWS_DIR" ] && find "$WORKFLOWS_DIR" -maxdepth 1 -name '*.json' | grep -q .; then
      n8n import:workflow --separate --input="$WORKFLOWS_DIR"
    fi

    touch "$WORKFLOWS_MARKER_FILE"
  fi
fi

exec n8n start
