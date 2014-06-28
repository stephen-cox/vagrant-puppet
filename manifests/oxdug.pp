# OxDUG Drupal 8 config

import "roles"

node default {

  $docroot = '/var/www/web'

  include lamp_server
    
  # Configure Apache
  apache::vhost { 'localhost':
    port              => '80',
    docroot           => $docroot,
    docroot_owner     => 'vagrant',
    docroot_group     => 'vagrant',
    serveradmin       => 'webmaster@example.com',
    options           => [ '-Indexes', 'FollowSymLinks' ],
    error_log_file    => 'error.log',
    log_level         => 'warn',
    access_log_file   => 'access.log',
    access_log_format => 'combined',
    directories       => [
      { path           => $docroot,
        allow_override => 'All',
        rewrites       => [
          { rewrite_base => '/',
            rewrite_cond => '%{REQUEST_FILENAME} !-f',
            rewrite_cond => '%{REQUEST_FILENAME} !-d',
            rewrite_rule => '^(.*)$ index.php?q=$1 [L,QSA]'
          }
        ]
      }
    ],
  }
  
  # Configure MySQL
  mysql::db { 'oxdug':
    user     => 'oxdug',
    password => 'FjiwefEFe93fer',
    host     => 'localhost',
    grant    => 'ALL',
  }

  # Configure Drupal 8
  class { 'drupal':
    version     => 8,
    drupal_root => $docroot,
  }

  # Install Xdebug
#  class { 'php::extension::xdebug':
#    idekey      => 'PHPSTORM',
#    remote_host => '_MY_IP_ADDRESS_',
#  }

}