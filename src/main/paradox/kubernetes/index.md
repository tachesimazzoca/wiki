# Kubernetes

## kubectl

### namespace

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
