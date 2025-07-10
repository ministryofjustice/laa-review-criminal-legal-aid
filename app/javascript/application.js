// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

import { Turbo } from "@hotwired/turbo-rails"

// defaults "data: { turbo: 'false' }"
Turbo.session.drive = false

import copyText from './local/copy_text'

// https://frontend.design-system.service.gov.uk/importing-css-assets-and-javascript/#javascript
import { initAll } from 'govuk-frontend'
initAll()

// used on application details page
copyText('#reference-number','#copy-reference-number', 'LAA reference copied', 'Copy LAA reference')
copyText('#overview-urn','#copy-overview-urn', 'Unique reference number copied')
copyText('#case-details-urn','#copy-case-details-urn', 'Unique reference number copied')
copyText('#date-of-birth','#copy-date-of-birth', 'Date of birth copied')
copyText('#nino','#copy-nino', 'National insurance number copied')
copyText('#partner-date-of-birth','#copy-partner-date-of-birth', 'Date of birth copied')
copyText('#partner-nino','#copy-partner-nino', 'National insurance number copied')

// Allow window.print(), otherwise blocked by CSP
import PrintAction from "./local/print-action"
const $elements = document.querySelectorAll('[data-module="print"]')
for (let i = 0; i < $elements.length; i++) {
    new PrintAction($elements[i]).init()
}