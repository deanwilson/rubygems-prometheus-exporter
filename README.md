# rubygems-prometheus-exporter
RubyGems Prometheus Pushgateway Exporter - Fetch and export user and gem details

## Introduction

A RubyGems Prometheus Pushgateway Exporter for fetching details about your
[RubyGems](https://rubygems.org/) account and gems and pushing them to
a Prometheus Pushgateway.

This is implemented as a push gateway client rather than a standard
exporter to be a good API client and reduce the traffic against the
RubyGems service. In most cases you won't need to collect metrics more
than once a day, possibly with an extra run once you've pushed a new
gem or release.

## Usage

### Command line

    rubygems-exporter.rb deanwilson

TODO: Add image.

### Docker image

To run `rubygems-exporter.rb` with docker, using all the default values including
only checking my RubyGems user name:

    docker run --net host --rm deanwilson/rubygems-prometheus-exporter:latest

The minumum configuration you will probably need is to change
`RUBYGEMS_EXPORTER_USERS` to point at your own user. This can be done
by rebuilding the docker images, specifying the `--users` flag or passing
a custom `RUBYGEMS_EXPORTER_USERS` environment variable.

    docker run --net host --env RUBYGEMS_EXPORTER_USERS=otheruser --rm deanwilson/rubygems-prometheus-exporter:latest

    docker run --net host --rm deanwilson/rubygems-prometheus-exporter:latest --users otheruser

The Configuration section contains more information on which settings you can change.

## Configuration

### Pushgateway

You can configure which remote pushgateway to send metrics to via
commandline switches or environment variables. If both are specified the
switches take precedence.

Environment variables:

    export RUBYGEMS_EXPORTER_HOST=http://10.10.100.100
    export RUBYGEMS_EXPORTER_PORT=99999
    rubygems-exporter.rb deanwilson

Or using the switches:

    rubygems-exporter.rb deanwilson --host http://10.10.100.100 --port 99999

### Users

You can specify which RubyGems users to query in three different ways

    RUBYGEMS_EXPORTER_USERS=deanwilson
    rubygems-exporter.rb

Is overridden by

    rubygems-exporter.rb deanwilson

which are both overridden by

    rubygems-exporter.rb --users deanwilson

In the first and last case you can specify multiple users as comma seperated strings.

    export RUBYGEMS_EXPORTER_USERS=deanwilson,notdeanwilson
    rubygems-exporter.rb --users deanwilson,notdeanwilson
    rubygems-exporter.rb deanwilson notdeanwilson # no comma

## Author

 * [Dean Wilson](https://www.unixdaemon.net)
