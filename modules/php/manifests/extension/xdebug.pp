class php::extension::xdebug (
  $extension        = '/usr/lib/php5/20121212/xdebug.so',
  $default_enable   = 1,
  $idekey           = '',
  $remote_enable    = 1,
  $remote_autostart = 0,
  $remote_host      = '127.0.0.1',
  $remote_port      = 9000,
  $remote_handler   = 'dbgp',
  $profiler_enable  = 1
) {

  if ! defined(Package['php5-dev']) {
    package{ 'php5-dev':
      ensure => 'present',
    }
  }

  if $lsbdistcodename == 'trusty' {
    $php_conf_dir = '/etc/php5/apache2/conf.d'
  }
  else {
    $php_conf_dir = '/etc/php5/conf.d'
  }

  exec { 'install_xdebug':
    command => "pecl install -Z xdebug",
    unless  => "pecl info xdebug",
    require => Class['php'],
  }

  file { "${php_conf_dir}/xdebug.ini":
    content => template('php/xdebug.ini.erb'),
    ensure  => present,
    require => [ Package['php5'], Exec['install_xdebug'] ],
    notify  => Service['apache2'],
  }

  file { '/var/log/xdebug':
    ensure  => "directory",
    owner   => "www-data",
    group   => "adm",
    mode    => 755,
    require => File["${php_conf_dir}/xdebug.ini"],
  }

}