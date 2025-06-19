class ApplicationController < ActionController::API
  include Pundit::Authorization

  # Disable session for Devise in API mode
  before_action :skip_session_storage

  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :role])
  end

  private

  def skip_session_storage
    request.session_options[:skip] = true
  end

  def user_not_authorized
    render json: { error: 'You are not authorized to perform this action.' }, status: :forbidden
  end
end
