# Kubernetes

## kubectl

### get vs. describe

The `get` command prints a table of the most important information about specified resources.

```
$ kubectl get --help
...
$ kubectl get componentsstatuses
$ kubectl get nodes
$ kubectl get -o wide nodes
$ kubectl get -o json nodes
```

The `describe` command shows details of specified resources with a name prefix.

```
$ kubectl describe --help
$ kubectl describe nodes <NAME_PREFIX>
```

### namespace

Kubernetes uses namespaces to organize objects in the cluster.

```
$ kubectl get namespaces
NAME          STATUS    AGE
default       Active    8d
kube-public   Active    8d
kube-system   Active    8d
```

You need to specify the `--namespace` flag to set the difference namespace temporarily.

```
$ kubectl get deployments --namespace=kube-system
NAME                    DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
event-exporter-v0.2.3   1         1         1            1           8d
fluentd-gcp-scaler      1         1         1            1           8d
heapster-v1.5.3         1         1         1            1           8d
kube-dns                2         2         2            2           8d
kube-dns-autoscaler     1         1         1            1           8d
l7-default-backend      1         1         1            1           8d
metrics-server-v0.2.1   1         1         1            1           8d
```

To save the namespace permanently, set a context with the `---namespace` flag.

```
$ kubectl config set-context $(kube config current-context) --namespace=my-resources
$ kubectl config view | grep namespace
```

### run vs. apply

The `run` command creates a deployment or job to manage the created containers.

```
$ kubectl run <DEPLOYMENT_NAME> --image=<IMAGE>
```

If you want to just create a pod, use the `apply` command with the Pod configuration.

```
$ cat my-pod.yml
apiVersion: v1
kind: Pod
metadata:
  ...
spec:
  containers:
    - image: <IMAGE>
      name: <POD_NAME>
      ...

$ kubectl apply -f my-pod.yml
```

### logs

```
$ kubectl logs <POD_NAME>
```

### exec / cp

```
$ kubectl exec -it <POD_NAME> -- bash
```

```
$ kubectl cp <POD_NAME>:/path/to/pod/file /path/to/local/file
```

### delete

```
$ kubectl delete <DEPLOYMENT_NAME>
```