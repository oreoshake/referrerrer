Meta referrer tag
=========
Setting a meta tag with the value in the path allows you to test the referrer between page loads.

The easiest way to test is to click the link with the same name as the current page and look for the referrer in the page.

test.rb simulates clicking each over various browsers.

the following test pages are available:
  /none
  /never
  /no-referrer
  /origin
  /origin-when-crossorigin
  /no-referrer-when-downgrade
  /unsafe-url

CSP tests
===========

  /csp-with-path - tries to load two images, only one should load
  /form-action - tries to post a form to an http: web page. the form submission should never happen, and the user should stay on the same page
  /nonce - tries to execute two scripts, but only one is whitelisted and the other should not execute (alert box = fail)
  /hash - same as nonce, but using hashes

Mixed Content
===========

  /mixed-content tries to load all types of resources over http, check the network tab to see which requests were aborted.