{{- define "tunneld.ServiceAccount" }}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ include "tunneld.name" . }}-service-reader
  namespace: {{ .Release.Namespace }}
{{- end }}

{{- define "tunneld.ClusterRole" }}
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: {{ include "tunneld.name" . }}-service-reader
rules:
- apiGroups: [""]
  resources: ["services"]
  verbs: ["get", "watch", "list"]
{{- end }}

{{- define "tunneld.ClusterRoleBinding" }}
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: {{ include "tunneld.name" . }}-service-reader-rolebinding
subjects:
- kind: ServiceAccount
  name: {{ include "tunneld.name" . }}-service-reader
  namespace: {{ .Release.Namespace }}
roleRef:
  kind: ClusterRole
  name: {{ include "tunneld.name" . }}-service-reader
  apiGroup: rbac.authorization.k8s.io
{{- end }}