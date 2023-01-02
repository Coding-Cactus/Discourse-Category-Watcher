class Bot
    def watch(event, domain, category_id, discord_channel)
        domain.downcase!
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
                    category_id => [discord_channel.to_i]
                }
            })
        else
            categories = data[:categories]

            if categories.include?(category_id)
                categories[category_id] << discord_channel.to_i
            else                
                categories[category_id] = [discord_channel.to_i]
            end

            @domains.update_one({ domain: domain }, { "$set" => { categories: categories } })
        end

        event.respond(
            embeds: [Discordrb::Webhooks::Embed.new(
                title: "Watching Category!",
                description: "I keep an eye on https://#{domain}/c/-/#{category_id} for you, and send any new topics to <##{discord_channel}>",
                colour: 0x00cc00,
                timestamp: Time.new
            )]
        )
    end
end
