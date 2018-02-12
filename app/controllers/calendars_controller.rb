class CalendarsController < ChouetteController
  include PolicyChecker
  include TimeTablesHelper

  defaults resource_class: Calendar
  before_action :ransack_contains_date, only: [:index]
  respond_to :html
  respond_to :json, only: :show
  respond_to :js, only: :index
  
  belongs_to :workgroup

  def index
    index! do
      @calendars = decorate_calendars(@calendars)
    end
  end

  def show
    show! do
      @year = params[:year] ? params[:year].to_i : Date.today.cwyear
      @calendar = @calendar.decorate(context: {
        workgroup: workgroup
      })
    end
  end

  def month
    @date = params['date'] ? Date.parse(params['date']) : Date.today
    @calendar = resource
  end

  def create
    create! do
      if @calendar.valid? && has_feature?('application_days_on_calendars')
        redirect_to([:edit, @calendar])
        return
      end
    end
  end

  def update
    if params[:calendar]
      super
    else
      state  = JSON.parse request.raw_post
      resource.state_update state
      respond_to do |format|
        format.json { render json: state, status: state['errors'] ? :unprocessable_entity : :ok }
      end
    end
  end

  private

  def decorate_calendars(calendars)
    ModelDecorator.decorate(
      calendars,
      with: CalendarDecorator,
      context: {
        workgroup: workgroup
      }
    )
  end

  def calendar_params
    permitted_params = [:id, :name, :short_name, :shared, periods_attributes: [:id, :begin, :end, :_destroy], date_values_attributes: [:id, :value, :_destroy]]
    permitted_params << :shared if policy(Calendar).share?
    params.require(:calendar).permit(*permitted_params)
  end

  def sort_column
    Calendar.column_names.include?(params[:sort]) ? params[:sort] : 'short_name'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ?  params[:direction] : 'asc'
  end

  protected

  alias_method :workgroup, :parent
  helper_method :workgroup

  def resource
    @calendar ||= workgroup.calendars.where('(organisation_id = ? OR shared = ?)', current_organisation.id, true).find_by_id(params[:id])
  end

  def build_resource
    super.tap do |calendar|
      calendar.workgroup = workgroup
      calendar.organisation = current_organisation
    end
  end

  def collection
    @calendars ||= begin
		    scope = workgroup.calendars.where('(organisation_id = ? OR shared = ?)', current_organisation.id, true)
		    scope = shared_scope(scope)
		    @q = scope.ransack(params[:q])
		    calendars = @q.result
		    calendars = calendars.order(sort_column + ' ' + sort_direction) if sort_column && sort_direction
		    calendars = calendars.paginate(page: params[:page])
                  end 
  end

  def ransack_contains_date
    date =[]
    if params[:q] && !params[:q]['contains_date(1i)'].empty?
      ['contains_date(1i)', 'contains_date(2i)', 'contains_date(3i)'].each do |key|
        date << params[:q][key].to_i
        params[:q].delete(key)
      end
      params[:q]['contains_date'] = Date.new(*date) rescue nil
    end
  end

  def shared_scope scope
    return scope unless params[:q]

    if params[:q][:shared_true] == params[:q][:shared_false]
      params[:q].delete(:shared_true)
      params[:q].delete(:shared_false)
    end

    scope
  end

end