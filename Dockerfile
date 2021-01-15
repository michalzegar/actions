FROM alpine
LABEL "repository"="https://github.com/sky-distribution/tag-version"
LABEL "homepage"="https://github.com/sky-distribution/tag-version"
LABEL "maintainer"="Sky distribution"

COPY ./semver ./semver
RUN install ./semver /usr/local/bin
COPY entrypoint.sh /entrypoint.sh

RUN apk update && apk add bash git curl jq

RUN ["chmod", "+x", "/entrypoint.sh"]

ENTRYPOINT ["/entrypoint.sh"]
