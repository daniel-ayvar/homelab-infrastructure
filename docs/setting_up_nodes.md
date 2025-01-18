# Setting up the proxmox nodes.

## Hardware Information
In the homelab vlan30 network, there are currently 4 nodes. Each are labeled minisXX.
The hardware for each is as follows:

> __minis00__
> * model: MINISFORUM UN100P
> * cpu: Intel N100 Processor, 4 Cores/4 Threads (6M Cache, up to 3.4 GHz)
> * gpu: Intel UHD Graphics
> * memory: 1*DDR4 SO-DIMM,3200MHz, single channel 16GB
> * storage: 512GB M.2 SSD, 1TB SATA SSD
> * network: 1 2.5G NIC, Wifi

> __minis01 - minis03__
> * model: MINISFORUM NAB9
> * cpu: Intel Core i9-12900HK Processor, 14 Cores/20 Threads (24M Cache, up to 5.0 GHz)
> * gpu: Intel Iris Xe Graphics
> * memory: 2*DDR4 SO-DIMM,3200MHz, dual channel 16GB
> * storage: 2TB M.2 SSD, 400GB Enterprise SATA SSD
> * network: 1 2.5G NIC, Wifi

## Initializing the nodes
Ensure the nodes are configured with the following:

__For all__
* ensure that the correct ip address defined in the terraform.

__For minis00__
* proxmox VE 8.3 iso

__For minis01 - minis03__
* debian 12.8 iso
* network is initialized with eth2
* gateway & dns is set to vlan30 gateway
* host url set to <NODE_NAME>.pve.local
* install the os on a 500gb partition
* make swap size 64gb

Once all nic are connected to the homelab router, then you can continue.

### **Initializing Extra Disk Space (for minis01 – minis03)**

After installing the OS and configuring your swap, you will have unallocated disk space on your NVMe drive (e.g. approximately **1.3 TB** available). Follow these steps to add that space to the existing LVM volume group (`pve`):

1. **Identify the Unallocated Space**
   Check your current disk layout with:
   ```bash
   lsblk
   ```
   You should see that your NVMe disk (e.g. `/dev/nvme0n1`) has unallocated space not used by existing partitions.

2. **Create a New Partition**
   Use `fdisk` (or `parted`) to create a new partition from the unused space. In this example, we assume you will create partition `/dev/nvme0n1p4`:
   ```bash
   fdisk /dev/nvme0n1
   ```
   Within `fdisk`:
   - Press **n** to create a new partition.
   - Select the default partition number (likely `4`).
   - Accept the default starting sector (after the last partition).
   - Accept the default ending sector or specify the last sector to use the remaining available space.
   - Press **t** to change the partition type.
   - Enter the new partition number (e.g. **4**).
   - Set the type to **8e** (Linux LVM).
   - Press **w** to write the changes and exit.

3. **Inform the Kernel of Changes**
   Notify the OS of the new partition table:
   ```bash
   partprobe /dev/nvme0n1
   ```

4. **Initialize the New Partition as a Physical Volume**
   Create a new LVM physical volume:
   ```bash
   pvcreate /dev/nvme0n1p4
   ```

5. **Extend the Volume Group**
   Add the new physical volume to your existing volume group `pve`:
   ```bash
   vgextend pve /dev/nvme0n1p4
   ```
   You can verify the extra free space with:
   ```bash
   vgdisplay pve
   ```

## IP Lease Binding

If you find the nodes not binding to a lease in the network, it may be necessary to restart the IP Lease service to start.

```bash
dhclient -r && dhclient
```
The binding of the lease will be fixed once ansible runs successfully on the node.

## Setting up a SSH key
To remove the need for password authentication for ssh, manually create a ssh key and add the public
key to the target machines.

### **Step 1: Generate an SSH Key Pair**
On your local machine, generate a new SSH key:
```bash
ssh-keygen -t ed25519 -C "github-actions@danielayvar.com" -f ~/id_ed25519
```

### **Step 2: Enable Root SSH Access on Each Node**
By default, root ssh login is disabled. Password authentication will will be enabled temporarily to  key-based authentication.

1. **SSH into the node:**
```bash
ssh your_user@target-machine-ip
```
If you are using the proxmox iso, just use the terminal in the ui (local_ip:8006) with the root user.

2. **Become a superuser:**
Become a superuser, using the password used in the node initialization.
```bash
su
```

3. **Edit the SSH Daemon Configuration:**
```bash
vi /etc/ssh/sshd_config
```

4. **Modify `PermitRootLogin`:**
Locate the line starting with `#PermitRootLogin`, uncomment it, and set its value to the following.
```bash
PermitRootLogin yes
```

5. **Ensure Public Key Authentication is Enabled:**
Confirm this line is enabled and present.
```bash
PubkeyAuthentication yes
```

6. **Restart the SSH Service:**
Save and exit then restart the sshd service. After exiting, disconnect from the ssh session.
```bash
systemctl restart sshd
```

### **Step 3: Enable Root SSH Access on Each Node**
Use `ssh-copy-id` to copy your public key to the root user's `authorized_keys`:
```bash
ssh-copy-id -i ~/id_ed25519.pub root@target-machine-ip
```

### **Step 4: Verify SSH Key-Based Access as Root**
Test the SSH key authentication to ensure you can access the machine without logging in:
```bash
ssh -i ~/id_ed25519 root@target-machine-ip
```

### **Step 5: Verify SSH Key-Based Access as Root**
To enhance security, disable password-based SSH authentication for the root user.

1. **Edit the SSH Configuration Again:**
```bash
vi /etc/ssh/sshd_config
```

2. **Modify `PermitRootLogin`:**
Change the `PermitRootLogin` directive to `prohibit-password`:
```bash
PermitRootLogin prohibit-password
```

3. **Restart the SSH Service:**
Confirm this line is enabled and present. Then exit the ssh session.
```bash
systemctl restart sshd
```

With this, ssh access to root should be possible with the ssh key. Store the ssh key in 
the github action environment under the `HOMELAB_SSH_KEY` var.

## Deploying the infrastructure
After completing these steps, your infrastructure should be able to be deployed via
ssh.
