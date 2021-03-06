require "remo_tool/version"

require 'optparse'
require "net/http"
require "json"
require "pp"

class RemoTool
  class Error < StandardError; end

  def cli(argv_orig)
    argv = argv_orig.dup
    subcmd = argv.shift

    case subcmd
    when "tv-src"
      tv_input_src(argv.first.to_i)
    when "tv-digital"
      tv_button("input-terrestrial")
    end
  end

  def initialize
    @remo_token = ENV.fetch("REMO_TOKEN")

    @apps = {
      tv: ENV.fetch("REMO_TV_ID"),
    }
  end

  def remo_post(path, args)
    puts "#{path}: #{args.pretty_inspect}"
    uri = URI.parse("https://api.nature.global#{path}")
    res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      req = Net::HTTP::Post.new(uri.path)
      req["Authorization"] = "Bearer #{@remo_token}"
      req.form_data = args
      http.request(req)
    end
    pp res
    res
  end

  def tv_button(name, skip_sleep: false)
    remo_post("/1/appliances/#{@apps[:tv]}/tv", button: name)
    sleep 0.4 if skip_sleep
  end

  def tv_input_src(src)
    seq = case src
    when 1
      %w(select-input-src up up up down ok)
    when 2
      %w(select-input-src up up up down down ok)
    when 3
      %w(select-input-src up up up down down down ok)
    end
    seq.each do |name|
      tv_button(name)
    end
  end
end
