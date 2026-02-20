#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
bash update_requirements.sh
bash update_Libraryupdate.sh
bash push_and_pr.sh
