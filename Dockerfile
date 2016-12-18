FROM ruby:2.3

RUN apt-get update -qq && apt-get install -y build-essential

RUN mkdir /app
WORKDIR /app

ADD .ruby-version /app
RUN curl -sSL https://rvm.io/mpapis.asc | gpg --import -
RUN \curl -L https://get.rvm.io | bash -s stable
RUN /bin/bash -l -c "rvm requirements && rvm install $(cat /app/.ruby-version) && gem install bundler --no-ri --no-rdoc && rvm use $(cat /app/.ruby-version)"

ADD Gemfile* $APP_HOME/
RUN bundle install

ADD . /app
