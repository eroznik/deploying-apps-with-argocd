# Team `red` repository

Team `red` uses `Helm` as their templating engine for Kubernetes manifests, within this demo, they have Helm chart
templates directly in the repository - no external chart dependencies.

They have one app called `world-domination` which requires 3 Kubernetes objects:

* Ingress
* Service
* StatefulSet

The team is relying on cluster operators to provide a cluster ingress which will understand their `Ingress` specs.

Since the business logic of the applications is rather complex, they have 2 deployments:

* `preview`, meant for testing/approval/review
* `production`, for production grade deployments :)

## CI/CD

Team `red` is quite advanced, they have a complete CI/CD workflow. The demo doesn't include their runner, but they were
kind enough to share 2 short snippets that allow them to manage application artifact preview deployment and production
promotion.

### RC Release - usage

With named variables:

```bash
# APP_NAME must equal the folder name in which the app manifests reside
./rc-release.sh $APP_NAME $NEW_VERSION
```

With values:

```bash
./rc-release.sh world-domination purple
```

### Promote - usage

With named variables:

```bash
# APP_NAME must equal the folder name in which the app manifests reside
./promote.sh $APP_NAME
```

With values:

```bash
./promote.sh world-domination
```