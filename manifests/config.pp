# == Class: grafyaml::config
#
# This class is used to manage arbitrary grafyaml configurations.
#
# === Parameters
#
# [*grafyaml_config*]
#   (optional) Allow configuration of arbitrary grafyaml configurations.
#   The value is an hash of grafyaml_config resources. Example:
#   { 'DEFAULT/foo' => { value => 'fooValue'},
#     'DEFAULT/bar' => { value => 'barValue'}
#   }
#   In yaml format, Example:
#   grafyaml_config:
#     DEFAULT/foo:
#       value: fooValue
#     DEFAULT/bar:
#       value: barValue
#
#   NOTE: The configuration MUST NOT be already handled by this module
#   or Puppet catalog compilation will fail with duplicate resources.
#
class grafyaml::config (
  $grafyaml_config = {},
) {

  validate_hash($grafyaml_config)

  create_resources('grafyaml_config', $grafyaml_config)
}
