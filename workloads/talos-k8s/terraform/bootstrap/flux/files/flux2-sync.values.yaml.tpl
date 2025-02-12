secret:
  # -- Create a secret for the git repository. Defaults to false.
  create: false

  # -- Data of the secret.
  # For HTTPS repositories the secret must contain username and password fields.
  # For SSH repositories the secret must contain identity, identity.pub and known_hosts fields.
  # Values will be encoded to base64 by the helm chart.
  data: {}

  # -- Algorithm of keys to generate.
  # If `data` object above is empty, and `create` is set to true. The Chart will generate the
  # Git SSH key secret automatically based on the key algorithms that are set below.
  generate:
    sshKeyAlgorithm: ecdsa
    sshEcdsaCurve: p521

cli:
  image: ghcr.io/fluxcd/flux-cli
  tag: v2.4.0
  nodeSelector: {}
  affinity: {}
  tolerations: []

gitRepository:
  labels: {}
  annotations: {}
  spec:
    # -- The repository URL, can be an HTTP/S or SSH address.
    url: "${repository_url}"

    # -- _Optional_ The secret name containing the Git credentials.
    # For HTTPS repositories the secret must contain username and password fields.
    # For SSH repositories the secret must contain identity, identity.pub and known_hosts fields.
    # If a secret.create is set, it will point to that one.
    secretRef: {
        name: ${github_credential_secret_ref}
    }

    # -- The interval at which to check for repository updates.
    interval: 5m

    # -- _Optional_ The timeout for remote Git operations like cloning, defaults to 20s.
    timeout: ""

    # -- _Optional_ The Git reference to checkout and monitor for changes, defaults to master branch.
    ref:
      branch: ${branch}

    # -- _Optional_ Verify OpenPGP signature for the Git commit HEAD points to.
    verify: {}

    # -- _Optional_ Ignore overrides the set of excluded patterns in the .sourceignore format (which is the same as .gitignore). If not provided, a default will be used, consult the documentation for your version to find out what those are. Make sure to set this as yaml multiline string.
    ignore: ""

    # -- _Optional_ This flag tells the controller to suspend the reconciliation of this source.
    suspend: ""

    # -- _Optional_ Determines which git client library to use. Defaults to go-git, valid values are (‘go-git’, ‘libgit2’).
    gitImplementation: ""

    # -- _Optional_ When enabled, after the clone is created, initializes all submodules within, using their default settings. This option is available only when using the ‘go-git’ GitImplementation.
    recurseSubmodules: false

    # -- _Optional_ Extra git repositories to map into the repository
    include: []

kustomizationlist:
  - spec:
      interval: 5m
      path: ./namespaces
      prune: true
      timeout: 5m
  - spec:
      dependsOn:
        - path: ./namespaces
      interval: 5m
      path: ./apps
      prune: true
      timeout: 5m
