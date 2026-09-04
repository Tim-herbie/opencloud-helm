# Changelog

All notable changes to this project will be documented in this file.

<!-- release-bot:start -->

## [3.0.1] - 2026-09-04

### Breaking Changes
- None

### Features
- None

### Fixes
- None

### Chore / Docs / CI / Other
- [#164](https://github.com/Tim-herbie/opencloud-helm/pull/164) Preserve storage users mount ID during legacy migration


## [3.0.0] - 2026-08-30

### Breaking Changes
- The chart no longer ships or manages bundled Keycloak, PostgreSQL, and MinIO resources.
- All internal templates for these components were removed.
- The chart now focuses on OpenCloud itself and expects identity/storage dependencies to be handled externally when needed.
- If you previously relied on bundled Keycloak/PostgreSQL/MinIO, you must migrate your setup before upgrading.

### Migration Notes
- Remove old values related to internal Keycloak/PostgreSQL/MinIO.
- Move to external services or to the current default architecture (integrated IDM and non-bundled dependencies).
- Re-check OIDC and storage values, because configuration structure and defaults changed.
- If you are using the httproutes with one gateway listener for all routes, please take a look on the values file. We added a new parameter to allow one exact listener for all httproutes and one prefix to generate listeners for each route.

### Breaking Changes
- [#107](https://github.com/Tim-herbie/opencloud-helm/pull/107) feat: enable HTTPS, OIDC auth, Collabora, ClamAV, and OPA policies- #107

### Features
- [#162](https://github.com/Tim-herbie/opencloud-helm/pull/162) feat(httproute): allow exact sectionName overrides for external gateways
- [#157](https://github.com/Tim-herbie/opencloud-helm/pull/157) feat: extend csp yaml for epub reader iframe sytle loading

### Fixes
- [#154](https://github.com/Tim-herbie/opencloud-helm/pull/154) fix: add Flux reconciler RBAC for Keycloak
- [#149](https://github.com/Tim-herbie/opencloud-helm/pull/149) fix: preserve proxy policies with role quotas

### Chore / Docs / CI / Other
- [#161](https://github.com/Tim-herbie/opencloud-helm/pull/161) chore(deps): update docker.io/collabora/code docker tag to v26.04.3.1.1
- [#155](https://github.com/Tim-herbie/opencloud-helm/pull/155) chore(deps): update docker.io/opencloudeu/opencloud-rolling docker tag to v7.5.0
- [#160](https://github.com/Tim-herbie/opencloud-helm/pull/160) chore(deps): update docker.io/alpine/openssl docker tag to v3.5.8
- [#153](https://github.com/Tim-herbie/opencloud-helm/pull/153) chore(deps): update oras-project/setup-oras action to v2
- [#152](https://github.com/Tim-herbie/opencloud-helm/pull/152) chore(ci): package and push every helm chart for the tag latest
- [#150](https://github.com/Tim-herbie/opencloud-helm/pull/150) chore(deps): update opencloudeu/web-extensions docker tag to draw-io-2.2.0
- [#159](https://github.com/Tim-herbie/opencloud-helm/pull/159) Feature: Move collaboration into the opencloud process


## [2.4.7] - 2026-08-09

### Breaking Changes
- None

### Features
- None

### Fixes
- [#129](https://github.com/Tim-herbie/opencloud-helm/pull/129) fix: improve httproute and gateway usability

### Chore / Docs / CI / Other
- [#136](https://github.com/Tim-herbie/opencloud-helm/pull/136) chore(deps): update docker.io/collabora/code docker tag to v26.04.2.4.1
- [#139](https://github.com/Tim-herbie/opencloud-helm/pull/139) chore(deps): update docker.io/opencloudeu/opencloud-rolling docker tag to v7.4.0
- [#140](https://github.com/Tim-herbie/opencloud-helm/pull/140) chore(deps): update quay.io/keycloak/keycloak docker tag to v26.7.1
- [#135](https://github.com/Tim-herbie/opencloud-helm/pull/135) chore(deps): update opencloudeu/web-extensions docker tag
- [#134](https://github.com/Tim-herbie/opencloud-helm/pull/134) chore(deps): update dependency node to v24
- [#133](https://github.com/Tim-herbie/opencloud-helm/pull/133) chore(deps): update opencloudeu/web-extensions docker tag
- [#131](https://github.com/Tim-herbie/opencloud-helm/pull/131) chore(deps): update actions/upload-artifact action to v7
- [#130](https://github.com/Tim-herbie/opencloud-helm/pull/130) chore(deps): update actions/setup-node action to v7
- [#128](https://github.com/Tim-herbie/opencloud-helm/pull/128) chore(tests): add e2e tests
- [#126](https://github.com/Tim-herbie/opencloud-helm/pull/126) chore(docs): add minimal-setup docs example
- [#124](https://github.com/Tim-herbie/opencloud-helm/pull/124) chore: move set OC_ADMIN_USER_ID always instead only when oidc is ena…
- [#132](https://github.com/Tim-herbie/opencloud-helm/pull/132) Enable Renovate updates for web extension image tags


## [2.4.6] - 2026-07-17

### Breaking Changes
- None

### Features
- None

### Fixes
- [#117](https://github.com/Tim-herbie/opencloud-helm/pull/117) fix: collaboration nats connection to opencloud

### Chore / Docs / CI / Other
- None


## [2.4.5] - 2026-07-14

### Breaking Changes
- None

### Features
- None

### Fixes
- None

### Chore / Docs / CI / Other
- [#114](https://github.com/Tim-herbie/opencloud-helm/pull/114) chore(deps): update docker.io/opencloudeu/opencloud-rolling docker tag to v7.3.0
- [#111](https://github.com/Tim-herbie/opencloud-helm/pull/111) chore(deps): update quay.io/keycloak/keycloak docker tag to v26.7.0
- [#112](https://github.com/Tim-herbie/opencloud-helm/pull/112) chore(deps): update docker.io/collabora/code docker tag to v26.04.2.1.1


## [2.4.4] - 2026-06-25

### Breaking Changes
- None

### Features
- None

### Fixes
- None

### Chore / Docs / CI / Other
- [#108](https://github.com/Tim-herbie/opencloud-helm/pull/108) chore(deps): update actions/checkout action to v7
- [#104](https://github.com/Tim-herbie/opencloud-helm/pull/104) chore(deps): update docker.io/collabora/code docker tag to v26
- [#105](https://github.com/Tim-herbie/opencloud-helm/pull/105) chore(deps): update quay.io/keycloak/keycloak docker tag to v26.6.3
- [#109](https://github.com/Tim-herbie/opencloud-helm/pull/109) chore(deps): update docker.io/opencloudeu/opencloud-rolling docker tag to v7.2.0


## [2.4.3] - 2026-06-02

### Breaking Changes
- None

### Features
- None

### Fixes
- None

### Chore / Docs / CI / Other
- [#102](https://github.com/Tim-herbie/opencloud-helm/pull/102) chore(deps): update docker.io/opencloudeu/opencloud-rolling docker tag to v7.1.0
- [#99](https://github.com/Tim-herbie/opencloud-helm/pull/99) chore(deps): update docker.io/collabora/code docker tag to v25.04.10.3.1


## [2.4.2] - 2026-05-31

### Breaking Changes
- None

### Features
- None

### Fixes
- None

### Chore / Docs / CI / Other
- [#95](https://github.com/Tim-herbie/opencloud-helm/pull/95) chore(deps): update docker.io/library/busybox docker tag to v1.38
- [#96](https://github.com/Tim-herbie/opencloud-helm/pull/96) chore(deps): update docker.io/apache/tika docker tag to v3.3.1.0
- [#98](https://github.com/Tim-herbie/opencloud-helm/pull/98) Make credential migration hook configurable via `opencloud.migration.enabled`


## [2.4.1] - 2026-05-22

### Breaking Changes
- None

### Features
- None

### Fixes
- [#93](https://github.com/Tim-herbie/opencloud-helm/pull/93) fix: idm authentication #92

### Chore / Docs / CI / Other
- None


## [2.4.0] - 2026-05-22

### Breaking Changes
- None

### Features
- [#85](https://github.com/Tim-herbie/opencloud-helm/pull/85) Feature/add init secretes

### Fixes
- None

### Chore / Docs / CI / Other
- [#90](https://github.com/Tim-herbie/opencloud-helm/pull/90) chore(deps): update docker.io/opencloudeu/opencloud-rolling docker tag to v7
- [#89](https://github.com/Tim-herbie/opencloud-helm/pull/89) chore(deps): update quay.io/keycloak/keycloak docker tag to v26.6.2
- [#88](https://github.com/Tim-herbie/opencloud-helm/pull/88) Update OpenCloud web extension tags to latest available releases


## [2.3.0] - 2026-05-12

### Breaking Changes
- None

### Features
- [#83](https://github.com/Tim-herbie/opencloud-helm/pull/83) feat: Add helm-unittest pipeline test cases for web extensions, ingress, and gateway HTTPRoutes
- [#80](https://github.com/Tim-herbie/opencloud-helm/pull/80) Add new web extensions: arcade, calculator, cast, maps, pastebin

### Fixes
- None

### Chore / Docs / CI / Other
- [#84](https://github.com/Tim-herbie/opencloud-helm/pull/84) chore(deps): update docker.io/opencloudeu/opencloud-rolling docker tag to v6.2.0
- [#79](https://github.com/Tim-herbie/opencloud-helm/pull/79) chore(deps): update peter-evans/create-pull-request action to v8
- [#77](https://github.com/Tim-herbie/opencloud-helm/pull/77) Add release bot

<!-- release-bot:end -->
