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
      trend = Trend.create(rank: rank, title: hashtag, count: posts)

      # Now fetch details for each trend (country and period-based)
      begin
        # Create the URL to fetch details based on the title, country, and period
        url2 = "https://ads.tiktok.com/business/creativecenter/hashtag/#{hashtag}/pc/en?countryCode=PT&period=7"
        html2 = URI.open(url2).read
        doc2 = Nokogiri::HTML(html2)

        # Extract the specific data for posts in the given country/period and overall posts
        posts_overall = doc2.css('span.DetailModal_title__kHEFx').last&.text&.strip

        # Update the Trend object with these additional post details
        trend.update(count_overall: posts_overall)

      rescue => e
        puts "Error fetching details for #{hashtag}: #{e.message}"
        puts e.backtrace
      end
    end
  rescue => e
    puts "Error: #{e.message}"
    puts e.backtrace
  end
end
