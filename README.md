# tunneld
---

POC of a method to make services running in a K8S cluster accessible via public internet. This POC should be a more privacy friendly alternative to cloudflare tunneling as the traffic between cluster and remote endpoint goes completely through wireguard. This means no unencrypted traffic that could possibly be read by Cloudflare.

The tunneld pod connects via wireguard to a remote endpoint which could be a cheap VPS for example. This VPS then has access to certain K8S service resources in the cluster via the tunnel. This means that access to these services can be set up via the VPS.

The implementation consists of two parts. An InitContainer, which creates the wireguard config and creates the corresponding interface in the pod. The second part is the actual daemon. A script runs within this second container, which uses a user-definable label to create iptables rules for the IPs of the corresponding labeled services.

This means that the remote endpoint only has access to these labeled services and no other resources within the cluster.

---

# Deployment with Helm

## 1. Add the helm repo

```
helm repo add tunneld https://ajquack.github.io/tunneld
helm repo update
```

## 2. Create values.yaml for the helm release

Please set the serviceLabelFilter value, otherwise no services will be reachable

```yaml
tunneld:
  # Label used to determine which service should be reachable by tunneld peer eg. "tunneld=true"
  serviceLabelFilter: {{your-service-label-filter}}
```

Also see <https://github.com/ajquack/tunneld/blob/main/charts/tunneld/values.yaml> for all configuration options

## 3. Wireguard configuration values for the Pod

### 3.1 Option 1: Create a secret before the helm release installation

#### 3.1.1 Create a config.yaml file

```yaml
internal:
  config:
    private-key: Ze4rNjahNIaXVYmbDO8krAg9OfpsDt
    private-ip: 10.1.0.2/32
peer:
  config:
    public-key: ucMvUSyuE8yVEQDWcskmRFtjcE959g
    public-ip: 123.456.789.012:51820
    private-ip: 10.1.0.1/32
wg:
  config:
    persistentKeepalive: 25
```

#### 3.1.2 Create the kubernetes secret from the config.yaml file

```
kubectl create secret generic {{secret-name}} -n {{desired-namespace}} --from-file=config.yaml
```

#### 3.1.3 Adjust the values.yaml for the helm release to use the existing secret
```yaml
tunneld:
  serviceLabelFilter: {{your-service-label-filter}}
  existingSecret:
    enabled: true
    secretName: {{secret-name}}
```

### 3.2 Option 2: Configure the release with the values.yaml

Just add all your config values to the values.yaml. The helm chart will create a secret for the values. The secret will then be mounted into the pod to become available for the sidecar container which creates the wireguard config. Keep in mind to disable existingSecret
```yaml
tunneld:
  # Label used to determine which service should be reachable by tunneld peer eg. "tunneld=true"
  serviceLabelFilter: {{your-service-label-filter}}
  # Required values if no exisitingSecret is provided. This will create a secret for tunneld to use as a config file
  config:
    enabled: true
    values: |-
      local:
        config:
          private-key: Ze4rNjahNIaXVYmbDO8krAg9OfpsDt
          private-ip: 10.1.0.2/32
      peer:
        config:
          public-key: ucMvUSyuE8yVEQDWcskmRFtjcE959g
          public-ip: 123.456.789.012:51820
          private-ip: 10.1.0.1/32
      wg:
       config:
         persistentKeepalive:
  existingSecret:
    enabled: false
```

## 4. Install the helm release

```
helm install {{your-release-name}} tunneld/tunneld -n {{desired-namespace}} -f values.yaml
```
