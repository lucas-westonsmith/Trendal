class YoutubeScraper
  require 'rest-client'
  require 'json'
  require 'active_support/core_ext/numeric/time' # For time conversions like duration

  API_KEY = ENV['YOUTUBE_API_KEY']  # Replace with your actual API key
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
      description = video['snippet']['description']
      video_duration = video['contentDetails']['duration']
      published_at = video['snippet']['publishedAt']
      channel_name = video['snippet']['channelTitle']
      tags = video['snippet']['tags'] || []  # Extract tags, defaults to empty array if not present
      video_id = video['id']

      # Build the video URL
      video_url = "https://www.youtube.com/watch?v=#{video_id}"

      # Convert tags array to a string for storing in the database
      formatted_tags = tags.join(', ')  # Join tags with commas for storage

      # Format video duration from ISO 8601 format (e.g., PT15M33S -> "15:33")
      formatted_duration = format_duration(video_duration)

      # Create or update a trend in the database
      trend = Trend.find_or_create_by(title: title)

      # Update the trend record with the new data
      trend.update(
        title: title,
        like_count: like_count,
        view_count: view_count,
        platform: 'youtube',
        hashtags: formatted_tags,
        video_duration: formatted_duration,
        published_at: published_at,
        channel_name: channel_name,
        video_url: video_url  # Save the video URL
      )
    end
  end

  private

  # Helper method to format video duration from ISO 8601 format
  def format_duration(duration)
    # Example: PT15M33S -> 15:33
    match = duration.match(/PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?/)
    hours = match[1].to_i if match[1]
    minutes = match[2].to_i if match[2]
    seconds = match[3].to_i if match[3]

    # Convert to a more readable format
    if hours && minutes && seconds
      "#{hours}:#{minutes.to_s.rjust(2, '0')}:#{seconds.to_s.rjust(2, '0')}"
    elsif minutes && seconds
      "#{minutes}:#{seconds.to_s.rjust(2, '0')}"
    elsif minutes
      "#{minutes}:00"
    elsif seconds
      "0:#{seconds.to_s.rjust(2, '0')}"
    else
      "0:00"
    end
  end
end
