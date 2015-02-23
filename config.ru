require './referrerrer'

run Sinatra::Application

use Rack::Static,
  :urls => ["/images", "/js", "/css"],
  :root => "public"