# eventsapp Puppet config

import "roles"

node default {

  include lamp_server
    
  # Configure Apache
  apache::vhost { 'localhost':
    port              => '80',
    docroot           => '/var/www/drupal',
    docroot_owner     => 'vagrant',
    docroot_group     => 'vagrant',
    serveradmin       => 'webmaster@src-dev.com',
    options           => [ '-Indexes', 'FollowSymLinks' ],
    error_log_file    => 'error.log',
    log_level         => 'warn',
    access_log_file   => 'access.log',
    access_log_format => 'combined',
    directories       => [
      { path           => '/var/www/drupal',
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
  mysql::db { 'eventsapp':
    user     => 'eventsapp',
    password => 'Njk2YjczMWU0OTAw',
    host     => 'localhost',
    grant    => 'ALL',
    sql      => '/vagrant/eventsapp.sql',
  }

  # Configure Drupal 7
  class { 'drupal7':
    drupal_root => '/var/www/drupal',
  }

  # Install Xdebug
  class { 'php::extension::xdebug':
    idekey      => 'PHPSTORM',
    remote_host => '192.168.0.57',
  }
}
