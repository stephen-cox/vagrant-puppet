# Define installation stages and roles

import "defines"

# Pre-installation configuration
class init {
  class { 'apt': 
    schedule_update => false,
  }
}

# Install base system
class base {
  install { [ 'build-essential', 'subversion', 'unzip' ]: }
#  if ! defined(Package['git']) {
#    install { 'git': }
#  }
#  if ! defined(Package['curl']) {
#    install { 'curl': }
#  }
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

# Drupal 7 specific setup
class drupal7 (
  $drupal_root = '/var/www',
  $drupal_uri  = 'localhost'
) {
    
  # Required packages
  php::extension { [ 'curl', 'gd', 'mcrypt' ]: }
  php::pear { [ 'PEAR', 'Console_Table' ]: }
  php::pear { 'drush':
    repository => "pear.drush.org",
  }
  php::pecl { 'uploadprogress': }
  class { 'php::extension::apc': }
  
  # Drupal Cron job
  cron { 'drupal-cron':
    command => "drush cron --root=${drupal_root} --uri=${drupal_uri} --quiet",
    ensure  => present,
    user    => 'www-data',
    minute  => 0,
    require => Php::Pear['drush'],
  }
}

# Drupal 8 specific setup
class drupal8 (
  $drupal_root = '/var/www',
  $drupal_uri  = 'localhost'
) {

  # Required packages
  php::extension { [ 'curl', 'gd', 'mcrypt' ]: }

  # Install Composer
  exec { 'composer_install':
    command => 'curl -sS https://getcomposer.org/installer | php && sudo mv composer.phar /usr/local/bin/composer',
    creates => '/usr/local/bin/composer',
  }

  # Install Drush from GitHub
  class { 'drush::git::drush':
    git_branch => 'master',
    update     => false,
    require    => Exec['composer_install'],
    notify     => Exec['composer_drush_install'],
  }

  # Complete Drush install
  exec { 'composer_drush_install':
    command     => '/usr/local/bin/composer install',
    environment => [ "COMPOSER_HOME=/usr/share/drush" ],
    cwd         => '/usr/share/drush',
    refreshonly => true,
  }

  # Drupal Cron job
  cron { 'drupal-cron':
    command => "drush cron --root=${drupal_root} --uri=${drupal_uri} --quiet",
    ensure  => present,
    user    => 'www-data',
    minute  => 0,
    require => Class['drush::git::drush'],
  }
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
