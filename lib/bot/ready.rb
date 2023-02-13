class Bot

    def ready
        @client.watching = "Discourse"

        unless @bot_started
            @bot_started = true

            Thread.new do
                begin
                    loop do
                        watch_discourse
                        sleep 20
                    end
                rescue
                    sleep 20
                    @bot_started = false
                end
            end
        end
    end

    private

    def watch_discourse
        domains = @domains.find

        domains.each do |data|
            domain      = data[:domain]
            last_id     = data[:last_id]
            new_last_id = last_id
            client      = Discourse::Client.new(domain)

            data[:categories].each do |category_id, channels|
                category   = client.get_category(category_id)
                new_topics = category.get_topics.select { |topic| topic.id > last_id }

                new_topics.each do |topic|
                    new_last_id = [new_last_id, topic.id].max
                    description = topic.description

                    channels.each do |channel_id|
                        begin
                            @client.send_message(
                                channel_id,
                                nil,
                                false,
                                Discordrb::Webhooks::Embed.new(
                                    title: topic.title,
                    				url: topic.url,
                    				description: description.length > 1000 ? "#{description[0..1000]}..." : description,
                    				colour: category.colour,
                    				timestamp: Time.new,
                    				author: Discordrb::Webhooks::EmbedAuthor.new(
                    					url:      topic.author.url,
                    					name:     topic.author.name,
                    					icon_url: topic.author.pfp
                    				),
                    				footer: Discordrb::Webhooks::EmbedFooter.new(text: category.name)
                                )
                            )
                        rescue
                            nil
                        end
                    end
                end
            end

            @domains.update_one({ domain: domain }, { "$set" => { last_id: new_last_id } })
            sleep 2
        end
    end
end
