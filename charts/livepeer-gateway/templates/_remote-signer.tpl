{{/*
Remote signer container spec — used as sidecar (singleton) or standalone container (distributed).
*/}}
{{- define "livepeer-gateway.remoteSignerContainerSpec" -}}
- name: remote-signer
  image: {{ include "livepeer-gateway.remoteSignerImage" . }}
  imagePullPolicy: {{ .Values.remoteSigner.image.pullPolicy }}
  {{- with .Values.remoteSigner.command }}
  command:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  args:
    - -remoteSigner
    {{- if eq .Values.gateway.mode "singleton" }}
    - -httpAddr=127.0.0.1:{{ .Values.remoteSigner.httpPort }}
    {{- else }}
    - -httpAddr=0.0.0.0:{{ .Values.remoteSigner.httpPort }}
    {{- end }}
    {{- range .Values.remoteSigner.args }}
    - {{ . }}
    {{- end }}
  {{- with .Values.remoteSigner.env }}
  env:
    {{- include "livepeer-common.envList" . | nindent 4 }}
  {{- end }}
  ports:
    - name: signer-http
      containerPort: {{ .Values.remoteSigner.httpPort }}
      protocol: TCP
  {{- with .Values.remoteSigner.resources }}
  resources:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}

{{/*
Validate remote signer configuration.
*/}}
{{- define "livepeer-gateway.validateRemoteSigner" -}}
{{- if .Values.remoteSigner.enabled }}
  {{- $forbiddenModes := list "-gateway" "-orchestrator" "-transcoder" "-broadcaster" }}
  {{- range .Values.remoteSigner.args }}
    {{- $arg := . }}
    {{- range $forbiddenModes }}
      {{- if hasPrefix . $arg }}
        {{- fail (printf "remoteSigner.args must not include other node mode flags, found: %s" $arg) }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end }}
