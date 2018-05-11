require 'test_helper'

class RankingTest < ActiveSupport::TestCase
  describe '#validations' do
    %i(type date period_day).each do |column|
      describe 'with presence' do
        subject { Ranking.new }

        it "rejects a bad #{column} in validation" do
          assert subject.invalid?(column)
          assert_includes subject.errors[column], I18n.t('errors.messages.blank')
        end
      end
    end

    %i(type).each do |column|
      describe 'with uniqueness' do
        subject { Ranking.take.dup }

        it "rejects a bad #{column} in validation" do
          assert subject.invalid?(column)
          assert_includes subject.errors[column], I18n.t('errors.messages.taken')
        end
      end
    end

    %i(type).each do |column|
      describe 'with inclusion' do
        subject { Ranking.new(column => 'invalid') }

        it "rejects a bad #{column} in validation" do
          assert subject.invalid?(column)
          assert_includes subject.errors[column], I18n.t('errors.messages.inclusion')
        end
      end
    end
  end

  describe 'priavte methods' do
    describe '#save' do
      subject { Ranking.new.save }
      it { assert_raise(NoMethodError) { subject } }
    end

    describe '#save!' do
      subject { Ranking.new.save! }
      it { assert_raise(NoMethodError) { subject } }
    end

    describe '#update' do
      subject { Ranking.new.update }
      it { assert_raise(NoMethodError) { subject } }
    end

    describe '#update!' do
      subject { Ranking.new.update! }
      it { assert_raise(NoMethodError) { subject } }
    end

    describe '#update_attributes' do
      subject { Ranking.new.update_attributes(foo: :bar) }
      it { assert_raise(NoMethodError) { subject } }
    end

    describe '#update_attributes!' do
      subject { Ranking.new.update_attributes!(foo: :bar) }
      it { assert_raise(NoMethodError) { subject } }
    end
  end
end
