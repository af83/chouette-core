class SubscriptionsController < ChouetteController
  layout "devise"

  skip_before_action :authenticate_user!
  before_action :check_feature_is_activated

  def devise_mapping
    Devise.mappings[:user]
  end
  helper_method :devise_mapping

  def resource
    @subscription ||= Subscription.new subscription_params
  end

  def resource_class
    Subscription
  end

  def create
    if resource.save
      sign_in resource.user
      redirect_to "/"
    else
      render "devise/sessions/new"
    end
  end

  def subscription_params
    params.require(:subscription).permit %i(organisation_name user_name email password password_confirmation)
  end

  private
  def check_feature_is_activated
    not_found unless Rails.application.config.accept_user_creation
  end
end
