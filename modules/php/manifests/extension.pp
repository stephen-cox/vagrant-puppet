define php::extension {

  include apache

  package { "php5-${name}":
    ensure => present,
    notify => Service['apache2'];
  }
}