# $Id: init.pp 4784 2011-11-13 16:36:18Z uwaechte $
import "opennebula_xen.pp"
import "opennebula_kvm.pp"

class opennebula::common {
  $oneadmin_home = "/var/lib/one"
    user{"oneadmin":
      uid => 112,
	  gid => 65534,
	  managehome => true,
	  home => "${oneadmin_home}",
	  shell => "/bin/bash",
    }
  File{
    owner => "oneadmin",
	  group => "oneadmin"
  }
  group{"oneadmin":
    gid => 999,
  }
  file{"${oneadmin_home}/.ssh":
    ensure => "directory",
	   require => File["${oneadmin_home}"]
  }
  file{[ "${oneadmin_home}", "${oneadmin_home}/.one" ]:
    ensure => "directory",
	   mode => 0750,
#recurse => true,
	   require => [ User["oneadmin"], Group["oneadmin"] ],
  }
  file{"${oneadmin_home}/.one/one_auth":
    mode => "0640",
	 require =>  [ File["${oneadmin_home}"], File["${oneadmin_home}/.one"] ],
  }
}



class opennebula::node::common inherits opennebula::common {
  $libvirtgroup = "kvm"
#  package{"opennebula-node":
#    require => [ Class["opennebula::common"], User["oneadmin"] ],
#  }
## import rsa keys from master
  Line <<| tag == "opennebula::rsa_keys::head" |>>
    pam::access::allow{"oneadmin_from_vmmaster":
      users => "oneadmin",
	    origins => "vmmaster.ikw.uni-osnabrueck.de",
	    require => User["oneadmin"],
    }

}

class opennebula::head inherits opennebula::common{
  package{["opennebula"]: }
  service{"libvirt-bin":
    ensure => "stopped",
	   enable => "false",
#	   require => Package["libvirt-bin"],
  } 
  service{"opennebula":
    ensure => "running",
	   enable => true,
	   pattern => "oned",
	   require => Package["opennebula"],
  }
  @@line{"oneadmin::rsa_pubkey":
    line => "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAlmSRkT7UTZgVpr5fRV2Q/24CNo+g6bTTyp0EDzCiPxs0u6DeKphjEw53y/zI/ZbWjGXAsqWx2ci2DUJacQEypp0Rxdx6+wxCp9cNUh+87ALlpdz2OrWyvFDj7oEkgSw9XlZpJjUfgTaa5gV/O59nmRegugaJkCkX2BWlgAJ9YZokOZmmHzyPmimoRqLhP8SW01r8+iWbraNSALn2c4NIsKIjgtWljJD6rXyD3Y7yDc41AYjtwUzjBSAnxFtJTwkZ2rPW8UZ+l2LeZjkt4buqtqcQ3cotYVqYJ24XxG4VTyrIXF5kZPRLrUB5eXa8+z9+AdiaD8ay2+js8/QW1NGDMQ== oneadmin@${hostname}",
	 file => "${opennebula::common::oneadmin_home}/.ssh/authorized_keys",
	 tag => "opennebula::rsa_keys::head",
	 require => [ File["${opennebula::common::oneadmin_home}"], File["${opennebula::common::oneadmin_home}/.ssh"] ],
  }
#  file{"/usr/lib/one/remotes/vmm/kvm/kvmrc":
#    source => "puppet:///modules/opennebula/usr_lib_one_remotes_vmm_kvm_kvmrc",
#	   notify => Service["opennebula"],
#  }
}
