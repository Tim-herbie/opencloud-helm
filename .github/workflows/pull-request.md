# Pull Request Doc

## E2E

Split dns concept:
- outside of the cluster, the domains are resolved to 127.0.0.1
- inside the cluster, the domains are resolved to the svc ip of traefik