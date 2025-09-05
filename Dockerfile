ADD alpine-minirootfs-3.22.0-aarch64.tar.gz / # buildkit

CMD ["/bin/sh"]

ENV NODE_VERSION=22.17.0

RUN /bin/sh -c addgroup -g 1000 node && adduser -u 1000 -G node -s /bin/sh -D node && apk add --no-cache libstdc++ && apk add --no-cache --virtual .build-deps curl && ARCH= OPENSSL_ARCH='linux*' && alpineArch="$(apk --print-arch)"       && case "${alpineArch##*-}" in         x86_64) ARCH='x64' CHECKSUM="830808c21d263bae5d0718ed61f7b6404693315d4b28e2ae6c5dc1b1f89fb2cb" OPENSSL_ARCH=linux-x86_64;;         x86) OPENSSL_ARCH=linux-elf;;         aarch64) OPENSSL_ARCH=linux-aarch64;;         arm*) OPENSSL_ARCH=linux-armv4;;         ppc64le) OPENSSL_ARCH=linux-ppc64le;;         s390x) OPENSSL_ARCH=linux-s390x;;         *) ;;       esac   && if [ -n "${CHECKSUM}" ]; then     set -eu;     curl -fsSLO --compressed "https://unofficial-builds.nodejs.org/download/release/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH-musl.tar.xz";     echo "$CHECKSUM  node-v$NODE_VERSION-linux-$ARCH-musl.tar.xz" | sha256sum -c -       && tar -xJf "node-v$NODE_VERSION-linux-$ARCH-musl.tar.xz" -C /usr/local --strip-components=1 --no-same-owner       && ln -s /usr/local/bin/node /usr/local/bin/nodejs;   else     echo "Building from source"     && apk add --no-cache --virtual .build-deps-full         binutils-gold         g++         gcc         gnupg         libgcc         linux-headers         make         python3         py-setuptools     && export GNUPGHOME="$(mktemp -d)"     && for key in       C0D6248439F1D5604AAFFB4021D900FFDB233756       DD792F5973C6DE52C432CBDAC77ABFA00DDBF2B7       CC68F5A3106FF448322E48ED27F5E38D5B0A215F       8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600       890C08DB8579162FEE0DF9DB8BEAB4DFCF555EF4       C82FA3AE1CBEDC6BE46B9360C43CEC45C17AB93C       108F52B48DB57BB0CC439B2997B01419BD92F80A       A363A499291CBBC940DD62E41F10027AF002F8B0     ; do       { gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$key" && gpg --batch --fingerprint "$key"; } ||       { gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key" && gpg --batch --fingerprint "$key"; } ;     done     && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION.tar.xz"     && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc"     && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc     && gpgconf --kill all     && rm -rf "$GNUPGHOME"     && grep " node-v$NODE_VERSION.tar.xz\$" SHASUMS256.txt | sha256sum -c -     && tar -xf "node-v$NODE_VERSION.tar.xz"     && cd "node-v$NODE_VERSION"     && ./configure     && make -j$(getconf _NPROCESSORS_ONLN) V=     && make install     && apk del .build-deps-full     && cd ..     && rm -Rf "node-v$NODE_VERSION"     && rm "node-v$NODE_VERSION.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt;   fi   && rm -f "node-v$NODE_VERSION-linux-$ARCH-musl.tar.xz"   && find /usr/local/include/node/openssl/archs -mindepth 1 -maxdepth 1 ! -name "$OPENSSL_ARCH" -exec rm -rf {} \; && apk del .build-deps && node --version && npm --version && rm -rf /tmp/* # buildkit

ENV YARN_VERSION=1.22.22

RUN /bin/sh -c apk add --no-cache --virtual .build-deps-yarn curl gnupg tar && export GNUPGHOME="$(mktemp -d)" && for key in 6A010C5166006599AA17F08146C2130DFD2497F5 ; do { gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$key" && gpg --batch --fingerprint "$key"; } || { gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key" && gpg --batch --fingerprint "$key"; } ;   done   && curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz" && curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz.asc" && gpg --batch --verify yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz && gpgconf --kill all && rm -rf "$GNUPGHOME" && mkdir -p /opt && tar -xzf yarn-v$YARN_VERSION.tar.gz -C /opt/ && ln -s /opt/yarn-v$YARN_VERSION/bin/yarn /usr/local/bin/yarn && ln -s /opt/yarn-v$YARN_VERSION/bin/yarnpkg /usr/local/bin/yarnpkg && rm yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz && apk del .build-deps-yarn && yarn --version && rm -rf /tmp/* # buildkit

COPY docker-entrypoint.sh /usr/local/bin/ # buildkit

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["node"]

COPY / / # buildkit

WORKDIR /home/node

ENV NODE_ICU_DATA=/usr/local/lib/node_modules/full-icu

EXPOSE map[5678/tcp:{}]

ARG N8N_VERSION=1.108.2

ARG N8N_RELEASE_TYPE=stable

ENV NODE_ENV=production

ENV N8N_RELEASE_TYPE=stable

ENV NODE_ICU_DATA=/usr/local/lib/node_modules/full-icu

ENV SHELL=/bin/sh

WORKDIR /home/node

COPY /app /usr/local/lib/node_modules/n8n # buildkit

COPY /launcher-bin/* /usr/local/bin/ # buildkit

COPY docker/images/n8n/docker-entrypoint.sh / # buildkit

COPY docker/images/n8n/n8n-task-runners.json /etc/n8n-task-runners.json # buildkit

RUN |2 N8N_VERSION=1.108.2 N8N_RELEASE_TYPE=stable /bin/sh -c cd /usr/local/lib/node_modules/n8n && npm rebuild sqlite3 && ln -s /usr/local/lib/node_modules/n8n/bin/n8n /usr/local/bin/n8n && mkdir -p /home/node/.n8n && chown -R node:node /home/node # buildkit

RUN |2 N8N_VERSION=1.108.2 N8N_RELEASE_TYPE=stable /bin/sh -c npm install -g npm@11.4.2 # buildkit

RUN |2 N8N_VERSION=1.108.2 N8N_RELEASE_TYPE=stable /bin/sh -c cd /usr/local/lib/node_modules/n8n/node_modules/pdfjs-dist && npm install @napi-rs/canvas # buildkit

EXPOSE map[5678/tcp:{}]

USER node

ENTRYPOINT ["tini" "--" "/docker-entrypoint.sh"]

LABEL org.opencontainers.image.title=n8n org.opencontainers.image.description=Workflow Automation Tool org.opencontainers.image.source=https://github.com/n8n-io/n8n org.opencontainers.image.url=https://n8n.io org.opencontainers.image.version=1.108.2
