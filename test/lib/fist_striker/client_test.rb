require 'test_helper'

class FistStriker::ClientTest < ActiveSupport::TestCase
  let(:described_class) { FistStriker::Client }
  let(:client)          { described_class.new }
  let(:request_method)  { :get }
  let(:end_point)       { '' }

  before do
    client.instance_variable_set(:@request_method, request_method)
    client.instance_variable_set(:@end_point, end_point)
  end

  let(:stubs) do
    Faraday::Adapter::Test::Stubs.new do |stub|
      stub.send(request_method, end_point) { stubbed_response }
    end
  end

  let(:stubbed_connection) do
    Faraday.new do |faraday|
      faraday.use     ::FistStriker::Middleware
      faraday.adapter :test, stubs
    end
  end

  let(:stubbed_response) do
    [200, {}, Oj.dump(meta: { code: code, error_message: msg }, data: {})]
  end

  describe '#send_request' do
    subject { client.send(:send_request) }

    describe 'positive testing' do
      let(:code) { '200' }
      let(:msg)  { '' }

      it 'returns true' do
        described_class.stub_any_instance(:connection, stubbed_connection) do
          assert(subject)
        end
      end
    end

    describe 'negative testing' do
      let(:code) { '400' }
      let(:msg)  { 'Bad Request' }

      it 'raises error with message' do
        described_class.stub_any_instance(:connection, stubbed_connection) do
          error = Exceptions::FistStriker::BadRequest
          assert_raises(error, msg) { subject }
        end
      end
    end
  end
end
