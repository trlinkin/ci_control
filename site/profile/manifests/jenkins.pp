class profile::jenkins {

  class { '::java':
    version => '8',
  }

  class { '::jenkins':
    install_java => false
  }

  File {
    ensure  => file,
    owner   => 'jenkins',
    group   => 'jenkins',
    mode    => '0755',
    require => Class['jenkins::package'],
    before  => Class['jenkins::service'],
  }

  file { '/var/lib/jenkins/jenkins.install.UpgradeWizard.state':
    content => '2.0',
  }

  file { '/var/lib/jenkins/secrets/slave-to-master-security-kill-switch':
    content => 'false',
  }

  file { '/var/lib/jenkins/init.groovy.d/basic-security.groovy':
    source => 'puppet:///modules/profile/jenkins_install',
  }

  include ::git
}
