class profile::base {

  service { 'firewalld':
    ensure => stopped,
    enable => false,
  }

  class { 'ntp':
      servers => [ '1.ca.pool.ntp.org', '2.ca.pool.ntp.org' ],
  }
}
