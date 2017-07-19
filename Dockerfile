FROM ruby:2.3

RUN apt-get update -qq && apt-get install -y build-essential

RUN mkdir /app
WORKDIR /app

ADD Gemfile* $APP_HOME/
RUN bundle install

ADD . /app

CMD ["rackup", "-p", "4567"]
