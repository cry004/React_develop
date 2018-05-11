require 'test_helper'

class MillviTest < ActiveSupport::TestCase
  let(:described_class) { Millvi::CustomResponseMiddleware }
  let(:request_method)  { :get }
  let(:end_point)       { '' }

  let(:stubs) do
    Faraday::Adapter::Test::Stubs.new do |stub|
      stub.send(request_method, end_point) { stubbed_response }
    end
  end

  let(:stubbed_connection) do
    Faraday.new do |faraday|
      faraday.use     described_class
      faraday.adapter :test, stubs
    end
  end

  let(:stubbed_response) do
    [code, {}, Oj.dump(meta: { code: code, error_message: msg }, data: {})]
  end

  after { VCR.eject_cassette }

  describe '#on_complete' do
    subject { stubbed_connection.send(request_method, end_point) }

    describe 'positive testing' do
      describe 'when status code is 200' do
        let(:code) { '200' }
        let(:msg)  { '' }

        it { assert(subject) }
      end

      describe 'when status code is 201' do
        let(:code) { '201' }
        let(:msg)  { '' }

        it { assert(subject) }
      end
    end

    describe 'negative testing' do
      before { VCR.insert_cassette 'millvi_aws_cloud_watch' }

      describe 'when status code is 500' do
        let(:code) { '500' }
        let(:msg)  { 'Millvi return 500 error' }

        it 'raises Millvi::InternalServerError with error message' do
          error = Millvi::InternalServerError
          assert_raises(error, msg) { subject }
        end
      end

      describe 'when status code is 503' do
        let(:code) { '503' }
        let(:msg)  { 'Millvi return 503 error' }

        it 'raises Millvi::ServiceUnavailable with error message' do
          error = Millvi::ServiceUnavailable
          assert_raises(error, msg) { subject }
        end
      end
    end
  end
end
