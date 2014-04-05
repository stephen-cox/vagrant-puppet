# Defines and defaults used in node and role definitions

File { 
  ensure => "present",
  owner  => "root",
  group  => "root",
  mode   => 644,
}

Exec { 
  path => "/usr/bin:/usr/sbin/:/bin:/sbin" 
}

# Disable a service
define no_service ( ) {
  service {
    "${name}":
      ensure => stopped,
      enable => false,
      status => "stat -t /etc/rc?.d/S??${name} > /dev/null 2>&1",
  }
}

# Install a package
define install ( ) {
  package {
    "${name}":
      ensure => present;
   }
}

# Remove a package
define remove ( ) {
  package {
    "${name}":
      ensure => absent;
  }
}
