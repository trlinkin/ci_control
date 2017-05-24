class profile::base {

  service { 'firewalld':
    ensure => stopped,
    enable => false,
  }
}
