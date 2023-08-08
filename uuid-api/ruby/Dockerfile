FROM ruby:2.7.8

ENV RUBYOPT -EUTF-8

RUN gem install cuba unicorn unicorn-worker-killer

COPY . .
CMD unicorn -c unicorn.rb

EXPOSE 3000
