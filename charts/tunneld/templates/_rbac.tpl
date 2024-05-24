{{- define "tunneld.ServiceAccount" }}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ tunneld.name }}-service-reader
  namespace: {{ .Release.Namespace }}
{{- end }}

{{- define "tunneld.ClusterRole" }}
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: {{ tunneld.name }}-service-reader
rules:
- apiGroups: [""]
  resources: ["services"]
  verbs: ["get", "watch", "list"]
{{- end }}

{{- define "tunneld.ClusterRoleBinding" }}
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: {{ tunneld.name }}-service-reader-rolebinding
subjects:
- kind: ServiceAccount
  name: {{ tunneld.name }}-service-reader
  namespace: {{ .Release.Namespace }}
roleRef:
  kind: ClusterRole
  name: {{ tunneld.name }}-service-reader
  apiGroup: rbac.authorization.k8s.io
{{- end }}