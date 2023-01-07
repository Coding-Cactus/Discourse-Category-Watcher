class Bot
    def unwatch(event, domain, category_id, discord_channel)
        domain.downcase!
        category_id = category_id.to_s
        discord_channel = discord_channel.to_i

        data = @domains.find({ domain: domain }).first

        if data.nil? || !data[:categories].include?(category_id) || !data[:categories][category_id].include?(discord_channel)
            event.respond(
                embeds: [Discordrb::Webhooks::Embed.new(
                    title: "Already Not Watching Category!",
                    description: "I'm not current watching https://#{domain}/c/-/#{category_id} in <##{discord_channel}>",
                    colour: 0xcc0000,
                    timestamp: Time.new
                )]
            )
        else
            if data[:categories][category_id].length == 1
                @domains.update_one({ domain: domain }, { "$unset" => { "categories.#{category_id}" => "" } })
            else
                @domains.update_one({ domain: domain }, { "$pull"  => { "categories.#{category_id}" => discord_channel } })
            end

            event.respond(
                embeds: [Discordrb::Webhooks::Embed.new(
                    title: "Stopped Watching Category!",
                    description: "I have now stopped watching https://#{domain}/c/-/#{category_id} in <##{discord_channel}> for you",
                    colour: 0x00cc00,
                    timestamp: Time.new
                )]
            )
        end
    end
end
