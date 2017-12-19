RSpec.describe LinesController, type: :controller do

  login_user

  let( :line_referential ){ create :line_referential }

  context 'collection' do
    it_should_redirect_to_forbidden 'GET :index' do
      get :index, line_referential_id: line_referential.id
    end

    it_should_redirect_to_forbidden 'GET :new' do
      get :new, line_referential_id: line_referential.id
    end

    it_should_redirect_to_forbidden 'POST :create', ok_status: 302 do
      post :create, line_referential_id: line_referential.id, line: attributes_for( :line )
    end
  end

  context 'member' do 
    let( :line ){ create :line, line_referential: line_referential }

    it_should_redirect_to_forbidden 'GET :show' do
      get :show, line_referential_id: line_referential.id, id: line.id
    end

    it_should_redirect_to_forbidden 'GET :edit' do
      get :edit, line_referential_id: line_referential.id, id: line.id
    end

    it_should_redirect_to_forbidden 'PUT :update', ok_status: 302 do
      put :update, line_referential_id: line_referential.id, id: line.id, line: attributes_for( :line )
    end

    it_should_redirect_to_forbidden 'DELETE :destroy', ok_status: 302 do
      delete :destroy, line_referential_id: line_referential.id, id: line.id
    end
  end
end
