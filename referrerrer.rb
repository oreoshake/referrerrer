require 'sinatra'
require 'sinatra/cookies'
require 'securerandom'

get '/' do
<<-HTML
<pre>
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
</pre>
HTML
end

DIRECTIVE_VALUES = %w{none never no-referrer origin origin-when-crossorigin no-referrer-when-downgrade unsafe-url}

before do
  headers['strict-transport-security'] = "max-age 1234567890123456; includeSubdomains"
end

DIRECTIVE_VALUES.each do |content|
  get "/#{content}" do
    <<-HTML
<html>
  <head>
    <meta name="referrer" content="#{content}" />
  </head>
  <body>
    <p><a href="/#{content}">self</a> <a href="http://bar.com">http://bar.com</a> <a href="https://google.com">https://google.com</a></p>
    <p>The default value for browser behavior is "<a href="https://w3c.github.io/webappsec/specs/referrer-policy/#referrer-policy-state-no-referrer-when-downgrade">no-referrer-when-downgrade</a>".</p>
    <p>Referrer: <data>#{request.referrer}</data></p>
    #{DIRECTIVE_VALUES.map {|value| "<a href=\"#{value}\">#{value}</a>"}.join(" | ")}
  </body>
HTML
  end
end

get '/csp-with-path' do
  headers['Content-Security-Policy'] = "default-src 'none'; img-src https://avatars2.githubusercontent.com/u; style-src 'unsafe-inline';"
  <<-HTML
  <p>If CSP with paths is working, you should see one image and one CSP violation in the console.</p>
  <p>If it's not working, you'll get an empty page.</p>
  <img src=\"https://avatars2.githubusercontent.com/u/2623954?v=3&amp;s=60\">
  <img src=\"https://avatars2.githubusercontent.com/b/2623954?v=3&amp;s=60\">"
HTML
end

get '/form-action' do
  headers['Content-Security-Policy'] = "default-src 'none'; form-action https:; report-uri /nowhere"
  "<form action=\"http://google.com\"><input type=text><input type=submit></form>"
end

get '/nonce' do
  nonce = SecureRandom.hex
  headers['Content-Security-Policy'] = "default-src 'none'; script-src 'nonce-#{nonce}'; report-uri /nowhere"
<<-HTML
  <script nonce="#{nonce}">console.log("this is expected, move along.")</script>
  <script>alert("if you are seeing this, the browser not support csp nonce")</script>
  If you get an alert box, fail. Otherwise, yay. You can check the console to check for a friendly message to show whitelisted scripts ran.
HTML
end

get '/hash' do
  nonce = SecureRandom.hex
  headers['Content-Security-Policy'] = "default-src 'none'; script-src 'nonce-#{nonce}'; report-uri /nowhere"
<<-HTML
  <script nonce="#{nonce}">console.log("this is expected, move along.")</script>
  <script>alert("if you are seeing this, the browser not support csp nonce")</script>
  If you get an alert box, fail. Otherwise, yay. You can check the console to check for a friendly message to show whitelisted scripts ran.
HTML
end



get '/mixed-content' do
<<-HTML
  Check the network tab and look for aborted requests
  <img src="http://www.marioverehrer.com/images/cover/nyan-cat.jpg?img">
  <script src="http://www.marioverehrer.com/images/cover/nyan-cat.jpg?script"></script>
  <link rel="stylesheet" type="text/css" href="http://www.marioverehrer.com/images/cover/nyan-cat.jpg?stylesheet">
  <video src="http://www.marioverehrer.com/images/cover/nyan-cat.jpg?video"></video>
  <audio src="http://www.marioverehrer.com/images/cover/nyan-cat.jpg?audio"></audio>
  <embed src="http://www.marioverehrer.com/images/cover/nyan-cat.jpg?swf" quality="high">
HTML
end
