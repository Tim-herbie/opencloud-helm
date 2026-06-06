# Install/Upgrade OpenLDAP via Timoni
kubectl apply -f ./charts/opencloud/deployments/timoni/openldap && \
timoni bundle apply -f ./charts/opencloud/deployments/timoni/openldap/openldap.cue --runtime ./charts/opencloud/deployments/timoni/openldap/runtime.cue
