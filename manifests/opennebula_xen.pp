# $Id: opennebula_xen.pp 3938 2010-12-16 12:34:54Z uwaechte $

class opennebula::node::xen::none {
  $presence = "absent"
    include opennebula::node::xen
}

class opennebula::node::xen inherits opennebula::node::common {
  $pres_real = $presence ? {
    "absent" => "absent",
      default => "present"
  }
  package{["xen-utils-4.0", "xen-qemu-dm-4.0",
      "xen-hypervisor-4.0-amd64", "xen-tools"
      ]:
      ensure => "${pres_real}",
  }
  sudoers{"sudo-oneadmin-xen::xm":
    hosts => "ALL",
	  users => "oneadmin",
	  commands => "(ALL) NOPASSWD: /usr/sbin/xm *",
  ensure => "${pres_real}",
  }
  sudoers{"sudo-oneadmin-xen::xentop":
    hosts => "ALL",
	  users => "oneadmin",
	  commands => "(ALL) NOPASSWD: /usr/sbin/xentop *",
      ensure => "${pres_real}",
  }
  
    kernel::module{["xen-netfront", 
            "xen-evtchn", 
            "xen-blkfront", 
            "xen_acpi_memhotplug", 
            "xenfs"]: 
        ensure => "${pres_real}",
    }
}
