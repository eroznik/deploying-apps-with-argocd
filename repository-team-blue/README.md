# Team `blue` repository

Team `blue` is pretty conservative, they don't use any manifest templating/packaging tooling - plain manifest yaml files
work just fine for them.

They have one app called `home-guard` which requires 3 Kubernetes objects:

* Ingress
* Service
* StatefulSet

The team is relying on cluster operators to provide a cluster ingress which will understand their `Ingress` specs.