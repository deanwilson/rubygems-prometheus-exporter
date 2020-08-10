#!/usr/bin/env ruby
# this require fixes
# uninitialized constant Prometheus::Client::Push::CGI (NameError) errors
require 'cgi'
require 'gems'
require 'ostruct'
require 'optparse'
require 'prometheus/client'
require 'prometheus/client/push'

APP_NAME = File.basename $PROGRAM_NAME

options = OpenStruct.new({})

options.instance = ENV['RUBYGEMS_EXPORTER_INSTANCE'] || ''
options.gateway_port = ENV['RUBYGEMS_EXPORTER_PORT'] || 9091
options.gateway_host = ENV['RUBYGEMS_EXPORTER_HOST'] || 'http://127.0.0.1'

# username precedence - take the values from the env var, override them
# with any raw command line args and then possibly with the cli switch
# in OptionParser
options.user_names = ENV['RUBYGEMS_EXPORTER_USERS'] ? ENV['RUBYGEMS_EXPORTER_USERS'].split(',') : []
options.user_names = ARGV.sort.uniq unless ARGV.empty?

OptionParser.new do |opts|
  opts.banner = <<-ENDOFUSAGE
    #{APP_NAME} queries the given users RubyGems account and sends metrics to a prometheus pushgateway
      $ #{APP_NAME} deanwilson
      ...
      TODO
      ...
  ENDOFUSAGE

  opts.on('--host HOST',
          'The pushgateway host. Defaults to http://127.0.0.1',
          '') { |host| options.gateway_host = host }

  opts.on('--instance INSTANCE',
          'The pushgateway instance label. Defaults to \'\'',
          '') { |instance| options.instance = instance }

  opts.on('--port PORT',
          'The pushgateway port. Defaults to 9091',
          '') { |port| options.gateway_port = port.to_i }

  opts.on('--users USERS',
          'The rubygems usernames. comma separated - deanwilson,notdeanwilson',
          '') { |users| options.user_names = users.split(',') }

  opts.on_tail('-h', '--help', 'Show this message') do
    puts opts
    exit
  end
end.parse!

registry = Prometheus::Client.registry

total_gems = Prometheus::Client::Gauge.new(
  :rubygems_user_gems,
  docstring: 'The number of RubyGems gems owned by this user.',
  labels: [:name]
)
registry.register(total_gems)

options.user_names.each do |user_name|
  gems = Gems.gems(user_name)

  total_gems.set(gems.length, labels: { name: user_name })
end

gateway_address = "#{options.gateway_host}:#{options.gateway_port}"

Prometheus::Client::Push.new('rubygems-exporter', options.instance, gateway_address).add(registry)
