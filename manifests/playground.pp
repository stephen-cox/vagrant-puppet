# Playground Puppet config

import "roles"

node default {

  class { 'init':
    stage => 'init',
  }

  class { 'base':
    stage => 'base',
  }

  # Install Apache
  class { 'apache':
    stage    => 'main',
    sendfile => 'Off',
  }

  # Link /var/www to /vagrant
  exec { 'rm -rf /var/www':
    onlyif  => ['test ! -L /var/www'],
    require => Package['apache2'],
    notify  => File['/var/www'],
  }
  file { '/var/www':
    ensure  => 'link',
    target  => '/vagrant',
    require => Exec['rm -rf /var/www'],
  }

}