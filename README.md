# Deploying apps with ArgoCD

Live demo code snippets for my talk on MakeIT/JCon 2023.

## Repository structure

* `manual-apply` contains yaml files that have to be applied manually
* `repository-ops` is a folder that simulates another repository, a repository meant to kick-start app deployment
    * for this particular demo, the repository contains the kick-start part, but also `Application` deployments of 2
      teams - in real life, this could be moved to other repositories(depends on the side of the organisation)
* `repository-team-blue`/`repository-team-red` are also folders that simulate repositories, these repositories contain
  manifests that describe which objects should be deployed for which `Application` that belongs to the associated team
* *(bonus folder)* `sample-yamls` contains various yaml files that I needed to prepare the presentation

Each "repository simulation" folder has its own `README.md` describing its purpose in more details.

## Local setup

### Kubernetes cluster

While you can use a manged service such as `AWS EKS` or `DigitalOcean Managed Kubernetes`, I usually do such tests
locally on my laptop. Most of the time I use [k3d](https://k3d.io):

```bash
k3d cluster create makeit-argocd -p "8081:80@loadbalancer"
```

This command will create a `k3d` cluster, add its config to your local `kube config` and expose it's load-balancer on
your
local `8080` port.

### ArgoCD

This step is pretty straight forward:

```bash
# be sure your local context is the desired one!
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

#### ArgoCD - `admin` user credentials

Whenever you do a fresh ArgoCD install, you get a fresh `admin` password stored in a secret. The easiest way to retrieve
it is with:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

#### ArgoCD - WebUI access

Since we won't be configuring a Kubernetes `Ingress` within the demo, we have to port foward directly to the
ArgoCD `Service`:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Now the UI should be available at: `http://localhost:8080/applications`. *Note: you might get a warning from the browser
that the connection is not secure, that's normal at this point with such setup.*

### Cluster demo apps boostrap

This step will initialise the cluster with all configured apps/projects/namespaces/... :

```bash
kubectl apply -f manual-apply/bootstrap.yaml
```

This is considered as a "push" change.