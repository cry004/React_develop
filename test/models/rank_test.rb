require 'test_helper'

class RankTest < ActiveSupport::TestCase
  describe '#validations' do
    %i(ranking ranker viewed_time national_rank).each do |column|
      describe 'with presence' do
        subject { Rank.new }

        it "rejects a bad #{column} in validation" do
          assert subject.invalid?(column)
          assert_includes subject.errors[column], I18n.t('errors.messages.blank')
        end
      end
    end

    describe 'with conditional presence' do
      describe 'with conditional presence prefecture_rank' do
        subject { Rank.new(prefecture_code: code) }

        describe 'when prefecture_code present' do
          let(:code) { 47 }
          it 'rejects a bad prefecture_rank in validation' do
            assert subject.invalid?(:prefecture_rank)
            assert_includes subject.errors[:prefecture_rank], I18n.t('errors.messages.blank')
          end
        end

        describe 'when prefecture_code is nil' do
          before { subject.validate }
          let(:code) { nil }
          it 'allows a prefecture_rank in validation' do
            assert_empty subject.errors[:prefecture_rank]
          end
        end
      end

      describe 'with conditional presence classroom_rank' do
        subject { Rank.new(classroom_id: classroom_id) }

        describe 'when classroom_id present' do
          let(:classroom_id) { 48 }
          it 'rejects a bad classroom_rank in validation' do
            assert subject.invalid?(:classroom_rank)
            assert_includes subject.errors[:classroom_rank], I18n.t('errors.messages.blank')
          end
        end

        describe 'when classroom_id is nil' do
          before { subject.validate }
          let(:classroom_id) { nil }
          it 'allows a classroom_rank in validation' do
            assert_empty subject.errors[:classroom_rank]
          end
        end
      end
    end

    %i(ranker_id national_rank prefecture_rank).each do |column|
      describe 'with uniqueness' do
        subject { Rank.take.dup }

        it "rejects a bad #{column} in validation" do
          assert subject.invalid?(column)
          assert_includes subject.errors[column], I18n.t('errors.messages.taken')
        end
      end
    end

    %i(ranker_type).each do |column|
      describe 'with inclusion' do
        subject { Rank.new(column => 'invalid') }

        it "rejects a bad #{column} in validation" do
          assert subject.invalid?(column)
          assert_includes subject.errors[column], I18n.t('errors.messages.inclusion')
        end
      end
    end

    %i(prefecture_code).each do |column|
      describe 'with inclusion and allow_nil' do
        subject { Rank.new(column => val) }

        [47, 99].each do |code|
          describe 'with valid value' do
            before { subject.validate }
            let(:val) { code }
            it "allows a #{column} in validation" do
              assert_empty subject.errors[column]
            end
          end
        end

        describe 'with invalid value' do
          let(:val) { 'invalid' }
          it "rejects a bad #{column} in validation" do
            assert subject.invalid?(column)
            assert_includes subject.errors[column], I18n.t('errors.messages.inclusion')
          end
        end

        describe 'with nil value' do
          before { subject.validate }
          let(:val) { nil }
          it "allows a #{column} in validation" do
            assert_empty subject.errors[column]
          end
        end
      end
    end
    describe 'with national_rank_greater_than_prefecture_rank' do
      subject { Rank.new(national_rank: 1, prefecture_rank: 2) }

      it 'rejects a bad record in validation' do
        assert subject.invalid?
        assert_includes subject.errors[:national_rank], I18n.t('errors.messages.invalid')
      end
    end
  end
end
