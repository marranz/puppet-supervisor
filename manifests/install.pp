# Class: supervisor
#
# Usage:
#   include supervisor
#
#   class { 'supervisor':
#     version                 => '3.1.3',
#     include_superlance      => false,
#     enable_http_inet_server => true,
#   }

class supervisor::init (
  $version                  = '3.1.3',
  $include_superlance       = true,
  $enable_http_inet_server  = false,
  $service_enabled = false,
  $service_ensure = 'stopped'
) {
  file{'/testfile':}
  case $::osfamily {
    redhat: {
        $pkg_setuptools = 'python-pip'
        $path_config    = '/etc'
    }
    default: { fail("ERROR: ${::osfamily} based systems are not supported!") }
  }

  package { $pkg_setuptools: ensure => installed, }

  package { 'supervisor':
    ensure   => $version,
    provider => 'pip'
  }


  file { '/var/log/supervisor':
    ensure  => directory,
    purge   => true,
    backup  => false,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Package['supervisor'],
  }

  file { "${path_config}/supervisord.conf":
    ensure  => file,
    content => template('supervisor/supervisord.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['supervisor'],
    notify  => Service['supervisord'],
  }

  file { "${path_config}/supervisord.d":
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => File["${path_config}/supervisord.conf"],
  }

  service { 'supervisord':
    ensure     => $service_ensure,
    enable     => $service_enabled,
    hasrestart => true,
    require    => File["${path_config}/supervisord.conf"],
  }

  if $include_superlance {
    package { 'superlance':
      ensure   => installed,
      provider => 'pip',
      require  => Package['supervisor'],
    }
  }

}
