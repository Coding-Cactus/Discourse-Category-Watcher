require "http"
require "json"
require "mongo"
require "sinatra"
require "discordrb"

require_relative "lib/bot"
require_relative "lib/discourse"

set :bind, "0.0.0.0"
set :protection, :except => :frame_options

get "/" do
	"hi"
end

Thread.new { Bot.new(ENV["token"], ENV["mongouri"]).run }
