class TiktokHashtagScraper
  COUNTRIES = %w[BR DE FR IT JP PT ZA ES GB US].freeze
  PERIODS = %w[7 30 120 365].freeze

  def call
    puts "Starting to scrape TikTok hashtags..."

    url = "https://ads.tiktok.com/business/creativecenter/inspiration/popular/hashtag/pc/en"
    html = URI.open(url).read
    doc = Nokogiri::HTML(html)

  # Liste des tendances actuelles scrapées
    scraped_trend_titles = doc.css('span.CardPc_titleText__RYOWo').map(&:text).map(&:strip)
    puts "Scraped Trend Titles: #{scraped_trend_titles}"

    puts "Checking old trends for deletion or update..."

    # Filtrer uniquement les tendances TikTok avec tiktok_page = 'hashtag'
    Trend.where(platform: 'tiktok', tiktok_page: 'hashtag').find_each do |trend|
      if trend.favorites.exists?
        # Si la tendance est dans les favoris, mais n'est pas dans la nouvelle liste scrappée
        if !scraped_trend_titles.include?(trend.title)
          trend.update(rank: nil, display: false)
          puts "Trend ##{trend.id} (#{trend.title}) is in favorites but no longer in scraped list, display set to false."
        else
          trend.counts.destroy_all
          puts "Trend ##{trend.id} (#{trend.title}) is in favorites. Replacing information inside of it"
        end
      else
        # Si la tendance n'est pas dans les favoris
          trend.destroy
          puts "Trend ##{trend.id} (#{trend.title}) has been deleted as it is not in favorites and no longer in scraped list."
      end
    end



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
      industry = card.at_css('div.CardPc_infoContent__qtNzO span:nth-child(2)')&.text&.strip
      industry = "" if industry.nil?
      puts "Industry: '#{industry}'"

      trend = Trend.find_by(title: hashtag)
      if trend
      trend.assign_attributes(
        title: hashtag,
        rank: rank,
        count: posts,
        industry: industry,
        platform: 'tiktok',
        display: trend.display.nil? ? true : trend.display,
        tiktok_page: 'hashtag'
      )
    else
      trend = Trend.new(
        title: hashtag,
        rank: rank,
        count: posts,
        industry: industry,
        platform: 'tiktok',
        display: trend.display.nil? ? true : trend.display,
        tiktok_page: 'hashtag'
      )
    end

    if trend.changed?
      trend.save!
      puts "Saved/Updated Trend ##{trend.id} - #{trend.title}"
    else
      puts "Trend ##{trend.id} - #{trend.title} is up to date, skipping save."
    end

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
      count = Count.create(
        country: country,
        period: period,
        number: post_count_in_period_converted,
        trend: trend
      )
      puts "Saved Count for Trend ##{trend.id} - Country: #{country}, Period: #{period}"

      # Extract and save video links
      fetch_video_links(doc, trend, count)

      # Fetch and save related interests
      fetch_related_interests(doc, trend, count)

    rescue => e
      puts "Error fetching country data for #{trend.title} (#{country}, #{period}): #{e.message}"
      puts e.backtrace
    end
  end

  def fetch_video_links(doc, trend, count = nil)
    # Vérifiez que count est valide si vous souhaitez le passer
    if count.nil?
      puts "Skipping count association as no valid count was provided."
      return
    else
      puts "Creating videos for count: #{count.id}, trend: #{trend.title}"
    end

    # Extraire jusqu'à 5 liens vidéo depuis le document HTML
    video_links = doc.css('blockquote.IframeEmbedVideo_embedQuote__BdyWZ').map { |blockquote| blockquote['cite'] }.first(3)

    puts "Found #{video_links.length} video links for trend #{trend.title}"

    # Sauvegarder les liens vidéo
    video_links.each_with_index do |link, index|
      puts "Video ##{index + 1}: #{link}"

      Video.create!(
        url: link,
        trend: trend,
        count: count
      )
    end
  end

  def fetch_related_interests(doc, trend, count)
    puts "Fetching related interests for trend: #{trend.title}"

    # Récupérer le conteneur plus large qui contient tous les éléments d'intérêt
    container = doc.css('div.Interest_interestItemWraper__cSbd2')

    # Compteur pour numérotation unique
    interest_counter = 1

    # Itérer sur chaque conteneur d'intérêts
    container.each_with_index do |item_container, container_index|
      # Récupérer les éléments d'intérêt dans le conteneur (chaque div.Interest_interestItem__WG9UP)
      interest_items = item_container.css('div.Interest_interestItem__WG9UP')

      # Itérer sur les éléments d'intérêt
      interest_items.each do |item|
        # Chercher tous les labels d'intérêts dans le même conteneur
        interest_names = item.css('span.Interest_interestItemLabel__Cs0r8')

        # Chercher tous les scores associés dans le même conteneur
        interest_scores = item.css('span.Interest_interestItemValue__lMLsg')

        # Itérer sur chaque label et son score
        interest_names.each_with_index do |interest_name, name_index|
          # S'assurer que nous avons un score pour chaque nom
          interest_score = interest_scores[name_index]&.text&.strip

          # Vérifier que les informations sont présentes avant de les traiter
          if interest_name.text.present? && interest_score.present?
            begin
              # Convertir la valeur du score en entier
              interest_score = interest_score.to_i

              # Affichage simplifié avec un compteur global
              puts "Related Interest ##{interest_counter}: #{interest_name.text.strip} (Score: #{interest_score})"

              # Sauvegarder l'intérêt dans la base de données
              RelatedInterest.create!(
                title: interest_name.text.strip,
                score: interest_score,
                trend: trend,
                count: count
              )

              # Incrémenter le compteur pour chaque intérêt
              interest_counter += 1
            rescue => e
              puts "Error saving RelatedInterest ##{interest_counter}: #{e.message}"
            end
          else
            puts "Skipping empty or incomplete related interest item (index: #{interest_counter})"
          end
        end
      end
    end
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
end
