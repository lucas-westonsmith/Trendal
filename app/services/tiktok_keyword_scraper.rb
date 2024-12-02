class TiktokKeywordScraper
  COUNTRIES = %w[BR DE FR IT JP PT ZA ES GB US].freeze
  PERIODS = %w[7 30 120 365].freeze

  def call
    puts "Starting to scrape TikTok keywords..."

    url = "https://ads.tiktok.com/business/creativecenter/keyword-insights/pc/en"
    html = URI.open(url).read
    doc = Nokogiri::HTML(html)

    # Liste des tendances scrapées
    scraped_trend_titles = doc.css('.byted-Table-Cell:nth-child(2) .creative-component-single-line').map(&:text).map(&:strip)

    puts "Marking old trends as obsolete..."

    # Filtrer uniquement les tendances TikTok et avec tiktok_page = 'keyword'
    Trend.where(platform: 'tiktok', tiktok_page: 'keyword').where.not(title: scraped_trend_titles).find_each do |trend|
      # Vérifier si la tendance est dans les favoris
      if trend.favorites.exists?
        puts "Trend ##{trend.id} (#{trend.title}) is in favorites, skipping deletion of associated keyword examples."
      else
        # Supprimer les exemples de mots-clés uniquement pour les tendances non favorites
        puts "Deleting related keyword examples for Trend ##{trend.id} (#{trend.title})"
        trend.keyword_examples.destroy_all
      end

      # Mettre à jour la tendance en marquant comme obsolète
      trend.update(rank: nil, display: false) # Définir "display" à false pour ne plus les montrer
      puts "Trend ##{trend.id} (#{trend.title}) marked as obsolete."
    end

    keyword_rows = doc.css('.byted-Table-Row')[1..-1]
    puts "Found #{keyword_rows.length} keyword rows."

    keyword_rows.each_with_index do |row, index|
      puts "Processing keyword #{index + 1}/#{keyword_rows.length}"

      rank = row.at_css('.byted-Table-Cell:nth-child(1) .KeywordTable_column__MJO36')&.text&.strip.to_i
      keyword = row.at_css('.byted-Table-Cell:nth-child(2) .creative-component-single-line')&.text&.strip
      next unless keyword

      popularity_text = row.at_css('.byted-Table-Cell:nth-child(3) .KeywordTable_column__MJO36')&.text&.strip
      popularity = convert_to_numeric(popularity_text)

      popularity_change_text = row.at_css('.byted-Table-Cell:nth-child(4) .KeywordTable_postChangeColumn__9JAGz')&.text&.strip
      popularity_change = extract_percentage(popularity_change_text)

      ctr_text = row.at_css('.byted-Table-Cell:nth-child(5) .KeywordTable_column__MJO36')&.text&.strip
      ctr = convert_to_numeric(ctr_text)

      cvr_text = row.at_css('.byted-Table-Cell:nth-child(6) .KeywordTable_column__MJO36')&.text&.strip
      cvr = convert_to_numeric(cvr_text)

      cpa_text = row.at_css('.byted-Table-Cell:nth-child(7) .KeywordTable_column__MJO36')&.text&.strip
      cpa = convert_to_numeric(cpa_text)

      cost_text = row.at_css('.byted-Table-Cell:nth-child(8) .KeywordTable_column__MJO36')&.text&.strip
      cost = convert_to_numeric(cost_text)

      impression_text = row.at_css('.byted-Table-Cell:nth-child(9) .KeywordTable_column__MJO36')&.text&.strip
      impression_count = convert_to_numeric(impression_text)

      view_rate_6s_text = row.at_css('.byted-Table-Cell:nth-child(10) .KeywordTable_column__MJO36')&.text&.strip
      view_rate_6s = convert_to_numeric(view_rate_6s_text)

      like_count_text = row.at_css('.byted-Table-Cell:nth-child(11) .KeywordTable_column__MJO36')&.text&.strip
      like_count = convert_to_numeric(like_count_text)

      share_count_text = row.at_css('.byted-Table-Cell:nth-child(12) .KeywordTable_column__MJO36')&.text&.strip
      share_count = convert_to_numeric(share_count_text)

      comment_count_text = row.at_css('.byted-Table-Cell:nth-child(13) .KeywordTable_column__MJO36')&.text&.strip
      comment_count = convert_to_numeric(comment_count_text)

      trend = Trend.find_or_initialize_by(title: keyword)
      trend.assign_attributes(
        rank: rank,
        popularity: popularity,
        popularity_change: popularity_change,
        ctr: ctr,
        cvr: cvr,
        cpa: cpa,
        cost: cost,
        impression_count: impression_count,
        view_rate_6s: view_rate_6s,
        like_count: like_count,
        share_count: share_count,
        comment_count: comment_count,
        tiktok_page: 'keyword',
        platform: 'tiktok',
        display: trend.display.nil? ? true : trend.display
      )
      trend.save!
      puts "Saved/Updated Trend ##{trend.id} - #{trend.title} (Popularity: #{popularity}, Rank: #{rank})"

      # Fetch additional country and period-specific data
      COUNTRIES.each do |country|
        PERIODS.each do |period|
          fetch_country_data(keyword, country, period, trend)
        end
      end
    end
  rescue => e
    puts "Error during scraping: #{e.message}"
    puts e.backtrace
  end

  private

  def fetch_country_data(keyword, country, period, trend)
    formatted_keyword = format_keyword_for_url(keyword)
    url = "https://ads.tiktok.com/business/creativecenter/tiktok-keyword/#{formatted_keyword}/pc/en?countryCode=#{country}&orderBy=1&orderType=2&period=#{period}&page=1"
    html = URI.open(url).read
    doc = Nokogiri::HTML(html)

    scrape_keyword_examples(doc, trend, country, period)

  rescue => e
    puts "Error fetching country data for #{trend.title} (#{country}, #{period}): #{e.message}"
  end

  def scrape_keyword_examples(doc, trend, country, period)
    puts "Scraping keyword examples..."

    keyword_rows = doc.css('.byted-Table-Row')[1..-1].first(20) # On saute la première ligne
    puts "Found #{keyword_rows.length} keyword rows."

    keyword_rows.each_with_index do |row, index|
      puts "Processing keyword example #{index + 1}/#{keyword_rows.length}"

      # Extraction des données
      keyword_phrase = row.at_css('.SentenceTable_sentence__cC8bO')&.text&.strip
      keyword_phrase = keyword_phrase.split("\n").map(&:strip).join(" ") if keyword_phrase

      ctr_text = row.at_css('td[aria-colindex="3"] div')&.text&.strip
      ctr = ctr_text.to_f if ctr_text =~ /\d+(\.\d+)?%/

      video_img = row.at_css('figure img')
      related_videos = video_img ? video_img['src'] : nil

      # Créer l'enregistrement
      KeywordExample.create!(
        keyword_phrase: keyword_phrase,
        ctr: ctr,
        related_videos: related_videos,
        trend: trend,
        country: country,
        period: period
      )

      puts "Saved KeywordExample: #{keyword_phrase}, CTR: #{ctr}, Related Videos: #{related_videos}"
    end
  end


  def format_keyword_for_url(keyword)
    URI.encode_www_form_component(keyword) # Convertit les espaces en %20 et autres caractères spéciaux
  end

  # Helper method to convert any numeric values (e.g., '569K', '653 USD', '2B') into integers
  def convert_to_numeric(value)
    return 0 if value.nil? || value.empty?

    case value
    when /(\d+)(K)/
      return $1.to_i * 1000  # Convert 'K' to thousands
    when /(\d+)(M)/
      return $1.to_i * 1_000_000  # Convert 'M' to millions
    when /(\d+)(B)/
      return $1.to_i * 1_000_000_000  # Convert 'B' to billions
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
