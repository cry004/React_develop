require 'test_helper'

class Juku::TestLoginControllerTest < ActionController::TestCase
  describe Juku::TestLoginControllerTest, :create do
    let(:env) { 'test' }

    before do
      Rails.env = env
      request.remote_addr = remote_addr
      get :create, login_params
    end

    after { Rails.env = 'test' }

    describe 'with IP address of monstar-lab' do
      let(:remote_addr) { '58.94.101.79' }

      describe 'with login_params[:type]' do
        let(:login_params) { { type: type } }

        describe 'with a valid login_params[:type]' do
          describe "when login_params[:type] is 'fist'" do
            let(:type) { 'fist' }
            let(:chief) { Chief::Fist.find_or_create_by(shin_cd: 'monstar-prd-test') }
            let(:params) do
              {
                token: assigns(:one_time_token),
                shin_cd: chief.shin_cd
              }
            end

            it 'assigns the FIST chief for test_login to @current_chief' do
              assert_equal chief.shin_cd, assigns(:current_chief)&.shin_cd
            end

            it 'assigns @one_time_token' do
              assert_not_nil assigns(:one_time_token)
            end

            it "changes @chief's one_time_token" do
              assert_equal assigns(:one_time_token), assigns(:current_chief)&.one_time_token
            end

            it "assigns the one_time_token and shin_cd to @params" do
              assert_equal params, assigns(:params)
            end

            it 'redirects to login#create with valid params' do
              assert_redirected_to controller: :login,
                                   action:     :create,
                                   params:     params
            end
          end

          describe "when login_params[:type] is 'plus'" do
            let(:type) { 'plus' }

            # NOTE: 'classroom' for testing as 'plus' has not been prepared yet.
            it 'renders 404' do
              assert_template file: "#{Rails.root}/public/404.html"
            end
          end
        end

        describe 'with a invalid login_params[:type]' do
          let(:type) { 'invalid' }
          it 'renders 404' do
            assert_template file: "#{Rails.root}/public/404.html"
          end
        end
      end

      describe 'without login_params[:type]' do
        let(:login_params) { nil }

        it 'renders 404' do
          assert_template file: "#{Rails.root}/public/404.html"
        end
      end
    end

    describe 'without IP address of monstar-lab' do
      let(:login_params) { { type: 'fist' } }

      describe 'with local loopback address' do
        let(:remote_addr) { "::1" }

        describe "when Rails.env is development" do
          let(:env) { 'development' }

          it 'redirects to login#create' do
            assert_redirected_to controller: :login,
                                 action:     :create,
                                 params:     assigns(:params)
          end
        end

        describe "when Rails.env isn't development" do
          it 'renders 404' do
            assert_template file: "#{Rails.root}/public/404.html"
          end
        end
      end

      describe 'without local loopback address' do
        let(:remote_addr) { "59.157.162.236" }

        it 'renders 404' do
          assert_template file: "#{Rails.root}/public/404.html"
        end
      end
    end
  end
end
