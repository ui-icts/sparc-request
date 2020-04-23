FROM ruby:2.5
LABEL maintainer="chris-ortman@uiowa.edu"

RUN apt-get update -qq && apt-get install -y --no-install-recommends nodejs yarn mariadb-client rsync

# throw errors if Gemfile has been modified since Gemfile.lock
RUN gem update bundler && bundle config --global frozen 1

RUN mkdir /app
WORKDIR /app
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
COPY package.json /app/package.json
COPY yarn.lock /app/yarn.lock
RUN bundle install --without test development deploy --jobs 2 --retry 5 --binstubs
COPY . /app
COPY config/epic.yml.example /app/config/epic.yml
COPY config/ldap.yml.example /app/config/ldap.yml
COPY config/database.yml.example /app/config/database.yml

RUN SECRET_KEY_BASE='b5b57bb7d19a59231f09d44bf72d9456bd9b45ca6ceaf770d0ef2a5e7d2997feb6a4fbe2e885616900f1afab9bf8a90c0cf2844b33f481b811c1c644e2ce06bd' RAILS_ENV=production bin/rake assets:precompile

RUN mkdir -p /var/www/html
VOLUME ["/var/www/html", "/app/public/system"]

EXPOSE 3000
ENTRYPOINT ["script/entrypoint.sh"]
CMD ["server"]
