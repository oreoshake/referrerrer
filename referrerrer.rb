require 'sinatra'

DIRECTIVE_VALUES = %w{no-referrer origin origin-when-crossorigin no-referrer-when-downgrade unsafe-url}

DIRECTIVE_VALUES.each do |content|
  get "/#{content}" do
    <<-HTML
<html>
  <head>
    <meta name="referrer" content="#{content}" />
  </head>
  <body>
    <a href="/#{content}">self</a><a href="http://bar.com">http://bar.com</a><a href="https://google.com">https://google.com</a><br />
    The default value for browser behavior is <a href="https://w3c.github.io/webappsec/specs/referrer-policy/#referrer-policy-state-no-referrer-when-downgrade">"no-referrer-when-downgrade".</a>
    Referrer: #{request.referrer}<br />
    #{DIRECTIVE_VALUES.map {|value| "<a href=\"#{value}\">#{value}</a>"}.join(" | ")}
  </body>
HTML
  end
end
