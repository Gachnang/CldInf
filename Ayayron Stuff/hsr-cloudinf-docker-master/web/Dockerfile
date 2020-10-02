FROM node:8.16.1-alpine AS development

WORKDIR /app
COPY . /app

ENV USER cldinf
ENV API_HOST api:5050
ENV PORT 8888

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