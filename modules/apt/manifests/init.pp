class apt (
  $schedule_update = false,
  $sleep           = 10
) {

  file { '/etc/apt/sources.list':
      source => 'puppet:///modules/apt/sources.list',
      notify => Exec['apt-get update'],
  }

  exec { 'apt-get update':
      onlyif    => '/bin/sh -c \'[ ! -f /var/cache/apt/pkgcache.bin ] || /usr/bin/find /etc/apt/* -cnewer /var/cache/apt/pkgcache.bin | /bin/grep . > /dev/null\'',
      logoutput => 'on_failure',
      require   => File['/etc/apt/sources.list'],
  }
  
  if ($schedule_update) {
    exec { 'apt-get dist-upgrade':
      command => "echo \"/usr/bin/apt-get -y dist-upgrade\" | at now + ${sleep} minute",
      user    => 'root',
      require => File['/etc/apt/sources.list'],
    }
  }
   
}
