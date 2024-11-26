namespace :scraper do
  desc 'Scrape hashtags TikTok'
  task tiktok: :environment do
    TiktokScraper.new.call
  end
end
