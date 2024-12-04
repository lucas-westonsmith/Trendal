class PredictionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @favorite_trends = current_user.favorite.trends

    if params[:trend_ids].present? && params[:industry].present?
      Rails.logger.debug "Trend IDs: #{params[:trend_ids]}, Industry: #{params[:industry]}"  # Debugging line

      industry = params[:industry] # Get the selected industry

      # Generate predictions for selected trends and industry
      @predictions = []
      params[:trend_ids].each do |trend_id|
        trend = Trend.find(trend_id)
        @predictions.concat(generate_predictions(trend, industry))  # Add all predictions to the array
      end
    else
      Rails.logger.debug "No trends or industry selected."
    end
  end

  private

  def generate_predictions(trend, industry)
    # Initialize OpenAI client
    client = OpenAI::Client.new

    # Generate multiple prompts to get different responses
    prompts = [
      " Avoid any AI-related disclaimers. Give me a detailed analysis of  the trend '#{trend.title}' on '#{trend.platform}', and try to guess the trend's future development in the #{industry} industry. Avoid any AI-related disclaimers or phrases like 'I predict'",
      "Analyze the future trends stemming from '#{trend.title}' in the #{industry} industry. Listing the relevant hashtags and including a confidence score above 80%. Be straightforward and don't use any disclaimers about AI limitations.",
      "Describe future trends emerging from '#{trend.title}' in the #{industry} industry, showing relevant hashtags. Keep the response direct and creative, giving a confidence score between 60% and 80%. Avoid any AI-related disclaimers or phrases like 'I predict'.",
      "Based on '#{trend.title}' in the #{industry} industry, predict new trends and relevant hashtags. Provide a creative response with a confidence score between 0% and 40%. Focus on unique and fresh trends, avoiding phrases like 'I predict' or 'as an AI'."
    ]

    # Request multiple predictions from OpenAI API
    prompts.each_with_index.map do |prompt, index|
      chatgpt_response = client.chat(
        parameters: {
          model: "gpt-4",
          messages: [{ role: "user", content: prompt }],
          max_tokens: 200
        }
      )

      # Extract the generated text from the chat response
      prediction_text = chatgpt_response["choices"][0]["message"]["content"].strip

      # Check if it's the first prompt and create a different class or title
      if index == 0
        # Creating a special class or title for the first prompt
        Prediction.create!(
          title: "Detailed Analysis for #{trend.title} in the #{industry} industry",
          description: prediction_text,
          prediction_type: 'detailed_analysis'  # A custom field for differentiating this prediction type
        )
      else
        # Creating regular predictions for other prompts
        Prediction.create!(
          description: prediction_text,
        )
      end
    end
  end
end
