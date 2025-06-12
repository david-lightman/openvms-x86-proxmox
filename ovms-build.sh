# openvms-x86-proxmox
Script to build openvms x86 on proxmox

#!/bin/bash

set -e

echo "                   === OpenVMS VM Builder ==="
cat <<'EOF'


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

EOF


read -rp "Enter path to OpenVMS VMDK descriptor (.vmdk): " VMDK_PATH
if [[ ! -f "$VMDK_PATH" ]]; then
  echo "ERROR: VMDK descriptor file not found: $VMDK_PATH"
  exit 1
fi

read -rp "Enter VM name [default: OpenVMS]: " VM_NAME
VM_NAME=${VM_NAME:-OpenVMS}

VMID=$(pvesh get /cluster/nextid)
echo "Assigned VMID: $VMID"

read -rp "Number of extra blank disks (excluding VMDK) [default: 1]: " DISK_COUNT
DISK_COUNT=${DISK_COUNT:-1}

read -rp "Disk size in GB [default: 16]: " DISK_SIZE
DISK_SIZE=${DISK_SIZE:-16}

read -rp "Memory size in MB [default: 4096]: " MEMORY
MEMORY=${MEMORY:-4096}

read -rp "Number of CPU cores [default: 2]: " CORES
CORES=${CORES:-2}

# Generate a default Locally Administered MAC address (LAA)
GEN_MAC=$(printf '52:54:00:%02x:%02x:%02x' $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)))
read -rp "Enter MAC address for net0 [default: $GEN_MAC]: " MAC
MAC=${MAC:-$GEN_MAC}
echo "Using MAC address: $MAC"

VM_IMAGE_DIR="/var/lib/vz/images/$VMID"
mkdir -p "$VM_IMAGE_DIR"

QCOW2_BOOT="$VM_IMAGE_DIR/vm-${VMID}-disk-0.qcow2"

echo "Converting VMDK to QCOW2..."
qemu-img convert -f vmdk -O qcow2 "$VMDK_PATH" "$QCOW2_BOOT"

# Ensure qemu-img is present
if ! command -v qemu-img >/dev/null 2>&1; then
  echo "ERROR: qemu-img is not installed. Please install it using: apt install qemu-utils"
  exit 1
fi

# Parse the virtual size in bytes from qemu-img info
ACTUAL_SIZE_BYTES=$(qemu-img info "$QCOW2_BOOT" | awk -F '[()]' '/virtual size/ { gsub(/[^0-9]/, "", $2); print $2 }')


ACTUAL_SIZE_GB=$((ACTUAL_SIZE_BYTES / 1024 / 1024 / 1024))

if (( DISK_SIZE < ACTUAL_SIZE_GB )); then
  echo "ERROR: The original disk is ${ACTUAL_SIZE_GB}GB, which is larger than your requested ${DISK_SIZE}GB."
  echo "Refusing to truncate disk. Please choose a disk size >= ${ACTUAL_SIZE_GB}GB."
  exit 1
elif (( DISK_SIZE > ACTUAL_SIZE_GB )); then
  echo "Expanding boot disk from ${ACTUAL_SIZE_GB}GB to ${DISK_SIZE}GB..."
  qemu-img resize "$QCOW2_BOOT" "${DISK_SIZE}G"
else
  echo "Boot disk size (${ACTUAL_SIZE_GB}GB) matches requested size."
fi

DISK_OPTS=""
for i in $(seq 1 "$DISK_COUNT"); do
  QCOW2_DATA="$VM_IMAGE_DIR/vm-${VMID}-disk-${i}.qcow2"
  echo "Creating blank disk: $QCOW2_DATA (${DISK_SIZE}G)"
  qemu-img create -f qcow2 "$QCOW2_DATA" "${DISK_SIZE}G"
  DISK_OPTS+="--scsi${i} local:${VMID}/vm-${VMID}-disk-${i}.qcow2,cache=writethrough,size=${DISK_SIZE}G "
done

echo "Creating VM $VMID..."

qm create "$VMID" \
  --name "$VM_NAME" \
  --memory "$MEMORY" \
  --cores "$CORES" \
  --sockets 2 \
  --cpu host \
  --numa 0 \
  --bios ovmf \
  --machine q35 \
  --ostype other \
  --serial0 socket \
  --scsihw virtio-scsi-single \
  --net0 e1000=${MAC},bridge=vmbr1,tag=161 \
  --scsi0 local:${VMID}/vm-${VMID}-disk-0.qcow2,cache=writethrough,size=${DISK_SIZE}G \
  $DISK_OPTS \
  --boot order=scsi0 \
  --ide2 none,media=cdrom \
  --args "-machine hpet=off"

echo "VM '$VM_NAME' (ID: $VMID) created successfully."
