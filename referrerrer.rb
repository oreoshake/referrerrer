require 'sinatra'
require 'sinatra/cookies'
require 'securerandom'
require 'redcarpet'

get '/' do
  file = File.read('README.md')
  Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(escape_html: true, safe_links_only: true), auto_link: true).render(file)
end

DIRECTIVE_VALUES = %w{none never no-referrer origin origin-when-crossorigin no-referrer-when-downgrade unsafe-url}

before do
  headers['strict-transport-security'] = "max-age 1234567890123456; includeSubdomains"
end

get '/google-analytics' do
  headers['content-security-policy'] = "default-src 'none'; img-src https://www.google-analytics.com; script-src https://www.google-analytics.com https://ssl.google-analytics.com/ga.js 'self' 'unsafe-inline' 'sha256-8lbEMYMJ3VJbtw9Vj7LRxW8djnQJ3eTp3AzEvsyMgBE=' 'sha256-rD8GJ6T/4tWnL1d2MkCyzv4RctCfHBah9bmNqAxvGW0='"

<<-HTML
<script src="js/cryptojs/rollups/sha256.js"></script>
<script src="js/cryptojs/components/enc-base64-min.js"></script>
<script src="js/jquery.min.js"></script>
<script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-xxxxxx-3', 'auto');
  ga('send', 'pageview');
</script>

<script>
  console.log("Add the following values to your script-src to whitelist them using hash sources:")
  $.each($('script'), function(index, x) {
    if (x.innerHTML !== "") {
      console.log("'sha256-" + CryptoJS.SHA256(x.innerHTML).toString(CryptoJS.enc.Base64) + "'");
    }
  });
</script>
Hi.
<p>Header is:</p>
<pre>#{headers['content-security-policy']}</pre>
<p>GA Code:</p>
<pre>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-xxxxxx-3', 'auto');
  ga('send', 'pageview');
</pre>
<p>See https://blog.matatall.com/2014/08/this-blog-uses-csp-level-2-script-hash-support/ for more info on generating the hash values.</p>
<p>You could also just externalize the GA inline code and include it. That's certainly preferrable as it removes the need for 'unsafe-inline', but don't worry, it's backwards compatible: browsers that understand the hash will ignore the 'unsafe-inline' and browsers that don't understand the hash will fall back to 'unsafe-inline' behavoir.</p>
HTML
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
  headers['Content-Security-Policy'] = "default-src 'none'; script-src 'unsafe-inline' 'nonce-#{nonce}'; report-uri /nowhere"
<<-HTML
  <script nonce="#{nonce}">console.log("this is expected, move along.")</script>
  <script>alert("if you are seeing this, the browser not support csp nonce sources")</script>
  If you get an alert box, fail. Otherwise, yay. You can check the console to check for a friendly message to show whitelisted scripts ran.
HTML
end

get '/hash' do
  headers['Content-Security-Policy'] = "default-src 'none'; script-src 'unsafe-inline' 'sha256-/5HM72XjTKVYv9UTgvVDdAY1yVNIE5yJkts47LQpWDY='; report-uri /nowhere"
<<-HTML
  <script>console.log("this is expected, move along.")</script>
  <script>alert("if you are seeing this, the browser not support csp hash sources")</script>
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
