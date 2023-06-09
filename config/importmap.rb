# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "govuk-frontend", to: "https://ga.jspm.io/npm:govuk-frontend@4.6.0/govuk-esm/all.mjs"
pin_all_from "app/javascript/local", under: "local"
