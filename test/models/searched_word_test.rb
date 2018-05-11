require 'test_helper'

class SearchedWordTest < ActiveSupport::TestCase
  describe '#validations' do
    %i(student name value).each do |column|
      describe 'with presence' do
        subject { SearchedWord.new }

        before { SearchedWord.skip_callback(:validation, :before, :set_value) }
        after  { SearchedWord.set_callback(:validation, :before, :set_value) }

        it "rejects a bad #{column} in validation" do
          assert subject.invalid?(column)
          assert_includes subject.errors[column], I18n.t('errors.messages.blank')
        end
      end
    end

    %i(name).each do |column|
      describe 'with uniqueness' do
        subject { SearchedWord.last.dup }

        it "rejects a bad #{column} in validation" do
          assert subject.invalid?(column)
          assert_includes subject.errors[column], I18n.t('errors.messages.taken')
        end
      end
    end

    %w(１ Ａ ａ A ア ｱ).each do |invalid_char|
      describe 'with format' do
        subject { SearchedWord.new(value: invalid_char) }

        before { SearchedWord.skip_callback(:validation, :before, :set_value) }
        after  { SearchedWord.set_callback(:validation, :before, :set_value) }

        it "rejects a bad value #{invalid_char} in validation" do
          assert subject.invalid?(:value)
          assert_includes subject.errors[:value], I18n.t('errors.messages.invalid')
        end
      end
    end

    describe 'with number_limitation' do
      subject do
        searched_word = SearchedWord.last.dup
        searched_word.name = 'uniq name'
        searched_word.save!(validate: false)
        searched_word
      end

      before { SearchedWord.skip_callback(:validation, :before, :remove_excess_records) }
      after  { SearchedWord.set_callback(:validation, :before, :remove_excess_records) }

      it 'rejects a bad record in validation' do
        assert subject.invalid?(:base)
        assert_includes subject.errors[:base],
                        I18n.t('activerecord.errors.messages.too_many_records')
      end
    end
  end

  describe '#before_validation' do
    describe '#remove_excess_records' do
      subject do
        searched_word = SearchedWord.last.dup
        searched_word.name = 'uniq name'
        searched_word.save!
        searched_word
      end

      it 'saves a new record' do
        assert subject.valid?
        assert_equal SearchedWord.last, subject
      end
    end
  end

  words = [%w(１ 1), %w(Ａ a), %w(ａ a), %w(A a), %w(ア あ), %w(ｱ あ), %w(ャ ゃ), %w(ｬ ゃ)]
  words.each do |word, converted|
    describe '#set_value' do
      subject do
        searched_word = SearchedWord.last
        searched_word.update!(name: word)
        searched_word.reload
      end

      it "saves a record with converted value #{word}" do
        assert subject.valid?
        assert_equal word,      subject.name
        assert_equal converted, subject.value
      end
    end
  end
end
