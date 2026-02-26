{{/*
Gateway container spec — shared across singleton and distributed modes.
Returns a single container dict suitable for embedding in a pod spec.
*/}}
{{- define "livepeer-gateway.containerSpec" -}}
- name: gateway
  image: {{ include "livepeer-common.image" (dict "imageValues" .Values.image "chartAppVersion" .Chart.AppVersion) }}
  imagePullPolicy: {{ .Values.image.pullPolicy }}
  {{- with .Values.gateway.command }}
  command:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  args:
  {{- if .Values.remoteSigner.enabled }}
    {{- $ethPattern := include "livepeer-gateway.ethArgPattern" . }}
    {{- range .Values.gateway.args }}
    {{- if not (regexMatch $ethPattern .) }}
    - {{ . }}
    {{- end }}
    {{- end }}
    - -remoteSignerUrl={{ include "livepeer-gateway.remoteSignerUrl" . }}
  {{- else }}
    {{- range .Values.gateway.args }}
    - {{ . }}
    {{- end }}
  {{- end }}
  {{- with .Values.gateway.env }}
  env:
    {{- include "livepeer-common.envList" . | nindent 4 }}
  {{- end }}
  ports:
    {{- include "livepeer-common.containerPorts" .Values.gateway.ports | nindent 4 }}
  {{- with (include "livepeer-common.probe" .Values.gateway.startupProbe) }}
  startupProbe:
    {{- . | nindent 4 }}
  {{- end }}
  {{- with (include "livepeer-common.probe" .Values.gateway.livenessProbe) }}
  livenessProbe:
    {{- . | nindent 4 }}
  {{- end }}
  {{- with (include "livepeer-common.probe" .Values.gateway.readinessProbe) }}
  readinessProbe:
    {{- . | nindent 4 }}
  {{- end }}
  {{- with .Values.gateway.resources }}
  resources:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with (include "livepeer-common.volumeMounts" .Values.gateway.volumeMounts) }}
  volumeMounts:
    {{- . | nindent 4 }}
  {{- end }}
{{- end }}
