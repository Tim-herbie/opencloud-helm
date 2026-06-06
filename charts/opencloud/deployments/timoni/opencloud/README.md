# Install/Upgrade OpenCloud via Timoni
kubectl apply -f ./charts/opencloud/deployments/timoni/opencloud && \
timoni bundle apply -f ./charts/opencloud/deployments/timoni/opencloud/opencloud.cue --runtime ./charts/opencloud/deployments/timoni/opencloud/runtime.cue
