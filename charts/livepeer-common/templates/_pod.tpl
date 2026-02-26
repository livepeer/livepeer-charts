{{/*
Pod-level scheduling helpers reusable across all Livepeer charts.
*/}}

{{/*
Render nodeSelector if non-empty.
Usage: {{ include "livepeer-common.nodeSelector" .Values.gateway.nodeSelector | nindent 6 }}
*/}}
{{- define "livepeer-common.nodeSelector" -}}
{{- if . }}
nodeSelector:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}

{{/*
Render tolerations if non-empty.
Usage: {{ include "livepeer-common.tolerations" .Values.gateway.tolerations | nindent 6 }}
*/}}
{{- define "livepeer-common.tolerations" -}}
{{- if . }}
tolerations:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}

{{/*
Render affinity if non-empty.
Usage: {{ include "livepeer-common.affinity" .Values.gateway.affinity | nindent 6 }}
*/}}
{{- define "livepeer-common.affinity" -}}
{{- if . }}
affinity:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}

{{/*
Render imagePullSecrets if non-empty.
Usage: {{ include "livepeer-common.imagePullSecrets" .Values.imagePullSecrets | nindent 6 }}
*/}}
{{- define "livepeer-common.imagePullSecrets" -}}
{{- if . }}
imagePullSecrets:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}

{{/*
Render container ports list.
Usage: {{ include "livepeer-common.containerPorts" .Values.gateway.ports | nindent 10 }}
*/}}
{{- define "livepeer-common.containerPorts" -}}
{{- range . }}
- name: {{ .name }}
  containerPort: {{ .containerPort }}
  protocol: {{ .protocol | default "TCP" }}
  {{- if .hostPort }}
  hostPort: {{ .hostPort }}
  {{- end }}
{{- end }}
{{- end }}

{{/*
Render volume mounts list.
Usage: {{ include "livepeer-common.volumeMounts" .Values.gateway.volumeMounts | nindent 10 }}
*/}}
{{- define "livepeer-common.volumeMounts" -}}
{{- if . }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
Render volumes list.
Usage: {{ include "livepeer-common.volumes" .Values.gateway.volumes | nindent 6 }}
*/}}
{{- define "livepeer-common.volumes" -}}
{{- if . }}
{{- toYaml . }}
{{- end }}
{{- end }}
