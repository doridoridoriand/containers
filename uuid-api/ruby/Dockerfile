FROM ruby:latest

ENV RUBYOPT -EUTF-8

RUN gem install cuba unicorn unicorn-worker-killer

COPY . .

EXPOSE 3000

CMD unicorn -c unicorn.rb