require 'rails_helper'

describe SessionsController, type: :controller do

  def current_user
    controller.send(:current_player)
  end

  def login_as(player)
    controller.send(:create_session, player)
  end

  let(:good_password) { 'mydoghasfleas' }
  let(:bad_password) { 'bogus' }
  let!(:alice) { create_player(player_name: 'alice', password: good_password) }

  describe "GET #new" do
    it "assigns a new session as @session" do
      get :new, {}, valid_session
      expect(assigns(:session)).to be_a_new(Session)
    end
  end

  describe "POST #create" do
    let(:login_name) { 'alice' }
    let(:login_password) { good_password }

    context "(posting)" do
      before { post :create, session: {name: login_name, password: login_password } }

      context 'given a valid username and password' do
        it 'signs in that user' do
          expect(current_user).to be
          expect(current_user).to eq(alice)
        end

        it "creates a new Session" do
          expect(Session.count).to eq(1)
        end

        it "assigns a newly created session as @session" do
          expect(assigns(:session)).to be_a(Session)
          expect(assigns(:session)).to be_persisted
        end

        it "sets this person's id in the db session" do
          expect(assigns(:session).player).to eq(alice)
        end

        it "sticks that db session's id in the cookie session (ugh)" do
          expect(session[SessionsController::SESSION_KEY]).to eq(assigns(:session).id)
        end

        it "redirects to the main page" do
          expect(response).to redirect_to('/') # todo: redirect whence we came to login page
        end
      end

      context 'given a valid username and bogus password' do
        let(:login_password) { bad_password }

        it 'fails to start a session' do
          expect(Session.count).to eq(0)
        end

        it "assigns a newly created but unsaved session as @session" do
          expect(assigns(:session)).to be_a_new(Session)
          expect(assigns(:session).name).to eq('alice')
        end

        it "re-renders the 'new' template" do
          expect(response).to render_template("new")
        end
      end
    end

    context 'if there is already a session' do

      let!(:old_session) { controller.send(:create_session, alice) }

      before do
        post :create, session: {name: login_name, password: login_password}
      end

      let(:new_session) { assigns(:session) }

      it 'removes it from the cookie session' do
        expect(session[SessionsController::SESSION_KEY]).to eq(new_session.id)
      end

      it 'removes it from the database' do
        expect(Session.find_by_id(old_session.id)).to be_nil
      end
    end

    #   context 'given a user with no password' do
    #     it 'fails to start a session' do
    #       alice.update(password: nil)
    #       get :create, name: 'alice', password: nil
    #       expect(response.body).to include('"status":"error"')
    #       expect(response_json).to include({"status" => "error"})
    #       expect(response_json["message"].downcase).to include("bad")
    #       expect(response.status).to eq(401)
    #     end
    #   end
    #
    #   context 'given a valid user id and password' do
    #
    #     before do
    #       get :create, name: alice.id, password: good_password
    #       expect_ok
    #     end
    #
    #     it 'returns a session token' do
    #       token = response_json['token']
    #       expect(token).to be
    #       expect(alice.reload.session_token).to eq(token)
    #     end
    #
    #     it 'sets a session token' do
    #       token = session[:token]
    #       expect(token).to be
    #       expect(alice.reload.session_token).to eq(token)
    #     end
    #
    #     it 'fetches a current player (user?)' do
    #       expect(subject.send(:current_player)).to eq(alice)
    #     end
    #   end
    # end
    #
    # context "with invalid params" do
    # end
  end

  describe "DELETE #destroy" do
    before { login_as alice }

    it "destroys the requested session in the db" do
      expect {
        delete :destroy
      }.to change(Session, :count).by(-1)
    end

    it 'removes it from the cookie session' do
      delete :destroy
      expect(session[SessionsController::SESSION_KEY]).to be_nil
    end

    it "signs out the current user" do
      delete :destroy
      expect(current_user).to be_nil
    end

    it "redirects to the main page" do
      delete :destroy
      expect(response).to redirect_to('/')
    end
  end

end
