require 'test_helper'

class FistTest < ActiveSupport::TestCase
  after { VCR.eject_cassette }

  describe '.valid_api_path' do
    subject { Fist.valid_api_path(path_param, jsessionid_param) }
    let(:jsessionid_param) { "xxxxxxxxxxxxxx" }

    describe 'when path_param is fist_login_url' do
      let(:path_param) { "fist_login_url" }
      it 'should return valid param included fist server query param' do
        assert_equal "/cstest/home.pc?tryg2", subject
      end
    end

    describe 'when path_param is fist_post_teacher_point_request_url' do
      let(:path_param) { "fist_post_teacher_point_request_url" }
      it 'should return valid param included fist server query param' do
        assert_equal "/cstest/conf.cs_R01-R010007.service;jsessionid=#{jsessionid_param};tryg2", subject
      end
    end

    describe 'when path_param is fist_get_kys_cd_url' do
      let(:path_param) { "fist_get_kys_cd_url" }
      it 'should return valid param included fist server query param' do
        assert_equal "/cstest/conf.cs_R01-R010006.service;jsessionid=#{jsessionid_param};tryg2", subject
      end
    end
  end

  describe '.post_to_login' do
    before { VCR.insert_cassette 'login' }
    subject { Fist.post_to_login }

    it 'should return 200' do
      res = subject

      assert_equal 200, res.status
      assert(Fist.login_check(res))
    end
  end

  describe '.get_jsession_id' do
    before { VCR.insert_cassette 'login' }
    subject { Fist.get_jsession_id }

    it 'should return 200' do
      return_value = subject

      assert(return_value.is_a? String)
      assert(return_value.size >= 20)
    end
  end

  describe '.get_kys_cd' do
    before { VCR.insert_cassette 'get_kys_cd' }
    let(:request_params) do
      {
       'KYS_SMI'        => '橋谷尚',
       'KYS_KNSMI'      => 'ハシヤヒサシ',
       'BIRTH_DATE_YMD' => '19460604',
       'TEL_NO'         => '0352112211',
       'MAIL'           => 'h.hashiya@example.com'
      }
    end
    subject { Fist.get_kys_cd(request_params) }

    it 'should return valid value' do
      subject

      assert_match /\d{11}/, subject
    end
  end

  describe '.post_teacher_point_request' do
    subject { Fist.post_teacher_point_request(request_params) }
    before { VCR.insert_cassette 'post_teacher_point_request' }
    let(:request_params) do
      {
        'KYS_CD' => '',
        'SHKKN_YTI_MNY' => 100
      }
    end
    it 'should return valid values' do
      res = subject

      assert(res.is_a? Array)
      assert_equal(2, res.count)
    end
  end
end
