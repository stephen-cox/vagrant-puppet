class php::extension::apc (
  $testing      = false,
  $extension    = 'apc.so',
  $enabled      = 1,
  $shm_size     = '64M',
  $shm_segments = 1,
  $stat         = 0,
  $ttl          = 0
) {

  package { 'libpcre3-dev':
    ensure => present;
  }

  if $lsbdistcodename == 'trusty' {
    $php_conf_dir = '/etc/php5/apache2/conf.d'
  }
  else {
    $php_conf_dir = '/etc/php5/conf.d'
  }

  exec { "install_apc":
    command => "printf \"\\n\" | pecl install apc",
    unless  => "pecl info apc",
    require => [ Package['libpcre3-dev'], Class['php'] ],
  }

  file { "${php_conf_dir}/apc.ini":
    content => template('php/apc.ini.erb'),
    ensure  => present,
    require => Package['php5'],
    notify  => Service['apache2'],
  }

}