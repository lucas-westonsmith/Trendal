class TiktokKeywordScraper
  COUNTRIES = %w[BR DE FR IT JP PT ZA ES GB US].freeze
  PERIODS = %w[7 30 120 365].freeze
  
  def call
    puts "Starting to scrape TikTok keywords..."

    url = "https://ads.tiktok.com/business/creativecenter/keyword-insights/pc/en"
    html = URI.open(url).read
    doc = Nokogiri::HTML(html)

    # Liste des lignes du tableau contenant les données des mots-clés, en excluant la première ligne d'en-têtes
    keyword_rows = doc.css('.byted-Table-Row')[1..-1] # Ignore la première ligne d'en-tête
    puts "Found #{keyword_rows.length} keyword rows."

    keyword_rows.each_with_index do |row, index|
      puts "Processing keyword #{index + 1}/#{keyword_rows.length}"

      # Extract Rank
      rank = row.at_css('.byted-Table-Cell:nth-child(1) .KeywordTable_column__MJO36')&.text&.strip.to_i

      # Extract Keyword (Title) - Cibler la classe creative-component-single-line
      keyword = row.at_css('.byted-Table-Cell:nth-child(2) .creative-component-single-line')&.text&.strip
      puts "Keyword: #{keyword}, Rank: #{rank}"

      # Extract Popularity
      popularity_text = row.at_css('.byted-Table-Cell:nth-child(3) .KeywordTable_column__MJO36')&.text&.strip
      popularity = convert_to_numeric(popularity_text)
      puts "Popularity: #{popularity}"

      # Extract Popularity Change
      popularity_change_text = row.at_css('.byted-Table-Cell:nth-child(4) .KeywordTable_postChangeColumn__9JAGz')&.text&.strip
      popularity_change = extract_percentage(popularity_change_text)
      puts "Popularity Change: #{popularity_change}"

      # Extract CTR (Click Through Rate)
      ctr_text = row.at_css('.byted-Table-Cell:nth-child(5) .KeywordTable_column__MJO36')&.text&.strip
      ctr = convert_to_numeric(ctr_text)
      puts "CTR: #{ctr}"

      # Extract CVR (Conversion Rate)
      cvr_text = row.at_css('.byted-Table-Cell:nth-child(6) .KeywordTable_column__MJO36')&.text&.strip
      cvr = convert_to_numeric(cvr_text)
      puts "CVR: #{cvr}"

      # Extract CPA (Cost Per Action)
      cpa_text = row.at_css('.byted-Table-Cell:nth-child(7) .KeywordTable_column__MJO36')&.text&.strip
      cpa = convert_to_numeric(cpa_text)
      puts "CPA: #{cpa}"

      # Extract Cost
      cost_text = row.at_css('.byted-Table-Cell:nth-child(8) .KeywordTable_column__MJO36')&.text&.strip
      cost = convert_to_numeric(cost_text)
      puts "Cost: #{cost}"

      # Extract Impression Count
      impression_text = row.at_css('.byted-Table-Cell:nth-child(9) .KeywordTable_column__MJO36')&.text&.strip
      impression_count = convert_to_numeric(impression_text)
      puts "Impression Count: #{impression_count}"

      # Extract 6s View Rate
      view_rate_6s_text = row.at_css('.byted-Table-Cell:nth-child(10) .KeywordTable_column__MJO36')&.text&.strip
      view_rate_6s = convert_to_numeric(view_rate_6s_text)
      puts "6s View Rate: #{view_rate_6s}"

      # Extract Like Count
      like_count_text = row.at_css('.byted-Table-Cell:nth-child(11) .KeywordTable_column__MJO36')&.text&.strip
      like_count = convert_to_numeric(like_count_text)
      puts "Like Count: #{like_count}"

      # Extract Share Count
      share_count_text = row.at_css('.byted-Table-Cell:nth-child(12) .KeywordTable_column__MJO36')&.text&.strip
      share_count = convert_to_numeric(share_count_text)
      puts "Share Count: #{share_count}"

      # Extract Comment Count
      comment_count_text = row.at_css('.byted-Table-Cell:nth-child(13) .KeywordTable_column__MJO36')&.text&.strip
      comment_count = convert_to_numeric(comment_count_text)
      puts "Comment Count: #{comment_count}"

      # Find or initialize the trend based on the keyword (title)
      trend = Trend.find_or_initialize_by(title: keyword)
      trend.rank = rank
      trend.popularity = popularity
      trend.popularity_change = popularity_change
      trend.ctr = ctr
      trend.cvr = cvr
      trend.cpa = cpa
      trend.cost = cost
      trend.impression_count = impression_count
      trend.view_rate_6s = view_rate_6s
      trend.like_count = like_count
      trend.share_count = share_count
      trend.comment_count = comment_count
      trend.tiktok_page = 'keyword'
      trend.platform = 'tiktok'
      trend.display = true if trend.display.nil?
      trend.save!
      puts "Saved/Updated Trend ##{trend.id} - #{trend.title} (Popularity: #{popularity}, Rank: #{rank})"
    end
  rescue => e
    puts "Error in main scraper process: #{e.message}"
    puts e.backtrace
  end

  private

  # Helper method to convert any numeric values (e.g., '569K', '653 USD') into integers
  def convert_to_numeric(value)
    return 0 if value.nil? || value.empty?
    case value
    when /(\d+)(K)/
      return $1.to_i * 1000  # Convert 'K' to thousands
    when /(\d+)(M)/
      return $1.to_i * 1_000_000  # Convert 'M' to millions
    when /(\d+)(USD|€)/
      return $1.to_i  # Convert 'USD' or '€' to numbers
    else
      return value.to_i  # Default case: just return the number if no unit found
    end
  end

  # Helper method to extract the percentage from text (e.g., '112.50%')
  def extract_percentage(value)
    return nil if value.nil? || value.empty?  # Skip empty or nil values
    if value.match(/(\d+(\.\d+)?)%/)
      return $1.to_f
    else
      return nil
    end
  end
end
