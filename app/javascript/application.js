// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

import { Turbo } from "@hotwired/turbo-rails"

// defaults "data: { turbo: 'false' }"
Turbo.session.drive = false

import copyText from 'local/copy_text'

// https://frontend.design-system.service.gov.uk/importing-css-assets-and-javascript/#javascript
import { initAll } from 'govuk-frontend'
initAll()

// used on application show page
copyText('#reference-number','#copy-reference-number')
copyText('#urn','#copy-urn-reference-number')