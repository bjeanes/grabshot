require 'env'

require 'sinatra'
require 'slim'
require 'uri'

require "screenshotter"

configure :development do
  require 'rack/reloader'
  Sinatra::Application.reset!
  use Rack::Reloader
end

set :slim, pretty: true, format: :html5
set :views, File.join(settings.root, "views")
set :server, :puma

get '/' do
  slim :index
end

post '/snap' do
  begin
    url      = URI.parse(params[:url])
    callback = URI.parse(params[:callback])
    width    = params[:width] && params[:width].to_i
    height   = params[:height] && params[:height].to_i
    format   = params[:format] || "png"

    possible = Screenshotter.plan(
      format: format,
      width: width,
      height: height,
      url: url,
      callback: callback)

    if possible
      status 200
      "OK"
    else
      status 400
      "ERROR"
    end
  rescue URI::InvalidURIError
    status 400
    "ERROR"
  end
end