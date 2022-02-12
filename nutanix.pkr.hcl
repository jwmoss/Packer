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
  default = "C:\\path\\to\\2019.iso"
}

variable "output_directory" {
  type    = string
  default = "C:\\path\\to\\outputdir"
}

variable "sysprep_unattended" {
  type    = string
  default = "C:\\path\\to\\unattend.xml"
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
    "C:\\path\\to\\scripts\\bootstrap.ps1",
    "C:\\path\\to\\files\\autounattend.xml",
    "C:\\path\\to\\files\\Nutanix-VirtIO-1.1.7\\Windows Server 2019\\amd64\\vioscsi.cat",
    "C:\\path\\to\\files\\Nutanix-VirtIO-1.1.7\\Windows Server 2019\\amd64\\vioscsi.inf",
    "C:\\path\\to\\files\\Nutanix-VirtIO-1.1.7\\Windows Server 2019\\amd64\\vioscsi.sys",
    "C:\\path\\to\\files\\Nutanix-VirtIO-1.1.7\\Windows Server 2019\\amd64\\netkvm.cat",
    "C:\\path\\to\\files\\Nutanix-VirtIO-1.1.7\\Windows Server 2019\\amd64\\netkvm.inf",
    "C:\\path\\to\\files\\Nutanix-VirtIO-1.1.7\\Windows Server 2019\\amd64\\netkvm.sys"
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
