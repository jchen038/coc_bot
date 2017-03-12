require 'slack-ruby-client'
require 'clashinator'
require 'nokogiri'
require 'open-uri'

class ClashBot
  attr_accessor :client, :api

  def initialize(token)
    @client = Slack::RealTime::Client.new
    @api    = Clashinator::Client.new(token)
  end

  def commands
    [
      "our_clan",
      "search (clan name)",
      "clan_info (clan tag)",
      "war_log (clan_tag)",
      "search_cocp (clan tag)"
    ]
  end

  def messages
    @client.on :message do |data|
      command   = data.text.split(" ")
      bot       = command[0]
      action    = command[1]
      variable  = command[2..(command.count)].join(" ")

      if !bot.match(/bot/im).nil?
        response =
          case action
          when 'hi' then
            "Hi <@#{data.user}>!"
          when "our_clan" then
            own_clan
          when "search_cocp" then
            self.class.search_cocp(variable)
          when "search" then
            search_clan(variable)
          when "clan_info" then
            clan_info(variable)
          when "war_log" then
            war_log(variable)
          when "help" then
            commands.join("\n")
          else
            "?????"
          end
        @client.message channel: data.channel, text: response
      end
    end
  end

  def start
    @client.start!
  end

  def search_clan(name)
    @api
      .search_clans(name: name, min_members: 10)
      .items[0..20]
      .map do |clan|
        self.class.display_clan(clan)
      end
      .join("\n")
  end

  def clan_info(tag)
    self.class.display_clan(@api.clan_info(tag))
  end

  def war_log(tag)
    @api
      .clan_war_log(tag)
      .items[0..20]
      .map{|log| self.class.display_log(log)}
      .join("\n")
  end

  def clan_players(tag)
    @api.list_clan_members(tag)
  end

  def own_clan
    clan_info("#L20GYPP")
  end

  class << self

    def search_cocp(tag)
      url   = "https://cocp.it/clan/"
      Nokogiri::HTML(open("#{url}#{tag}"))
        .css("div.rocknrollanimal")
        .map do |stat|
          display_cocp(stat)
        end
        .join("\n")
    end

    private

    def display_cocp(war_result)
      clan      = war_result.css("div.birtherror")[0]
      opponent  = war_result.css("div.birtherror")[1]
      [
        clan.css("div.name").text,
        clan.css("div.stats1").css("div").css("span").map{|stat| stat.text}.join(" "),
        opponent.css("div.name").text,
        opponent.css("div.tag").text,
        opponent.css("div.stats1").css("div").css("span").map{|stat| stat.text}.join(" ")
      ].join(" ")
    end

    def display_clan(clan)
      "#{clan.name} - #{clan.tag} - #{clan.members} members - #{clan.war_win_streak} current win streak - War Log: #{clan.is_war_log_public ? "Public" : "Private"}"
    end

    def display_log(log)
      "Size: #{log.team_size} - #{log.result} - Attacks: #{log.clan.attacks}/#{log.team_size.to_i * 2} - Stars: #{log.clan.stars} - Destruction: #{log.clan.destruction_percentage.to_i.round} - Opponent: #{log.opponent.name} - Stars: #{log.opponent.stars} - Destruction: #{log.opponent.destruction_percentage}"
    end
  end
end