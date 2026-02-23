# laa-review-criminal-legal-aid

[![Ministry of Justice Repository Compliance Badge](https://github-community.service.justice.gov.uk/repository-standards/api/laa-review-criminal-legal-aid/badge)](https://github-community.service.justice.gov.uk/repository-standards/laa-review-criminal-legal-aid)

[![CI and CD](https://github.com/ministryofjustice/laa-review-criminal-legal-aid/actions/workflows/test-build-deploy.yml/badge.svg)](https://github.com/ministryofjustice/laa-review-criminal-legal-aid/actions/workflows/test-build-deploy.yml)

A service to review criminal legal aid applications.  
This service is the case-worker side of [Apply for criminal legal aid](https://github.com/ministryofjustice/laa-apply-for-criminal-legal-aid).

## Getting Started

Clone the repository, and follow these steps in order.  
The instructions assume you have [Homebrew](https://brew.sh) installed in your machine, as well as use some ruby version manager, usually [rbenv](https://github.com/rbenv/rbenv). If not, please install all this first.

**1. Pre-requirements**

- `brew bundle`
- `gem install bundler`
- `bundle install`

**2. Configuration**

- Copy `.env.development` to `.env.development.local` and modify with suitable values for your local machine
- Copy `.env.test` to `.env.test.local` and modify with suitable values for your local machine

After you've defined your DB configuration in the above files, run the following:

- `bin/rails db:prepare` (for the development database)
- `RAILS_ENV=test bin/rails db:prepare` (for the test database)

**3. GOV.UK Frontend (styles, javascript and other assets)**

- `yarn`

**4. Run the app locally**

Once all the above is done, you should be able to run the application as follows:

a) `bin/dev` - will run foreman, spawning:
 1. a rails server
 2. `yarn build` and `yarn build:css` to process JS and SCSS files and watch for any changes
 3. `sidekiq` to execute background jobs. This requires Redis.
 4. `message_poller` to facilitate SNS/SQS message polling between Datastore and Review. Note that this requires Localstack - refer to the [Datastore SNS notifications and S3 buckets section](https://github.com/ministryofjustice/laa-criminal-applications-datastore#getting-started).

b) `rails server` - will only run the rails server, usually fine if you are not making changes to the CSS and do not require background jobs or messaging between Datastore and Review.

You can also compile assets manually with `rails assets:precompile` at any time, and just run the rails server, without foreman.

If you ever feel something is not right with the CSS or JS, run `rails assets:clobber` to purge the local cache.

**5. Authenticating a user locally**

After clicking "Sign in," you will be shown a list of all users in the local database. Select one to sign in as that user.

To add users, select a user that can manage others and use the user management interface. A seed admin user is created by default (run `bundle exec rails db:seed` if none are listed). To ensure that the user's name is set correctly on first authorisation, use the format "<Firstname.Lastname@example.com>."

The last user in the list is "<Not.Authorised@example.com>." Select this user to simulate a non-authorised authenticated user.

This authentication strategy can be disabled locally by setting `DEV_AUTH_ENABLED=false`

**NOTE:** The dev_auth authentication strategy has been enabled for local development and docker compose by setting `DEV_AUTH_ENABLED=true` and `IS_LOCAL_DOCKER_ENV=true`.
This must never be enabled in the live (staging/production) service in it's current form as it will expose sensitive information.

## Local development with the temporary API gem

The app utilises [puma-dev](https://github.com/puma/puma-dev) for local development.

Follow the setup procedure for puma-dev [outlined here](https://github.com/puma/puma-dev#install)

Clone [apply](https://github.com/ministryofjustice/laa-apply-for-criminal-legal-aid), and the [laa-crime-apply-dev-api](https://github.com/ministryofjustice/laa-crime-apply-dev-api) locally.

Point the dev gem in apply's gemfile to your local laa-crime-apply-dev-api repo:

```
gem 'laa_crime_apply_dev_api', path: '../laa-crime-apply-dev-api'
```

Ensure that you have a `~/.puma-dev/` dir set up which contains symlinks to you local Apply and Review repos ([instructions](https://github.com/puma/puma-dev#usage))

You should now be able to access apply and review at the following convenience URLs:

```
http://laa-review-criminal-legal-aid.test/

http://laa-apply-for-criminal-legal-aid.test/

## Access dev api (as defined in the gem)
http://laa-apply-for-criminal-legal-aid.test/api/applications
http://laa-apply-for-criminal-legal-aid.test/api/applications/<application-id>
```

### Pre-commit hooks

We use the Ministry of Justice [DevSecOps Hooks](https://github.com/ministryofjustice/devsecops-hooks) to scan our repository and stop us from committing hardcoded secrets and credentials. Refer to their repository for documentation on how to set up the pre-commit hooks locally.

With pre-commit hooks enabled, the following tools are run on each commit:
- GitLeaks (via [devsecops-hooks](https://github.com/ministryofjustice/devsecops-hooks))
- Rubocop
- ERB Lint

To bypass the hooks, use the `-n` or `--no-verify` option, e.g.
```shell
git commit -nam 'My commit'
```

## Running the tests

You can run all the code linters and tests with:

- `rake`

The tasks run by default when using `rake`, are defined in the `Rakefile`.

Or you can run them individually:

- `rake spec`
- `rake erblint`
- `rake rubocop`
- `rake brakeman`

## Docker

The application can be run inside a docker container. This will take care of the ruby environment, postgres database
and any other dependency for you, without having to configure anything in your machine.

- `docker compose up`

The application will be run in "production" mode, so will be as accurate as possible to the real production environment.

**NOTE:** never use `docker compose` for a real production environment. This is only provided to test a local container. The
actual docker images used in the cluster are built as part of the deploy pipeline.

## Feature Flags

Feature flags can be set so that functionality can be enabled and disabled depending on the environment that the application is running in.

Set a new feature flag in the `config/settings.yml` under the heading `feature_flags` like so:

```yaml
# config/settings.yml
feature_flags:
  your_new_feature:
    local: true
    staging: true
    production: false
```

To check if a feature is enabled / disabled and run code accordingly, use:

```ruby
FeatureFlags.your_new_feature.enabled?
FeatureFlags.your_new_feature.disabled?
```

## Kubernetes deployment

### To provision infrastructure

AWS infrastructure is created by Cloud Platforms via PR to [their repository](https://github.com/ministryofjustice/cloud-platform-environments).  
Read [how to connect the cluster](https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/kubectl-config.html).

**Namespaces for this service:**

- [staging namespace](https://github.com/ministryofjustice/cloud-platform-environments/tree/main/namespaces/live.cloud-platform.service.justice.gov.uk/laa-review-criminal-legal-aid-staging)
- [production namespace](https://github.com/ministryofjustice/cloud-platform-environments/tree/main/namespaces/live.cloud-platform.service.justice.gov.uk/laa-review-criminal-legal-aid-production)

### Applying the configuration

Configuration is applied automatically as part of each deploy. You can also apply configuration manually, for example:

```bash
kubectl apply -f config/kubernetes/staging/ingress.yml
```

### Continuous integration and delivery

The application is setup to trigger tests on every pull request and, in addition, to build and release to staging
automatically on merge to `main` branch. Release to production will need to be approved manually.

All this is done through **github actions**.

The secrets needed for these actions are created automatically as part of the **terraforming**. You can read more about
it in [this document](https://user-guide.cloud-platform.service.justice.gov.uk/documentation/deploying-an-app/github-actions-continuous-deployment.html#automating-the-deployment-process).

## Architectural decision records

ADRs are in the `./docs/architectural-decisions/` folder will hold markdown documents that record Architectural decision records (ARDs) for the LAA Review Criminal Legal Aid applications.

Please install [ADRs Tools](https://github.com/npryce/adr-tools) (`brew install adr-tools`) to help manage the creation of new ADR documents.

### To create a new ADR

After installing ADR tools use:

```
adr new <your ADR title>
```

This will initialise new blank ADR with your title as a heading and increment the ARD prefix to the correct number on the ARDs file name.

### Further info

For information on what ARDs are see [here](https://adr.github.io/).
