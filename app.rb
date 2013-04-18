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
set :server, :puma

get '/' do
  slim :index
end

post '/snap' do
  begin
    require 'uri'

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

require 'thread'

class Screenshotter
  QUEUE  = Queue.new
  SCRIPT = File.expand_path('../render.coffee', __FILE__)

  (ENV['WORKER_COUNT'] || 1).to_i.times do |worker_id|
    Thread.new do
      me = Thread.current
      me[:id] = worker_id
      me[:job_id] = -1

      loop do
        me[:job_id] += 1
        Screenshotter.take QUEUE.pop, "#{me[:id]}-#{me[:job_id]}"
      end
    end
  end

  def self.take(params, id)
    puts "[#{id}] Processing: #{params.inspect}"
    params = params.dup

    url      = params[:url].to_s
    format   = params[:format].to_s.upcase
    width    = params[:width]
    height   = params[:height]
    cmd      = "phantomjs #{SCRIPT} #{url.inspect} #{format} #{width} #{height}"

    puts "[#{id}] Executing: #{cmd}"
    json = JSON.parse(%x[#{cmd}])

    params.merge!(
      width: json["width"],
      height: json["height"],
      title: json["title"],
      imageData: json["imageData"])

    respond(:success, params)
  rescue => e
    STDERR.puts e.message
    STDERR.puts e.backtrace.join("\n")

    respond(:error, params)
  ensure
    params[:imageData] = params[:imageData].to_s[0, 20] + "..."
    puts "[#{id}] Processed: #{params.inspect}"
  end

  def self.plan(params)
    if valid? params
      QUEUE.push params
      true
    else
      false
    end
  rescue
    false
  end

  private

  def self.respond(status, params = {})
    require 'net/http'
    require 'net/https'

    params[:status] = status

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
    !!(http?(params[:url]) &&
      http?(params[:callback]) &&
      params[:width].to_i <= 4000 &&
      params[:format] =~ /^jpe?g|gif|png$/i)
  end

  def self.http?(uri)
    !!(uri &&
      uri.scheme =~ /^https?$/ &&
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
