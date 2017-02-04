require './lib/clash_bot'

slack_token = ARGV[0]
clash_token = ARGV[1]

Slack.configure do |config|
	config.token = slack_token
end

bot = ClashBot.new(clash_token)

bot.messages

bot.start