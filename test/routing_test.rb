require 'test_helper'

class RoutingTest < ActionDispatch::IntegrationTest
  let(:content_types) { Settings.contents.content_type.to_h.values }

  student_proc = proc do
    describe 'students routings' do
      describe 'students/welcome' do
        it 'should get /' do
          assert_routing '/', controller: 'students/welcome', action: 'index'
        end
      end

      describe 'students/welcome' do
        it 'should get /password_reminder_page' do
          assert_routing '/password_reminder_page', controller: 'students/password_reminder', action: 'password'
        end
      end

      describe 'students/welcome' do
        it 'should get /sign_out_and_sign_in' do
          assert_routing '/sign_out_and_sign_in', controller: 'students/welcome', action: 'reset_session'
        end
      end
    end
  end

  admin_proc = proc do
    describe 'admin routings' do
      describe 'admin/terms' do
        it 'should get admin/terms' do
          assert_routing '/admin/terms', controller: 'admin/terms', action: 'terms'
        end
      end

      describe 'admin/faq' do
        it 'should get admin/faq' do
          assert_routing '/admin/faq', controller: 'admin/faq', action: 'index'
        end
      end

      describe 'admin/password_resets' do
        describe 'password_resets#index' do
          it 'should get /admin/password_resets' do
            assert_routing '/admin/password_resets', controller: 'admin/password_resets', action: 'index'
          end
        end

        describe 'admin/password_resets#create' do
          it 'should get create password' do
            assert_routing({ method: :post,
                             path: '/admin/password_resets'},
                           { controller: 'admin/password_resets',
                             action: 'create' })
          end
        end

        describe 'admin/password_resets#new' do
          it 'should get /admin/password_resets/new' do
            assert_routing '/admin/password_resets/new', controller: 'admin/password_resets', action: 'new'
          end
        end

        describe 'admin/password_resets#edit' do
          it 'should get /admin/password_resets/id/edit' do
            assert_routing '/admin/password_resets/1/edit', controller: 'admin/password_resets', action: 'edit', id: '1'
          end
        end

        describe 'admin/password_resets#show' do
          it 'should get /admin/password_resets/id' do
            assert_routing '/admin/password_resets/1', controller: 'admin/password_resets', action: 'show', id: '1'
          end
        end

        describe 'admin/password_resets#update PATCH' do
          it 'should get /admin/password_resets/id' do
            assert_routing({ method: :patch,
                             path: '/admin/password_resets/1' },
                           { controller: "admin/password_resets",
                             action: 'update', id: '1' })
          end
        end

        describe 'admin/password_resets#update PUT' do
          it 'should get /admin/password_resets/id' do
            assert_routing({ method: :put,
                             path: '/admin/password_resets/1' },
                           { controller: 'admin/password_resets',
                             action: 'update', id: '1' })
          end
        end

        describe 'admin/password_resets#destroy DELETE' do
          it 'should get /admin/password_resets/id' do
            assert_routing({ method: :delete,
                             path: '/admin/password_resets/1' },
                           { controller: 'admin/password_resets',
                             action: 'destroy', id: '1' })
          end
        end
      end

      describe 'admin/dashboard　routings' do
        describe 'admin/dashboard#index' do
          it 'should get /admin/dashboard' do
            assert_routing '/admin/dashboard', controller: 'admin/dashboard', action: 'index'
          end
        end

        describe 'dashboard#show' do
          it 'should get /admin/dashboard/:application' do
            assert_routing '/admin/dashboard/1', controller: 'admin/dashboard', action: 'show', application: '1'
          end
        end
      end

      describe 'admin/session　routings' do
        describe 'admin/session#destroy' do
          it 'should get /admin/session' do
            assert_routing({ method: :delete,
                             path: '/admin/session' },
                           { controller: 'admin/session',
                             action: 'destroy' })
          end
        end

        describe 'admin/session#create' do
          it 'should get /admin/session/create' do
            assert_routing({ method: :post,
                             path: '/admin/session'},
                           { controller: 'admin/session',
                             action: 'create' })
          end
        end

        describe 'admin/session#new' do
          it 'should get /admin/session/new' do
            assert_routing '/admin/session/new', controller: 'admin/session', action: 'new'
          end
        end
      end

      describe 'admin/teacher_accounts　routings' do
        describe 'admin/teacher_accounts#confirm' do
          it 'should get /admin/teacher_accounts/confirm' do
            assert_routing({ method: :post,
                             path: '/admin/teacher_accounts/confirm' },
                           { controller: 'admin/teacher_accounts',
                             action: 'confirm' })
          end
        end

        describe 'admin/teacher_accounts#create' do
          it 'should get /admin/teacher_accounts' do
            assert_routing({ method: :post,
                             path: '/admin/teacher_accounts'},
                           { controller: 'admin/teacher_accounts',
                             action: 'create' })
          end
        end

        describe 'admin/teacher_accounts#thankyou' do
          it 'should get /admin/teacher_accounts/thankyou' do
            assert_routing '/admin/teacher_accounts/thankyou', controller: 'admin/teacher_accounts', action: 'thankyou'
          end
        end

        describe 'admin/teacher_accounts#new' do
          it 'should get /admin/teacher_accounts/new' do
            assert_routing '/admin/teacher_accounts/new', controller: 'admin/teacher_accounts', action: 'new'
          end
        end
      end

      describe 'admin/account　routings' do
        describe 'admin/account#send_password' do
          it 'should get /admin/account/send_password' do
            assert_routing({ method: :post,
                             path: '/admin/account/send_password' },
                           { controller: 'admin/account',
                             action: 'send_password' })
          end
        end

        describe 'admin/account#create' do
          it 'should get /admin/account' do
            assert_routing({ method: :post,
                             path: '/admin/account'},
                           { controller: 'admin/account',
                             action: 'create' })
          end
        end

        describe 'admin/account#new' do
          it 'should get /admin/account/new' do
            assert_routing '/admin/account/new', controller: 'admin/account', action: 'new'
          end
        end

        describe 'admin/account#forgot_pasword' do
          it 'should get /admin/account/forgot_password' do
            assert_routing '/admin/account/forgot_password', controller: 'admin/account', action: 'forgot_password'
          end
        end

        describe 'admin/account#show' do
          it 'should get /admin/account/id' do
            assert_routing '/admin/account/1', controller: 'admin/account', action: 'show', id: '1'
          end
        end
      end

      # typusが生成されているactionのテス
      controller_action = {
        admin_users: %w(index update edit show point_request check_action csv_download),
        fees: %w(index show),
        incomprehensibles: %w(index csv_download study_log_csv_download),
        line_items: %w(show set_schoolbook),
        orders: %w(index cancel unsettle return_ordered settle return_unsettled
                   csv_download_for_textbook csv_download_for_credit batch),
        parents: %w(destroy docomo_users_csv),
        posts: %w(index update answer check show judge),
        products: %w(index),
        questions: %w(index accept pending work assign assigned show examine stop_examine
                      deassign stop_work index_of_open index_of_accepted index_of_pending
                      index_of_auto_assign index_of_answered_unchecked history_for_examined
                      history_for_answered histroy_for_answered_checked examining checking
                      refuse force_reject_edit force_reject),
        students: %w(index update search_param csv_download delete_blank_student_params
                     change_member_type do_student_info_rake_task),
        videos: %w(index show pdf_replace pdf_upload typeset) }

      controller_action.each do |controller, actions|
        describe "admin/#{controller}　routings" do
          actions.each do |action|
            %w(get post patch delete).each do |http_verb|
              it "should get /admin/#{controller}/#{action}" do
                assert_routing({ method: http_verb,
                                 path: "/admin/#{controller}/#{action}/1" },
                               { controller: "admin/#{controller}",
                                 action: action,
                                 id: '1' })
              end
            end
          end
        end
      end
    end
  end

  juku_proc = proc do
    describe 'juku routings' do
      it 'should get /juku' do
        assert_routing '/juku', controller: 'juku/welcome', action: 'index'
      end
    end
  end

  describe 'healthcheck routings' do
    it 'should get healthcheck' do
      assert_routing '/healthcheck', controller: 'healthcheck', action: 'index'
    end
  end

  describe '環境に応じてテストを実行する' do
    after(:all) do
      Rails.env = 'test'
    end

    # テスト環境
    describe 'test 環境' do
      student_proc.call
    end

    # development環境
    describe 'development 環境' do
      before(:all) do
        Rails.env = 'development'
        Rails.application.reload_routes!
      end
      student_proc.call
      juku_proc.call
      admin_proc.call
    end

    # Rails.env.include?('teacher')
    teacher_env = %w(teacher_develop teacher_production teacher_staging)
    teacher_env.each do |new_env|
      describe 'when environment includes teacher' do
        before(:all) do
          Rails.env = new_env
        end
        admin_proc.call if Rails.env == new_env
      end
    end

    # その他
    other_env = %w(batch_develop assets_production api_staging jiritsu_staging api_develop api_production)
    other_env.each do |new_env|
      describe 'other environments' do
        before(:all) do
          Rails.env = new_env
        end
        student_proc.call if Rails.env == new_env
      end
    end
  end
end
