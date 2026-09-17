## Release 3.1.0

Base: changes since 3.0.0.

OpenCloud version from values.yaml: 8.0.1

### Pull Requests
- [#176](https://github.com/Tim-herbie/opencloud-helm/pull/176) chore(deps): update docker.io/collabora/code docker tag to v26.04.4.1.1
- [#175](https://github.com/Tim-herbie/opencloud-helm/pull/175) chore(deps): update docker.io/opencloudeu/opencloud-rolling docker tag to v8.0.1
- [#173](https://github.com/Tim-herbie/opencloud-helm/pull/173) feat: expose prometheus metrics for opencloud
- [#171](https://github.com/Tim-herbie/opencloud-helm/pull/171) chore(deps): update docker.io/opencloudeu/opencloud-rolling docker tag to v8
- [#170](https://github.com/Tim-herbie/opencloud-helm/pull/170) fix(opencloud): init-container creates and validates IDM LDAP cert/ke…
- [#169](https://github.com/Tim-herbie/opencloud-helm/pull/169) fix(identity): add opencloud.ldap.keepIdm for external OIDC without OpenLDAP
- [#168](https://github.com/Tim-herbie/opencloud-helm/pull/168) chore(ci): package and push every pr change to the registry
- [#166](https://github.com/Tim-herbie/opencloud-helm/pull/166) option to use HTTPS protocol when TLS is provided externally
- [#163](https://github.com/Tim-herbie/opencloud-helm/pull/163) chore(deps): update docker.io/collabora/code docker tag to v26.04.3.2.1
- [#164](https://github.com/Tim-herbie/opencloud-helm/pull/164) Preserve storage users mount ID during legacy migration

### Changelog
## [3.1.0] - 2026-09-17

### Breaking Changes
- None

### Features
- [#173](https://github.com/Tim-herbie/opencloud-helm/pull/173) feat: expose prometheus metrics for opencloud

### Fixes
- [#170](https://github.com/Tim-herbie/opencloud-helm/pull/170) fix(opencloud): init-container creates and validates IDM LDAP cert/ke…
- [#169](https://github.com/Tim-herbie/opencloud-helm/pull/169) fix(identity): add opencloud.ldap.keepIdm for external OIDC without OpenLDAP

### Chore / Docs / CI / Other
- [#176](https://github.com/Tim-herbie/opencloud-helm/pull/176) chore(deps): update docker.io/collabora/code docker tag to v26.04.4.1.1
- [#175](https://github.com/Tim-herbie/opencloud-helm/pull/175) chore(deps): update docker.io/opencloudeu/opencloud-rolling docker tag to v8.0.1
- [#171](https://github.com/Tim-herbie/opencloud-helm/pull/171) chore(deps): update docker.io/opencloudeu/opencloud-rolling docker tag to v8
- [#168](https://github.com/Tim-herbie/opencloud-helm/pull/168) chore(ci): package and push every pr change to the registry
- [#163](https://github.com/Tim-herbie/opencloud-helm/pull/163) chore(deps): update docker.io/collabora/code docker tag to v26.04.3.2.1
- [#166](https://github.com/Tim-herbie/opencloud-helm/pull/166) option to use HTTPS protocol when TLS is provided externally
- [#164](https://github.com/Tim-herbie/opencloud-helm/pull/164) Preserve storage users mount ID during legacy migration
