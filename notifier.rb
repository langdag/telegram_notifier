require 'feedjira'
require 'httparty'
require 'nokogiri'

BOT_TOKEN = '6107749827:AAFYd8Z7Rv3SIeYxkl1Dt0R4iPPauA7_jM8'
CHAT_ID = -1002098483762
FEED_URL = 'https://www.upwork.com/ab/feed/jobs/rss?api_params=1&orgUid=1714668117140828161&paging=0-10&proposals=0-4,5-9,10-14&q=Ruby&securityToken=8f5acbc2d30e0cb5466fd11dad5a8fa718318579aaf2fd4776c5705a5f775667a688007ef82afb2df33fffed39c5e152acc1fc9dd7bb300fd3ff05409900c3ab&sort=recency&userUid=1714668117140828160&verified_payment_only=1'
BASE_URL= "https://api.telegram.org/bot#{BOT_TOKEN}/sendMessage"

class Notifier
  def send_message(data)
    headers = {
      'Content-Type' => 'application/json'
    }
    HTTParty.post(BASE_URL, body: { chat_id: CHAT_ID,
                            text: "#{data[:title]}:#{data[:message_body]}:#{data[:url]}" }.to_json,
                            headers: headers)
  end

  def parse_rss_feed
    rss = HTTParty.get(FEED_URL).body
    feed = Feedjira.parse(rss)

    feed.entries.each do |entry|
      current_time = Time.now.utc
      published_minutes_ago = current_time - entry.published
      if published_minutes_ago < 20*60
        entry_title = Nokogiri::HTML(entry.title)
        entry_body = Nokogiri::HTML(entry.summary)
        title = entry_title.text
        message_body = entry_body.text
        data = {
           title: title,
           message_body: message_body,
           url: entry.url
        }
        send_message(data)
      end
    end
  end
end
