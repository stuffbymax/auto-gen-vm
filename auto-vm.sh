#!/bin/bash

# Check if VBoxManage is installed
if ! command -v VBoxManage &> /dev/null
then
    echo "VBoxManage could not be found. Please install VirtualBox."
    exit 1
fi

# Variables (customize as needed or pass as arguments)
VM_NAME=${1:-demovm} # Default to 'demovm' if no name is provided
RAM_SIZE=${2:-1024}  # Default RAM size 1024MB
VRAM_SIZE=${3:-16}   # Default VRAM size 16MB
DISK_SIZE=${4:-10000} # Default disk size 32GB
ISO_PATH=${5:-/home/zdislav/Downloads/openmandriva.rome-23.01-plasma.x86_64.iso} # Path to ISO image
NIC_TYPE="82540EM"# Network card type for NAT
BRIDGE_ADAPTER="#" # Bridge adapter name

# Create a new VM
VBoxManage createvm --name "$VM_NAME" --register

# Set OS type to Linux 64-bit
VBoxManage modifyvm "$VM_NAME" --ostype Linux_64

# Configure RAM and VRAM
VBoxManage modifyvm "$VM_NAME" --memory "$RAM_SIZE" --vram "$VRAM_SIZE"

# Create virtual hard disk
VBoxManage createhd --filename "$VM_NAME.vdi" --size "$DISK_SIZE"

# Add storage controller and attach hard disk
VBoxManage storagectl "$VM_NAME" --name "SATA Controller" --add sata --controller IntelAHCI
VBoxManage storageattach "$VM_NAME" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$VM_NAME.vdi"

# Attach ISO image to boot from
VBoxManage storageattach "$VM_NAME" --storagectl "SATA Controller" --port 1 --device 0 --type dvddrive --medium "$ISO_PATH"

# Set boot order
VBoxManage modifyvm "$VM_NAME" --boot1 dvd --boot2 disk --boot3 none --boot4 none

# Configure network settings
VBoxManage modifyvm "$VM_NAME" --nic1 nat --nictype1 "$NIC_TYPE"
VBoxManage modifyvm "$VM_NAME" --nic1 bridged --nictype1 "$NIC_TYPE" --bridgeadapter1 "$BRIDGE_ADAPTER"

# Enable Physical Address Extension (PAE)
VBoxManage modifyvm "$VM_NAME" --pae on

# Start the VM
VBoxManage startvm "$VM_NAME"

echo "Virtual machine '$VM_NAME' has been created and started successfully!"
