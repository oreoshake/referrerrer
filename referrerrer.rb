require 'sinatra'
require 'sinatra/cookies'

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

get '/' do
  redirect to("/no-referrer-when-downgrade")
end

get '/mixed-content' do
<<-HTML
If mixed content is blocked, the image won't load:
<img src="http://www.marioverehrer.com/images/cover/nyan-cat.jpg?img">
<script src="http://www.marioverehrer.com/images/cover/nyan-cat.jpg?script"></script>
<link rel="stylesheet" type="text/css" href="http://www.marioverehrer.com/images/cover/nyan-cat.jpg?stylesheet">
<video src="http://www.marioverehrer.com/images/cover/nyan-cat.jpg?video"></video>
<audio src="http://www.marioverehrer.com/images/cover/nyan-cat.jpg?audio"></audio>
<embed src="http://www.marioverehrer.com/images/cover/nyan-cat.jpg?swf" quality="high">
HTML
end

get '/never-no-referrer' do
<<-HTML
<html>
  <head>
    <meta name="referrer" content="never" />
    <meta name="referrer" content="no-referrer" />
    <meta name="referrer" content="none" />
  </head>
  <body>
    <p><a href="/never-no-referrer">self</a></p>
    <p>Referrer: <data>#{request.referrer}</data></p>
  </body>
HTML
end