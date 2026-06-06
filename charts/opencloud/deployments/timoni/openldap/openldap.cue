bundle: {
	apiVersion: "v1alpha1"
	name:       "openldap"
	instances: {
		"openldap": {
			module: {
				url:     "oci://ghcr.io/stefanprodan/modules/flux-helm-release"
				version: "latest"
			}
			namespace: "openldap"
			values: {
				repository: {
					url: "https://charts.osixia.io"
				}
				chart: {
					name:    "openldap"
					version: "0.1.0"
				}
				sync: {
					timeout: 5
					createNamespace: true
				}
				helmValues: {
					replicaCount: int @timoni(runtime:int:OPENLDAP_REPLICA_COUNT)
					image: {
						repository: "osixia/openldap"
						tag:        "2.6.10-alpha"
					}
					openldap: {
						bootstrap: {
							organization: "openCloud"
							suffix:       "dc=opencloud,dc=eu"
							schemas: ["core.ldif", "cosine.ldif", "inetorgperson.ldif", "rfc2307bis.ldif"]
							config: {
								rootDnPrefix: "cn=admin"
							}
							database: {
								rootDnPrefix: "cn=admin"
								maxSize:      "10737418240"
							}
							memberof: {
								enabled:           true
								groupObjectClass:  "groupOfNames"
								memberAttribute:   "member"
								memberOfAttribute: "memberOf"
							}
						}
					}
					bootstrapCustomDataLdifVolume: {
						configMap: {
							name: "openldap-custom-ldif"
						}
					}
					customSchemasVolume: {
						configMap: {
							name: "openldap-custom-schemas"
						}
					}
					persistence: {
						enabled: true
						accessModes: ["ReadWriteOnce"]
						conf: {
							size: "1Gi"
						}
						data: {
							size: "8Gi"
						}
						backups: {
							size: "8Gi"
						}
					}
					extraDeploy: [
						{
							apiVersion: "v1"
							kind:       "ConfigMap"
							metadata: {
								name:      "openldap-custom-ldif"
								namespace: "openldap"
							}
							data: {
								"01_root.ldif": """
									dn: dc=opencloud,dc=eu
									objectClass: organization
									objectClass: dcObject
									dc: opencloud
									o: openCloud

									dn: ou=users,dc=opencloud,dc=eu
									objectClass: organizationalUnit
									ou: users

									dn: cn=admin,dc=opencloud,dc=eu
									objectClass: inetOrgPerson
									objectClass: person
									cn: admin
									sn: admin
									uid: ldapadmin

									dn: ou=groups,dc=opencloud,dc=eu
									objectClass: organizationalUnit
									ou: groups

									dn: ou=custom,ou=groups,dc=opencloud,dc=eu
									objectClass: organizationalUnit
									ou: custom
									"""
								"02_users.ldif": """
									dn: uid=alan,ou=users,dc=opencloud,dc=eu
									objectClass: inetOrgPerson
									cn: Alan Turing
									sn: Turing
									uid: alan
									mail: alan@opencloud.test

									dn: uid=mary,ou=users,dc=opencloud,dc=eu
									objectClass: inetOrgPerson
									cn: Mary Kenneth Keller
									sn: Kenneth Keller
									uid: mary
									mail: mary@opencloud.test

									dn: uid=margaret,ou=users,dc=opencloud,dc=eu
									objectClass: inetOrgPerson
									cn: Margaret Hamilton
									sn: Hamilton
									uid: margaret
									mail: margaret@opencloud.test

									dn: uid=dennis,ou=users,dc=opencloud,dc=eu
									objectClass: inetOrgPerson
									cn: Dennis Ritchie
									sn: Ritchie
									uid: dennis
									mail: dennis@opencloud.test

									dn: uid=lynn,ou=users,dc=opencloud,dc=eu
									objectClass: inetOrgPerson
									cn: Lynn Conway
									sn: Conway
									uid: lynn
									mail: lynn@opencloud.test

									dn: uid=admin,ou=users,dc=opencloud,dc=eu
									objectClass: inetOrgPerson
									cn: Admin
									sn: Admin
									uid: admin
									mail: admin@opencloud.test
									"""
								"03_groups.ldif": """
									dn: cn=users,ou=groups,dc=opencloud,dc=eu
									objectClass: groupOfNames
									objectClass: top
									cn: users
									description: Users
									member: uid=alan,ou=users,dc=opencloud,dc=eu
									member: uid=mary,ou=users,dc=opencloud,dc=eu
									member: uid=margaret,ou=users,dc=opencloud,dc=eu
									member: uid=dennis,ou=users,dc=opencloud,dc=eu
									member: uid=lynn,ou=users,dc=opencloud,dc=eu
									member: uid=admin,ou=users,dc=opencloud,dc=eu

									dn: cn=chess-lovers,ou=custom,ou=groups,dc=opencloud,dc=eu
									objectClass: groupOfNames
									cn: chess-lovers
									description: Chess lovers
									member: uid=alan,ou=users,dc=opencloud,dc=eu

									dn: cn=machine-lovers,ou=custom,ou=groups,dc=opencloud,dc=eu
									objectClass: groupOfNames
									cn: machine-lovers
									description: Machine Lovers
									member: uid=alan,ou=users,dc=opencloud,dc=eu

									dn: cn=bible-readers,ou=custom,ou=groups,dc=opencloud,dc=eu
									objectClass: groupOfNames
									cn: bible-readers
									description: Bible readers
									member: uid=mary,ou=users,dc=opencloud,dc=eu

									dn: cn=apollos,ou=custom,ou=groups,dc=opencloud,dc=eu
									objectClass: groupOfNames
									cn: apollos
									description: Contributors to the Apollo mission
									member: uid=margaret,ou=users,dc=opencloud,dc=eu

									dn: cn=unix-lovers,ou=custom,ou=groups,dc=opencloud,dc=eu
									objectClass: groupOfNames
									cn: unix-lovers
									description: Unix lovers
									member: uid=dennis,ou=users,dc=opencloud,dc=eu

									dn: cn=basic-haters,ou=custom,ou=groups,dc=opencloud,dc=eu
									objectClass: groupOfNames
									cn: basic-haters
									description: Haters of the Basic programming language
									member: uid=dennis,ou=users,dc=opencloud,dc=eu

									dn: cn=vlsi-lovers,ou=custom,ou=groups,dc=opencloud,dc=eu
									objectClass: groupOfNames
									cn: vlsi-lovers
									description: Lovers of VLSI microchip design
									member: uid=lynn,ou=users,dc=opencloud,dc=eu

									dn: cn=programmers,ou=custom,ou=groups,dc=opencloud,dc=eu
									objectClass: groupOfNames
									cn: programmers
									description: Computer Programmers
									member: uid=alan,ou=users,dc=opencloud,dc=eu
									member: uid=margaret,ou=users,dc=opencloud,dc=eu
									member: uid=dennis,ou=users,dc=opencloud,dc=eu
									member: uid=lynn,ou=users,dc=opencloud,dc=eu
									"""
							}
						},
						{
							apiVersion: "v1"
							kind:       "ConfigMap"
							metadata: {
								name:      "openldap-custom-schemas"
								namespace: "openldap"
							}
							data: {
								"10_opencloud_schema.ldif": """
									dn: cn=opencloud,cn=schema,cn=config
									objectClass: olcSchemaConfig
									cn: opencloud
									olcObjectIdentifier: openCloudOid 1.3.6.1.4.1.63016
									olcAttributeTypes: ( openCloudOid:1.1.1 NAME 'openCloudUUID'
									  DESC 'A non-reassignable and persistent account ID)'
									  EQUALITY uuidMatch
									  SUBSTR caseIgnoreSubstringsMatch
									  SYNTAX 1.3.6.1.1.16.1 SINGLE-VALUE )
									olcAttributeTypes: ( openCloudOid:1.1.2 NAME 'openCloudExternalIdentity'
									  DESC 'A triple representing objectIdentity'
									  EQUALITY caseIgnoreMatch
									  SUBSTR caseIgnoreSubstringsMatch
									  SYNTAX 1.3.6.1.4.1.1466.115.121.1.15 )
									olcAttributeTypes: ( openCloudOid:1.1.3 NAME 'openCloudUserEnabled'
									  DESC 'Boolean indicating if user is enabled'
									  EQUALITY booleanMatch
									  SYNTAX 1.3.6.1.4.1.1466.115.121.1.7 SINGLE-VALUE)
									olcAttributeTypes: ( openCloudOid:1.1.4 NAME 'openCloudUserType'
									  DESC 'User type (Member or Guest)'
									  EQUALITY caseIgnoreMatch
									  SYNTAX 1.3.6.1.4.1.1466.115.121.1.15 SINGLE-VALUE )
									olcAttributeTypes: ( openCloudOid:1.1.5 NAME 'openCloudLastSignInTimestamp'
									  DESC 'Timestamp of last sign-in'
									  EQUALITY generalizedTimeMatch
									  ORDERING generalizedTimeOrderingMatch
									  SYNTAX 1.3.6.1.4.1.1466.115.121.1.24 SINGLE-VALUE )
									olcObjectClasses: ( openCloudOid:1.2.1 NAME 'openCloudObject'
									  DESC 'OpenCloud base objectclass'
									  AUXILIARY
									  MAY ( openCloudUUID ) )
									olcObjectClasses: ( openCloudOid:1.2.2 NAME 'openCloudUser'
									  DESC 'OpenCloud User objectclass'
									  SUP openCloudObject
									  AUXILIARY
									  MAY ( openCloudExternalIdentity $ openCloudUserEnabled $ openCloudUserType $ openCloudLastSignInTimestamp) )
									"""
							}
						}
					]
				}
			}
		}
	}
}
