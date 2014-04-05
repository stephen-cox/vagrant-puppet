define php::pecl {

  include apache
  include php

  exec { "install_${name}":
    command => "pecl install ${name}",
    unless  => "pecl info ${name}",
    require => Class['php'];
  }

  file { "/etc/php5/conf.d/${name}.ini":
    content => "extension = ${name}.so",
    ensure  => 'present',
    require => Exec["install_${name}"],
    notify => Service['apache2'];
  }
  
}

