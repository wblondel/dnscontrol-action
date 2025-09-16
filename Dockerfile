FROM stackexchange/dnscontrol:4.25.0

LABEL repository="https://github.com/wblondel/dnscontrol-action"
LABEL maintainer="William Gérald Blondel <contact@williamblondel.fr>"

LABEL "com.github.actions.name"="DNSControl"
LABEL "com.github.actions.description"="Check, preview and deploy your DNS configuration to multiple providers."
LABEL "com.github.actions.icon"="cloud"
LABEL "com.github.actions.color"="yellow"

RUN dnscontrol version && \
    apk add --no-cache bash

COPY README.md entrypoint.sh bin/filter-preview-output.sh /
ENTRYPOINT ["/entrypoint.sh"]
