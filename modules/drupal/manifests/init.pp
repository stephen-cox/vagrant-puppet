class drupal (
  $version = 7
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

}