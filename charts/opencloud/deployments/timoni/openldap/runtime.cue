runtime: {
	apiVersion: "v1alpha1"
	name: "openldap"
	values: [
		{
			query: "k8s:v1:Secret:openldap:openldap-admin-secrets"
			for: {
				"LDAP_ADMIN_PASSWORD":  "obj.data.adminPassword"
				"LDAP_CONFIG_PASSWORD": "obj.data.configPassword"
			}
		},
		{
			query: "k8s:v1:ConfigMap:openldap:openldap-config"
			for: {
				"LDAP_GLOBAL_DOMAIN": "obj.data.LDAP_GLOBAL_DOMAIN"
				"OPENLDAP_REPLICA_COUNT": "obj.data.OPENLDAP_REPLICA_COUNT"
				"OPENLDAP_REPLICATION_ENABLED": "obj.data.OPENLDAP_REPLICATION_ENABLED"
			}
		}
	]
	defaults: {
		LDAP_ADMIN_PASSWORD: "admin"
		LDAP_CONFIG_PASSWORD: "config"
		LDAP_GLOBAL_DOMAIN: "opencloud.eu"
		OPENLDAP_REPLICA_COUNT: 1
		OPENLDAP_REPLICATION_ENABLED: false
	}
}
