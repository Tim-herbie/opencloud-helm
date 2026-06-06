bundle: {
    apiVersion: "v1alpha1"
    name:       "clamav"
    instances: {
        "clamav": {
            module: {
                url: "oci://ghcr.io/stefanprodan/modules/flux-helm-release"
                version: "latest"
            }
            namespace: "clamav"
            values: {
                repository: {
                    url: "https://wiremind.github.io/wiremind-helm-charts"
                }
                chart: {
                    name:    "clamav"
                    version: "3.7.1"
                }
                sync: {
                    timeout: 5
                    createNamespace: true
                }
                helmValues: {
                    _persistenceStorageClassName: string @timoni(runtime:string:CLAMAV_PERSISTENCE_STORAGE_CLASS)
                    _persistenceAccessModes:     string @timoni(runtime:string:CLAMAV_PERSISTENCE_ACCESS_MODES)

                    replicaCount: int @timoni(runtime:int:CLAMAV_REPLICA_COUNT)
                    
                    updateStrategy: {
                        type: string @timoni(runtime:string:CLAMAV_UPDATE_STRATEGY_TYPE)
                        rollingUpdate: {
                            partition: int @timoni(runtime:int:CLAMAV_UPDATE_STRATEGY_PARTITION)
                        }
                    }
                    
                    hpa: {
                        enabled: bool @timoni(runtime:bool:CLAMAV_HPA_ENABLED)
                    }
                    
                    podDisruptionBudget: {
                        enabled: bool @timoni(runtime:bool:CLAMAV_PDB_ENABLED)
                        minAvailable: int @timoni(runtime:int:CLAMAV_PDB_MIN_AVAILABLE)
                    }
                    
                    topologySpreadConstraints: [
                        {
                            maxSkew: int @timoni(runtime:int:CLAMAV_TOPOLOGY_MAX_SKEW)
                            topologyKey: string @timoni(runtime:string:CLAMAV_TOPOLOGY_KEY)
                            whenUnsatisfiable: string @timoni(runtime:string:CLAMAV_TOPOLOGY_UNSATISFIABLE)
                            labelSelector: {
                                matchLabels: {
                                    "app.kubernetes.io/name": "clamav"
                                }
                            }
                        }
                    ]
                    
                    persistentVolume: {
                        enabled: bool @timoni(runtime:bool:CLAMAV_PERSISTENCE_ENABLED)
                        size: string @timoni(runtime:string:CLAMAV_PERSISTENCE_SIZE)
                        storageClass: "\(_persistenceStorageClassName)"
                        accessModes: [ "\(_persistenceAccessModes)" ]
                    }
                    
                    resources: {
                        limits: {
                            cpu: string @timoni(runtime:string:CLAMAV_RESOURCES_LIMITS_CPU)
                            memory: string @timoni(runtime:string:CLAMAV_RESOURCES_LIMITS_MEMORY)
                        }
                        requests: {
                            cpu: string @timoni(runtime:string:CLAMAV_RESOURCES_REQUESTS_CPU)
                            memory: string @timoni(runtime:string:CLAMAV_RESOURCES_REQUESTS_MEMORY)
                        }
                    }
                }
            }
        }
    }
}
