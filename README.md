# 2beFOUND API-Platform
This is a fork of https://github.com/api-platform/api-platform with a few additions to make google-cloud integration easier.

## About
The master branch is left as is and is updated regularly, the google-cloud version is found in a seperate branch.

## Main differences
* Helm setup:
    * google-cloud-sql settings.
    * dynamic names as to avoid multiple "api-php" "api-nginx" deployments in kubernetes.
    * database_url is injected via. secret.
* behat tests are included.
* postgres uses version 9.6.