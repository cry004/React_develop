require 'test_helper'

class Ranking::DailyTest < ActiveSupport::TestCase
  describe '#validations' do
    %i(type date).each do |column|
      describe 'with presence' do
        subject { Ranking::Daily.new }

        it "rejects a bad #{column} in validation" do
          assert subject.invalid?(column)
          assert_includes subject.errors[column], I18n.t('errors.messages.blank')
        end
      end
    end

    %i(type).each do |column|
      describe 'with uniqueness' do
        subject { Ranking::Daily.take.dup }

        it "rejects a bad #{column} in validation" do
          assert subject.invalid?(column)
          assert_includes subject.errors[column], I18n.t('errors.messages.taken')
        end
      end
    end

    %i(type period_day).each do |column|
      describe 'with inclusion' do
        subject { Ranking::Daily.new(column => 'invalid') }

        it "rejects a bad #{column} in validation" do
          assert subject.invalid?(column)
          assert_includes subject.errors[column], I18n.t('errors.messages.inclusion')
        end
      end
    end
  end

  describe '.generate!' do
    subject { Ranking::Daily.generate!(date) }

    describe 'with valid date' do
      let(:date)  { Time.zone.today }
      let(:count) { Ranking::TYPES.size }

      it 'generates records' do
        assert_difference 'Ranking.count', count do
          subject
        end
      end

      it 'returns generated records' do
        assert subject.all?(&:persisted?)
        assert_equal count,  subject.size
        assert_equal [date], subject.map(&:date).uniq
      end
    end

    describe 'with invalid date' do
      let(:date) { '2017-01-32' }

      it 'raises ActiveRecord::RecordInvalid' do
        assert_raise ActiveRecord::RecordInvalid do
          subject
        end
      end
    end
  end

  describe '#aggregation_start_date' do
    subject { ranking.aggregation_start_date }
    let(:ranking) { Ranking.find(1) } # from fixtures
    it { assert_equal 9.days.ago.to_date, subject }
  end

  describe '#aggregation_end_date' do
    subject { ranking.aggregation_end_date }
    let(:ranking) { Ranking.find(1) } # from fixtures
    it { assert_equal 3.days.ago.to_date, subject }
  end
end
