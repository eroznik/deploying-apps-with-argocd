# Cluster management repository

Repository used to manage cluster "root" level applications and cluster level services.

For demo purposes, our root application will be called `bootstrap`(this one is manually installed). The app creates two
namespaces, two ArgoCD projects and two `Apps of Apps`.

The first `App of Apps` is the `team-blue` app which instructs ArgoCD to boot up an application for team blue(plain
Kubernetes manifests configuration).

The second `App of Apps` is the `team-red` app which instructs ArgoCD to boot up two applications of team blue(Helm
configuration).