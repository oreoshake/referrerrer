require 'sinatra'

['no-referrer', 'never', 'origin', 'origin-when-crossorigin', 'no-referrer-when-downgrade', 'unsafe-url'].each do |content|
  get "/#{content}" do
    "<meta name=\"referrer\" content=\"#{content}\"><a href=\"/#{content}\">self</a><br>Referrer: #{request.referrer}"
  end
end
