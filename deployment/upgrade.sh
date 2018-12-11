#!/bin/bash
helm dependency update ./api/helm/api

# build
docker build -t gcr.io/<GCLOUDPROJECTID>/authapi-php -t gcr.io/<GCLOUDPROJECTID>/authapi-php:latest api --target api_platform_php
docker build -t gcr.io/<GCLOUDPROJECTID>/authapi-nginx -t gcr.io/<GCLOUDPROJECTID>/authapi-nginx:latest api --target api_platform_nginx
docker build -t gcr.io/<GCLOUDPROJECTID>/authapi-varnish -t gcr.io/<GCLOUDPROJECTID>/authapi-varnish:latest api --target api_platform_varnish

# push
gcloud docker -- push gcr.io/<GCLOUDPROJECTID>/<APINAME>-php
gcloud docker -- push gcr.io/<GCLOUDPROJECTID>/<APINAME>-nginx
gcloud docker -- push gcr.io/<GCLOUDPROJECTID>/<APINAME>-varnish


helm upgrade auth-api-staging --install ./api/helm/api --namespace=beta  \
    --set php.repository=gcr.io/<GCLOUDPROJECTID>/<APINAME>-php \
    --set nginx.repository=gcr.io/<GCLOUDPROJECTID>/<APINAME>-nginx \
    --set secret=<SECRET> \
    --set postgresql.enabled=false \
    --set postgresql.url="pgsql://<DBHOST>:<DBPW>@127.0.0.1/<APINAME>?serverVersion=9.6" \
    --set corsAllowOrigin='^https?://[a-z\]*\.alpinresorts.com$' \
    --set varnish.enabled=false \
    --set varnish.url=https://www.alpinresorts.com \
    --set nameOverride=<APINAME> \
    --recreate-pods