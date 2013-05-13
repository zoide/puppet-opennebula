# $Id: init.pp 4784 2011-11-13 16:36:18Z uwaechte $
import "opennebula_xen.pp"
import "opennebula_kvm.pp"

class opennebula::common ($ensure = "present",
    $libvirtgroup = "kvm") {
    $oneadmin_home = "/var/lib/one"
    user {
        "oneadmin" :
            uid => 112,
            gid => "oneadmin",
            managehome => true,
            home => "${oneadmin_home}",
            shell => "/bin/bash",
            groups => "${libvirtgroup}",
            membership => "inclusive"
    }
    File {
        owner => "oneadmin",
        group => "oneadmin"
    }
    group {
        "oneadmin" :
            gid => 200,
            before => User["oneadmin"],
    }
    file {
        "${oneadmin_home}/.ssh" :
            ensure => "directory",
            require => File["${oneadmin_home}"]
    }
    file {
        ["${oneadmin_home}", "${oneadmin_home}/.one"] :
            ensure => "directory",
            mode => 0750,
            require => [User["oneadmin"], Group["oneadmin"]],
    }
    file {
        "${oneadmin_home}/.one/one_auth" :
            mode => "0640",
            require => [File["${oneadmin_home}"],
            File["${oneadmin_home}/.one"]],
    }
}
class opennebula::node::common ($ensure = "present",
    $libvirtgroup = "kvm") {
    class {
        "opennebula::common" :
            ensure => $ensure
    }
    Line <<| tag == "opennebula::rsa_keys::head" |>>
    #    pam::access::allow {
    #        "oneadmin_from_vmmaster" :
    #            users => "oneadmin",
    #            origins => $VM_MASTER,
    #            require => User["oneadmin"],
    #    }

}
class opennebula::head ($ensure="present") inherits opennebula::common {
    package {
        ["opennebula"] :
        ensure => $ensure,
    }
    service {
        "libvirt-bin" :
            ensure => "stopped",
            enable => "false",
            #	   require => Package["libvirt-bin"],

    }
    service {
        "opennebula" :
            ensure => "running",
            enable => true,
            pattern => "oned",
            require => Package["opennebula"],
    }

    file {
        "/etc/init.d/sunstone-server" :
            source => "puppet:///modules/opennebula/sunstone-server.init",
            ensure => $ensure,
    }
    service {
        "sunstone-server" :
            ensure => $ensure ? {
                "present" => "running",
                default => "stopped",
            },
    }
#    @@line {
#        "oneadmin::rsa_pubkey" :
#            line =>
#            "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAlmSRkT7UTZgVpr5fRV2Q/24CNo+g6bTTyp0EDzCiPxs0u6DeKphjEw53y/zI/ZbWjGXAsqWx2ci2DUJacQEypp0Rxdx6+wxCp9cNUh+87ALlpdz2OrWyvFDj7oEkgSw9XlZpJjUfgTaa5gV/O59nmRegugaJkCkX2BWlgAJ9YZokOZmmHzyPmimoRqLhP8SW01r8+iWbraNSALn2c4NIsKIjgtWljJD6rXyD3Y7yDc41AYjtwUzjBSAnxFtJTwkZ2rPW8UZ+l2LeZjkt4buqtqcQ3cotYVqYJ24XxG4VTyrIXF5kZPRLrUB5eXa8+z9+AdiaD8ay2+js8/QW1NGDMQ== oneadmin@${hostname}",
#            file =>
#            "${opennebula::common::oneadmin_home}/.ssh/authorized_keys",
#            tag => "opennebula::rsa_keys::head",
#            require => [File["${opennebula::common::oneadmin_home}"],
#            File["${opennebula::common::oneadmin_home}/.ssh"]],
#    }
}
