#!/bin/bash

# Ensure the script is run as a regular user (not root)
if [[ $EUID -eq 0 ]]; then
   echo "This script must NOT be run as root. Please run it as a regular user." 
   exit 1
fi

# Function to display a menu and get the user's choice
function show_menu() {
    echo "-----------------------------------------"
    echo "        VirtualBox Management Script      "
    echo "-----------------------------------------"
    echo "1. List all VMs"
    echo "2. Create a new VM"
    echo "3. Start a VM"
    echo "4. Stop a VM"
    echo "5. Delete a VM"
    echo "6. Exit"
    echo "-----------------------------------------"
    read -p "Choose an option [1-6]: " choice
    echo ""
    return $choice
}

# Function to list all VMs
function list_vms() {
    echo "Listing all VMs..."
    VBoxManage list vms
}

# Function to create a new VM
function create_vm() {
    read -p "Enter the name of the new VM: " vm_name
    read -p "Enter the type of OS (e.g., Linux, Windows): " os_type
    read -p "Enter the version of the OS (e.g., Ubuntu_64, Windows10_64): " os_version
    read -p "Enter the amount of RAM in MB (e.g., 2048): " ram_size
    read -p "Enter the size of the virtual disk in MB (e.g., 20000): " disk_size

    echo "Creating VM..."
    VBoxManage createvm --name "$vm_name" --ostype "$os_version" --register
    VBoxManage modifyvm "$vm_name" --memory "$ram_size" --vram 16 --acpi on --boot1 dvd --nic1 nat
    VBoxManage createhd --filename "$HOME/VirtualBox VMs/$vm_name/$vm_name.vdi" --size "$disk_size" --variant Standard
    VBoxManage storagectl "$vm_name" --name "SATA Controller" --add sata --controller IntelAhci
    VBoxManage storageattach "$vm_name" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$HOME/VirtualBox VMs/$vm_name/$vm_name.vdi"

    echo "VM $vm_name created successfully!"
}

# Function to start a VM
function start_vm() {
    read -p "Enter the name or UUID of the VM to start: " vm_name
    VBoxManage startvm "$vm_name" --type headless
    echo "VM $vm_name is starting in headless mode."
}

# Function to stop a VM
function stop_vm() {
    read -p "Enter the name or UUID of the VM to stop: " vm_name
    VBoxManage controlvm "$vm_name" poweroff
    echo "VM $vm_name is shutting down."
}

# Function to delete a VM
function delete_vm() {
    read -p "Enter the name or UUID of the VM to delete: " vm_name
    VBoxManage unregistervm "$vm_name" --delete
    echo "VM $vm_name has been deleted."
}

# Main script logic
while true; do
    show_menu
    choice=$?

    case $choice in
        1)
            list_vms
            ;;
        2)
            create_vm
            ;;
        3)
            start_vm
            ;;
        4)
            stop_vm
            ;;
        5)
            delete_vm
            ;;
        6)
            echo "Exiting VirtualBox management script. Goodbye!"
            break
            ;;
        *)
            echo "Invalid choice. Please try again."
            ;;
    esac
    echo ""
done
