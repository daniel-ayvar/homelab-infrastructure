CSIDriver:
  fsGroupPolicy: "File"
  seLinuxMount: true

csiConfig:
  - clusterID: "${cluster_id}"
    monitors:
      %{ for mon in monitors }
      - ${mon}
      %{ endfor }
    cephFS:
      subvolumeGroup: "${ceph_subvolume_group}"
      radosNamespace: "${rados_namespace}"
secret:
  create: true
  adminID: "${ceph_user}"
  adminKey: "${ceph_key}"
  userID: "${ceph_user}"
  userKey: "${ceph_key}"

storageClass:
  create: true
  fsName: "${fsName}"
  pool: "${pool}"
  clusterID: "${cluster_id}"
