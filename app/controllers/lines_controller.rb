class LinesController < ChouetteController
  include ApplicationHelper
  include Activatable
  include PolicyChecker
  include TransportModeFilter

  defaults :resource_class => Chouette::Line
  respond_to :html
  respond_to :xml
  respond_to :json
  respond_to :kml, :only => :show
  respond_to :js, :only => :index

  belongs_to :line_referential

  def index
    @hide_group_of_line = line_referential.group_of_lines.empty?

    # Selected2 autocompletion purpose
    respond_to do |format|
      format.json do
        @lines = line_referential.lines
        @lines = @lines.where("id IN (#{@lines.by_name(params[:q]).select(:id).to_sql}) OR id IN (#{@lines.ransack(number_or_company_name_cont: params[:q]).result.select(:id).to_sql})") if (params[:q].present?)
      end

      format.html do
        index! do
          @lines = LineDecorator.decorate(
            @lines,
            context: {
              line_referential: @line_referential,
              current_organisation: current_organisation
            }
          )

          if collection.out_of_bounds?
            redirect_to params.merge(:page => 1)
          end
        end
      end
    end
  end

  def available_line_notices
    resource
    autocomplete_collection = @line.line_referential.line_notices
    if params[:q].present?
      autocomplete_collection = autocomplete_collection.autocomplete(params[:q]).order(:name)
    else
      autocomplete_collection = autocomplete_collection.order('created_at desc')
    end

    render json: autocomplete_collection.select(:title, :id).limit(10).map{|r| {name: r.title, id: r.id}}
  end

  def show
    @group_of_lines = resource.group_of_lines
    show! do
      @line = @line.decorate(context: {
        line_referential: @line_referential,
        current_organisation: current_organisation
      })
    end
  end

  def new
    authorize resource_class
    build_resource
    @line.transport_mode = Chouette::Line.sorted_transport_modes.first
    @line.color = '#FFFFFF'
    super
  end

  def create
    authorize resource_class
    super
  end

  def update
    update! do
      if line_params[:line_notice_ids]
        [@line_referential, @line, :line_notices]
      else
        [@line_referential, @line]
      end
    end
  end

  # overwrite inherited resources to use delete instead of destroy
  # foreign keys will propagate deletion)
  def destroy_resource(object)
    object.delete
  end

  def delete_all
    objects =
      get_collection_ivar || set_collection_ivar(end_of_association_chain.where(:id => params[:ids]))
    objects.each { |object| object.delete }
    respond_with(objects, :location => smart_collection_url)
  end

  def name_filter
    respond_to do |format|
      format.json { render :json => filtered_lines_maps}
    end
  end

  protected

  def filtered_lines_maps
    filtered_lines.collect do |line|
      { :id => line.id, :name => (line.published_name ? line.published_name : line.name) }
    end
  end

  def filtered_lines
    line_referential.lines.by_text(params[:q])
  end

  def collection
    @lines ||= begin
      %w(network_id company_id group_of_lines_id comment_id).each do |filter|
        if params[:q] && params[:q]["#{filter}_eq"] == '-1'
          params[:q]["#{filter}_eq"] = ''
          params[:q]["#{filter}_blank"] = '1'
        end
      end

      scope = ransack_status line_referential.lines
      scope = ransack_transport_mode scope
      @q = scope.ransack(params[:q])

      if sort_column && sort_direction
        lines ||= @q.result(:distinct => true).order(sort_column + ' ' + sort_direction).paginate(:page => params[:page]).includes([:network, :company])
      else
        lines ||= @q.result(:distinct => true).order(:number).paginate(:page => params[:page]).includes([:network, :company])
      end
      lines
    end
  end

  alias_method :line_referential, :parent

  private

  def sort_column
    (Chouette::Line.column_names + ['companies.name', 'networks.name']).include?(params[:sort]) ? params[:sort] : 'number'
  end
  def sort_direction
    %w[asc desc].include?(params[:direction]) ?  params[:direction] : 'asc'
  end

  alias_method :current_referential, :line_referential
  helper_method :current_referential

  def line_params
    out = params.require(:line)
    out = out.permit(
      :activated,
      :active_from,
      :active_until,
      :transport_mode,
      :network_id,
      :company_id,
      :objectid,
      :object_version,
      :name,
      :number,
      :published_name,
      :transport_mode,
      :registration_number,
      :comment,
      :mobility_restricted_suitability,
      :int_user_needs,
      :flexible_service,
      :group_of_lines,
      :group_of_line_ids,
      :group_of_line_tokens,
      :url,
      :color,
      :text_color,
      :stable_id,
      :transport_submode,
      :seasonal,
      :line_notice_ids,
      :secondary_company_ids => [],
      footnotes_attributes: [:code, :label, :_destroy, :id]
    )
    out[:line_notice_ids] = out[:line_notice_ids].split(',') if out[:line_notice_ids]
    out[:secondary_company_ids] = (out[:secondary_company_ids] || []).select(&:present?)
    out
  end

   # Fake ransack filter
  def ransack_status scope
    return scope unless params[:q].try(:[], :status)
    return scope if params[:q][:status] == 'all'

    scope_root = params[:q][:status] == 'activated' ? 'active' : 'not_active'
    full_status_scope = true
    @status_from = params[:q][:status_from_enabled] == '1' && params[:q]['status_from(1i)'] && Date.new(params[:q]['status_from(1i)'].to_i, params[:q]['status_from(2i)'].to_i, params[:q]['status_from(3i)'].to_i)
    @status_until = params[:q][:status_until_enabled] == '1' && params[:q]['status_until(1i)'] && Date.new(params[:q]['status_until(1i)'].to_i, params[:q]['status_until(2i)'].to_i, params[:q]['status_until(3i)'].to_i)

    if @status_from
      if @status_until
        scope = scope.send("#{scope_root}_between", @status_from, @status_until)
      else
        scope = scope.send("#{scope_root}_after", @status_from)
      end
      full_status_scope = false
    elsif @status_until
      scope = scope.send("#{scope_root}_before", @status_until)
      full_status_scope = false
    end
    scope = scope.send(params[:q][:status]) if full_status_scope
    scope
  end
end
