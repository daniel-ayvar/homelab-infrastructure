selinuxMount: false
csiConfig:
  - clusterID: "${cluster_id}"
    monitors:
      %{ for mon in monitors }
      - ${mon}
      %{ endfor }
secret:
  create: true
  userID: "${ceph_user}"
  userKey: "${ceph_key}"
storageClass:
  create: true
  pool: cephfs_pool
  clusterID: "${cluster_id}"
