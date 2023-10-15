FROM ruby:3.2

RUN mkdir -p /var/www/boreas
WORKDIR /var/www/boreas

ENV RAILS_ENV production

# we don't set cookies so this is actually not relevant
ENV SECRET_KEY_BASE changeme

COPY . /var/www/boreas

RUN bundle config set --local deployment true
RUN bundle config set --local without 'development test'
RUN bundle install

EXPOSE 3000
CMD ["bin/rails", "server", "-b", "0.0.0.0", "-p", "3000"]