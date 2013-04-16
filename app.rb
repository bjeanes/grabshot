require 'rubygems'
require 'bundler'
require 'json'

Bundler.setup(:default, ENV["RACK_ENV"] || :development)
require 'sinatra'
require 'slim'

configure :development do
  require 'rack/reloader'
  Sinatra::Application.reset!
  use Rack::Reloader
end

set :slim, pretty: true, format: :html5
set :views, File.join(settings.root, "views")

get '/' do
  slim :index
end

post '/snap' do
  begin
    require 'uri'

    possible = Screenshotter.plan(
      format: params[:format] || "png",
      url: URI.parse(params[:url]),
      callback: URI.parse(params[:callback]))

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

require 'thread'
Thread.abort_on_exception = true
class Screenshotter
  QUEUE  = Queue.new
  SCRIPT = File.expand_path('../render.js', __FILE__)

  (ENV['WORKER_COUNT'] || 1).to_i.times do
    Thread.new { loop { Screenshotter.take QUEUE.pop } }
  end

  def self.take(params)
    puts "Processing: #{params.to_json}"
    url      = params[:url].to_s
    format   = params[:format].to_s.upcase
    json     = `phantomjs #{SCRIPT} #{url} #{format}`
    response = JSON.parse(json)
    respond(:success, params.merge(response))
    puts "Processed: #{params.to_json}"
  end

  def self.plan(params)
    QUEUE.push params if valid?(params)
  end

  private

  def self.respond(status, params = {})
    require 'net/http'
    require 'net/https'

    params["status"] = status

    uri = params[:callback]
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if params[:callback].scheme == "https"
    headers = {'Content-Type' =>'application/json'}
    request = Net::HTTP::Post.new(uri.request_uri, headers)
    request["User-Agent"] = "Grabshot (https://github.com/bjeanes/grabshot)"
    request.body = params.to_json
    http.request(request)
  end

  def self.valid?(params)
    !!(
      http?(params[:url]) &&
       http?(params[:callback]) &&
      params[:format] =~ /^jpe?g|gif|png$/i)
  end

  def self.http?(uri)
    !!(uri.scheme =~ /^https?$/ &&
      uri.host &&
      (development? ||
        uri.host !~ /^\d|localhost|\[/))
  end

  def self.development?
    Sinatra::Application.settings.environment.to_s == "development"
  end

  if ENV['KEEP_ALIVE_URL']
    require 'open-uri'

    Thread.new do
      loop do
        sleep 300

        unless QUEUE.empty?
          open(ENV['KEEP_ALIVE_URL'])
        end
      end
    end
  end
end
