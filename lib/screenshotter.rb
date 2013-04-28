require 'thread'
require 'json'
require 'net/http'
require 'net/https'

class Screenshotter
  QUEUE  = Queue.new
  SCRIPT = File.expand_path('../render.coffee', __FILE__)

  (ENV['WORKER_COUNT'] || 1).to_i.times do |worker_id|
    Thread.new do
      me = Thread.current
      me[:id] = worker_id
      me[:job_id] = -1

      loop do
        begin
          me[:job_id] += 1
          Screenshotter.take QUEUE.pop, "#{me[:id]}-#{me[:job_id]}"
        rescue => e
          log_exception e
        end
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
  rescue JSON::ParserError => e
    log_exception(e)
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
    params[:status] = status

    uri = params[:callback]
    http = Net::HTTP.new(uri.host, uri.port)
    http.ssl_timeout = 5
    http.open_timeout = 5
    http.read_timeout = 10
    http.continue_timeout = 10
    http.use_ssl = true if params[:callback].scheme == "https"
    headers = {'Content-Type' =>'application/json'}
    request = Net::HTTP::Post.new(uri.request_uri, headers)
    request["User-Agent"] = "Grabshot (https://github.com/bjeanes/grabshot)"
    request.body = params.to_json
    http.request(request)
  rescue => e
    log_exception e
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
    Grabshot.environment == :development
  end
end

def log_exception(e)
  STDERR.puts "#{e.class}: #{e.message}"
  STDERR.puts e.backtrace.join("\n")
end
