require 'spec_helper'

describe "referentials/show", type: :view do

  let!(:referential) do
    referential = create(:referential, organisation: current_organisation)
    assign :referential, referential.decorate(context: {
      current_organisation: referential.organisation
    })
  end
  let(:permissions){ [] }
  let(:current_organisation) { organisation }
  let(:current_offer_workbench) { create :workbench, organisation: current_organisation}
  let(:readonly){ false }

  before :each do
    assign :reflines, []
    allow(view).to receive(:current_offer_workbench).and_return(current_offer_workbench)
    allow(view).to receive(:current_organisation).and_return(current_organisation)
    allow(view).to receive(:current_user).and_return(current_user)

    allow(view).to receive(:resource).and_return(referential)
    allow(view).to receive(:has_feature?).and_return(true)
    allow(view).to receive(:user_signed_in?).and_return true
    controller.request.path_parameters[:id] = referential.id
    allow(view).to receive(:params).and_return({action: :show})

    allow(referential).to receive(:referential_read_only?){ readonly }
    render template: "referentials/show", layout: "layouts/application"
  end

  it "should not present edit button" do
    expect(rendered).to_not have_selector("a[href=\"#{view.edit_referential_path(referential)}\"]")
  end

  with_permission "referentials.update" do
    it "should present edit button" do
      expect(rendered).to have_selector("a[href=\"#{view.edit_referential_path(referential)}\"]")
    end

    context "with a readonly referential" do
      let(:readonly){ true }
      it "should not present edit button" do
        expect(rendered).to_not have_selector("a[href=\"#{view.edit_referential_path(referential)}\"]")
      end
    end
  end

end
