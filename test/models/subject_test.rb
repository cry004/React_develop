require 'test_helper'

class SubjectTest < ActiveSupport::TestCase
  describe '.for_question_subject' do
    subject { Subject.for_question_subject(school: school, name: subject_name, type: "question") }

    describe 'when name is "english"' do
      let(:subject_name) { 'english' } # Minitest::Spec::nameとのNameCollision回避

      describe 'when school is "c"' do
        let(:school) { 'c' }
        it 'returns english.regular subject' do
          assert_equal subject.full_name, 'english_question'
        end
      end

      describe 'when school is "k"' do
        let(:school) { 'k' }
        it 'returns english.grammar subject' do
          assert_equal subject.full_name, 'english_question'
        end
      end
    end
  end

  describe '#convert_for_question_subject' do
    subject { Subject.where(school: school, name: subject_name).where.not(type: "question").first.convert_for_question_subject }

    describe 'when name is english' do
      let(:subject_name) { 'english' }
      describe 'when school is c' do
        let(:school) { 'c' }
        it 'returns english.question subject' do
          assert_equal subject.full_name, 'english_question'
        end
        it 'returns subject school is c' do
          assert_equal subject.school, 'c'
        end
      end

      describe 'when school is k' do
        let(:school) { 'k' }
        it 'returns english.question subject' do
          assert_equal subject.full_name, 'english_question'
        end
        it 'returns subject school is k' do
          assert_equal subject.school, 'k'
        end
      end
    end

    describe 'when subject is socialogy_geography_b' do
      subject { subject_obj.convert_for_question_subject }
      let(:subject_obj) do
        Subject.find_by(name: 'sociology', type: 'geography_b', school: 'k')
      end

      let(:expected_subject_obj) do
        Subject.find_by(name: 'geography', type: 'question', school: 'k')
      end

      it 'should return expected object' do
        assert_equal(expected_subject_obj, subject)
      end
    end

    describe 'when subject is socialogy_japanese_history_b' do
      subject { subject_obj.convert_for_question_subject }
      let(:subject_obj) do
        Subject.find_by(name: 'sociology', type: 'japanese_history_b', school: 'k')
      end

      let(:expected_subject_obj) do
        Subject.find_by(name: 'japanese_history', type: 'question', school: 'k')
      end

      it 'should return expected object' do
        assert_equal(expected_subject_obj, subject)
      end
    end
  end

  describe '#displayable_lesson_text_purchace_page?' do
    subject { subject_obj.displayable_lesson_text_purchace_page? }
    let(:subject_obj) do
      Subject.find_by(name: name_param, type: type_param)
    end

    describe 'when english_grammar' do
      let(:name_param) { 'english' }
      let(:type_param) { 'grammar' }

      it 'should return true' do
        assert(subject)
      end
    end

    describe 'when mathematics_1' do
      let(:name_param) { 'mathematics' }
      let(:type_param) { '1' }

      it 'should return true' do
        assert(subject)
      end
    end
    describe 'when mathematics_a' do
      let(:name_param) { 'mathematics' }
      let(:type_param) { 'a' }

      it 'should return true' do
        assert(subject)
      end
    end
    describe 'when mathematics_2' do
      let(:name_param) { 'mathematics' }
      let(:type_param) { '2' }

      it 'should return true' do
        assert(subject)
      end
    end

    describe 'when mathematics_b' do
      let(:name_param) { 'mathematics' }
      let(:type_param) { 'b' }

      it 'should return true' do
        assert(subject)
      end
    end

    describe 'when mathematics_3' do
      let(:name_param) { 'mathematics' }
      let(:type_param) { '3' }

      it 'should return false' do
        assert_equal(false, subject)
      end
    end

    describe 'when english_regular' do
      let(:name_param) { 'english' }
      let(:type_param) { 'regular' }

      it 'should return false' do
        assert_equal(false, subject)
      end
    end
  end
end
