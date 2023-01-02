require "discordrb"

bot = Discordrb::Bot.new(token: ENV["token"])

bot.register_application_command(:ping,   "Ping!")
bot.register_application_command(:invite, "Invite me!")

bot.register_application_command(:watch, "Tell me which category to watch, and where to send the new topics") do |cmd|
	cmd.string("domain", "Enter the domain of the Discourse forum on which the category exists", required: true)
	cmd.integer("id", "Enter the ID of the category that you want me to watch", required: true)
	cmd.channel("channel", "Enter the channel to which I should send the new topics from the catagory", required: true)
end
