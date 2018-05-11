require 'test_helper'

class API::V5::VersionsTest < ActiveSupport::TestCase
  include Rack::Test::Methods
  include API::Root.helpers

  def app
    Rails.application
  end

  describe 'GET api/v5/versions' do
    subject { get '/api/v5/versions', params }

    let(:params)        { { os: os } }
    let(:response_data) { Oj.load(last_response.body)['data'] }

    after { VCR.eject_cassette }

    %w(ios android).each do |os|
      before do
        VCR.insert_cassette "get_version_#{os}"
        subject
      end

      let(:os) { os }

      describe "when os is #{os}" do
        describe "without ENV[#{os.upcase}_VERSION]" do
          # FIXME: Comment in
          # before { ENV['IOS_VERSION']     = nil }
          # before { ENV['ANDROID_VERSION'] = nil }

          let(:version) { '1.0.0' } # from cassette

          it 'returns status ok' do
            assert last_response.ok?
          end

          it 'returns body with the version' do
            assert_equal version, response_data['version']
          end
        end

        # FIXME: Comment in
        # describe "with ENV[#{os.upcase}_VERSION]" do
        #   before { ENV['IOS_VERSION']     = version }
        #   before { ENV['ANDROID_VERSION'] = version }
        #   after { ENV['IOS_VERSION']     = nil }
        #   after { ENV['ANDROID_VERSION'] = nil }
        #
        #   let(:version) { '9.9.9' }
        #
        #   it 'returns status ok' do
        #     assert last_response.ok?
        #   end
        #
        #   it 'returns body with the version' do
        #     assert_equal version, response_data['version']
        #   end
        # end
      end
    end
  end
end
