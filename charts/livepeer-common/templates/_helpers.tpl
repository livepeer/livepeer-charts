{{/*
Expand the name of the chart.
*/}}
{{- define "livepeer-common.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Fully qualified app name.
Truncated to 63 chars (DNS naming spec).
*/}}
{{- define "livepeer-common.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Chart name and version for the chart label.
*/}}
{{- define "livepeer-common.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels applied to every resource.
*/}}
{{- define "livepeer-common.labels" -}}
helm.sh/chart: {{ include "livepeer-common.chart" . }}
{{ include "livepeer-common.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels used in matchLabels and service selectors.
*/}}
{{- define "livepeer-common.selectorLabels" -}}
app.kubernetes.io/name: {{ include "livepeer-common.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Service account name.
*/}}
{{- define "livepeer-common.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "livepeer-common.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Render image string from context.
Expects a dict with "imageValues" (the image map) and "chartAppVersion" (fallback tag).
Usage: {{ include "livepeer-common.image" (dict "imageValues" .Values.image "chartAppVersion" .Chart.AppVersion) }}
*/}}
{{- define "livepeer-common.image" -}}
{{- $img := .imageValues }}
{{- if $img.digest }}
{{- printf "%s@%s" $img.repository $img.digest }}
{{- else }}
{{- $tag := $img.tag | default .chartAppVersion | default "latest" }}
{{- printf "%s:%s" $img.repository $tag }}
{{- end }}
{{- end }}

{{/*
Merge additional labels onto a base set.
Usage: {{ include "livepeer-common.mergeLabels" (dict "base" (include "livepeer-common.labels" .) "extra" .Values.gateway.labels) }}
*/}}
{{- define "livepeer-common.mergeLabels" -}}
{{- $base := .base | fromYaml }}
{{- $extra := .extra | default dict }}
{{- toYaml (merge $extra $base) }}
{{- end }}

{{/*
Render annotations map if non-empty.
Usage: {{ include "livepeer-common.annotations" .Values.gateway.annotations }}
*/}}
{{- define "livepeer-common.annotations" -}}
{{- if . }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
Render env list from a string-keyed map.
Usage: {{ include "livepeer-common.envList" .Values.gateway.env }}
*/}}
{{- define "livepeer-common.envList" -}}
{{- range $key, $value := . }}
{{- if kindIs "string" $value }}
- name: {{ $key }}
  value: {{ $value | quote }}
{{- else if kindIs "map" $value }}
- name: {{ $key }}
  {{- toYaml $value | nindent 2 }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Render a probe block if enabled.
Usage: {{ include "livepeer-common.probe" .Values.gateway.livenessProbe }}
*/}}
{{- define "livepeer-common.probe" -}}
{{- if .enabled }}
{{- $probe := omit . "enabled" }}
{{- toYaml $probe }}
{{- end }}
{{- end }}
