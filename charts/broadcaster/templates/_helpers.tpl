{{/* get env map */}}
{{- define "broadcaster.env" -}}
env:
{{- range $key, $value := .Values.env }}
- name: {{ $key }}
  value: {{ $value | quote }}
{{- end }}
{{- end -}}

{{- define "broadcaster.streamInfo.env" -}}
env:
{{- range $key, $value := .Values.streamInfo.env }}
- name: {{ $key }}
  value: {{ $value | quote }}
{{- end }}
{{- end -}}
