require 'multi_json'
require 'net/http'
require 'net/https'
require 'queue_classic'

class Screenshotter
  SCRIPT = File.expand_path('../render.coffee', __FILE__)

  def self.perform(params)
    puts "Processing: #{params.inspect}"
    params = params.dup

    url      = params["url"]
    format   = params["format"].upcase
    width    = params["width"]
    height   = params["height"]
    cmd      = "phantomjs #{SCRIPT} #{url.inspect} #{format} #{width} #{height}"

    puts "Executing: #{cmd}"
    json = MultiJson.load(%x[#{cmd}])

    params.merge!(
      "width"     => json["width"],
      "height"    => json["height"],
      "title"     => json["title"],
      "format"    => format,
      "imageData" => json["imageData"])

    respond(:success, params)
  rescue MultiJson::LoadError => e
    log_exception(e)
    respond(:error, params)
  ensure
    params["imageData"] = params["imageData"].to_s[0, 20] + "..."
    puts "Processed: #{params.inspect}"
  end

  def self.plan(params)
    params[:format] ||= "png"
    if valid? params
      QC.enqueue "Screenshotter.perform", params
      true
    else
      false
    end
  rescue
    false
  end

  private

  def self.respond(status, params = {})
    params[:status] = status

    uri                   = URI.parse(params["callback"])
    http                  = Net::HTTP.new(uri.host, uri.port)
    http.ssl_timeout      = 5
    http.open_timeout     = 5
    http.read_timeout     = 10
    http.continue_timeout = 10
    http.use_ssl          = true if uri.scheme == "https"
    headers               = {'Content-Type' => 'application/json'}
    request               = Net::HTTP::Post.new(uri.request_uri, headers)
    request["User-Agent"] = "Grabshot (https://github.com/bjeanes/grabshot)"
    request.body          = MultiJson.dump(params)
    http.request(request)
  rescue => e
    log_exception e

    if params[:status] == :success
      params[:error] = e.class.name
      params.delete(:imageData)
      respond(:error, params)
    end
  end

  def self.valid?(params)
    !!(http?(params[:url]) &&
      http?(params[:callback]) &&
      params[:width].to_i <= 4000 &&
      params[:format] =~ /^jpe?g|gif|png$/i)
  end

  def self.http?(uri)
    uri = URI.parse(uri)
    !!(uri &&
      uri.scheme =~ /^https?$/ &&
      uri.host &&
      (development? ||
        uri.host !~ /^([0-9.]+$)|localhost|\[/))
  rescue URI::InvalidURIError, ArgumentError => e
    log_exception e
  end

  def self.development?
    Grabshot.environment == :development
  end
end

def log_exception(e)
  STDERR.puts "#{e.class}: #{e.message}"
  STDERR.puts e.backtrace.join("\n")
end
