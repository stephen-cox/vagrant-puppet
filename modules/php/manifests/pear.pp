define php::pear (
  $package    = $title,
  $repository = 'pear.php.net',
  $version    = 'latest'
) {

  include php

  if $version != 'latest' {
    $pear_source = "$$repository/{package}-${version}"
  } else {
    $pear_source = "$repository/${package}"
  }

  if ! defined(Exec["add_repos_${repository}"]) { 
    exec { "add_repos_${repository}":
      command => "pear channel-discover ${repository}",
      creates => "/usr/share/php/.channels/${repository}.reg",
      require => Package['php-pear'];
    }
  }

  exec { "install_${title}":
    command   => "pear install --alldeps ${pear_source}",
    unless   => "pear list -a | grep \"${title}\"",
    logoutput => 'on_failure',
    require   => Package['php-pear'];
  }

}