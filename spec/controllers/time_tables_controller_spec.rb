RSpec.describe TimeTablesController, :type => :controller do
  login_user

  describe 'POST create' do
    let(:request){ post :create, referential_id: referential.id, time_table: time_table_params }
    let(:time_table_params){{comment: "test"}}

    it "should create a timetable" do
      expect{request}.to change{ Chouette::TimeTable.count }.by 1
      expect(Chouette::TimeTable.last.comment).to eq "test"
      %i(monday tuesday wednesday thursday friday saturday sunday).each do |d|
        expect(Chouette::TimeTable.last.send(d)).to be_falsy
      end
    end

    context "when given a calendar" do
      let(:calendar){ create :calendar, int_day_types: Calendar::MONDAY | Calendar::SUNDAY }
      let(:time_table_params){{comment: "test", calendar_id: calendar.id}}
      it "should create a timetable" do
        expect{request}.to change{ Chouette::TimeTable.count }.by 1
        expect(Chouette::TimeTable.last.comment).to eq "test"
        expect(Chouette::TimeTable.last.calendar).to eq calendar
        %i(monday tuesday wednesday thursday friday saturday sunday).each do |d|
          expect(Chouette::TimeTable.last.send(d)).to eq calendar.send(d)
        end
      end
    end
  end
end
