FROM node:8.16.1-alpine AS development

WORKDIR /app
COPY . /app

ENV USER cldinf
ENV DB "postgres://username:password@db/database"
ENV PORT 5050

RUN addgroup "$USER" \
    && adduser \
    --disabled-password \
    --gecos "" \
    --ingroup "$USER" \
    --no-create-home \
    "$USER" && \
    npm install

EXPOSE $PORT
USER $USER

ENTRYPOINT [ "npm" ]
CMD [ "start" ]