# $Id: opennebula_kvm.pp 4646 2011-09-01 09:01:59Z uwaechte $
class opennebula::node::kvm ($ensure = "present",
    $libvirtd_listen = $ipaddress,
    $libvirtgroup = "kvm") {
    class {
        "opennebula::node::common" :
            ensure => $ensure,
    }
    $pkgs = $lsbdistid ? {
        "Ubuntu" => ["kvm", "qemu-kvm-extras", "kvm-pxe", "libvirt-bin",
        "qemu-kvm"],
        default => ["libvirt-bin", "qemu-kvm", "qemu-user", "qemu-utils",
        "etherboot-qemu"]
    }
    package {
        $pkgs :
            ensure => $ensure,
    }
#    if $ensure == "present" {
#        user {
#            "oneadmin" :
#                groups => "${libvirtgroup}",
#                membership => "inclusive"
#        }
#    }
    kernel::module {
        ["virtio_balloon", "virtio_console", "virtio_rng"] :
            ensure => $ensure,
    }
    #remove strange private network config
    file {
        "/etc/libvirt/qemu/networks/autostart/default.xml" :
            ensure => "absent",
            require => [Package["libvirt-bin"]],
            notify => Service["libvirt-bin"],
    }
    $service_enable = $ensure ? {
        "absent" => false,
        default => true,
    }
    notice("KVM: ${ensure} // Service[libvirt-bin] should be enabled ${service_enable}")
    service {
        "libvirt-bin" :
            ensure => $service_enable,
            enable => $service_enable,
            require => Package["libvirt-bin"],
            hasrestart => true,
    }
    File {
        ensure => $ensure,
        notify => Service["libvirt-bin"],
    }
    $start_libvirtd = $service_enable ? {
        false => "no",
        default => "yes"
    }
    file {
        "/etc/default/libvirt-bin" :
            content => template("opennebula/etc_default_libvirt-bin.erb"),
    }
    file {
        "/etc/libvirt/libvirtd.conf" :
            content => template("opennebula/libvirtd.conf.erb"),
    }
    file {
        "/etc/libvirt/qemu.conf" :
            content => template("opennebula/qemu.conf.erb"),
    }
    file {
        "/etc/udev/rules.d/45-kvm.rules" :
            content =>
            "KERNEL=='kvm', GROUP='${opennebula::node::common::libvirtgroup}', OWNER='oneadmin', MODE='0660'\n",
            notify => Exec["opennebula-reload-udev"],
    }
    exec {
        "opennebula-reload-udev" :
            command => "/sbin/udevadm control --reload-rules",
            refreshonly => true,
    }
}
