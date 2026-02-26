{{/*
Gateway chart helpers — delegates to livepeer-common and adds gateway-specific logic.
*/}}

{{- define "livepeer-gateway.name" -}}
{{ include "livepeer-common.name" . }}
{{- end }}

{{- define "livepeer-gateway.fullname" -}}
{{ include "livepeer-common.fullname" . }}
{{- end }}

{{- define "livepeer-gateway.chart" -}}
{{ include "livepeer-common.chart" . }}
{{- end }}

{{- define "livepeer-gateway.labels" -}}
{{ include "livepeer-common.labels" . }}
{{- with .Values.gateway.labels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{- define "livepeer-gateway.selectorLabels" -}}
{{ include "livepeer-common.selectorLabels" . }}
app.kubernetes.io/component: gateway
{{- end }}

{{- define "livepeer-gateway.serviceAccountName" -}}
{{ include "livepeer-common.serviceAccountName" . }}
{{- end }}

{{/*
Remote signer fullname — suffixed with -remote-signer.
*/}}
{{- define "livepeer-gateway.remoteSignerFullname" -}}
{{- printf "%s-remote-signer" (include "livepeer-gateway.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "livepeer-gateway.remoteSignerLabels" -}}
{{ include "livepeer-common.labels" . }}
{{- with .Values.remoteSigner.labels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{- define "livepeer-gateway.remoteSignerSelectorLabels" -}}
{{ include "livepeer-common.selectorLabels" . }}
app.kubernetes.io/component: remote-signer
{{- end }}

{{/*
Resolve the remote signer image. Falls back to the top-level image tag,
then to Chart.AppVersion.
*/}}
{{- define "livepeer-gateway.remoteSignerImage" -}}
{{- $signerImg := merge (dict) .Values.remoteSigner.image }}
{{- if not $signerImg.tag }}
{{- $_ := set $signerImg "tag" (.Values.image.tag | default .Chart.AppVersion) }}
{{- end }}
{{- include "livepeer-common.image" (dict "imageValues" $signerImg "chartAppVersion" .Chart.AppVersion) }}
{{- end }}
