require 'spec_helper'

describe "/layouts/application", :type => :view do

  let(:organisation){ create :organisation }
  let!(:workbench){ create :workbench, organisation: organisation}

  before(:each) do
    allow(view).to receive_messages :user_signed_in? => true
    allow(view).to receive_messages :current_organisation => organisation
    allow(Rails.application.config).to receive_messages :portal_url => "portal_url"
    allow(Rails.application.config).to receive_messages :codifligne_url => "codifligne_url"
    allow(Rails.application.config).to receive_messages :reflex_url => "reflex_url"
  end

  it "should have menu items" do
    render
    expect(rendered).to have_menu_title 'layouts.navbar.current_offer.other'.t
    expect(rendered).to have_menu_link_to '/'
    expect(rendered).to have_menu_link_to workbench_output_path(workbench)

    expect(rendered).to have_menu_title 'activerecord.models.workbench.one'.t.capitalize
    expect(rendered).to have_menu_link_to workbench_path(workbench)
    expect(rendered).to have_menu_link_to workbench_imports_path(workbench)
    expect(rendered).to have_menu_link_to workbench_exports_path(workbench)
    expect(rendered).to have_menu_link_to workgroup_calendars_path(workbench.workgroup)
    expect(rendered).to have_menu_link_to workbench_compliance_check_sets_path(workbench)
    expect(rendered).to have_menu_link_to compliance_control_sets_path

    expect(rendered).to have_menu_title('layouts.navbar.line_referential'.t)
    expect(rendered).to have_menu_link_to line_referential_path(workbench.line_referential)
    expect(rendered).to have_menu_link_to line_referential_lines_path(workbench.line_referential)
    expect(rendered).to have_menu_link_to line_referential_networks_path(workbench.line_referential)
    expect(rendered).to have_menu_link_to line_referential_companies_path(workbench.line_referential)

    expect(rendered).to have_menu_title 'layouts.navbar.stop_area_referential'.t
    expect(rendered).to have_menu_link_to stop_area_referential_path(workbench.stop_area_referential)
    expect(rendered).to have_menu_link_to stop_area_referential_stop_areas_path(workbench.stop_area_referential)

    expect(rendered).to have_menu_title 'layouts.navbar.configuration'.t
    expect(rendered).to_not have_menu_link_to edit_workbench_path(workbench)
    expect(rendered).to_not have_menu_link_to edit_workgroup_path(workbench.workgroup)

    expect(rendered).to have_menu_title 'layouts.navbar.tools'.t
    expect(rendered).to have_menu_link_to 'portal_url'
    expect(rendered).to have_menu_link_to 'codifligne_url'
    expect(rendered).to have_menu_link_to 'reflex_url'
  end

  with_permission "workbenches.update" do
    it "should have a link to update the workbench" do
      render
      expect(rendered).to have_menu_link_to edit_workbench_path(workbench)
    end
  end

  context "when belonging to the workgroups owner" do
    let(:user){ build_stubbed(:user, organisation: organisation) }
    before do
      workbench.workgroup.update owner: organisation
      allow(view).to receive_messages :current_user => user
      render
    end
    it "should have a link to update the workgroup" do
      expect(rendered).to have_menu_link_to edit_workgroup_path(workbench.workgroup)
    end
  end
end
