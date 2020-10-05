FROM ruby:2.7.2-slim-buster

ENV RUBYGEMS_EXPORTER USERS deanwilson

COPY ["Gemfile", "rubygems-exporter.rb", "/app/"]
WORKDIR /app

RUN bundle install --without=development

ENTRYPOINT ["./rubygems-exporter.rb"]
