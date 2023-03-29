// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

import { Turbo } from "@hotwired/turbo-rails"

// defaults "data: { turbo: 'false' }"
Turbo.session.drive = false

import copyReferenceNumber from 'local/copy_reference_number'

// https://frontend.design-system.service.gov.uk/importing-css-assets-and-javascript/#javascript
import { initAll } from 'govuk-frontend'
initAll()

// used on application show page
copyReferenceNumber()
