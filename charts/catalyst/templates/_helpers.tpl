{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "catalyst.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "catalyst.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "catalyst.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "catalyst.labels" -}}
helm.sh/chart: {{ include "catalyst.chart" . }}
{{ include "catalyst.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- include "catalyst.customlabels" .Values.labels }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "catalyst.selectorLabels" -}}
app.kubernetes.io/name: {{ include "catalyst.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
livepeer.live/catalyst-service: server
{{- end -}}

{{/*
Common labels for coturn
*/}}
{{- define "catalyst.coturn.labels" -}}
helm.sh/chart: {{ include "catalyst.chart" . }}-coturn
{{ include "catalyst.coturn.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- include "catalyst.customlabels" .Values.labels }}
{{- end -}}

{{/*
Selector labels for coturn
*/}}
{{- define "catalyst.coturn.selectorLabels" -}}
app.kubernetes.io/name: {{ include "catalyst.name" . }}-coturn
app.kubernetes.io/instance: {{ .Release.Name }}-coturn
livepeer.live/catalyst-service: coturn-server
{{- end -}}

{{/* get labels map */}}
{{- define "catalyst.customlabels" -}}
{{- range $key, $value := . }}
{{ $key }}: {{ $value }}
{{- end -}}
{{- end -}}

{{/* get annotations map */}}
{{- define "catalyst.annotations" -}}
{{- range $key, $value := . }}
{{ $key }}: "{{ $value }}"
{{- end -}}
{{- end -}}

{{/* generate a Mist protocols list from a protocol map */}}
{{/* usually the "connector" of the protocol is taken from the map but */}}
{{/* you can also override it manually to allow for duplicates */}}
{{- define "catalyst.protocols" -}}
{{ $protocols := list }}
{{- range $key, $this := . -}}
{{/* allow for disabling protocols by setting them to null */}}
{{- if not (eq (kindOf $this) "invalid") -}}
{{- range $k, $v := $this -}}
{{/* disallow "null" as a value to a parameter (it gets stringified to "null", yuck) */}}
{{- if eq (kindOf $v) "invalid" -}}
{{- fail (cat $k "is not a string, it's" (kindOf $v) (quote $v)) -}}
{{- end -}}
{{- end -}}
{{- $connector := default $key $this.connector -}}
{{- $protocol := merge $this (dict "connector" $connector) -}}
{{- $protocols = append $protocols $protocol -}}
{{- end -}}
{{- end -}}
{{ $protocols | toPrettyJson }}
{{- end -}}
