require 'test_helper'
include SubjectHelper

class SubjectHelperTest < ActiveSupport::TestCase
  describe '#name_node' do
    subject { name_node(name: name_param, school: school_param, type: type_param, key: key_param) }
    let(:school_param) { 'c' }
    let(:type_param) { 'regular' }
    let(:key_param) { 'english_regular' }

    describe 'when name param is present' do
      let(:name_param) { '英語' }
      it "return name param value" do
        assert_equal subject, name_param
      end
    end

    describe 'when name params is nil' do
      let(:name_param) { nil }
      describe 'when school param is c' do
        it 'return name for type param' do
          assert_equal subject, '通常学習編'
        end
      end

      describe 'when school params is k' do
        let(:school_param) { 'k' }
        let(:type_param) { 'english_grammar' }
        let(:key_param) { 'english_grammar' }
        it 'return name for key_param' do
          assert_equal subject, '英語文法'
        end
      end
    end
  end

  describe '#name_html_node' do
    subject { name_html_node(name: name_param, school: school_param, type: type_param, key: key_param) }
    let(:name_param) { nil }
    let(:school_param) { 'k' }

    describe 'when key_param has roman number' do
      let(:type_param) { 'mathematics_1' }
      let(:key_param) { 'mathematics_1' }
      it 'return <span> tag' do
        assert_equal subject, "数学<span class='roman_num'>Ⅰ</span>"
      end
    end

    describe 'when key_param has not roman number' do
      let(:type_param) { 'english_grammar' }
      let(:key_param) { 'english_grammar' }
      it 'return value as same as name node' do
        assert_equal subject, '英語文法'
      end
    end

    describe 'when key_param has roman number' do
      let(:school_param) { 'c' }
      let(:type_param)   { 'high-level' }
      let(:key_param)    { nil }
      it 'return <p> and <span> tag' do
        assert_equal subject, <<~HTML
          <p class='exam highschool'>
            <span class='label'>入試対策編</span>
            <span class='type'>ハイレベル</span>
          </p>
        HTML
      end
    end
  end
end
