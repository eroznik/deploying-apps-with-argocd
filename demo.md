# Live demo

All links below expect that you have your ArgoCD instance available at `https://localhost:8080` through port forward.

## Setup overview

* cluster bootstrap app(apps + projects)
* nested apps(team blue + red)
* leaf apps

## UI Overview

* applications overview
* various health states
* various sync states
* filters
* app specific overview(status header, actions,...)

## Do a GitOps pull change with auto sync on

The apps that we have installed are all on "auto sync". We can test this out with a few simple steps:

1. go to the [team red preview application values](repository-team-red/world-domination/values-preview.yaml)
2. change the replicas to `3`
3. commit & push the change
4. go to the app [ArgoCD UI](https://localhost:8080/applications/argocd/tr-world-domination-preview?view=tree&resource=)
5. if ArgoCD didn't detect the change yet(we can see that based on the latest synced commit), we can speed it up a bit
   by clicking `Refresh`
6. notice that ArgoCD scaled up the pod count to `3`

## Disable auto sync permanently

Since we're modifying apps that are created through the pull strategy, we have to disable auto-sync in the source,
otherwise it is not permanent.

We do this by removing the `autoSync` Application CRD attribute.

1. go to the [application ops repository of team red](repository-ops/team-red/apps.yaml)
2. comment out the following two lines of the app `tr-world-domination`, because team read from now wants to manually
   sync their production app
    ```yaml
      syncPolicy:
        automated: { }
    ```
3. commit & push the change

4. go to [team-red-apps](https://localhost:8080/applications/argocd/team-red-apps?view=tree&resource=)
5. check that the latest sync event happened because of the commit that you just created, if not, click "Refresh" and
   then "Sync"
6. [here](https://localhost:8080/applications/argocd/tr-world-domination?resource=&node=argoproj.io%2FApplication%2Fargocd%2Ftr-world-domination%2F0)
   we can now see that auto sync is off(sync policy set to `none`)

## Do a pull change with auto sync off

(Requires `Disable auto sync permanently` to be completed)

1. go to the [team red production application values](repository-team-red/world-domination/values.yaml)
2. change the replicas to `8`
3. commit & push the change
4. go to the app [ArgoCD UI](https://localhost:8080/applications/argocd/tr-world-domination?view=tree&resource=)
5. if ArgoCD didn't detect the change yet(we can see that based on `Sync status`, it should be `OutOfSync`), we can
   speed it up a bit by clicking `Refresh`
6. explore a bit the UI, try to click on `OutOfSync` - see what happens
7. click on `Sync` and observe while ArgoCD scales up pods to `8`

## Create a new app through the pull based strategy

We're going to do this on the team red world domination app.

1. create a new file within the [world-domination app manifests repository](repository-team-red/world-domination):
    * `values-special-preview.yaml`, the content should be:
       ```yaml
      app:
        name: world-domination-special-preview
        image:
          tag: green
       ```
2. add a new application to the [red team apps ops repository manifests](repository-ops/team-red/apps.yaml)
   ```yaml
   apiVersion: argoproj.io/v1alpha1
   kind: Application
   metadata:
      name: tr-world-domination-special-preview
      namespace: argocd
      finalizers:
        - resources-finalizer.argocd.argoproj.io
   spec:
      project: team-red-project
      source:
        repoURL: https://github.com/eroznik/deploying-apps-with-argocd.git
        targetRevision: prep-testing
        path: repository-team-red/world-domination
        helm:
          valueFiles:
            - values.yaml
            - values-special-preview.yaml
      destination:
        server: https://kubernetes.default.svc
        namespace: team-red-ns
      syncPolicy:
        automated: { }
     ```
3. go to [team red apps on ArgoCD](https://localhost:8080/applications/argocd/team-red-apps?view=tree&resource=)
4. if ArgoCD didn't detect the change yet(we can see that based on the latest synced commit), we can speed it up a bit
   by clicking `Refresh`
5. observe ArgoCD how a new app gets created and everything comes up and running

## Manual push ops examples

1. navigate
   to [here](https://localhost:8080/applications/argocd/tr-world-domination-preview?resource=&node=argoproj.io%2FApplication%2Fargocd%2Ftr-world-domination-preview%2F0&tab=parameters)
2. click `Edit`
3. update `app.replicas` to 6, click `Save`
4. wait the replicas to be added
5. notice, there is now a flag which indicates that we have a parameter over-ride
6. go
   back [here](https://localhost:8080/applications/argocd/tr-world-domination-preview?resource=&node=argoproj.io%2FApplication%2Fargocd%2Ftr-world-domination-preview%2F0&tab=parameters)
7. click `Edit`
8. on the `app.replicas` row, click `Remove override`
9. set `app.image.tag` to `green`, click `Save`
10. wait for the change to be applied
11. notice, we still have the flag which indicates that we have a parameter over-ride
12. lets now remove all over-rides
13. go
    back [here](https://localhost:8080/applications/argocd/tr-world-domination-preview?resource=&node=argoproj.io%2FApplication%2Fargocd%2Ftr-world-domination-preview%2F0&tab=parameters)
14. click `Edit`
15. on the `app.image.tag` row, click `Remove override`, click `Save`
16. notice that the flag for parameter over-rides is gone

## CI/CD simulation

1. open a terminal, go to `repository-team-red`
2. simulate a version update on the `preview` deployment of the app with `./rc-release.sh world-domination green`
    * review what changed in the last commit
3. now you have to push the changes with `git push`
4. check that ArgoCD deployed your version to [this app](https://localhost:8080/applications/argocd/tr-world-domination-preview?view=tree&resource=)
5. now simulate an environment promotion with `./promote.sh world-domination`
   * review what changed in the last commit
6. now you have to push the changes with `git push`
7. check that ArgoCD deployed your version to [this app](https://localhost:8080/applications/argocd/tr-world-domination?view=tree&resource=)