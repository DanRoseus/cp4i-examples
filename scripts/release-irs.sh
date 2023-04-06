#!/bin/bash

# See https://www.ibm.com/docs/en/app-connect/containers_cd?topic=resources-integration-runtime-reference


oc create secret generic test-https-routes-auth-secret --from-literal=username=my-username --from-literal=password=my-password

cat <<EOF | oc apply -f -
apiVersion: appconnect.ibm.com/v1beta1
kind: Configuration
metadata:
  name: barauth-empty
spec:
  type: barauth
  description: Authentication for public GitHub, no credentials needed
  data: $(echo '{"authType":"BASIC_AUTH","credentials":{"username":"","password":""}}' | base64)
---
apiVersion: appconnect.ibm.com/v1beta1
kind: IntegrationRuntime
metadata:
  name: test-http-routes-noauth
spec:
  barURL:
  - https://github.com/DanRoseus/cp4i-examples/blob/main/bars/test-1.bar?raw=true
  - https://github.com/DanRoseus/cp4i-examples/blob/main/bars/test-2.bar?raw=true
  configurations:
  - barauth-empty
  license:
    accept: true
    license: L-APEH-CJUCNR
    use: CloudPakForIntegrationProduction
  version: "12.0"
---
apiVersion: appconnect.ibm.com/v1beta1
kind: IntegrationRuntime
metadata:
  name: test-https-routes-noauth
spec:
  barURL:
  - https://github.com/DanRoseus/cp4i-examples/blob/main/bars/test-1.bar?raw=true
  - https://github.com/DanRoseus/cp4i-examples/blob/main/bars/test-2.bar?raw=true
  configurations:
  - barauth-empty
  license:
    accept: true
    license: L-APEH-CJUCNR
    use: CloudPakForIntegrationProduction
  version: "12.0"
  forceFlowsHTTPS:
    enabled: true
---
apiVersion: appconnect.ibm.com/v1beta1
kind: IntegrationRuntime
metadata:
  name: test-http-svc-noauth
spec:
  barURL:
  - https://github.com/DanRoseus/cp4i-examples/blob/main/bars/test-1.bar?raw=true
  - https://github.com/DanRoseus/cp4i-examples/blob/main/bars/test-2.bar?raw=true
  configurations:
  - barauth-empty
  license:
    accept: true
    license: L-APEH-CJUCNR
    use: CloudPakForIntegrationProduction
  version: "12.0"
  routes:
    disabled: true
---
apiVersion: appconnect.ibm.com/v1beta1
kind: IntegrationRuntime
metadata:
  name: test-https-routes-auth
spec:
  barURL:
  - https://github.com/DanRoseus/cp4i-examples/blob/main/bars/test-1.bar?raw=true
  - https://github.com/DanRoseus/cp4i-examples/blob/main/bars/test-2.bar?raw=true
  configurations:
  - barauth-empty
  license:
    accept: true
    license: L-APEH-CJUCNR
    use: CloudPakForIntegrationProduction
  version: "12.0"
  forceFlowsHTTPS:
    enabled: true
  forceFlowBasicAuth:
    enabled: true
---
apiVersion: appconnect.ibm.com/v1beta1
kind: IntegrationRuntime
metadata:
  name: test-https-routes-auth-secret
spec:
  barURL:
  - https://github.com/DanRoseus/cp4i-examples/blob/main/bars/test-1.bar?raw=true
  - https://github.com/DanRoseus/cp4i-examples/blob/main/bars/test-2.bar?raw=true
  configurations:
  - barauth-empty
  license:
    accept: true
    license: L-APEH-CJUCNR
    use: CloudPakForIntegrationProduction
  version: "12.0"
  forceFlowsHTTPS:
    enabled: true
  forceFlowBasicAuth:
    enabled: true
    secretName: test-https-routes-auth-secret
EOF
