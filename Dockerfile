FROM ruby:3.3.6

RUN mkdir /app
WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .

ENTRYPOINT [ "ruby", "main.rb" ]