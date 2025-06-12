# openvms-x86-proxmox

Simple script to remember the settings for an OpenVMS/x86 proxmox build.


```
root@pm0:~# ./openvms-builder.sh
                   === OpenVMS VM Builder ===


   ▒█████   ██▓███  ▓█████  ███▄    █ ██▒   █▓ ███▄ ▄███▓  ██████
  ▒██▒  ██▒▓██░  ██▒▓█   ▀  ██ ▀█   █▓██░   █▒▓██▒▀█▀ ██▒▒██    ▒
  ▒██░  ██▒▓██░ ██▓▒▒███   ▓██  ▀█ ██▒▓██  █▒░▓██    ▓██░░ ▓██▄
  ▒██   ██░▒██▄█▓▒ ▒▒▓█  ▄ ▓██▒  ▐▌██▒ ▒██ █░░▒██    ▒██   ▒   ██▒
  ░ ████▓▒░▒██▒ ░  ░░▒████▒▒██░   ▓██░  ▒▀█░  ▒██▒   ░██▒▒██████▒▒
  ░ ▒░▒░▒░ ▒▓▒░ ░  ░░░ ▒░ ░░ ▒░   ▒ ▒   ░ ▐░  ░ ▒░   ░  ░▒ ▒▓▒ ▒ ░
    ░ ▒ ▒░ ░▒ ░      ░ ░  ░░ ░░   ░ ▒░  ░ ░░  ░  ░      ░░ ░▒  ░ ░
  ░ ░ ░ ▒  ░░          ░      ░   ░ ░     ░░  ░      ░   ░  ░  ░
      ░ ░              ░  ░         ░      ░         ░         ░
                                           ░
            OpenVMS x86 / Proxmox Configuration Tool
                        wopr::lightman

Enter path to OpenVMS VMDK descriptor (.vmdk): /media/vmdk/X86_V923-community.vmdk
Enter VM name [default: OpenVMS]:
Assigned VMID: 103
Number of extra blank disks (excluding VMDK) [default: 1]:
Disk size in GB [default: 16]:
Memory size in MB [default: 4096]:
Number of CPU cores [default: 2]:
Enter MAC address for net0 [default: 52:54:00:ab:c3:a7]:
Using MAC address: 52:54:00:ab:c3:a7
Converting VMDK to QCOW2...
Expanding boot disk from 8GB to 16GB...
Image resized.
Creating blank disk: /var/lib/vz/images/103/vm-103-disk-1.qcow2 (16G)
Formatting '/var/lib/vz/images/103/vm-103-disk-1.qcow2', fmt=qcow2 cluster_size=65536 extended_l2=off compression_type=zlib size=17179869184 lazy_refcounts=off refcount_bits=16
Creating VM 103...
VM 'OpenVMS' (ID: 103) created successfully.
```
