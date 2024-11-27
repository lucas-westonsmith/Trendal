class YoutubeScraper
  require 'rest-client'
  require 'json'

  API_KEY = 'AIzaSyCN7iVp8jk11jmj6x-DnTvVIyWT2FakfiU'  # Replace with your actual API key
  API_URL = "https://www.googleapis.com/youtube/v3/videos?part=snippet,contentDetails,statistics&chart=mostPopular&regionCode=PT&maxResults=50&key=#{API_KEY}"

  def call
    # Fetch YouTube trending videos
    response = RestClient.get(API_URL)

    # Parse the JSON response
    video_data = JSON.parse(response.body)

    # Process and save each video
    video_data['items'].each do |video|
      title = video['snippet']['title']
      view_count = video['statistics']['viewCount'].to_i
      like_count = video['statistics']['likeCount'].to_i

      # Calculate engagement count
      engagement_count = view_count + like_count

      # Create or update a trend in the database
      trend = Trend.find_or_create_by(title: title)

      # Update the trend record with the new data
      trend.update(
        title: title,
        engagement_count: engagement_count
      )
    end
  end
end
