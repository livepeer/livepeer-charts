{{/* get api env map */}}
{{- define "api.env" -}}
env:
{{- range $key, $value := .Values.env }}
- name: {{ $key }}
  value: '{{ $value }}'
{{- end }}
- name: DOMAIN
  valueFrom:
    fieldRef:
      fieldPath: metadata.labels['livepeer.live/domain']
{{- if .Values.postgres.enabled }}
- name: LP_POSTGRES_URL
  valueFrom:
    secretKeyRef:
      name: postgres-url
      key: postgres-url.secret
{{- end }}
- name: LP_KUBE_NAMESPACE
  valueFrom:
    fieldRef:
      fieldPath: metadata.namespace
{{- end -}}