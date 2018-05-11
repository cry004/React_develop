require 'test_helper'

class FistStriker::MiddlewareTest < ActiveSupport::TestCase
  let(:described_class) { FistStriker::Middleware }
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
    [200, {}, Oj.dump(meta: { code: code, error_message: msg }, data: {})]
  end

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
      describe 'when status code is 400' do
        let(:code) { '400' }
        let(:msg)  { 'Bad Request' }

        it 'raises FistStriker::BadRequest with error message' do
          error = Exceptions::FistStriker::BadRequest
          assert_raises(error, msg) { subject }
        end
      end

      describe 'when status code is 406' do
        let(:code) { '406' }
        let(:msg)  { 'NotAcceptable' }

        it 'raises FistStriker::NotAcceptable with error message' do
          error = Exceptions::FistStriker::NotAcceptable
          assert_raises(error, msg) { subject }
        end
      end

      describe 'when status code is 500' do
        let(:code) { '500' }
        let(:msg)  { 'Internal Server Error' }

        it 'raises FistStriker::InternalServerError with error message' do
          error = Exceptions::FistStriker::InternalServerError
          assert_raises(error, msg) { subject }
        end
      end

      describe 'when status code is others' do
        let(:code) { '999' }
        let(:msg)  { 'unknown' }

        it 'raises FistStriker::Error with error message' do
          error = Exceptions::FistStriker::Error
          assert_raises(error, msg) { subject }
        end
      end
    end
  end
end
