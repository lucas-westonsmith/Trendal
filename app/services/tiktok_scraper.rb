class TiktokScraper
  COUNTRIES = %w[PT US GB FR ES IT].freeze
  PERIODS = %w[7 30 120].freeze

  def call
    puts "Starting to scrape TikTok hashtags..."

    url = "https://ads.tiktok.com/business/creativecenter/inspiration/popular/hashtag/pc/en"
    html = URI.open(url).read
    doc = Nokogiri::HTML(html)

    puts "Deleting all related videos from the database..."
    Video.delete_all

    puts "Deleting all related counts from the database..."
    Count.delete_all

    puts "Deleting all existing trends from the database..."
    Trend.delete_all

    hashtag_cards = doc.css('div.CommonDataList_cardWrapper__kHTJP')
    puts "Found #{hashtag_cards.length} hashtag cards."

    hashtag_cards.each_with_index do |card, index|
      puts "Processing hashtag #{index + 1}/#{hashtag_cards.length}"

      # Extract Rank
      rank = card.at_css('span.RankingStatus_rankingIndex__ZMDrH')&.text&.strip.to_i

      # Extract Hashtag Name
      hashtag = card.at_css('span.CardPc_titleText__RYOWo')&.text&.strip
      hashtag_without_hash = hashtag.gsub('#', '')
      puts "Hashtag: #{hashtag_without_hash}, Rank: #{rank}"

      encoded_hashtag = CGI.escape(hashtag_without_hash).gsub('+', '')

      # Extract Number of Posts
      posts_text = card.at_css('span.CardPc_itemValue__XGDmG')&.text&.strip
      posts = convert_to_numeric(posts_text)
      puts "Posts: #{posts} for #{hashtag_without_hash}"

      # Extract Industry (if present)
      industry = card.at_css('span.CardPc_industryTag__XYZABC')&.text&.strip
      industry = "" if industry.nil?
      puts "Industry: '#{industry}'"

      # Save Trend
      trend = Trend.create(rank: rank, title: hashtag, count: posts, industry: industry, platform: 'tiktok')
      puts "Saved Trend ##{trend.id} - #{trend.title} (Industry: #{trend.industry})"

      # Fetch country and period-specific data
      begin
        COUNTRIES.each do |country|
          PERIODS.each do |period|
            fetch_country_data(encoded_hashtag, country, period, trend)
          end
        end

        # Fetch overall data
        url2 = "https://ads.tiktok.com/business/creativecenter/hashtag/#{encoded_hashtag}/pc/en?countryCode=PT&period=7"
        puts "Fetching overall details from #{url2}"

        html2 = URI.open(url2).read
        doc2 = Nokogiri::HTML(html2)

        posts_overall = doc2.css('span.DetailModal_title__kHEFx').last&.text&.strip
        posts_overall_value = convert_to_numeric(posts_overall)
        puts "Overall posts: #{posts_overall_value} for #{hashtag_without_hash}"

        trend.update(count_overall: posts_overall_value)
        puts "Updated Trend ##{trend.id} with overall post count."

      rescue => e
        puts "Error fetching details for #{hashtag_without_hash}: #{e.message}"
        puts e.backtrace
      end
    end
  rescue => e
    puts "Error in main scraper process: #{e.message}"
    puts e.backtrace
  end

  private

  def fetch_country_data(encoded_hashtag, country, period, trend)
    url = "https://ads.tiktok.com/business/creativecenter/hashtag/#{encoded_hashtag}/pc/en?countryCode=#{country}&period=#{period}"

    begin
      puts "Fetching data for Trend #{trend.title} - Country: #{country}, Period: #{period}"
      puts "URL: #{url}"

      html = URI.open(url).read
      doc = Nokogiri::HTML(html)

      post_count_in_period = doc.css('span.DetailModal_title__kHEFx').first&.text&.strip
      post_count_in_period_converted = convert_to_numeric(post_count_in_period)

      puts "Extracted post count for #{country} (#{period} days): #{post_count_in_period_converted}"

      # Save the post count
      Count.create(
        country: country,
        period: period,
        number: post_count_in_period_converted,
        trend: trend
      )
      puts "Saved Count for Trend ##{trend.id} - Country: #{country}, Period: #{period}"

      # Extract and save video links
      fetch_video_links(doc, trend)

    rescue => e
      puts "Error fetching country data for #{trend.title} (#{country}, #{period}): #{e.message}"
      puts e.backtrace
    end
  end

  def fetch_video_links(doc, trend, count = nil)
    # Vérifiez que count est valide si vous souhaitez le passer
    if count.nil?
      puts "Skipping count association as no valid count was provided."
    end

    # Extraire jusqu'à 5 liens vidéo depuis le document HTML
    video_links = doc.css('blockquote.IframeEmbedVideo_embedQuote__BdyWZ').map { |blockquote| blockquote['cite'] }.first(5)

    puts "Found #{video_links.length} video links for trend #{trend.title}"

    # Sauvegarder les liens vidéo
    video_links.each_with_index do |link, index|
      puts "Video ##{index + 1}: #{link}"

      Video.create!(
        url: link,
        trend: trend,
        count: count # Passer le count ici, même s'il est `nil`
      )
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
end
