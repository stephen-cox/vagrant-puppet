# Drupal 8 Puppet config

import "roles"

node default {

  include lamp_server

  class { 'drupal':
    version => 8,
  }

  drupal::install { 'drupal8':
    version => '8.0.x',
    host    => 'l.drupal8',
  }

  drupal::install { 'stephencox':
    version => '8.0.0-beta14',
    host    => 'l.stephencox',
  }

  class { 'php::extension::xdebug':
    idekey      => 'PHPSTORM',
    remote_host => '192.168.50.5',
  }

}