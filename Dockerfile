FROM ruby:3.4.8-alpine3.23
LABEL maintainer="LAA Crime Apply Team"

RUN apk --no-cache add --virtual build-deps \
  build-base \
  postgresql15-dev \
  git \
  bash \
  curl \
  && apk --no-cache add \
  postgresql15-client \
  shared-mime-info \
  linux-headers \
  nodejs \
  xz-libs \
  tzdata \
  yaml-dev \
  gcompat

# add non-root user and group with alpine first available uid, 1000
RUN addgroup -g 1000 -S appgroup && \
  adduser -u 1000 -S appuser -G appgroup

# create some required directories
RUN mkdir -p /usr/src/app && \
  mkdir -p /usr/src/app/log && \
  mkdir -p /usr/src/app/tmp && \
  mkdir -p /usr/src/app/tmp/pids

WORKDIR /usr/src/app

COPY Gemfile* .ruby-version ./

RUN gem install bundler && \
  bundle config set frozen 'true' && \
  bundle config without test:development && \
  bundle install --jobs 2 --retry 3

COPY . .

# Install JavaScript dependencies
RUN corepack enable && corepack prepare yarn@4.11.0 --activate && \
  yarn install --frozen-lockfile

RUN RAILS_ENV=production \
  ENV_NAME=production \
  SECRET_KEY_BASE=dummy_for_turbo_signed_stream_verifier_on_precompile \
  GOVUK_NOTIFY_API_KEY=replace_this_at_build_time \
  rails assets:precompile --trace

# tidy up installation
RUN apk del build-deps && rm -rf /tmp/*

# non-root/appuser should own only what they need to
RUN chown -R appuser:appgroup log tmp db

# Download RDS certificates bundle -- needed for SSL verification
# We set the path to the bundle in the ENV, and use it in `/config/database.yml`
#
ENV RDS_COMBINED_CA_BUNDLE=/usr/src/app/config/global-bundle.pem
ADD https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem $RDS_COMBINED_CA_BUNDLE
RUN chmod +r $RDS_COMBINED_CA_BUNDLE

ARG APP_BUILD_DATE
ENV APP_BUILD_DATE=${APP_BUILD_DATE}

ARG APP_BUILD_TAG
ENV APP_BUILD_TAG=${APP_BUILD_TAG}

ARG APP_GIT_COMMIT
ENV APP_GIT_COMMIT=${APP_GIT_COMMIT}

ENV APPUID=1000
USER $APPUID

ENV PORT=3000
EXPOSE $PORT

ENTRYPOINT ["./run.sh"]
