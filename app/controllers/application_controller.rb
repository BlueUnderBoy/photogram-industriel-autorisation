class ApplicationController < ActionController::Base
  include Pundit::Authorization
  
  # after_action :verify_authorized, except: :index
  # after_action :verify_policy_scoped, only: :index

  # If the project is set up with Devise accounts
  # after_action :verify_authorized, unless: :devise_controller?
  # after_action :verify_policy_scoped, only: :index, unless: :devise_controller?


    # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
    allow_browser versions: :modern

  before_action :authenticate_user!
  before_action :set_user_search, if: -> { current_user.present? }
  before_action :configure_permitted_parameters, if: :devise_controller?

  def set_user_search
    @q = User.where.not(id: current_user.id).ransack(params[:q])
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :username, :private, :name, :bio, :website, :avatar_image ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :username, :private, :name, :bio, :website, :avatar_image ])
  end

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    flash[:alert] = "You're not authorized for that. From Application Controller."

    redirect_back(fallback_location: root_url)
  end
end
