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

  exec { "install_apc":
    command => "printf \"\\n\" | pecl install apc",
    unless  => "pecl info apc",
    require => [ Package['libpcre3-dev'], Class['php'] ],
  }

  file { '/etc/php5/conf.d/apc.ini':
    content => template('php/apc.ini.erb'),
    ensure  => present,
    require => Package['php5'],
    notify  => Service['apache2'],
  }

}