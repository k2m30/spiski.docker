FROM ruby:2.7-alpine
RUN apk add --no-cache alpine-sdk \
    mysql-dev

WORKDIR /app
COPY Gemfile* /app/
RUN bundle install

COPY Rakefile /app/
COPY *.rb /app/
RUN mkdir logs
CMD ["rake", "test"]
