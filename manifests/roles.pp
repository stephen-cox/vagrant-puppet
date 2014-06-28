# Define installation stages and roles

import "defines"

# Pre-installation configuration
class init {
  class { 'apt': 
    schedule_update => true,
  }
}

# Install base system
class base {
  install { [ 'build-essential', 'curl', 'git', 'subversion', 'unzip' ]: }
}

# LAMP server installation
class lamp {
  
  # Install Apache
  class { 'apache':
    default_vhost       => false,
    default_mods        => false,
    default_confd_files => false,
    mpm_module          => 'prefork',
    server_tokens       => 'Prod',
    server_signature    => 'Off',
    sendfile            => 'Off',
  }
  apache::mod { [ 'headers', 'rewrite', 'unique_id' ]: }
  
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
  
  # Install MySQL
  class { 'mysql::server':
    root_password    => 'vagrant',
    override_options => {
      'mysqld' => { 'bind_address' => '*' }
    },
    users => {
      'root@%' => {
        ensure        => 'present',
        password_hash => mysql_password('vagrant')
      }
    },
    grants => {
      'root@%/*.*' => {
        ensure     => 'present',
        privileges => ['ALL'],
        table      => '*.*',
        user       => 'root@%',
      }
    },
  }
  
  # Install PHP
  class { 'php': }
  php::ini { '/etc/php5/apache2/php.ini':
    display_errors => 'On',
    expose_php     => 'Off',
    memory_limit   => '256M',

  }
  php::extension { 'mysql': }
  class { 'apache::mod::php': }
  
  # Install email
  class { 'exim': }

}

# Post-installation configuration
class cleanup {
    
}

# Stages
stage { 'init': }
stage { 'base': }
stage { 'post': }
Stage['init'] -> Stage['base'] -> Stage['main'] -> Stage['post']

# Load classes in stages
class lamp_server {
  class { 'init':
    stage => 'init',
  }
  class { 'base':
    stage => 'base',
  }
  class { 'lamp':
    stage => 'main',
  }
  class { 'cleanup':
    stage =>'post',
  }
}
