# == Class: grafyaml
#
# Grafyaml takes simple descriptions of Grafana dashboards in YAML format, and
# uses them to configure Grafana.
#
# === Parameters
#
# [*config_dir*]
#
# [*git_revision*]
#
# [*git_source*]
#
# [*grafana_url*]
#
class grafyaml (
  $config_dir,
  $git_revision = 'master',
  $git_source = 'https://git.openstack.org/openstack-infra/grafyaml',
  $grafana_url = 'http://localhost:8080',
) {
  include ::pip

  git { '/opt/grafyaml':
    ensure => present,
    branch => $git_revision,
    latest => true,
    origin => $git_source,
  }

  exec { 'install_grafyaml':
    command     => 'pip install /opt/grafyaml',
    notify      => Exec['grafana_dashboard_update'],
    path        => '/usr/local/bin:/usr/bin:/bin/',
    refreshonly => true,
    subscribe   => Git['/opt/grafyaml'],
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
    logoutput   => true,
    path        => '/bin:/usr/bin:/usr/local/bin',
    refreshonly => true,
    require     => [
      Exec['install_grafyaml'],
    ],
  }
}
