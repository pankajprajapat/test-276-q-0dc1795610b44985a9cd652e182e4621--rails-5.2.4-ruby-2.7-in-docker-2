FROM ruby:2.7

USER root

RUN apt-get update && apt-get install --assume-yes wget

# Pre Build Commands
RUN wget https://codejudge-starter-repo-artifacts.s3.ap-south-1.amazonaws.com/backend-project/ruby/pre-build.sh
RUN chmod 775 ./pre-build.sh
RUN sh pre-build.sh

RUN wget https://codejudge-starter-repo-artifacts.s3.ap-south-1.amazonaws.com/backend-project/database/db-setup.sh
RUN chmod 775 ./db-setup.sh
RUN sh db-setup.sh

RUN mkdir /myapp
WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
RUN bundle install
COPY . /myapp

RUN wget https://codejudge-starter-repo-artifacts.s3.ap-south-1.amazonaws.com/backend-project/rails/run.sh
RUN chmod 775 ./run.sh
CMD sh run.sh
