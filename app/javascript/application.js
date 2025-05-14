// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

import { Turbo } from "@hotwired/turbo-rails"

// defaults "data: { turbo: 'false' }"
Turbo.session.drive = false

import copyText from './local/copy_text'

// https://frontend.design-system.service.gov.uk/importing-css-assets-and-javascript/#javascript
import { initAll } from 'govuk-frontend'
initAll()

// used on application details page
copyText('#reference-number','#copy-reference-number')
copyText('#overview-urn','#copy-overview-urn')
copyText('#case-details-urn','#copy-case-details-urn')

// Allow window.print(), otherwise blocked by CSP
import PrintAction from "./local/print-action"
const $elements = document.querySelectorAll('[data-module="print"]')
for (let i = 0; i < $elements.length; i++) {
    new PrintAction($elements[i]).init()
}