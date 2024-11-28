namespace :scraper do
  desc 'Scrape hashtags TikTok'
  task tiktok: :environment do
    TiktokScraper.new.call

  end
  desc 'Scrape trends Youtube'
  task youtube: :environment do
    YoutubeScraper.new.call
  end
end
