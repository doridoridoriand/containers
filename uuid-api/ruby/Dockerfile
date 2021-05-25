FROM ruby:2.6.3

ENV RUBYOPT -EUTF-8

RUN gem install cuba unicorn unicorn-worker-killer

COPY . .
CMD unicorn -c unicorn.rb

EXPOSE 3000
