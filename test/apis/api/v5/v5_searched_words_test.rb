require 'test_helper'

class API::V5::SearchedWordsTest < ActiveSupport::TestCase
  include Rack::Test::Methods
  include API::Root.helpers

  def app
    Rails.application
  end

  def setup
    super # Not done without SeedFu
    unless (name.include?('ログイン') || name.include?('login'))
      @current_student = Student.take
      create_access_token
      header 'X-Authorization', "Bearer #{@access_token}"
    end
  end

  def params
    @params ||= {}
  end

  describe 'GET /api/v5/searched_words' do
    subject { get '/api/v5/searched_words' }

    let(:words) { Oj.load(last_response.body)['data']['words'] }

    describe 'when current_student has searched_words' do
      before { subject }

      it 'returns status 200' do
        assert_equal 200, last_response.status
      end

      it 'returns words with name and values' do
        assert words.all? { |word| word['name'] }
        assert words.all? { |word| word['values'] }
      end
    end

    describe 'when current_student has no searched_words' do
      before do
        SearchedWord.update_all(student_id: 2)
        subject
      end

      it 'returns status 200' do
        assert_equal 200, last_response.status
      end

      it 'returns words as a empty array' do
        assert_equal [], words
      end
    end
  end

  describe 'POST /api/v5/searched_words' do
    subject { post '/api/v5/searched_words', params }

    let(:params) { { searched_word: searched_word } }
    let(:words)  { Oj.load(last_response.body)['data']['words'] }

    %w(単語 たんご word 123).each do |word|
      describe "with no convert words #{word}" do
        before { subject }

        let(:searched_word) { word }
        let(:saved_record)  { SearchedWord.last }

        it 'returns status 201' do
          assert_equal 201, last_response.status
        end

        it 'saves a record with same name and value' do
          assert_equal word, saved_record.name
          assert_equal word, saved_record.value
        end
      end
    end

    words = [%w(１ 1), %w(Ａ a), %w(ａ a), %w(A a), %w(ア あ), %w(ｱ あ)]
    words.each do |word, converted|
      describe "with convert words #{word}" do
        before { subject }

        let(:searched_word) { word }
        let(:saved_record)  { SearchedWord.last }

        it 'returns status 201' do
          assert_equal 201, last_response.status
        end

        it 'saves a record with name and converted value' do
          assert_equal word,      saved_record.name
          assert_equal converted, saved_record.value
        end
      end
    end

    describe 'with present searched_word' do
      before { subject }

      let(:searched_word)  { '25' }
      let(:updated_record) { SearchedWord.order(:updated_at).last }

      it 'returns status 201' do
        assert_equal 201, last_response.status
      end

      it 'updates updated_at column of the record' do
        assert_equal searched_word, updated_record.name
      end
    end
  end
end
