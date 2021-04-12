#!/bin/bash

DATA_DEVICES="nvme7n1 nvme8n1 nvme9n1 nvme10n1 nvme11n1 nvme12n1 nvme13n1 nvme15n1"
METADATA_DEVICES="nvme0n1 nvme1n1 nvme2n1 nvme3n1 nvme4n1 nvme5n1 nvme6n1 nvme16n2"

for devices in $DATA_DEVICES ; do pvcreate -ff /dev/$devices ; done

for PV in $DATA_DEVICES ; do vgcreate -y ceph_data_vg_$PV /dev/$PV ; done

SIZE=3.4T

for PV in $DATA_DEVICES ; do
  for VG in ceph_data_vg_$PV ; do
    for LV in 1 2 ; do
      lvcreate -n ceph_data_lv_$LV -L $SIZE $VG ;
      done;
    done;
done


for i in $METADATA_DEVICES ; do pvcreate /dev/$i ; done

for PV in $METADATA_DEVICES ; do vgcreate -y ceph_db_wal_vg_$PV /dev/$PV ; done

WAL_SIZE=25G
for PV in $METADATA_DEVICES ; do
  for VG in ceph_db_wal_vg_$PV ; do
    for LV in {1..2} ; do
        lvcreate -n ceph_wal_lv_"$LV" -L $WAL_SIZE $VG ;
      done;
    done;
done

DB_SIZE=320G
for PV in $METADATA_DEVICES ; do
  for VG in ceph_db_wal_vg_$PV ; do
    for LV in {1..2} ; do
        lvcreate -n ceph_db_lv_"$LV" -L $DB_SIZE $VG ;
      done;
    done;
done
