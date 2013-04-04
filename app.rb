 require 'rubygems'
require 'bundler'
require 'json'

Bundler.setup(:default)
require 'sinatra'
Bundler.setup(:default, settings.environment)

configure :development do
  require 'rack/reloader'
  Sinatra::Application.reset!
  use Rack::Reloader
end

get '/' do
  <<-EOResp
  <p>Post to /snap with the following query params:</p>
  <ul>
   <li><code>format</code>: one of "jpg", "png", or "gif"</li>
   <li><code>url</code>: the url to take a screenshot of</li>
   <li><code>callback</code>: the URL you want notified on completetion</li>
  </ul>

  <p>You will get a response back at the callback shortly after with a JSON body that looks like:</p>

  <pre>{
  "url":"http://google.com",
  "callback":"http://example.com/your/callback",
  "title":"Google",
  "imageData":"iVBORw0KGgoAAAANSUhEUgAAAlsAAAG6CAYAAAA/NYPLAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAALEwAACxMBAJqcGAAAIABJREFUeJzs3WdgXNWd...",
  "format":"PNG",
  "status":"success"
}</pre>

  <p>The <code>imageData</code> key is Base64 encoded.
  EOResp
end

post '/snap' do
  begin
    require 'uri'

    task = Screenshotter.plan(
      format: params[:format] || "png",
      url: URI.parse(params[:url]),
      callback: URI.parse(params[:callback]))

    if task.possible?
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
  WORKER = Thread.new { loop { Screenshotter.take QUEUE.pop } }
  SCRIPT = File.expand_path('../render.js', __FILE__)

  def self.take(params)
    puts "Processing: #{params.to_json}"
    require 'phantomjs'
    url      = params[:url].to_s
    format   = params[:format].to_s.upcase
    response = JSON.parse(Phantomjs.run(SCRIPT, url, format))
    respond(:success, params.merge(response))
    puts "Processed: #{params.to_json}"
  end

  def self.plan(params)
    possible = valid?(params)
    QUEUE.push params if possible
    Struct.new(:possible?).new(possible)
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
    puts request.body = params.to_json
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
