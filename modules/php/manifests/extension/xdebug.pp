class php::extension::xdebug (
  $extension        = '/usr/lib/php5/20090626/xdebug.so',
  $default_enable   = 1,
  $idekey           = '',
  $remote_enable    = 1,
  $remote_autostart = 0,
  $remote_host      = '127.0.0.1',
  $remote_port      = 9000,
  $remote_handler   = 'dbgp',
  $profiler_enable  = 1
) {

  exec { "install_xdebug":
    command => "pecl install xdebug",
    creates => $extension,
    require => Class['php'],
  }

  file { '/etc/php5/conf.d/xdebug.ini':
    content => template('php/xdebug.ini.erb'),
    ensure  => present,
    require => Package['php5'],
    notify  => Service['apache2'],
  }

  file { '/var/log/xdebug':
    ensure  => "directory",
    owner   => "www-data",
    group   => "adm",
    mode    => 755,
    require => File['/etc/php5/conf.d/xdebug.ini'],
  }

}