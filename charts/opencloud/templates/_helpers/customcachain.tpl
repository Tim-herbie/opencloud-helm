{{- define "opencloud.customCA" -}}
{{- if .Values.customCA.enabled }}
- name: custom-ca
  configMap:
    name: {{ include "opencloud.fullname" . }}-custom-ca
{{- end }}
{{- end -}}

{{- define "opencloud.customCAVolumeMount" -}}
{{- if .Values.customCA.enabled }}
- name: custom-ca
  mountPath: /etc/ssl/certs/custom-ca.crt
  subPath: ca.crt
  readOnly: true
{{- end }}
{{- end -}}
