FROM ruby:3.4.2

RUN mkdir /app
WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .

ENTRYPOINT [ "ruby", "main.rb" ]