# Simple shop written in D lang

## Features
* OAuth2 Google login
* JWT based authorization
* PayPal payments
* MySQL databse
* Docker

## Configuration
Configuration is stored in: `/source/config/Config.d` but by default come from env variables.

Available variables:
* GOOGLE_API_URL: https://www.googleapis.com
* PAYPAL_API_URL: https://api-m.sandbox.paypal.com
* PAYAPL_API_KEY:  dummy
* DATABASE_URL: 127.0.0.1
* DATABASE_NAME: project_d
* DATABASE_USERNAME: root
* DATABASE_PASSWORD: dummy
* JWT_SECRET: dummy
## Run
```
dub
```
