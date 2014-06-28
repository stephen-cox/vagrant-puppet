class drupal::drush (
  $git_branch = 'master',
  $git_repo = 'https://github.com/drush-ops/drush.git'
) {

  if ! defined(Package['git']) {
    package { 'git':
      ensure => present,
      before => Vcsrepo['/usr/share/drush'],
    }
  }

  # Install Drush from GitHub
  vcsrepo { '/usr/share/drush':
    ensure   => present,
    provider => git,
    source   => $git_repo,
    revision => $git_branch,
    user     => 'root',
    require  => Class['PHP::composer'],
    notify   => Exec['composer_drush_install'],
  }

  # Symlink Drush
  file { 'symlink_drush':
    ensure  => link,
    path    => '/usr/bin/drush',
    target  => '/usr/share/drush/drush',
    require => Vcsrepo['/usr/share/drush'],
  }

  # Complete Drush install
  exec { 'composer_drush_install':
    command     => '/usr/local/bin/composer install',
    environment => [ "COMPOSER_HOME=/usr/share/drush" ],
    cwd         => '/usr/share/drush',
    refreshonly => true,
  }

}