class PredictionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @favorite_trends = current_user.favorite.trends

    if params[:trend_ids].present?
      Rails.logger.debug "Trend IDs: #{params[:trend_ids]}"  # Debugging line
      @predictions = params[:trend_ids].map do |trend_id|
        trend = Trend.find(trend_id)
        generate_prediction(trend)
      end
    else
      Rails.logger.debug "No trends selected."
    end
  end

  private

  def generate_prediction(trend)
    # Initialize OpenAI client
    client = OpenAI::Client.new

    # Generate prompt based on the trend name
    message_content = "How is the current activity on the trend '#{trend.title}'  on '#{trend.platform}', what will be development of this trend,
     and based on this trend predcit new ones, also give me a confidence score that goes between 0 and 100% (never give less than 20).
     I dont want any of your awnser, like 'As an Ai i cant predict the future' just go straight to the point, also i dont want you to say things like 'For social media managers and companies' just show the #s,
     also on the hashtags use no capital letter  and dont say 'i predict' dont sound like an ai? make the sentence fit in a setence that would spend me a maximum od 100 tokens"

    # Request a prediction from the OpenAI API using gpt-4 model
    chatgpt_response = client.chat(
      parameters: {
        model: "gpt-4",
        messages: [
          { role: "user", content: message_content }
        ],
        max_tokens: 100
      }
    )

    # Extract the generated text from the chat response
    prediction_text = chatgpt_response["choices"][0]["message"]["content"].strip

    # Optionally, you can calculate a confidence score based on some factors or use a fixed value
    confidence_score = 0.85 # Example placeholder value

    # Create or find an existing prediction based on the generated text
    Prediction.create!(
      title: "Prediction for #{trend.title}",
      description: prediction_text,
    )
  end
end
