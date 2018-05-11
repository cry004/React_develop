require 'test_helper'

class CombinationOfYearAndSubjectTest < ActiveSupport::TestCase
  subject { validator.validate_param!(:year, params) }

  let(:validator) do
    scope = Grape::Validations::ParamsScope.new(api: Grape::API)
    CombinationOfYearAndSubject.new({}, {}, {}, scope)
  end
  let(:params) { { year: year_params, subject: subject_params } }

  describe 'yearパラメータが"c1"の時' do
    let(:year_params) { 'c1' }

    describe 'subjectパラメータがenglish_regularの時' do
      let(:subject_params) { 'english_regular' }
      it { assert subject }
    end

    describe 'subjectパラメータがenglish_grammarの時' do
      let(:subject_params) { 'english_grammar' }
      it { assert_raise(Grape::Exceptions::Validation) { subject } }
    end
  end

  describe 'yearパラメータが"k"の時' do
    let(:year_params) { 'k' }

    describe 'subjectパラメータがenglish_grammarの時' do
      let(:subject_params) { 'english_grammar' }
      it { assert subject }
    end

    describe 'subjectパラメータがenglish_regularの時' do
      let(:subject_params) { 'english_regular' }
      it { assert_raise(Grape::Exceptions::Validation) { subject } }
    end
  end

  describe 'yearパラメータが無いとき' do
    let(:year_params) { nil }

    describe 'subjectパラメータがenglish_regularの時' do
      let(:subject_params) { 'english_regular' }
      it { assert subject }
    end

    describe 'subjectパラメータがenglish_grammarの時' do
      let(:subject_params) { 'english_grammar' }
      it { assert_raise(Grape::Exceptions::Validation) { subject } }
    end
  end
end
