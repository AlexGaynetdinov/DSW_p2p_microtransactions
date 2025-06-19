class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  # Skip Devise's default session storage for API mode
  def sign_up(resource_name, resource)
    # Prevent Devise from signing in and using sessions
  end

  def store_location_for(resource_or_scope, _location)
    # Prevent redirect tracking
  end
  

  # Override to avoid flash usage in API mode
  def require_no_authentication
    if current_user
      render json: { error: 'You are already signed up.' }, status: :unprocessable_entity
    end
  end

  private

  def respond_with(resource, _opts = {})
    if resource.persisted?
      render json: {
        message: 'Signed up successfully.',
        user: resource,
        token: request.env['warden-jwt_auth.token']
      }, status: :ok
    else
      render json: {
        message: 'Sign up failed.',
        errors: resource.errors.full_messages
      }, status: :unprocessable_entity
    end
  end
end