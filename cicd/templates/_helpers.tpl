{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "cicd.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "cicd.fullname" -}}
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
{{- define "cicd.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "cicd.labels" -}}
helm.sh/chart: {{ include "cicd.chart" . }}
{{ include "cicd.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "cicd.selectorLabels" -}}
app.kubernetes.io/name: {{ include "cicd.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "cicd.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "cicd.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}


{{/*
   cicd ingress load balancer
*/}}
{{- define "cicd.ingressloadbalancer" -}}
kubernetes.io/ingress.class: alb
alb.ingress.kubernetes.io/target-type: ip
alb.ingress.kubernetes.io/scheme: internet-facing
alb.ingress.kubernetes.io/subnets: subnet-00bd3ca3f8e900426,subnet-0ddc59954703ef12a
alb.ingress.kubernetes.io/security-groups: sg-0c62ca3cf561ea109
alb.ingress.kubernetes.io/tags: Name=eks
#alb.ingress.kubernetes.io/certificate-arn: my-acm-certificate-arn
alb.ingress.kubernetes.io/listen-ports: '[{"HTTP":80}]'
# allow 404s on the health check
alb.ingress.kubernetes.io/healthcheck-path: "/"
alb.ingress.kubernetes.io/success-codes: "200,404"
{{- end -}}

