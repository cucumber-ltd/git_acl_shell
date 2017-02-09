FROM ruby:2.4.0
RUN apt-get update -qq && apt-get install -y build-essential
RUN mkdir /work
WORKDIR /work
ADD . /work
RUN bundle install
