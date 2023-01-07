require_relative "bot/ready"

require_relative "bot/watch"
require_relative "bot/unwatch"
require_relative "bot/kill_bot"


class Bot
    def initialize(bot_token, mongo_uri)        
        @client  = Discordrb::Commands::CommandBot.new(token: bot_token)
        @domains = Mongo::Client.new(mongo_uri, database: "watcher")[:domains]

        @client.ready { ready }
        
        slash_command(:kill)          { |event,       _| kill_bot(event) } 
        slash_command(:ping)          { |event,       _| event.respond(content: "pong :ping_pong:") }
        slash_command(:invite)        { |event,       _| event.respond(content: "https://discord.com/api/oauth2/authorize?client_id=1059437148631220304&permissions=0&scope=bot%20applications.commands") }
        slash_command(:watch, true)   { |event, options|   watch(event, options["domain"], options["id"], options["channel"]) }
        slash_command(:unwatch, true) { |event, options| unwatch(event, options["domain"], options["id"], options["channel"]) }
    end

    def run
        @client.run
    end

    private

    def slash_command(name, needs_admin=false)
        @client.application_command(name) do |event|
            if needs_admin && !(event.user.defined_permission?(:administrator) || event.server.owner == event.user)
                event.respond(
                    embeds: [Discordrb::Webhooks::Embed.new(
                        title: "Insufficient Permissions!",
                        description: "You must be an admin to use that command.",
                        colour: 0xcc0000,
                        timestamp: Time.new
                    )]
                )
            else
                yield event, event.options
            end
        end
    end
end
