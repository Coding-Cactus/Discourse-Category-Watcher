require "http"
require "json"
require "mongo"
require "discordrb"

require_relative "lib/bot"
require_relative "lib/discourse"

Bot.new(ENV["token"], ENV["mongouri"]).run
