./release-irs.sh

oc get ir



./publish.sh -i test-http-routes-noauth
curl -k -v https://ademo-gw-gateway-dan.apps.fermi-dan.cp.fyre.ibm.com/main-demo/main-demo-catalog/test-1/test/healthz
curl -k -v https://ademo-gw-gateway-dan.apps.fermi-dan.cp.fyre.ibm.com/main-demo/main-demo-catalog/test-2/test/healthz


./delete-products.sh 
curl -k -v https://ademo-gw-gateway-dan.apps.fermi-dan.cp.fyre.ibm.com/main-demo/main-demo-catalog/test-1/test/healthz

./publish.sh -i test-https-routes-noauth
curl -k -v https://ademo-gw-gateway-dan.apps.fermi-dan.cp.fyre.ibm.com/main-demo/main-demo-catalog/test-1/test/healthz

./delete-products.sh 
curl -k -v https://ademo-gw-gateway-dan.apps.fermi-dan.cp.fyre.ibm.com/main-demo/main-demo-catalog/test-1/test/healthz

./publish.sh -i test-http-svc-noauth
curl -k -v https://ademo-gw-gateway-dan.apps.fermi-dan.cp.fyre.ibm.com/main-demo/main-demo-catalog/test-1/test/healthz


fermi-dan $ oc get secret test-https-routes-auth-ingress-basic-auth -o json | jq -r .data.configuration | base64 --decode
local::basicAuthOverride aceuser aHs2Zwi8XN1Modm4L3Uy57cEAKQTWG0V

curl -k -v https://test-https-routes-auth-https-dan.apps.fermi-dan.cp.fyre.ibm.com/test-1/test/healthz -u "aceuser:aHs2Zwi8XN1Modm4L3Uy57cEAKQTWG0V"

./publish.sh -i test-https-routes-auth
curl -k -v https://ademo-gw-gateway-dan.apps.fermi-dan.cp.fyre.ibm.com/main-demo/main-demo-catalog/test-1/test/healthz


