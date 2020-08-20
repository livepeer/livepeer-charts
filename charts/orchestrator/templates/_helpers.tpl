{{/* get orchestrator env map */}}
{{- define "orchestrator.env" -}}
env:
{{- range $key, $value := . }}
- name: {{ $key }}
  value: {{ $value | quote }}
{{- end }}
- name: NODE_NAME
  valueFrom:
    fieldRef:
      fieldPath: spec.nodeName
- name: MY_POD_IP
  valueFrom:
    fieldRef:
        fieldPath: status.podIP
{{- end -}}
