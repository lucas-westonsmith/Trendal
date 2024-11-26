namespace :scraper do
  desc 'Scrape hashtags TikTok'
  task tiktok: :environment do
    url = "https://ads.tiktok.com/business/creativecenter/inspiration/popular/hashtag/pc/en"
    html = URI.open(url).read
    doc = Nokogiri::HTML(html)

    # Clear existing trends to avoid duplicates (optional)
    Trend.delete_all

    hashtag_cards = doc.css('div.CommonDataList_cardWrapper__kHTJP')

    hashtag_cards.each do |card|
      # Extract Rank
      rank = card.at_css('span.RankingStatus_rankingIndex__ZMDrH')&.text&.strip.to_i

      # Extract Hashtag Name
      hashtag = card.at_css('span.CardPc_titleText__RYOWo')&.text&.strip

      # Extract Number of Posts
      posts = card.at_css('span.CardPc_itemValue__XGDmG')&.text&.strip.gsub(',', '').to_i

      # Save data to the database
      Trend.create(rank: rank, title: hashtag, count: posts)
    end
  rescue => e
    puts "Error: #{e.message}"
    puts e.backtrace
  end
end




