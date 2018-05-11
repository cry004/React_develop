require 'test_helper'

class AdminUserTest < ActiveSupport::TestCase
  test "scopes" do
    assert_equal 'gatekeeper', AdminUser.gatekeepers.first.role
    assert_equal 'executive_answerer', AdminUser.executive_answerers.first.role
    assert_equal 'answerer', AdminUser.answerers.first.role
  end

  describe '#accepted_posts_at_prev_month' do
    let(:admin) { AdminUser.first }
    let(:post1) { Post.create(state: :accepted_read,   postable: admin, accepted_at: Date.today.prev_month) }
    let(:post2) { Post.create(state: :accepted_unread, postable: admin, accepted_at: Date.today.prev_month) }

    before { post1 && post2 }

    it '先月の承認済み回答を返す' do
      assert_equal 2, admin.accepted_posts_at_prev_month.count
    end
  end

  describe "#judge_rank" do
    before do
      @admin_user = AdminUser.first
    end
    it "回答数が100以下の場合ランクはbronze" do
      AdminUser.stub_any_instance(:accepted_posts_at_prev_month, Array.new(0)) do
        assert_equal "bronze", @admin_user.judge_rank
      end
      AdminUser.stub_any_instance(:accepted_posts_at_prev_month, Array.new(100)) do
        assert_equal "bronze", @admin_user.judge_rank
      end
    end
    it "回答数が101以上の300未満の場合ランクはsilver" do
      AdminUser.stub_any_instance(:accepted_posts_at_prev_month, Array.new(101)) do
        assert_equal "silver", @admin_user.judge_rank
      end
      AdminUser.stub_any_instance(:accepted_posts_at_prev_month, Array.new(200)) do
        assert_equal "silver", @admin_user.judge_rank
      end
      AdminUser.stub_any_instance(:accepted_posts_at_prev_month, Array.new(300)) do
        assert_equal "silver", @admin_user.judge_rank
      end
    end
    it "回答数が301以上の場合ランクはgold" do
      AdminUser.stub_any_instance(:accepted_posts_at_prev_month, Array.new(301)) do
        assert_equal "gold", @admin_user.judge_rank
      end
      AdminUser.stub_any_instance(:accepted_posts_at_prev_month, Array.new(10000)) do
        assert_equal "gold", @admin_user.judge_rank
      end
    end
  end

  describe "#check_accepted_posts" do
    before do
      @having_posts_admin_user = AdminUser.first
      @no_posts_admin_user = AdminUser.create
      post = Post.create(postable: @having_posts_admin_user)
      @having_posts_admin_user.posts << post
      @having_posts_admin_user.save
    end

    it "Postを持つAdminUserは削除されない" do
      assert_equal false, @having_posts_admin_user.destroy
    end

    it "Postを持たないAdminUserは削除できる" do
      admin_user = @no_posts_admin_user
      assert_equal admin_user, @no_posts_admin_user.destroy
    end
  end

  describe "#exec_decide_answerer_rank" do
    before do
      @admin_user = AdminUser.first
      @admin_user.update_attributes current_month: Time.now.prev_month.strftime("%Y%m").to_i, rank: "bronze"
      150.times { Post.create(postable: @admin_user, state: "accepted_read", accepted_at: Time.now.prev_month.beginning_of_month) }
    end

    it "current＿monthと現在の月が同じ場合は何にも実行されない" do
      @admin_user.update_attributes current_month: Time.now.strftime("%Y%m").to_i
      assert_nil @admin_user.exec_decide_answerer_rank
      assert_equal "bronze", @admin_user.rank
    end

    it "current＿monthと現在の月が同じでない場合はrankとcurrent＿monthが更新される" do
      @admin_user.exec_decide_answerer_rank
      assert_equal Time.now.strftime("%Y%m").to_i, @admin_user.current_month
      assert_equal "silver", @admin_user.rank
    end
  end

  describe '#unpaid_point' do
    subject { @admin_user.unpaid_point }
    before do
      @admin_user = AdminUser.where(role: "answerer").last
      @posts = []
      10.times { @posts << Post.create(postable: @admin_user, fee_point: 100, state: "accepted_unread") }
    end
    it 'return total fee_point of accepted posts' do
      assert_equal @posts.map(&:fee_point).sum, subject
    end
  end

  describe '#rank_at' do
    subject { @admin_user.rank_at @base_month_obj }
    before do
      @base_month_obj = Time.now.prev_month
      @admin_user = AdminUser.where(role: "answerer", rank: "bronze").last
      @posts = []
      200.times { @posts << Post.create(postable: @admin_user, state: "accepted_unread", accepted_at: @base_month_obj.prev_month) }
    end
    it 'return rank at prams time object' do
      assert_equal "silver", subject
    end
  end

  describe '#set_rank' do
    subject { @admin_user.set_rank @base_month }
    before do
      time = Time.now
      @base_month = time.strftime("%Y%m").to_i
      @admin_user = AdminUser.where(role: "answerer", rank: "bronze").last
      @admin_user.update_attributes current_month: time.prev_month.strftime("%Y%m").to_i
      @posts = []
      200.times { @posts << Post.create(postable: @admin_user, state: "accepted_unread", accepted_at: time.prev_month) }
    end
    it 'return rank at prams time object' do
      subject
      assert_equal "silver", @admin_user.rank
      assert_equal @base_month, @admin_user.current_month
    end
  end

  describe '#accepted_posts_at' do
    subject { @admin_user.accepted_posts_at @base_month_obj }
    before do
      @base_month_obj = Time.now.prev_month
      @admin_user = AdminUser.where(role: "answerer").last
      @posts = []
      20.times { @posts << Post.create(postable: @admin_user, state: "accepted_unread", accepted_at: @base_month_obj) }
    end
    it 'return accepted posts at some month which is designated param' do
      assert_equal @posts.sort_by(&:id), subject.order('id ASC')
    end
  end
end
