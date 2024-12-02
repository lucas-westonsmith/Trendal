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
      "Give me a detailed analysis of the current activity around the trend '#{trend.title}' on '#{trend.platform}', and predict the trend's future development in the #{industry} industry. Provide a concise answer with 50 words and include relevant hashtags. The confidence score should be higher than 80%. Avoid any AI-related disclaimers or phrases like 'I predict'",
     "Analyze the future trends stemming from '#{trend.title}' in the #{industry} industry. Provide a focused answer of 50 words, listing the relevant hashtags and including a confidence score above 80%. Be straightforward and don't use any disclaimers about AI limitations.",
     "Describe future trends emerging from '#{trend.title}' in the #{industry} industry with 50 words, showing relevant hashtags. Keep the response direct and creative, giving a confidence score between 60% and 80%. Avoid any AI-related disclaimers or phrases like 'I predict'.",
    ]

    # Request multiple predictions from OpenAI API
    prompts.map do |prompt|
      chatgpt_response = client.chat(
        parameters: {
          model: "gpt-4",
          messages: [{ role: "user", content: prompt }],
          max_tokens: 100
        }
      )

      # Extract the generated text from the chat response
      prediction_text = chatgpt_response["choices"][0]["message"]["content"].strip

      # Create and store a prediction for each prompt
      Prediction.create!(
        title: "#{trend.title} in the #{industry} industry",
        description: prediction_text,
      )
    end
  end
end
