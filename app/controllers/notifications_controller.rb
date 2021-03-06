class NotificationsController < ChouetteController
  def index
    render json: {} && return unless params[:channel]

    notifications = Notification.where(channel: params[:channel]).order(:created_at)
    if params[:lastSeen] && params[:lastSeen].to_i > 0
      notifications = notifications.where('id > ?', params[:lastSeen].to_i)
    else
      notifications = [notifications.last]
    end
    render json: notifications.compact.map(&:full_payload)
  end
end
