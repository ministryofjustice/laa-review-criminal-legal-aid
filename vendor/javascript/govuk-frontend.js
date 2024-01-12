export{version}from"./common/govuk-frontend-version.mjs";import{isSupported as o}from"./common/index.mjs";import{Accordion as m}from"./components/accordion/accordion.mjs";import{Button as n}from"./components/button/button.mjs";import{CharacterCount as r}from"./components/character-count/character-count.mjs";import{Checkboxes as t}from"./components/checkboxes/checkboxes.mjs";import{ErrorSummary as e}from"./components/error-summary/error-summary.mjs";import{ExitThisPage as i}from"./components/exit-this-page/exit-this-page.mjs";import{Header as s}from"./components/header/header.mjs";import{NotificationBanner as c}from"./components/notification-banner/notification-banner.mjs";import{Radios as a}from"./components/radios/radios.mjs";import{SkipLink as p}from"./components/skip-link/skip-link.mjs";import{Tabs as f}from"./components/tabs/tabs.mjs";import{SupportError as u}from"./errors/index.mjs";import"./common/normalise-dataset.mjs";import"./govuk-frontend-component.mjs";import"./i18n.mjs";import"./common/closest-attribute-value.mjs";
/**
 * Initialise all components
 *
 * Use the `data-module` attributes to find, instantiate and init all of the
 * components provided as part of GOV.UK Frontend.
 *
 * @param {Config & { scope?: Element }} [config] - Config for all components (with optional scope)
 */function initAll(l){var d;l=typeof l!=="undefined"?l:{};if(!o()){console.log(new u);return}const j=[[m,l.accordion],[n,l.button],[r,l.characterCount],[t],[e,l.errorSummary],[i,l.exitThisPage],[s],[c,l.notificationBanner],[a],[p],[f]];const h=(d=l.scope)!=null?d:document;j.forEach((([o,m])=>{const n=h.querySelectorAll(`[data-module="${o.moduleName}"]`);n.forEach((n=>{try{"defaults"in o?new o(n,m):new o(n)}catch(o){console.log(o)}}))}))}export{m as Accordion,n as Button,r as CharacterCount,t as Checkboxes,e as ErrorSummary,i as ExitThisPage,s as Header,c as NotificationBanner,a as Radios,p as SkipLink,f as Tabs,initAll};

