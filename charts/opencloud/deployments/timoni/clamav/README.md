# Install/Upgrade ClamAV via Timoni
kubectl apply -f ./charts/opencloud/deployments/timoni/clamav && \
timoni bundle apply -f ./charts/opencloud/deployments/timoni/clamav/clamav.cue --runtime ./charts/opencloud/deployments/timoni/clamav/runtime.cue
