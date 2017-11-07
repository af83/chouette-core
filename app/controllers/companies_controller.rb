class CompaniesController < InheritedResources::Base
  include ApplicationHelper
  include PolicyChecker
  defaults :resource_class => Chouette::Company
  respond_to :html
  respond_to :xml
  respond_to :json
  respond_to :js, :only => :index

  belongs_to :line_referential

  def index
    index! do |format|
      format.html {
        if collection.out_of_bounds?
          redirect_to params.merge(:page => 1)
        end

        @companies = decorate_companies(@companies)
      }

      format.json {
        @companies = decorate_companies(@companies)
      }
    end
  end

  def new
    authorize resource_class
    super
  end

  def create
    authorize resource_class
    super
  end


  protected
  def collection
    @q = line_referential.companies.search(params[:q])

    if sort_column && sort_direction
      @companies ||= @q.result(:distinct => true).order(sort_column + ' ' + sort_direction).paginate(:page => params[:page])
    else
      @companies ||= @q.result(:distinct => true).order(:name).paginate(:page => params[:page])
    end
  end


  def resource_url(company = nil)
    line_referential_company_path(line_referential, company || resource)
  end

  def collection_url
    line_referential_companies_path(line_referential)
  end

  alias_method :line_referential, :parent

  alias_method :current_referential, :line_referential
  helper_method :current_referential

  def company_params
    params.require(:company).permit( :objectid, :object_version, :creator_id, :name, :short_name, :organizational_unit, :operating_department_name, :code, :phone, :fax, :email, :registration_number, :url, :time_zone )
  end

  private

  def sort_column
    line_referential.companies.column_names.include?(params[:sort]) ? params[:sort] : 'name'
  end
  def sort_direction
    %w[asc desc].include?(params[:direction]) ?  params[:direction] : 'asc'
  end

  def decorate_companies(companies)
    ModelDecorator.decorate(
      companies,
      with: CompanyDecorator,
      context: {
        referential: line_referential
      }
    )
  end

end
