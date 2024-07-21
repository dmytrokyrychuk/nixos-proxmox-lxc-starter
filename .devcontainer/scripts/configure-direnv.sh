#!/bin/bash
set -e -o pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Create direnv config file if it does not exist
DIRENV_CONFIG_FILE=~/.config/direnv/direnv.toml
if [ ! -f $DIRENV_CONFIG_FILE ]; then
  mkdir -p $(dirname $DIRENV_CONFIG_FILE)
  cat <<EOF > $DIRENV_CONFIG_FILE
[global]
hide_env_diff = true

[whitelist]
exact = [ "$(realpath $DIR/../../.envrc)" ]
EOF
  echo "Direnv config file created at $DIRENV_CONFIG_FILE"
fi
