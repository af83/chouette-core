require 'spec_helper'

describe "/time_tables/show", :type => :view do

  assign_referential
  let!(:time_table) do
    assign(
      :time_table,
      create(:time_table).decorate(context: {
        referential: referential
      })
    )
  end
  let!(:year) { assign(:year, Date.today.cwyear) }
  let!(:time_table_combination) {assign(:time_table_combination, TimeTableCombination.new)}

  before do
    allow(view).to receive_messages(current_organisation: referential.organisation)
  end

  it "should render h2 with the time_table comment" do
    render
    expect(rendered).to have_selector("h1", :text => Regexp.new(time_table.comment))
  end

  it "should render a link to edit the time_table" do
    render
    expect(rendered).to have_selector(" a[href='#{view.edit_referential_time_table_path(referential, time_table)}']")
  end

  it "should render a link to remove the time_table" do
    render
    expect(rendered).to have_selector(" a[href='#{view.referential_time_table_path(referential, time_table)}']")
  end

end
