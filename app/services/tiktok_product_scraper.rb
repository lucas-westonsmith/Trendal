class TiktokProductScraper
  COUNTRIES = %w[BR DE FR IT JP PT ZA ES GB US].freeze
  PERIODS = %w[7 30 120 365].freeze

  def call
    puts "Starting to scrape TikTok products..."

    url = "https://ads.tiktok.com/business/creativecenter/top-products/pc/en"
    html = URI.open(url).read
    doc = Nokogiri::HTML(html)

    scraped_trend_titles = doc.css('.byted-Table-Cell:nth-child(2) .creative-component-single-line').map(&:text).map(&:strip)

    puts "Checking old trends for deletion or update..."

    # Filtrer uniquement les tendances TikTok et avec tiktok_page = 'product'
    Trend.where(platform: 'tiktok', tiktok_page: 'product').find_each do |trend|
      if trend.favorites.exists?
        # Si la tendance est dans les favoris, mais n'est pas dans la nouvelle liste scrappée
        if !scraped_trend_titles.include?(trend.title)
          trend.update(display: false)
          puts "Trend ##{trend.id} (#{trend.title}) is in favorites but no longer in scraped list, display set to false."
        else
          puts "Trend ##{trend.id} (#{trend.title}) is in favorites, no action needed."
        end
      else
        # Si la tendance n'est pas dans les favoris
        if !scraped_trend_titles.include?(trend.title)
          trend.destroy
          puts "Trend ##{trend.id} (#{trend.title}) has been deleted as it is not in favorites and no longer in scraped list."
        else
          puts "Trend ##{trend.id} (#{trend.title}) is up to date, skipping deletion."
        end
      end
    end

    product_rows = doc.css('.byted-Table-Row')[1..-1]
    puts "Found #{product_rows.length} product rows."

    product_rows.each_with_index do |row, index|
      begin
        puts "Processing product #{index + 1}/#{product_rows.length}"

        product = row.at_css('.CategoryTrendListTable_nameWrap__g2loc .CategoryTrendListTable_categoryName__UZkSM')&.text&.strip
        puts "Product Name: #{product}" if product
        next unless product

        industry = row.at_css('.CategoryTrendListTable_categoryLevel__tnnmA')&.text&.strip
        puts "Industry: #{industry}" if industry

        popularity_text = row.at_css('.byted-Table-Cell:nth-child(2)')&.text&.strip
        puts "Popularity Text: #{popularity_text}" if popularity_text
        popularity = convert_to_numeric(popularity_text)
        puts "Popularity: #{popularity}"

        popularity_change_text = row.at_css('.byted-Table-Cell:nth-child(3) .CategoryTrendListTable_postChange__R7JcS')&.text&.strip
        puts "Popularity Change Text: #{popularity_change_text}" if popularity_change_text
        popularity_change = extract_percentage(popularity_change_text)
        puts "Popularity Change: #{popularity_change}"

        ctr_text = row.at_css('.byted-Table-Cell:nth-child(4)')&.text&.strip
        puts "CTR Text: #{ctr_text}" if ctr_text
        ctr = convert_to_numeric(ctr_text)
        puts "CTR: #{ctr}"

        cvr_text = row.at_css('.byted-Table-Cell:nth-child(5)')&.text&.strip
        puts "CVR Text: #{cvr_text}" if cvr_text
        cvr = convert_to_numeric(cvr_text)
        puts "CVR: #{cvr}"

        cpa_text = row.at_css('.byted-Table-Cell:nth-child(6)')&.text&.strip
        puts "CPA Text: #{cpa_text}" if cpa_text
        cpa = convert_to_numeric(cpa_text)
        puts "CPA: #{cpa}"

        cost_text = row.at_css('.byted-Table-Cell:nth-child(7)')&.text&.strip
        puts "Cost Text: #{cost_text}" if cost_text
        cost = convert_to_numeric(cost_text)
        puts "Cost: #{cost}"

        impression_text = row.at_css('.byted-Table-Cell:nth-child(10)')&.text&.strip
        puts "Impression Text: #{impression_text}" if impression_text
        impression_count = convert_to_numeric(impression_text)
        puts "Impression Count: #{impression_count}"

        view_rate_6s_text = row.at_css('.byted-Table-Cell:nth-child(11)')&.text&.strip
        puts "View Rate 6s Text: #{view_rate_6s_text}" if view_rate_6s_text
        view_rate_6s = convert_to_numeric(view_rate_6s_text)
        puts "View Rate 6s: #{view_rate_6s}"

        like_count_text = row.at_css('.byted-Table-Cell:nth-child(12)')&.text&.strip
        puts "Like Count Text: #{like_count_text}" if like_count_text
        like_count = convert_to_numeric(like_count_text)
        puts "Like Count: #{like_count}"

        share_count_text = row.at_css('.byted-Table-Cell:nth-child(8)')&.text&.strip
        puts "Share Count Text: #{share_count_text}" if share_count_text
        share_count = convert_to_numeric(share_count_text)
        puts "Share Count: #{share_count}"

        comment_count_text = row.at_css('.byted-Table-Cell:nth-child(9)')&.text&.strip
        puts "Comment Count Text: #{comment_count_text}" if comment_count_text
        comment_count = convert_to_numeric(comment_count_text)
        puts "Comment Count: #{comment_count}"

        trend = Trend.find_by(title: product)

        if trend
          trend.assign_attributes(
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
            tiktok_page: 'product',
            platform: 'tiktok',
            industry: industry,
            display: trend.display.nil? ? true : trend.display
          )
        else
          # Si la tendance n'existe pas, créez-en une nouvelle
          trend = Trend.new(
            title: product,
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
            tiktok_page: 'product',
            platform: 'tiktok',
            industry: industry,
            display: true
          )
        end
        if trend.changed?
          trend.save!
          puts "Saved/Updated Trend ##{trend.id} - #{trend.title} (Popularity: #{popularity})"
        else
          puts "Trend ##{trend.id} - #{trend.title} is up to date, skipping save."
        end

      rescue => e
        puts "Error during processing product #{index + 1}: #{e.message}"
        puts e.backtrace
      end
    end
  end

  private

  def convert_to_numeric(value)
    return 0 if value.nil? || value.empty?

    case value
    when /(\d+)(K)/
      return $1.to_i * 1000  # Convert 'K' to thousands (still integer)
    when /(\d+)(M)/
      return $1.to_i * 1_000_000  # Convert 'M' to millions (still integer)
    when /(\d+)(B)/
      return $1.to_i * 1_000_000_000  # Convert 'B' to billions (still integer)
    when /(\d+)(USD|€)/
      return $1.to_f  # Convert 'USD' or '€' to float to keep decimals
    when /(\d+(\.\d+)?)%/  # Capture percentages with decimal values
      return $1.to_f  # Convert percentage directly to float
    else
      # If the value doesn't match any specific case, simply return it as a float
      return value.to_f
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
