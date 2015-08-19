define drupal::install (
  $version = '7.x',
  $host    = 'localhost',
  $aliases = []
) {

  # Install Drupal from git
  $docroot = "/var/www/${name}/web"
  file { "/var/www/${name}":
    ensure => directory,
    owner  => 'vagrant',
    group  => 'vagrant',
    mode   => '0755',
  }
  vcsrepo { $docroot:
    ensure   => present,
    provider => git,
    source   => 'git://git.drupal.org/project/drupal.git',
    revision => $version,
    require  => File["/var/www/${name}"],
  }

  # Configure Apache
  apache::vhost { $name:
    port              => '80',
    servername        => $host,
    serveraliases     => $aliases,
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
    require => Vcsrepo[$docroot],
  }
  
  # Configure MySQL
  mysql::db { $name:
    user     => 'drupal',
    password => 'drupal',
    host     => 'localhost',
    grant    => 'ALL',
  }

  # Drupal Cron job
  cron { "drupal-cron-${name}":
    command => "drush cron --root=${docroot} --uri=${host} --quiet",
    ensure  => present,
    user    => 'www-data',
    minute  => 0,
    require => Class['drupal::drush'],
  }

}
