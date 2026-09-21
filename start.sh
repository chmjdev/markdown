#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
if [ "$#" -ne 1 ]; then printf '%s\n' 'Usage: ./start.sh dev|prod|stop|restart|logs|status|clean'; exit 2; fi
PROJECT_NAME=markdown
STAGE="$1"
jcds_port() { python3 -c 'import json,sys; print(json.load(open("jcds.config"))["ports"][sys.argv[1]])' "$1"; }
jcds_env_file() {
    local f="/etc/jcds/env/${PROJECT_NAME}-${STAGE}.env"
    if [ -r "$f" ]; then printf '%s' "$f"; elif [ "$STAGE" = dev ] && [ -f .env ]; then printf '%s' .env; fi
}
case "$STAGE" in
    dev)
        python3 scripts/check_guide.py
        MARKDOWN_DRIVER=$(python3 -c 'import json; d=json.load(open("jcds.config")); print(d.get("dev_driver",d["driver"]))')
        [ "$MARKDOWN_DRIVER" = native ] || { printf '%s\n' 'Dev driver must be native'; exit 1; }
        exec python3 -m http.server "$(jcds_port dev)" --bind 127.0.0.1 --directory public
        ;;
    prod)
        python3 scripts/check_guide.py
        MARKDOWN_PORT=$(jcds_port prod)
        MARKDOWN_ENV=$(jcds_env_file)
        docker build -t markdown-guide:prod .
        if docker container inspect markdown-prod >/dev/null 2>&1; then docker stop markdown-prod; docker rm markdown-prod; fi
        MARKDOWN_ARGS=()
        if [ -n "$MARKDOWN_ENV" ]; then MARKDOWN_ARGS+=(--env-file "$MARKDOWN_ENV"); fi
        docker run -d --name markdown-prod --restart unless-stopped -p "127.0.0.1:${MARKDOWN_PORT}:8080" "${MARKDOWN_ARGS[@]}" markdown-guide:prod
        ;;
    uat) printf '%s\n' 'markdown.pltfm.ai supports dev → prod only'; exit 2 ;;
    status) docker inspect --format '{{.State.Status}}' markdown-prod ;;
    logs) docker logs --tail 100 markdown-prod ;;
    restart) docker restart markdown-prod ;;
    stop) docker stop markdown-prod ;;
    clean) printf '%s\n' 'No persistent guide data to clean.' ;;
    *) printf '%s\n' 'Unknown command'; exit 2 ;;
esac
