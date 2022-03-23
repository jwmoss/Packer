packer {
  required_plugins {
    windows-update = {
      version = "0.14.0"
      source  = "github.com/rgl/windows-update"
    }
  }
}

variable "disk_size" {
  type    = string
  default = "80000"
}

variable "disk_interface" {
  type    = string
  default = "virtio-scsi"
}

variable "format" {
  type    = string
  default = "qcow2"
}

variable "net_device" {
  type    = string
  default = "e1000"
}

variable "iso_checksum" {
  type    = string
  default = "03850FA3D131ACA4FDBF0C92F4CEDC389C45C9DA64E75C5FA4E80D89D5F622FA"
}

variable "iso_checksum_type" {
  type    = string
  default = "sha256"
}

variable "iso_url" {
  type    = string
  default = "C:\\iso\\2019\\Server_10.0.17763.2452.iso"
}

variable "output_directory" {
  type    = string
  default = "C:\\_PackerNutanix\\vm\\win2019-qemu"
}

variable "sysprep_unattended" {
  type    = string
  default = "C:\\_PackerNutanix\\unattend.xml"
}

variable "upgrade_timeout" {
  type    = string
  default = "240"
}

variable "vm_name" {
  type    = string
  default = "Server2019.qcow2"
}

source "qemu" "template" {
  disk_interface   = "${var.disk_interface}"
  communicator     = "winrm"
  format           = "qcow2"
  cpus             = 4
  disk_size        = "${var.disk_size}"
  iso_checksum     = "${var.iso_checksum_type}:${var.iso_checksum}"
  iso_url          = "${var.iso_url}"
  memory           = 8192
  output_directory = "${var.output_directory}"
  shutdown_timeout = "30m"
  vm_name          = "${var.vm_name}"
  winrm_password   = "password"
  winrm_timeout    = "8h"
  winrm_username   = "Administrator"
  floppy_files = [
    "C:\\_PackerNutanix\\files\\bootstrap.ps1",
    "C:\\_PackerNutanix\\files\\autounattend.xml",
    "C:\\_PackerNutanix\\files\\Nutanix-VirtIO-1.1.7\\Windows Server 2019\\amd64\\vioscsi.cat",
    "C:\\_PackerNutanix\\files\\Nutanix-VirtIO-1.1.7\\Windows Server 2019\\amd64\\vioscsi.inf",
    "C:\\_PackerNutanix\\files\\Nutanix-VirtIO-1.1.7\\Windows Server 2019\\amd64\\vioscsi.sys",
    "C:\\_PackerNutanix\\files\\Nutanix-VirtIO-1.1.7\\Windows Server 2019\\amd64\\netkvm.cat",
    "C:\\_PackerNutanix\\files\\Nutanix-VirtIO-1.1.7\\Windows Server 2019\\amd64\\netkvm.inf",
    "C:\\_PackerNutanix\\files\\Nutanix-VirtIO-1.1.7\\Windows Server 2019\\amd64\\netkvm.sys",
    "C:\\_PackerNutanix\\files\\virtio-win-0.1.215\\viostor\\2k19\\amd64\\*.cat",
    "C:\\_PackerNutanix\\files\\virtio-win-0.1.215\\viostor\\2k19\\amd64\\*.inf",
    "C:\\_PackerNutanix\\files\\virtio-win-0.1.215\\viostor\\2k19\\amd64\\*.sys",
  ]
  qemuargs = [
    ["-m", "8000"],
    ["-smp", "4"]
  ]
}

build {
  sources = ["source.qemu.template"]

  provisioner "file" {
    destination = "C:\\Windows\\System32\\Sysprep\\unattend.xml"
    source      = "${var.sysprep_unattended}"
  }

  provisioner "powershell" {
    elevated_user     = "Administrator"
    elevated_password = "password"
    inline            = ["Write-Output Sysprep", "if (!(Test-Path -Path $Env:SystemRoot\\system32\\Sysprep\\unattend.xml)){ Write-Output 'No file';exit (10)}", "& $Env:SystemRoot\\System32\\Sysprep\\Sysprep.exe /oobe /generalize /shutdown /quiet /unattend:C:\\Windows\\system32\\sysprep\\unattend.xml"]
  }
}
