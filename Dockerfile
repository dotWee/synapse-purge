FROM python:3.9-alpine

ARG USER_ID=1000
ARG GROUP_ID=1000

ENV \
  USER_ID=$USER_ID \
  GROUP_ID=$GROUP_ID \
  SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.1.11/supercronic-linux-amd64\
  SUPERCRONIC=supercronic-linux-amd64 \
  SUPERCRONIC_SHA1SUM=a2e2d47078a8dafc5949491e5ea7267cc721d67c

WORKDIR /usr/src/app

COPY . .

RUN \
  apk --no-cache add \
    build-base \
    curl \
    postgresql-dev && \
  curl -fsSLO "$SUPERCRONIC_URL" && \
  echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - && \
  chmod +x "$SUPERCRONIC" && \
  mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" && \
  ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic && \
  pip install virtualenv && \
  virtualenv venv && \
  source venv/bin/activate && \
  pip install \
    loguru~=0.5.3 \
    postgres~=3.0.0 \
    requests~=2.25.0 && \
  rm -r ~/.cache && \
  apk del build-base && \
  chown -R ${USER_ID}:${GROUP_ID} /usr/src/app && \
  mkdir /data && chown -R ${USER_ID}:${GROUP_ID} /data

COPY docker-cmd-run.sh /usr/local/bin/run
COPY docker-cmd-cron.sh /usr/local/bin/cron
RUN \
  chmod +x /usr/local/bin/run && \
  chmod +x /usr/local/bin/cron

USER ${USER_ID}:${GROUP_ID}

CMD ["run"]
