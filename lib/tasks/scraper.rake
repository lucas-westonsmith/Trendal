namespace :scraper do
  desc 'Scrape hashtags TikTok'
  task tiktok_hashtag: :environment do
    TiktokHashtagScraper.new.call
  end
  desc 'Scrape keywords TikTok'
  task tiktok_keyword: :environment do
    TiktokKeywordScraper.new.call
  end
  desc 'Scrape trends Youtube'
  task youtube: :environment do
    YoutubeScraper.new.call
  end
end
