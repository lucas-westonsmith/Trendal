namespace :scraper do
  desc 'Scrape hashtags TikTok'
  task tiktok: :environment do
    puts "Starting to scrape TikTok hashtags..."  # Debug print

    url = "https://ads.tiktok.com/business/creativecenter/inspiration/popular/hashtag/pc/en"
    html = URI.open(url).read
    doc = Nokogiri::HTML(html)

    # Clear existing trends to avoid duplicates (optional)
    Trend.delete_all

    hashtag_cards = doc.css('div.CommonDataList_cardWrapper__kHTJP')
    puts "Found #{hashtag_cards.length} hashtag cards."  # Debug print

    hashtag_cards.each do |card|
      # Extract Rank
      rank = card.at_css('span.RankingStatus_rankingIndex__ZMDrH')&.text&.strip.to_i

      # Extract Hashtag Name
      hashtag = card.at_css('span.CardPc_titleText__RYOWo')&.text&.strip
      hashtag_without_hash = hashtag.gsub('#', '') # Remove '#' from hashtag
      puts "Processing Hashtag: #{hashtag_without_hash}"  # Debug print

      # Here we escape only the special characters like &, ? etc., but not the spaces
      encoded_hashtag = CGI.escape(hashtag_without_hash)  # Only encode special chars, not spaces
      encoded_hashtag = encoded_hashtag.gsub('+', '') # Remove '+' and keep space if needed

      # Extract Number of Posts (Handle K, M)
      posts_text = card.at_css('span.CardPc_itemValue__XGDmG')&.text&.strip
      posts = convert_to_numeric(posts_text)  # Convert to numeric, handling K, M
      puts "Hashtag: #{hashtag_without_hash} has #{posts} posts."  # Debug print

      # Save data to the database
      trend = Trend.create(rank: rank, title: hashtag, count: posts)

      # Now fetch details for each trend (country and period-based)
      begin
        # Create the URL to fetch details based on the title, country, and period
        url2 = "https://ads.tiktok.com/business/creativecenter/hashtag/#{encoded_hashtag}/pc/en?countryCode=PT&period=7"
        puts "Fetching details for URL: #{url2}"  # Debug print

        html2 = URI.open(url2).read
        doc2 = Nokogiri::HTML(html2)

        # Extract the specific data for posts in the given country/period and overall posts
        posts_overall = doc2.css('span.DetailModal_title__kHEFx').last&.text&.strip

        # Convert "947K" or "8M" to a more usable format
        posts_overall_value = convert_to_numeric(posts_overall)
        puts "Found overall posts: #{posts_overall_value}"  # Debug print

        # Update the Trend object with these additional post details
        trend.update(count_overall: posts_overall_value)

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

# Helper method to convert the post value (e.g., '947K', '8M') to a numeric value
def convert_to_numeric(value)
  case value
  when /(\d+)(K)/
    return $1.to_i * 1000  # Convert 'K' to thousands
  when /(\d+)(M)/
    return $1.to_i * 1_000_000  # Convert 'M' to millions
  else
    return value.to_i  # Default case: just return the number if no 'K' or 'M'
  end
end

