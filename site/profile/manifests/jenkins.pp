class profile::jenkins {

  package {'jre':
    name   => 'java-1.8.0-openjdk.x86_64',
    ensure => installed,
  }

  class { '::jenkins':
    version      => '2.62-1.1',
    install_java => false,
    require      => Package['jre'],
  }

  File {
    ensure  => file,
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0755',
 }

  file { '/var/lib/jenkins/jenkins.install.UpgradeWizard.state':
    content => '2.62',
    require => Class['jenkins::package'],
    before  => Class['jenkins::service'],
  }

  file { ['/var/lib/jenkins/init.groovy.d/', '/var/lib/jenkins/secrets/']:
    ensure => directory,
    require => Class['jenkins::package'],
    before  => Class['jenkins::service'],
  }

  file { '/var/lib/jenkins/init.groovy.d/basic-security.groovy':
    source => 'puppet:///modules/profile/jenkins_install',
    require => Class['jenkins::package'],
    before  => Class['jenkins::service'],
  }

  file { '/var/lib/jenkins/secrets/slave-to-master-security-kill-switch':
    content => 'false',
    require => Class['jenkins'],
  }

  file_line { 'no_install_wizard':
    ensure  => 'present',
    path    => '/etc/sysconfig/jenkins',
    line    => 'JENKINS_JAVA_OPTIONS="-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false"',
    match   => 'JENKINS_JAVA_OPTIONS="-Djava.awt.headless=true"',
    replace => true,
    before  => Class['jenkins::service'],
    require => Class['jenkins::package'],
  }

  include ::git
}
