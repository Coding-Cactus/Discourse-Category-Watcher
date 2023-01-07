class Bot
    def watch(event, domain, category_id, discord_channel)
        domain.downcase!
        category_id     = category_id.to_s
        discord_channel = discord_channel.to_i
        
        client = Discourse::Client.new(domain)

        begin
            client.get_category(category_id)
        rescue
            event.respond(
                embeds: [Discordrb::Webhooks::Embed.new(
    				title: "Invalid Discourse URL or category ID",
    				description: "I was unable to access any data at https://#{domain}/c/-/#{category_id}",
    				colour: 0xcc0000,
    				timestamp: Time.new
    			)]
            )
            return
        end

        data = @domains.find({ domain: domain }).first

        if data.nil?
            @domains.insert_one({
                domain: domain,
                last_id: 0,
                categories: {
                    category_id => [discord_channel]
                }
            })
        else
            categories = data[:categories]

            if categories.include?(category_id)
                if categories[category_id].include?(discord_channel)
                    event.respond(
                        embeds: [Discordrb::Webhooks::Embed.new(
            				title: "Already Watching!",
            				description: "I am already watching https://#{domain}/c/-/#{category_id} in <##{discord_channel}>",
            				colour: 0xcc0000,
            				timestamp: Time.new
            			)]
                    )
                    return
                end
                
                @domains.update_one({ domain: domain }, { "$push" => { "categories.#{category_id}" => discord_channel } })
            else                
                @domains.update_one({ domain: domain }, { "$set"  => { "categories.#{category_id}" => [discord_channel] } })
            end
        end

        event.respond(
            embeds: [Discordrb::Webhooks::Embed.new(
                title: "Watching Category!",
                description: "I'll keep an eye on https://#{domain}/c/-/#{category_id} for you, and send any new topics to <##{discord_channel}>",
                colour: 0x00cc00,
                timestamp: Time.new
            )]
        )
    end
end
