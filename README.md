# tunneld

**Selfmade implementation of a cloudflare tunnel by running wireguard in k8s. Tunneld-sidecar is the prefered method. The remote enpoint as access to the pod running the sidecar and can therefore accesse eg. a Webservice.**

---

Example deplyoment for running the tunneld-sidecar container. The sidecar establishes a wireguard connection to an endpoint. The connection is accessible by all containers running in the pod. Only traffic comming from the remote endpoint is routed via the wireguard interface.

## k8s secret
The secret is used to configure the sidecar wireguard connection.
```
apiVersion: v1
kind: Secret
metadata:
  name: example_name
  namespace: example_namespace
type: Opaque
data:
  private_key: <private_key_of_the_wg_connection>
  address: <private_ip_of_the_wg_connection/32>
  peer_public_key: <public_key_of_the_remote_endpoint>
  endpoint: <public_ip_of_the_remote_endpoint:port>
  endpoint_private: <private_ip_of_the_remote_endpoint>
  allowed_ips: <private_ip_of_the_remote_endpoint/32>
  persistent_keepalive: <persistent_keep_alive_timer>
```

## k8s deployment
Example deployment which established a wireguard connection to a remote endpoint from the pod. The wireguard connection is configureg via env variables sourced from the secret

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: example_name
  namespace: example_namespace
  labels:
    app: example_label
spec:
  selector:
    matchLabels:
      app: example_label
  replicas: 1
  strategy:
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: example_label
    spec:
      volumes:
        - name: tunneld-conf
          emptyDir: {}
      initContainers:
      - name: tunneld-sidecar
        image: "ghcr.io/ajquack/tunneld/tunneld-sidecar:latest"
        restartPolicy: Always
        command: ["sh", "-c"]
        args:
          - wg-init.sh;
            iptables -t nat -A POSTROUTING -d 10.43.0.10/32 -j MASQUERADE; #Example iptables rule to allow the remote endpoint to access kubedns
        env:
        - name: PRIVATE_KEY
          valueFrom:
            secretKeyRef:
              name: tunneld-secret
              key: private_key
        - name: ADDRESS
          valueFrom:
            secretKeyRef:
              name: tunneld-secret
              key: address
        - name: PEER_PUBLIC_KEY
          valueFrom:
            secretKeyRef:
              name: tunneld-secret
              key: peer_public_key
        - name: ENDPOINT
          valueFrom:
            secretKeyRef:
              name: tunneld-secret
              key: endpoint
        - name: ENDPOINT_PRIVATE
          valueFrom:
            secretKeyRef:
              name: tunneld-secret
              key: endpoint_private
        - name: ALLOWED_IPS
          valueFrom:
            secretKeyRef:
              name: tunneld-secret
              key: allowed_ips
        - name: PERSISTENT_KEEPALIVE
          valueFrom:
            secretKeyRef:
              name: tunneld-secret
              key: persistent_keepalive
        securityContext:
          capabilities:
            add:
              - NET_ADMIN
              - SYS_MODULE
          privileged: true
      containers:
      - name: webserver
        image: ghcr.io/ajquack/docker-nginx-sample:latest
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "100m"
          limits:
            memory: "128Mi"
            cpu: "200m"
```
