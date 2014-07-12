class drupal (
  $version = 7,
  $drupal_root = '/var/www',
  $drupal_uri  = 'localhost'
) {

  if $version == 7 {

  }
  elsif $version == 8 {

  }
  else {
    err("This Drupal module only supports versions 7 and 8")
  }

  # Required packages by both versions
  php::extension { [ 'curl', 'gd', 'mcrypt' ]: }
  class { 'php::composer': }

  # Install Drush
  class { 'drupal::drush': }

  # Drupal Cron job
  cron { 'drupal-cron':
    command => "drush cron --root=${drupal_root} --uri=${drupal_uri} --quiet",
    ensure  => present,
    user    => 'www-data',
    minute  => 0,
    require => Class['drupal::drush'],
  }

}