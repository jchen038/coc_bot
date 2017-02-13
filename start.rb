require './lib/clash_bot'
require 'yaml'

TOKEN = YAML.load_file('./config.yml')

Slack.configure do |config|
	config.token = TOKEN["slack"]
end

bot = ClashBot.new(TOKEN["clash"])

bot.messages

bot.start