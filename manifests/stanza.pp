# == Define: beaver::stanza
#
# This define is responsible for adding stanzas to the beaver config
#
#
# === Parameters
# [*type*]
#   String.  Type to be passed on to logstash
#
# [*source*]
#   String.  Source logfile to be read
#
# [*tags*]
#   String/Array of strings.  What tags should be added to this stream and
#   passed back to logstash
#
# [*redis_url*]
#   String.  Redis connection url to use for this specific log stream
#
# [*redis_namespace*]
#   String.  Redis namespace to use for this specific log stream
#
# [*format*]
#   String.  What format is the source logfile in.
#   Valid options: json, msgpack, raw, rawjson, string
#   Default (unset): json
#
# [*sincedb_write_interval*]
#   Integer.  Number of seconds between sincedb write updates
#   Default: 3
#
# [*exlcude*]
#   String/Array of strings.  Valid python regex strings to exlude
#   from file globs.
#
# [*multiline_regex_before*]
#   String.
#
# [*multiline_regex_after*]
#   String.
#
# [*add_fields*]
#   Hash.
#
# === Authors
#
# * Justin Lambert <mailto:jlambert@letsevenup.com>
#
#
# === Copyright
#
# Copyright 2013 EvenUp.
#
define beaver::stanza (
  $type,
  $source                 = '',
  $tags                   = [],
  $redis_url              = '',
  $redis_namespace        = '',
  $format                 = '',
  $exclude                = [],
  $sincedb_write_interval = 300,
  $multiline_regex_before = '',
  $multiline_regex_after  = '',
  $add_field              = '',
){

  $source_real = $source ? {
    ''      => $name,
    default => $source,
  }

  validate_string($type, $source, $source_real)
  if type($sincedb_write_interval) != 'integer' { fail('sincedb_write_interval is not an integer') }

  if ($add_field  != '') {
    validate_hash($add_fields)
    $arr_add_fields = inline_template('<%= add_fields.sort.collect { |k,v| "\"#{k}\", \"#{v}\"" }.join(",") %>')
  } else {
    $arr_add_fields = ''
  }

  include beaver
  Class['beaver::package'] ->
  Beaver::Stanza[$name] ~>
  Class['beaver::service']

  $filename = regsubst($name, '[/:\n]', '_', 'GM')
  file { "/etc/beaver/conf.d/${filename}":
    content => template("${module_name}/beaver.stanza.erb"),
    notify  => Class['beaver::service'],
  }

}
