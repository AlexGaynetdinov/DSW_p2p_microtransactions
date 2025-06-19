class Users::SessionsController < Devise::SessionsController
  respond_to :json

  # Skip Devise's default session storage for API mode
  skip_before_action :verify_signed_out_user
  skip_before_action :require_no_authentication, only: [:create]

  def sign_up(resource_name, resource)
    # Prevent storing sessions
  end

  def store_location_for(resource_or_scope, _location)
    # Prevent redirect tracking
  end
  

  private

  def respond_with(resource, _opts = {})
    if current_user
      render json: {
        message: 'Logged in successfully.',
        user: current_user,
        token: request.env['warden-jwt_auth.token']
      }, status: :ok
    else
      render json: {
        message: 'Login failed.',
        user: nil,
        token: nil
      }, status: :unauthorized
    end
  end

  def respond_to_on_destroy
    render json: { message: 'Logged out successfully.' }, status: :ok
  end
end