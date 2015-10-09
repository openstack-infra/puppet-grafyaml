# == Class: grafyaml
#
# Full description of class grafyaml here.
#
# === Parameters
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#
class grafyaml (
  $config_dir = '',
  $git_revision = 'master',
  $git_source = 'https://git.openstack.org/openstack-infra/grafyaml',
  $grafana_url = 'http://localhost:8080',
) {
  include ::pip

  vcsrepo { '/opt/grafyaml':
    ensure   => latest,
    provider => git,
    revision => $git_revision,
    source   => $git_source,
  }

  exec { 'install_grafyaml':
    command     => 'pip install /opt/grafyaml',
    path        => '/usr/local/bin:/usr/bin:/bin/',
    refreshonly => true,
    subscribe   => Vcsrepo['/opt/grafyaml'],
  }

  file { '/etc/grafyaml':
    ensure => directory,
  }

  file { '/etc/grafyaml/config':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    recurse => true,
    purge   => true,
    force   => true,
    source  => $config_dir,
    require => File['/etc/grafyaml'],
    notify  => Exec['grafana_dashboard_update'],
  }

  file { '/etc/grafyaml/grafyaml.conf':
    ensure  => present,
    content => template('grafyaml/grafyaml.conf.erb'),
    mode    => '0400',
    require => File['/etc/grafyaml'],
  }

  exec { 'grafana_dashboard_update':
    command     => 'grafana-dashboard --config-file /etc/grafyaml/grafyaml.conf update /etc/grafyaml/config',
    path        => '/bin:/usr/bin:/usr/local/bin',
    refreshonly => true,
    require     => [
      Exec['install_grafyaml'],
    ],
  }
}
