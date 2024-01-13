FROM ruby:3.3.0

ENV RUBYOPT -EUTF-8

RUN gem install cuba unicorn unicorn-worker-killer

COPY . .
CMD unicorn -c unicorn.rb

EXPOSE 3000
