./release-irs.sh

cd tmp
For each IR []

for ir in test-http-routes-noauth test-http-svc-noauth test-https-routes-auth test-https-routes-noauth test-https-routes-auth-secret
do
    echo "127.0.0.1 ${ir}-ir.dan"
done


for ir in test-http-routes-noauth test-http-svc-noauth test-https-routes-auth test-https-routes-noauth test-https-routes-auth-secret
do
    echo -e "\n\n\n$ir:"

    creds=$(oc get secret $ir-ir -o json | jq -r .data.adminusers | base64 --decode)
    creds=${creds/ /:}

    oc get secret ${ir}-ir-admincert -o json | jq -r '.data["ca.crt"]' | base64 --decode > ${ir}-ca.crt
    oc get secret ${ir}-ir-admincert -o json | jq -r '.data["tls.crt"]' | base64 --decode > ${ir}-tls.crt
    oc get secret ${ir}-ir-admincert -o json | jq -r '.data["tls.key"]' | base64 --decode > ${ir}-tls.key

    echo "oc port-forward service/$ir-ir 7600:7600"
    echo "curl --cert ${ir}-tls.crt --key ${ir}-tls.key --cacert ${ir}-ca.crt https://$ir-ir.dan:7600/apiv2/rest-apis/test-1/document -u $creds > original-swagger-$ir-1.json"
    echo "curl --cert ${ir}-tls.crt --key ${ir}-tls.key --cacert ${ir}-ca.crt https://$ir-ir.dan:7600/apiv2/rest-apis/test-2/document -u $creds > original-swagger-$ir-2.json"

done



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


