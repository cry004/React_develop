require 'test_helper'

class PostTest < ActiveSupport::TestCase
  describe "spent_one_hour?" do
    it "1時間経過している場合trueを返す" do
      post = Post.create(created_at: 1.hours.ago)
      assert_equal true, post.spent_one_hour?
    end
    it "1時間経過していない場合はfalseを返す" do
      post = Post.create
      assert_equal false, post.spent_one_hour?
    end
  end

  describe "#accept" do
    before do
      @student = Student.first
      @student.recount_unreads
      @post = @student.questions.where(state: "checking").first.posts.where(postable_type: AdminUser, auto_reply: false).last
    end
    it "承認者が回答者の回答を承認するとstateがaccepted＿unreadになる" do
      @post.accept
      @post.reload
      assert_equal "accepted_unread", @post.state
    end
    it "承認者が回答者の回答を承認すると生徒の未読数が1増える" do
      assert_difference "@student.unreads", +1 do
        @post.accept
      end
    end
  end

  describe '#set_fee_point' do
    subject { @post.set_fee_point }
    before do
      @admin_user = AdminUser.where(role: "answerer").first
      @post = Post.create(postable: @admin_user, auto_reply: false)
    end
    describe 'when role is gold' do
      it 'postable_user fee point be Settings.fee_point_base.gold' do
        AdminUser.stub_any_instance(:judge_rank, "gold") do
          subject
          assert_equal Settings.fee_point_base.gold, @post.fee_point
        end
      end
    end
    describe 'when role is silver' do
      it 'postable_user fee point be Settings.fee_point_base.silver' do
        AdminUser.stub_any_instance(:judge_rank, "silver") do
          subject
          assert_equal Settings.fee_point_base.silver, @post.fee_point
        end
      end
    end
    describe 'when role is bronz' do
      it 'postable_user fee point be Settings.fee_point_base.bronze' do
        AdminUser.stub_any_instance(:judge_rank, "bronze") do
          subject
          assert_equal Settings.fee_point_base.bronze, @post.fee_point
        end
      end
    end
  end
end
