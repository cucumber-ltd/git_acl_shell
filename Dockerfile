FROM ruby:2.4.1-alpine
RUN apk add --no-cache --update --upgrade bash git build-base
RUN mkdir /work
WORKDIR /work
ADD . /work
RUN bundle install
