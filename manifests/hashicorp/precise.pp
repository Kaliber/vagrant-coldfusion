group { "puppet":
	ensure => "present",
}

File { owner => 0, group => 0, mode => 0644 }

Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

exec { 'apt-get update':
  command => 'apt-get update',
}

class { 'apt':
 always_apt_update => true,
}

apt::ppa { 'ppa:chris-lea/node.js':}

# We single nodejs out to be able to specify 
# the relationship to Apt::Ppa properly
package { 'nodejs':
  ensure => 'installed'
}

Apt::Ppa['ppa:chris-lea/node.js'] ->
Package['nodejs']

package { ['bower', 'grunt-cli']:
  ensure => present,
  provider => 'npm',
  require => Package["nodejs"],
}

package { ["wget", "nmap"]:
  ensure => "installed",
  require => Exec['apt-get update']
}

package { "apache2":
  ensure => "installed",
  require => Exec['apt-get update']
}

service { 'apache2':
  ensure => running,
  require => Package['apache2']
}

package { "postfix":
    ensure => "installed",
    require => Exec['apt-get update']
}

package { "postfix-pcre":
    ensure => "installed",
    require => Package["postfix"]
}

package { "dovecot-postfix":
    ensure => "installed",
    require => Package["postfix-pcre"]
}

package { "squirrelmail":
    ensure => "installed",
    require => Package["apache2", "dovecot-postfix"]
}

package { "openjdk-7-jdk":
    ensure => "installed",
    require => Exec['apt-get update']
}

package { "daemon":
  ensure => "installed",
  require => Exec['apt-get update']
}

exec { "uptime":
    command => "uptime",
}

