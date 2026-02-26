{{/*
Mode validation and helpers.
*/}}

{{/*
Validate gateway.mode is a supported value.
*/}}
{{- define "livepeer-gateway.validateMode" -}}
{{- $allowed := list "singleton" "distributed" }}
{{- if not (has .Values.gateway.mode $allowed) }}
{{- fail (printf "gateway.mode must be one of %s, got: %s" ($allowed | join ", ") .Values.gateway.mode) }}
{{- end }}
{{- end }}

{{/*
Derive the cluster-local remote signer URL for gateway to use.
In singleton mode the sidecar is on localhost.
In distributed mode it points at the remote-signer ClusterIP service.
*/}}
{{- define "livepeer-gateway.remoteSignerUrl" -}}
{{- if eq .Values.gateway.mode "singleton" }}
{{- printf "http://127.0.0.1:%d" (int .Values.remoteSigner.httpPort) }}
{{- else }}
{{- printf "http://%s:%d" (include "livepeer-gateway.remoteSignerFullname" .) (int .Values.remoteSigner.httpPort) }}
{{- end }}
{{- end }}

{{/*
Regex pattern for Ethereum/payment args that should be stripped from gateway
when remote signer is enabled (these flags belong on the signer side only).
*/}}
{{- define "livepeer-gateway.ethArgPattern" -}}
^-(network|ethUrl|ethPassword|ethController|depositMultiplier|maxTicketEV|maxTotalEV|pixelsPerUnit|maxPricePerUnit|maxPricePerCapability|blockPollingInterval|orchBlocklist|orchMinLivepeerVersion|initializeRound)=
{{- end }}
