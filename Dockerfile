# Stages
#
# debian:stable-slim
# -> base
#   -> assets-builder
#   -> final with COPY assets-builder/public/assets

# Create a production image for Chouette
#
# Usage (minimalist) :
# docker build --build-arg WEEK=`date +%Y%U` -t chouette-core .
# docker run --add-host "db:172.17.0.1" -e RAILS_DB_PASSWORD=chouette -p 3000:3000 -it chouette-core

FROM ruby:2.6.4-slim-stretch as base

# To force rebuild every week
ARG WEEK

# Configure locales
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8
ENV BUNDLER_VERSION 2.1.4

RUN apt-get update && apt-get dist-upgrade -y && apt-get install -y --no-install-recommends locales && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen && \
    gem install bundler:$BUNDLER_VERSION && \
    apt-get clean && apt-get -y autoremove && rm -rf /var/lib/apt/lists/*

ENV DEV_PACKAGES="build-essential libpq-dev libxml2-dev zlib1g-dev libmagic-dev libmagickwand-dev git-core"
ENV RUN_PACKAGES="libpq5 libxml2 zlib1g libmagic1 imagemagick libproj-dev libgeos-c1v5 postgresql-client-common postgresql-client-9.6 cron"

# Install bundler packages
COPY Gemfile Gemfile.lock /app/
RUN apt-get update && mkdir -p /usr/share/man/man1 /usr/share/man/man7 && \
    apt-get -y install --no-install-recommends $DEV_PACKAGES $RUN_PACKAGES && \
    cd /app && bundle install --deployment --jobs 4 --without development test && \
    apt-get -y remove $DEV_PACKAGES && \
    rm -rf /usr/share/man/ && \
    rm -rf vendor/bundle/ruby/$RUBY_MAJOR.0/cache vendor/bundle/ruby/$RUBY_MAJOR.0/bundler/gems/*/.git && \
    apt-get clean && apt-get -y autoremove && rm -rf /var/lib/apt/lists/*

FROM base as assets-builder

# Prepare nodejs 6.x and yarn package installation
RUN apt-get update && apt-get install -y --no-install-recommends curl gnupg ca-certificates apt-transport-https && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list && \
    curl -sS https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
    echo "deb https://deb.nodesource.com/node_8.x stretch main" > /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && apt-get install -y --no-install-recommends yarn nodejs

# Install yarn packages
COPY package.json yarn.lock /app/
RUN cd /app && yarn --frozen-lockfile install

# Install application file
COPY . /app/

# Override database.yml and secrets.yml files
COPY config/database.yml.docker app/config/database.yml
COPY config/secrets.yml.docker app/config/secrets.yml

RUN if [ ! -f /app/config/environments/production.rb ]; then echo "creating production env file from sample" && cp /app/config/environments/production.rb.sample /app/config/environments/production.rb; fi

# Run assets:precompile (with nulldb)
RUN cd /app && bundle exec rake ci:fix_webpacker assets:precompile i18n:js:export RAILS_DB_ADAPTER=nulldb RAILS_DB_PASSWORD=none RAILS_ENV=production

FROM base as final

# Install application file
COPY . /app/

RUN if [ ! -f /app/config/environments/production.rb ]; then echo "creating production env file from sample" && cp /app/config/environments/production.rb.sample /app/config/environments/production.rb; fi

# Override database.yml and secrets.yml files
COPY config/database.yml.docker app/config/database.yml
COPY config/secrets.yml.docker app/config/secrets.yml

# Run whenever to define crontab
# Create version.json file if VERSION is available
ARG VERSION
COPY --from=assets-builder /app/public/assets/ /app/public/assets/
COPY --from=assets-builder /app/public/packs/ /app/public/packs/

RUN cd /app && \
    RAILS_ENV=production bundle exec whenever --output '/proc/1/fd/1' --update-crontab chouette --set 'environment=production&bundle_command=bundle exec' --roles=app,db,web && \
    ([ -n "$VERSION" ] && echo "{\"build_name\": \"$VERSION\"}" > config/version.json) || true

WORKDIR /app
VOLUME /app/public/uploads

EXPOSE 3000
ENV RAILS_ENV=production RAILS_SERVE_STATIC_FILES=true RAILS_LOG_TO_STDOUT=true

ENTRYPOINT ["./script/docker-entrypoint.sh"]
# Use front by default. async and sync 'modes' are available
CMD ["front"]
