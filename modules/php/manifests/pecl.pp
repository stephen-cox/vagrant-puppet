define php::pecl {

  include apache
  include php

  if $lsbdistcodename == 'trusty' {
    $php_conf_dir = '/etc/php5/apache2/conf.d'
  }
  else {
    $php_conf_dir = '/etc/php5/conf.d'
  }

  exec { "install_${name}":
    command => "pecl install ${name}",
    unless  => "pecl info ${name}",
    require => Class['php'];
  }

  file { "${php_conf_dir}/${name}.ini":
    content => "extension = ${name}.so",
    ensure  => present,
    require => Exec["install_${name}"],
    notify => Service['apache2'];
  }
  
}

