class Bot
    def kill_bot(event)
        if event.user.id != @client.bot_application.owner.id
            event.respond(
                embeds: [Discordrb::Webhooks::Embed.new(
                    title: "No!",
                    description: "Only my owner has the power to turn me off!",
                    colour: 0xcc0000,
                    timestamp: Time.new
                )]
            )
            return
        end

        event.respond(
            embeds: [Discordrb::Webhooks::Embed.new(
                title: "GoodBye!",
                description: "Goodbye world! I will miss you :sob: :sob:",
                colour: 0x00cc00,
                timestamp: Time.new
            )]
        )

        exit
    end
end
