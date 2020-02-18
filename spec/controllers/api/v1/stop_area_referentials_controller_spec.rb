RSpec.describe Api::V1::StopAreaReferentialsController do

  describe "POST webhook" do

    context "without authentication" do
      it "returns a 401 status" do
        get :webhook, params: { id: 1 }
        expect(response.status).to eq(401)
      end
    end

    context "with authentication" do

      let(:token) { 'secret' }
      let(:event_attributes) { { type: "destroyed", stop_place: { "id" => "42" } } }

      before do
        allow(ApiKey).to receive(:find_by).with(token: token).and_return(double(workgroup: double))
        request.env['HTTP_AUTHORIZATION'] =
          ActionController::HttpAuthentication::Token.encode_credentials(token)
      end

      describe "destroyed event" do

        let(:event_attributes) do
          {
            type: "destroyed",
            stop_place: { "id" => "42" },
            quays: [{ "id" => "42" },{ "id" => "43" }],
          }
        end

        it "assigns event with provided attributes" do
          get :webhook, params: { id: 1, stop_area_referential: event_attributes }
          expect(assigns(:event)).to have_attributes(event_attributes)
        end

      end

      it "returns a 200 status" do
        get :webhook, params: { id: 1, stop_area_referential: event_attributes }
        expect(response.status).to eq(200)
      end

    end

  end

  describe "#permitted_attributes" do

    subject(:permitted_attributes) { controller.send :permitted_attributes }

    it "includes 'type' attribute" do
      expect(permitted_attributes).to include("type")
    end

    %w{stop_place stop_places quay quays}.each do |resource_name|
      it "includes '#{resource_name}' attribute as string" do
        expect(permitted_attributes).to include(resource_name)
      end
    end

    %w{stop_place quay}.each do |resource_name|
      it "includes '#{resource_name}' attribute as hash" do
        expect(permitted_attributes.last).to include(resource_name => {})
      end
    end

    %w{stop_places quays}.each do |resource_name|
      it "includes '#{resource_name}' attribute as array" do
        expect(permitted_attributes.last).to include(resource_name => [:id])
      end
    end

  end

end
