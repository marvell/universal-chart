{{/*
Expand the name of the chart.
*/}}
{{- define "universal-chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "universal-chart.fullname" -}}
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
Create chart name and version as used by the chart label.
*/}}
{{- define "universal-chart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "universal-chart.labels" -}}
helm.sh/chart: {{ include "universal-chart.chart" . }}
{{ include "universal-chart.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "universal-chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "universal-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "universal-chart.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "universal-chart.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Render a single service port entry.
*/}}
{{- define "universal-chart.formatServicePort" -}}
{{- $port := .port -}}
{{- $index := default 0 .index -}}
{{- $name := default (printf "port-%d" $index) $port.name -}}
{{- $hasName := ne (default "" $port.name) "" -}}
{{- $targetDefault := ternary $port.name (printf "%v" $port.port) $hasName -}}
{{- $target := default $targetDefault $port.targetPort -}}
- name: {{ $name }}
  port: {{ $port.port }}
  targetPort: {{ $target }}
  protocol: {{ default "TCP" $port.protocol }}
{{ with $port.nodePort }}
  nodePort: {{ . }}
{{ end }}
{{ with $port.appProtocol }}
  appProtocol: {{ . }}
{{ end }}
{{- end }}

{{/*
Render the service ports list, falling back to a default when none provided.
*/}}
{{- define "universal-chart.formatServicePorts" -}}
{{- $ports := .ports -}}
{{- $fallback := .fallback -}}
{{- if and $ports (gt (len $ports) 0) -}}
{{- range $index, $port := $ports -}}
{{ include "universal-chart.formatServicePort" (dict "port" $port "index" $index) }}
{{- end -}}
{{- else if $fallback -}}
{{ include "universal-chart.formatServicePort" (dict "port" $fallback "index" 0) }}
{{- end -}}
{{- end }}

{{/*
Return the default service backend port (name or number) for consumers like ingress.
*/}}
{{- define "universal-chart.defaultServiceBackendPort" -}}
{{- if and .Values.service.ports (gt (len .Values.service.ports) 0) -}}
{{- $first := index .Values.service.ports 0 -}}
{{- if $first.name -}}
{{- $first.name -}}
{{- else -}}
{{- $first.port -}}
{{- end -}}
{{- else if .Values.service.portName -}}
{{- .Values.service.portName -}}
{{- else -}}
{{- .Values.service.port -}}
{{- end -}}
{{- end }}

{{/*
Return the first service port number for use in hooks or tests.
*/}}
{{- define "universal-chart.primaryServicePortNumber" -}}
{{- if and .Values.service.ports (gt (len .Values.service.ports) 0) -}}
{{- (index .Values.service.ports 0).port -}}
{{- else -}}
{{- .Values.service.port -}}
{{- end -}}
{{- end }}
