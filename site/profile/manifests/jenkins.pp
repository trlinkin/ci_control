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

  ## The rtyler/jenkins module has not been full updated for Jenkins 2.0 yet. As such,
  ## we need to bypass the installation wizard. For the most part the jenkins module
  ## will do a good enough job, we just need to help it along.

  file_line { 'no_install_wizard':
    ensure  => 'present',
    path    => '/etc/sysconfig/jenkins',
    line    => 'JENKINS_JAVA_OPTIONS="-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false"',
    match   => 'JENKINS_JAVA_OPTIONS="-Djava.awt.headless=true"',
    replace => true,
    before  => Class['jenkins::service'],
    require => Class['jenkins::package'],
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

  ## Disable the agent -> master security warnings
  file { '/var/lib/jenkins/secrets/slave-to-master-security-kill-switch':
    content => 'false',
    notify  => Exec['reload jenkins jobs'],
  }

  ## Install desired plugins - the lazy way!
  $plugin_curl_calls = [
    '/usr/bin/curl -XPOST "http://admin:admin@localhost:8080/pluginManager/installNecessaryPlugins" -d "<install plugin=\'workflow-aggregator@current\'/>"',
    '/usr/bin/curl -XPOST "http://admin:admin@localhost:8080/pluginManager/installNecessaryPlugins" -d "<install plugin=\'puppet-enterprise-pipeline@current\'/>"'
  ]

  exec { $plugin_curl_calls:
    tries       => '3',
    try_sleep   => '5',
    refreshonly => true,
    subscribe   => Class['jenkins::package'],
  }

  ## Tell Jenkins to reload configuratios without restarting
  exec { 'reload jenkins jobs':
    command     => '/usr/bin/curl --retry-max-time 30 --retry 3 --retry-delay 5 -d "Submit=Yes" http://admin:admin@localhost:8080/reload',
    tries       => '3',
    try_sleep   => '5',
    refreshonly => true,
  }

  include ::git
}
