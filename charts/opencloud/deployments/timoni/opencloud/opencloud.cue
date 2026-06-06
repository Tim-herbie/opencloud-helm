bundle: {
    apiVersion: "v1alpha1"
    name:       "opencloud"
    instances: {
        "opencloud": {
            module: {
                url: "oci://ghcr.io/stefanprodan/modules/flux-helm-release"
                version: "latest"
            }
            namespace: "opencloud"
            values: {
                repository: {
                    url: "oci://ghcr.io/tim-herbie/opencloud-helm"
                }
                chart: {
                    name:    "opencloud"
                    version: "2.4.3"
                }
                sync: {
                    timeout: 10
                    createNamespace: true
                }
                helmValues: {
                    global: {
                        domain: {
                            opencloud: string @timoni(runtime:string:EXTERNAL_DOMAIN)
                            oidc:      "keycloak.opencloud.test"
                            minio:     "minio.opencloud.test"
                            collabora: string @timoni(runtime:string:COLLABORA_DOMAIN)
                        }
                        tls: {
                            enabled: false
                        }
                    }
                    opencloud: {
                        image: {
                            tag: string @timoni(runtime:string:TAG)
                        }
                        logLevel: string @timoni(runtime:string:OPENCLOUD_LOGGING_LEVEL)
                        storage: {
                            users: {
                                driver: string @timoni(runtime:string:STORAGE_USERS_BACKEND_DRIVER)
                            }
                        }
                    }
                    oidc: {
                        issuerUrl: string @timoni(runtime:string:OIDC_ISSUER_URI)
                        clientId:  string @timoni(runtime:string:WEB_OIDC_WEB_CLIENT_ID)
                    }
                    ingress: {
                        enabled: bool @timoni(runtime:bool:INGRESS_ENABLED)
                        ingressClassName: string @timoni(runtime:string:INGRESS_CLASS_NAME)
                        annotations: {
                            "nginx.ingress.kubernetes.io/proxy-body-size": string @timoni(runtime:string:INGRESS_PROXY_BODY_SIZE)
                        }
                    }
                    httpRoute: {
                        enabled: bool @timoni(runtime:bool:GATEWAY_HTTPROUTE_ENABLED)
                    }
                    insecure: {
                        oidcIdpInsecure: bool @timoni(runtime:bool:OIDC_IDP_INSECURE)
                        ocHttpApiInsecure: bool @timoni(runtime:bool:OC_HTTP_API_INSECURE)
                    }
                    features: {
                        externalUserManagement: {
                            enabled: bool @timoni(runtime:bool:EXTERNAL_USER_MANAGEMENT_ENABLED)
                            adminUUID: string @timoni(runtime:string:EXTERNAL_USER_MANAGEMENT_ADMIN_UUID)
                            autoprovisionAccounts: {
                                enabled: bool @timoni(runtime:bool:AUTOPROVISION_ACCOUNTS_ENABLED)
                                claimUserName: string @timoni(runtime:string:AUTOPROVISION_ACCOUNTS_CLAIM_USER_NAME)
                            }
                            oidc: {
                                domain:    "keycloak.opencloud.test"
                                issuerURI: string @timoni(runtime:string:OIDC_ISSUER_URI)
                                userIDClaim: string @timoni(runtime:string:OIDC_USER_ID_CLAIM)
                                userIDClaimAttributeMapping: string @timoni(runtime:string:OIDC_USER_ID_CLAIM_ATTRIBUTE_MAPPING)
                                roleAssignment: {
                                    claim: string @timoni(runtime:string:OIDC_ROLE_ASSIGNMENT_CLAIM)
                                }
                            }
                            ldap: {
                                writeable: bool @timoni(runtime:bool:LDAP_WRITEABLE)
                                uri:       string @timoni(runtime:string:LDAP_URI)
                                insecure:  bool @timoni(runtime:bool:LDAP_INSECURE)
                                bindDN:    string @timoni(runtime:string:LDAP_BIND_DN)
                                user: {
                                    userNameMatch: string @timoni(runtime:string:LDAP_USER_NAME_MATCH)
                                    schema: {
                                        id: string @timoni(runtime:string:LDAP_USER_SCHEMA_ID)
                                    }
                                }
                                group: {
                                    schema: {
                                        id: string @timoni(runtime:string:LDAP_GROUP_SCHEMA_ID)
                                    }
                                }
                            }
                        }
                        virusscan: {
                            enabled: bool @timoni(runtime:bool:ANTIVIRUS_ENABLED)
                            infectedFileHandling: string @timoni(runtime:string:ANTIVIRUS_INFECTED_FILE_HANDLING)
                            scannerType: string @timoni(runtime:string:ANTIVIRUS_SCANNER_TYPE)
                            clamavSocket: string @timoni(runtime:string:ANTIVIRUS_CLAMAV_SOCKET)
                        }
                        emailNotifications: {
                            enabled: bool @timoni(runtime:bool:EMAIL_NOTIFICATIONS_ENABLED)
                            smtp: {
                                host:           string @timoni(runtime:string:SMTP_HOST)
                                port:           string @timoni(runtime:string:SMTP_PORT)
                                sender:         string @timoni(runtime:string:SMTP_SENDER)
                                authentication: string @timoni(runtime:string:SMTP_AUTHENTICATION)
                                encryption:     string @timoni(runtime:string:SMTP_ENCRYPTION)
                            }
                        }
                    }
                    collabora: {
                        enabled: bool @timoni(runtime:bool:COLLABORA_ENABLED)
                        tag:     string @timoni(runtime:string:COLLABORA_TAG)
                        domain:  string @timoni(runtime:string:COLLABORA_DOMAIN)
                    }
                    secretRefs: {
                        ldapSecretRef:        "ldap-bind-secrets"
                        s3CredentialsSecretRef: "s3secret"
                    }
                }
            }
        }
    }
}
