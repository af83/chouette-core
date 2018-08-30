class VehicleJourneysCollectionsController < ChouetteController
  include ReferentialSupport

  respond_to :json
  belongs_to :referential do
    belongs_to :line, :parent_class => Chouette::Line do
      belongs_to :route, :parent_class => Chouette::Route
    end
  end
  alias_method :route, :parent
  include PolicyChecker

  def update
    state = JSON.parse request.raw_post
    @resources = Chouette::VehicleJourney.state_update route, state
    errors = state.any? {|item| item['errors']}

    respond_to do |format|
      format.json { render json: state, status: errors ? :unprocessable_entity : :ok }
    end
  end
end
