FROM alpine
LABEL "repository"="https://github.com/michalzegar/actions"
LABEL "homepage"="https://github.com/michalzegar/actions"
LABEL "maintainer"="Michal Zegar"

COPY entrypoint.sh /entrypoint.sh

RUN apk update && apk add bash git curl jq && apk add --update nodejs npm && npm install -g semver

ENTRYPOINT ["/entrypoint.sh"]
