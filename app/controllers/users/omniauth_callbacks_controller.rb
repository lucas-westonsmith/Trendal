# app/controllers/users/omniauth_callbacks_controller.rb
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # Action to handle the callback from Google
  def google_oauth2
    # Grab user data from Google
    user_info = request.env["omniauth.auth"]

    # Find or create the user based on the OAuth data
    user = User.find_or_create_by(provider: user_info['provider'], uid: user_info['uid']) do |u|
      u.email = user_info['info']['email']
      u.first_name = user_info['info']['first_name']
      u.last_name = user_info['info']['last_name']
    end

    # Sign the user in after successful login
    sign_in_and_redirect user, event: :authentication
  end
end
