class ExportsController < ChouetteController
  include PolicyChecker
  include RansackDateFilter
  include IevInterfaces
  skip_before_action :authenticate_user!, only: [:upload]
  skip_before_action :verify_authenticity_token, only: [:upload]
  defaults resource_class: Export::Base, collection_name: 'exports', instance_name: 'export'

  def upload
    if params[:token] == resource.token_upload
      resource.file = params[:file]
      resource.save!
      render json: {status: :ok}
    else
      user_not_authorized
    end
  end

  def new
    referentials = parent.referentials.exportable.pluck(:id)
    referentials += parent.workgroup.output.referentials.pluck(:id)
    @referentials = Referential.where(id: referentials).order("created_at desc")
    new!
  end

  private

  def index_model
    Export::Base
  end

  def build_resource
    Export::Base.force_load_descendants if Rails.env.development?
    @export ||= Export::Base.new(*resource_params) do |export|
      export.workbench = parent
      export.creator   = current_user.name
    end
    @export
  end

  def export_params
    permitted_keys = %i(name type referential_id)
    export_class = params[:export] && params[:export][:type] && params[:export][:type].safe_constantize
    if export_class
      permitted_keys += export_class.options.keys
    end
    params.require(:export).permit(permitted_keys)
  end

  def decorate_collection(exports)
    ExportDecorator.decorate(
      exports,
      context: {
        workbench: @workbench
      }
    )
  end
end
