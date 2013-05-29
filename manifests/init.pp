# == Class: motd
#
# Sets motd
#
# === Parameters
#
# [ssh_port]
#   Sets the SSH port that the server should listen on
#   Defaults to 22
#
# === Variables
#
# none
#
# === Examples
#
# include motd
#
# === Authors
#
# George Ornbo <george@shapeshed.com>
#
# === Copyright
#
# Copyright 2012 George Ornbo, unless otherwise noted.
#
class iptables($ssh_port = 22) {

  package { "iptables":
	 ensure => installed
  }

  file { "/root/bin":
    ensure => directory,
    recurse => true,
    owner => "root",
    group => "root",
    mode => 0644
  }

  file { "/root/bin/firewall.sh" :
	  ensure => present,
	  recurse => true,
    mode => 0644,
	  owner => "root",
	  group => "root",
    content => template("iptables/firewall.sh.erb")
  }

  exec { "run firewall":
    command => "/bin/bash /root/bin/firewall.sh",
	  subscribe => File["/root/bin/firewall.sh"],
	  refreshonly => true
  }

  exec { "save rules":
    path    => '/bin:/usr/bin:/usr/sbin:/sbin',
    subscribe => File["/root/bin/firewall.sh"],
    refreshonly => true
    command => "iptables-save > /etc/iptables.rules",
  }

  exec { "add pre-up":
    path    => '/bin:/usr/bin:/usr/sbin:/sbin',
    subscribe => File["/root/bin/firewall.sh"],
    refreshonly => true
    command => "echo 'pre-up iptables-restore /etc/iptables.rules' >> /etc/network/interfaces",
  }

}
