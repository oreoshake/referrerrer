require 'sinatra'

DIRECTIVE_VALUES = %w{none never no-referrer origin origin-when-crossorigin no-referrer-when-downgrade unsafe-url}

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

get '/' do
  redirect to("/no-referrer-when-downgrade")
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
    <p><a href="/self">self</a></p>
  </body>
HTML
end