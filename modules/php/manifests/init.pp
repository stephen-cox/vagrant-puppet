class php {

  package {
    [ 'php5', 'php5-cli', 'libapache2-mod-php5', 'php-pear' ]:
      ensure => 'present';
  }

}
