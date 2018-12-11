# build images
docker build -t gcr.io/<GCLOUDPROJECTID>/php -t gcr.io/<GCLOUDPROJECTID>/php:latest api --target api_platform_php
docker build -t gcr.io/<GCLOUDPROJECTID>/nginx -t gcr.io/<GCLOUDPROJECTID>/nginx:latest api --target api_platform_nginx
docker build -t gcr.io/<GCLOUDPROJECTID>/varnish -t gcr.io/<GCLOUDPROJECTID>/varnish:latest api --target api_platform_varnish

# push
gcloud docker -- push gcr.io/<GCLOUDPROJECTID>/php
gcloud docker -- push gcr.io/<GCLOUDPROJECTID>/nginx
gcloud docker -- push gcr.io/<GCLOUDPROJECTID>/varnish


# install helm deps
helm dependency update ./api/helm/api

# install deployment
helm install ./api/helm/api --namespace=beta --name <APINAME>-staging \
    --set php.repository=gcr.io/<GCLOUDPROJECTID>/<APINAME>-php \
    --set nginx.repository=gcr.io/<GCLOUDPROJECTID>/<APINAME>-varnish \
    --set secret=<SECRET> \
    --set postgresql.enabled=false \
    --set postgresql.url="pgsql://<DBHOST>:<DBPW>@127.0.0.1/<APINAME>?serverVersion=9.6" \
    --set corsAllowOrigin='^https?://[a-z\]*\.<URL>$' \
    --set varnish.enabled=false \
    --set varnish.url=<VARNISHURL>   \
    --set nameOverride=<APINAME>
                                                          
    

# init database
PHP_POD=$(kubectl --namespace=beta get pods -l app=order-api-php -o jsonpath="{.items[0].metadata.name}")
kubectl --namespace=beta exec -it $PHP_POD -c api-php -- bin/console doctrine:schema:create 


# upgrade deployment
helm upgrade order-api-staging ./api/helm/api --namespace=beta  \
    --set php.repository=gcr.io/<GCLOUDPROJECTID>/<APINAME>-php \
    --set nginx.repository=gcr.io/<GCLOUDPROJECTID>/<APINAME>-varnish \
    --set secret=<SECRET> \
    --set postgresql.enabled=false \
    --set postgresql.url="pgsql://<DBHOST>:<DBPW>r@127.0.0.1/<APINAME>?serverVersion=9.6" \
    --set corsAllowOrigin='^https?://[a-z\]*\.<URL>$' \
    --set varnish.enabled=false \
    --set varnish.url=<VARNISHURL> \
    --set nameOverride=<APINAME>