require 'test_helper'

class QuestionTest < ActiveSupport::TestCase
  let(:question_point) { Product.find_by(category: "question").point }
  let(:current_student) { Student.first }

  test "initial state is initial" do
    question = Question.new(student: current_student)
    question.save
    assert_equal 'initial', question.state
  end

  describe "scope" do
    it ".resolved" do
      assert_equal Question.where(state: "closed"), Question.resolved
    end
    it ".no＿resolved" do
      assert_equal Question.unscope(where: :state).where.not(state: ["closed", "deleted"]), Question.no_resolved
    end
    it ".opened" do
      assert_equal Question.where(state: ["open", "accepted", "assigned", "answered_unchecked", "examining", "checking", "pending"]), Question.opened
    end
    it ".answered" do
      assert_equal Question.where(state: "answered_checked"), Question.answered
    end
    it ".refused" do
      assert_equal Question.where(state: "refused"), Question.refused
    end
  end

  describe "質問を受理する / 拒否する" do
    before do
      @student = Student.first
      @student.update_attributes current_monthly_point: 2000, spent_point: 0
      @question = Question.new(student: @student, state: "examining")
      post = Post.create(postable: @student)
      @question.posts << post
      product = Product.find_by(category: "question")
      @order = Order.execute(@student, [product])
      @prev_total_point = @student.reload.current_total_point
      @question.order = @order
      @question.save
    end

    describe "受理する場合" do
      it "accepptするとポストがaccepted＿readになる" do
        @question.accept
        @question.reload
        assert_equal 'accepted_read', @question.posts.last.state
      end
    end

    describe "拒否する場合" do
      before do
        @question.refuse_and_post_refuse_reason("テスト", "テスト", AdminUser.first)
      end

      it "refuseするとポストがrejectedになる" do
        assert_equal 'rejected', @question.posts.where(postable: @student).first.state
      end

      it "ポイントが返却される" do
        assert_equal question_point, @student.reload.current_total_point - @prev_total_point
      end

      it "orderがcanceledになる" do
        assert_equal "canceled", @order.state
      end
    end
  end

  describe "auto_assign_scope" do
    before do
      ["open", "examining", "accepted", "assigned", "checking", "answered_unchecked"].each { |state| Question.create!(opened_at: 1.days.ago, state: state, student: current_student) }
    end
    it "昨日以前に作られており, stateがopen, examining, accepted, assigned, checking, answered＿uncheckedのものが返ってくる" do
      assert_equal 6, Question.auto_assign_scope.count
    end
  end

  describe "return_point_scope" do
    before do
      @student = Student.first
      @student.update_attributes! spent_point: 0 , current_monthly_point: 15000
      ["open", "accepted", "assigned", "answered_unchecked", "examining", "checking", "pending"].each do |state|
        question = Question.create!(opened_at: 48.hours.ago, state: state, student: current_student)
        order = Order.new(orderable: @student, state: "ordered", total_point: 500)
        order.line_items << LineItem.create!(product: Product.find_by(category: "question"), point: 500)
        order.save!
        question.update_attributes! order: order
      end
    end

    it "作成されてから48時間経過し,stateがopen, accepted, assigned, answered_unchecked, examining, checking, pendingであるquestionsを取得する" do
      assert_equal 7, Question.return_point_scope.count
    end
  end

  describe "consume_point" do
    it "質問するとポイントが消費される" do
      student = Student.first
      student.update_attribute :current_monthly_point, 10000
      prev_total_point = student.current_total_point
      Question.consume_point(student)
      assert_equal question_point, prev_total_point - student.reload.current_total_point
    end

    it "ポイントが足りないと質問できない" do
      student = Student.first
      student.update_attribute :current_monthly_point, 0
      assert_raise Exceptions::CurrentPointShortageError do
        Question.consume_point(student)
      end
    end
  end

  describe "assign_and_create_post(admin_user)" do
    before do
      @admin_user = AdminUser.find_by(role: "answerer")
      @question = Question.new(state: "accepted", student: current_student)
      post = Post.create(postable: Student.first)
      @question.posts << post
      @question.save
      @question.assign_and_create_post(@admin_user)
      @question.reload
    end

    it "AdminUserのポストが作成される" do
      assert_equal @question.posts.where(postable_type: "AdminUser").first, Post.where(question: @question, postable: @admin_user).first
    end

    it "questionがassignedになる" do
      assert_equal "assigned", @question.state
    end
  end

  describe "質問のアサインを外す場合" do
    before do
      @admin_user = AdminUser.find_by(role: "answerer")
      @question = Question.new(state: "assigned", answerer_id: @admin_user.id, student: current_student)
      post = Post.create(postable: Student.first)
      post_from_admin = Post.create(postable: @admin_user)
      @question.posts << post
      @question.posts << post_from_admin
      @question.save
      @question.deassign
      @question.reload
    end

    it "回答者のポストが削除される" do
      assert_equal [], @question.posts.where(postable_type: "AdminUser")
    end

    it "質問のステートがacceptedに戻る" do
      assert_equal "accepted", @question.state
    end

    it "質問のanswerer_idがnilになる" do
      assert_nil @question.answerer_id
    end
  end

  describe "deassign_if_one_hour_spent(admin_user) method" do
    before do
      @admin_user = AdminUser.find_by(role: "answerer")
      @question = Question.new(state: "assigned", answerer_id: @admin_user.id, student: current_student)
      post = Post.create(postable: Student.first)
      @post_from_admin = Post.create(postable: @admin_user, created_at: 1.hours.ago)
      @question.posts << post
      @question.posts << @post_from_admin
      @question.save
    end
    describe "回答者がアサインしてから１時間が経過した場合" do
      it "trueを返す" do
        assert true, @question.deassign_if_one_hour_spent(@admin_user)
      end

      it "回答者のポストが削除される" do
        @question.deassign_if_one_hour_spent(@admin_user)
        @question.reload
        assert_equal [], @question.posts.where(postable_type: "AdminUser")
      end

      it "質問のステートがacceptedに戻る" do
        @question.deassign_if_one_hour_spent(@admin_user)
        @question.reload
        assert_equal "accepted", @question.state
      end

      it "質問のanswerer_idがnilになる" do
        @question.deassign_if_one_hour_spent(@admin_user)
        @question.reload
        assert_nil @question.answerer_id
      end
    end

    describe "回答者がアサインしてから１時間が経過していない場合" do
      before do
        @post_from_admin.update_attributes(created_at: 30.minutes.ago)
        @post_from_admin.reload
      end
      it "falseを返す" do
        assert_equal false, @question.deassign_if_one_hour_spent(@admin_user)
      end
    end
  end

  describe "#check" do
    before do
      @student = Student.first
      @student.recount_unreads
      @question = @student.questions.where(state: "checking").first
    end
    it "stateがanswered＿checkedになる" do
      @question.check
      @question.reload
      assert_equal "answered_checked", @question.state
    end
    it "Questionに紐づくOrderが確定する" do
      @question.check
      assert_equal "settled", @question.order.state
    end
  end

  describe "#update_with_video" do
    before do
      @student = Student.first
      @student.update_attributes current_monthly_point: 15000
      @previous_point = @student.available_point
      @question = Question.create(student: @student)
      @question.posts << Post.create(postable: Student.first)
      @question.save
    end

    describe "create_flagがtrueの場合" do
      before { @question.update_with_video("test", true) }

      it "ポイントが消費される" do
        assert_equal 500, (@previous_point - @student.available_point)
      end

      it "Postのbodyがupdateされる" do
        assert_equal "test", @question.posts.where(postable: @student).first.body
      end

      it "Postのstateがupdateされる" do
        assert_equal "accepted_read", @question.posts.where(postable: @student).first.state
      end

      it "Questionのstateがopenになる" do
        assert_equal "open", @question.state
      end

      it "回答botからの返信がくる" do
        assert_equal "質問ありがとうございました。返信をお待ちください。", @question.posts.where(postable_type: "AdminUser").first.body
      end
    end
    describe "create_flagがfalseの場合" do
      before { @question.update_with_video("test", false) }

      it "bodyが更新される" do
        assert_equal "test", @question.posts.where(postable: @student).first.body
      end

      it "stateがdraftになる" do
        assert_equal "draft", @question.state
      end
    end
  end

  describe "#delete_state?" do
    it "stateがinitialの場合trueを返す" do
      question = Question.create(state: "initial", student: current_student)
      assert_equal question.delete_state?, true
    end

    it "stateがdraftの場合trueを返す" do
      question = Question.create(state: "draft", student: current_student)
      assert_equal question.delete_state?, true
    end

    it "stateがrefusedの場合trueを返す" do
      question = Question.create(state: "refused", student: current_student)
      assert_equal question.delete_state?, true
    end

    it "stateがopenの場合falseを返す" do
      question = Question.create(state: "open", student: current_student)
      assert_equal question.delete_state?, false
    end
  end

  describe "#delete_tryit" do
    before do
      @admin_user = AdminUser.find_by(role: "answerer")
      @student = Student.first
      @question = Question.create(student: @student, state: question_state_param)
      @question.posts << Post.create(postable: Student.first)
      @admin_user_post = Post.create(question: @question, postable: @admin_user, auto_reply: false, state: admin_user_post_state_param)
      @question.posts << @admin_user_post
      @question.save
      @previous_question_count = @student.questions.unscope(where: :state).count
      @previous_post_count = @student.posts.unscope(where: :state).count
    end

    let(:question_state_param) { 'draft' }
    let(:admin_user_post_state_param) { 'draft' }

    describe "stateがinitialかdraftかclosedの時のみ削除できる" do
      it "stateがinitialの場合削除される" do
        @question.delete_tryit
        assert_equal @previous_question_count - 1, @student.questions.unscope(where: :state).count
        assert_equal @previous_post_count - 1, @student.posts.unscope(where: :state).count
      end

      it "stateがdraftの場合削除される" do
        @question.update_attributes(state: "draft")
        @question.reload
        @question.delete_tryit
        assert_equal @previous_question_count - 1, @student.questions.unscope(where: :state).count
        assert_equal @previous_post_count - 1, @student.posts.unscope(where: :state).count
      end

      it "stateがrefusedの場合削除される" do
        @question = @student.questions.refused.first
        @question.delete_tryit
        assert_equal @previous_question_count - 1, @student.questions.unscope(where: :state).count
        assert_equal @previous_post_count - 1, @student.posts.unscope(where: :state).count
      end

      it "stateがclosedの時は削除されない" do
        @question.update_attributes(state: "closed")
        @question.reload
        @question.delete_tryit
        assert_equal @previous_question_count, @student.questions.unscope(where: :state).count
        assert_equal @previous_post_count, @student.posts.unscope(where: :state).count
      end

      it "stateがopenの場合削除されない。" do
        @question.update_attributes(state: "open")
        @question.reload
        @question.delete_tryit
        assert_equal @previous_question_count, @student.questions.unscope(where: :state).count
        assert_equal @previous_post_count, @student.posts.unscope(where: :state).count
      end
    end

    describe '承認済みの回答がある場合' do
      let(:question_state_param) { 'refused' }
      let(:admin_user_post_state_param) { 'question_refused' }

      it 'question及びpostsは削除されず、questionのstateはdeletedになる' do
        @question.delete_tryit
        @question.reload

        assert_equal 'deleted', @question.state
        assert_equal @previous_question_count, @student.questions.unscope(where: :state).count
        assert_equal @previous_post_count, @student.posts.unscope(where: :state).count
      end
    end
  end

  describe ".except_deleted_state_scope" do
    before do
      @student = Student.first
      @question = Question.create(student: @student, state: "deleted")
      @question.posts << Post.create(postable: Student.first)
      @question.save
    end
    it "stateがdelete以外のものを抽出する" do
      questions = @student.questions.except_deleted_state_scope
      question_states = questions.map(&:state).uniq
      assert_not question_states.include? ("deleted")
    end
  end

  describe "#add_favorite" do
    before do
      @student = Student.first
      @question = Question.create(student: @student, favorite: false)
    end

    it "favoriteカラムがtrueになる" do
      @question.add_favorite
      @question.reload
      assert_equal true, @question.favorite
    end
  end

  describe "#remove_favorite" do
    before do
      @student = Student.first
      @question = Question.create(student: @student, favorite: true)
    end

    it "favoriteカラムがfalseになる" do
      @question.remove_favorite
      @question.reload
      assert_equal false, @question.favorite
    end
  end

  describe '#update_without_video' do
    before do
      @student = Student.first
      @student.update_attributes current_monthly_point: 15000
      @previous_point = @student.available_point
      @question = Question.create(student: @student)
      @question.posts << Post.create(postable: Student.first)
      @question.save
    end

    describe 'without old_question_flag' do
      describe 'create_flagがtrueの場合' do
        before { @question.update_without_video(nil, 'english', 'test', true) }

        it 'ポイントが消費される' do
          assert_equal 500, (@previous_point - @student.available_point)
        end

        it 'Postのbodyがupdateとされる' do
          assert_equal 'test', @question.posts.where(postable: @student).first.body
        end

        it 'Postのstateがupdateされる' do
          assert_equal 'accepted_read', @question.posts.where(postable: @student).first.state
        end

        it 'Questionのstateがopenになる' do
          assert_equal 'open', @question.state
        end

        it '回答botからの返信がくる' do
          assert_equal '質問ありがとうございました。返信をお待ちください。', @question.posts.where(postable_type: :AdminUser).first.body
        end

        describe 'subject for without video question' do
          let(:mock) do
            MiniTest::Mock.new.expect(:call, Subject.new, [name: name_param, school: school])
          end

          let(:name_param)   { 'english' }
          let(:school) { @student.school }

          it 'calls Subject::for_question_subject' do
            Subject.stub(:for_question_subject, mock) do
              @question.update_without_video(nil, 'english', 'test', true)
            end
            assert mock.verify
          end
        end
      end

      describe 'create_flagがfalseの場合' do
        before { @question.update_without_video(nil, 'english', 'test', false) }

        it 'bodyが更新される' do
          assert_equal 'test', @question.posts.where(postable: @student).first.body
        end

        it 'stateがdraftになる' do
          assert_equal 'draft', @question.state
        end

        describe 'subject for without video question' do
          let(:mock) do
            MiniTest::Mock.new.expect(:call, Subject.new, [name: name_param, school: school])
          end

          let(:name_param)   { 'english' }
          let(:school) { @student.school }

          it 'calls Subject::for_question_subject' do
            Subject.stub(:for_question_subject, mock) do
              @question.update_without_video(nil, 'english', 'test', false)
            end
            assert mock.verify
          end
        end
      end
    end

    describe 'when old_question_flag is false' do
      let(:old_question_flag) { false }

      describe 'create_flagがtrueの場合' do
        before { @question.update_without_video(nil, 'english', 'test', true, old_question_flag) }

        it 'ポイントが消費される' do
          assert_equal 500, (@previous_point - @student.available_point)
        end

        it 'Postのbodyがupdateとされる' do
          assert_equal 'test', @question.posts.where(postable: @student).first.body
        end

        it 'Postのstateがupdateされる' do
          assert_equal 'accepted_read', @question.posts.where(postable: @student).first.state
        end

        it 'Questionのstateがopenになる' do
          assert_equal 'open', @question.state
        end

        it '回答botからの返信がくる' do
          assert_equal '質問ありがとうございました。返信をお待ちください。', @question.posts.where(postable_type: :AdminUser).first.body
        end

        describe 'subject for without video question' do
          let(:mock) do
            MiniTest::Mock.new.expect(:call, Subject.new, [name: name_param, school: school])
          end

          let(:name_param) { 'english' }
          let(:school)     { nil }

          it 'calls Subject::for_question_subject' do
            Subject.stub(:for_question_subject, mock) do
              @question.update_without_video(nil, 'english', 'test', true, old_question_flag)
            end
            assert mock.verify
          end
        end
      end

      describe 'create_flagがfalseの場合' do
        before { @question.update_without_video(nil, 'english', 'test', false) }

        it 'bodyが更新される' do
          assert_equal 'test', @question.posts.where(postable: @student).first.body
        end

        it 'stateがdraftになる' do
          assert_equal 'draft', @question.state
        end

        describe 'subject for without video question' do
          let(:mock) do
            MiniTest::Mock.new.expect(:call, Subject.new, [name: name_param, school: school])
          end

          let(:name_param) { 'english' }
          let(:school)     { nil }

          it 'calls Subject::for_question_subject' do
            Subject.stub(:for_question_subject, mock) do
              @question.update_without_video(nil, 'english', 'test', false, old_question_flag)
            end
            assert mock.verify
          end
        end
      end
    end
  end

  describe "#unresolve" do
    before do
      @student = Student.first
      @question = Question.create(student: @student)
    end
    describe "質問の状態がclosedの場合" do
      before {  @question.update_attributes(state: "closed") }

      it "stateがanswered＿checkedに更新される。" do
        @question.unresolve
        assert_equal "answered_checked", @question.state
      end
    end

    describe "質問の状態がclosed以外の場合" do
      before {  @question.update_attributes(state: "answered_checked") }
      it "stateは更新されない。" do
        @question.unresolve
        assert_equal "answered_checked", @question.state
      end
    end
  end

  describe '#build_type_node' do
    subject { question.build_type_node }
    before do
      student = Student.first
      @video_question = Question.create(video_id: 1,  student: student)
      @not_video_question = Question.create(video_id: nil, student: student)
    end

    describe 'when question has video_id' do
      let(:question) { @video_question }
      it 'return video' do
        assert_equal 'video', subject
      end
    end

    describe 'when question has not video_id' do
      let(:question) { @not_video_question }
      it 'return other' do
        assert_equal 'other', subject
      end
    end
  end

  describe '.force_reject' do
    before do
      @admin_user = AdminUser.find_by(role: "answerer")
      @student = Student.first
      @student.update_attributes current_monthly_point: 15000
      @order = Question.consume_point(@student)
      @question = Question.create(state: state_param, student: @student, order: @order)
      @student_post = Post.create(question: @question, postable: @student)
      @admin_user_post = Post.create(question: @question, postable: @admin_user, auto_reply: false)
    end

    describe 'when question state is checking' do
      before do
        @question.force_reject
      end

      let(:state_param) { 'checking' }

      it 'state should be refused' do
        assert_equal 'refused', @question.state
      end

      it 'post should be set point' do
        @admin_user_post.reload
        assert_equal 200, @admin_user_post.fee_point
      end

      it 'accepted_at should be not nil' do
        @admin_user_post.reload
        assert_not_nil @admin_user_post.accepted_at
      end

      it 'state should be question_refused' do
        @admin_user_post.reload
        assert_equal "question_refused", @admin_user_post.state
      end
    end

    describe 'when question state is answered_unchecked' do
      before do
        @question.force_reject
      end

      let(:state_param) { 'answered_unchecked' }

      it 'state should be refused' do
        assert_equal 'refused', @question.state
      end

      it 'post should be set point' do
        @admin_user_post.reload
        assert_equal 200, @admin_user_post.fee_point
      end

      it 'accepted_at should be not nil' do
        @admin_user_post.reload
        assert_not_nil @admin_user_post.accepted_at
      end

      it 'state should be question_refused' do
        @admin_user_post.reload
        assert_equal "question_refused", @admin_user_post.state
      end
    end

    describe 'when question state is draft' do
      before do
        @question.force_reject
      end

      let(:state_param) { 'accepted' }

      it 'state should be refused' do
        assert_equal 'refused', @question.state
      end

      it 'post should not be set point' do
        @admin_user_post.reload
        assert_nil @admin_user_post.fee_point
      end
    end

    describe 'when question state is assigned' do
      before do
        @question.force_reject
      end

      let(:state_param) { 'assigned' }

      it 'state should be refused' do
        assert_equal 'refused', @question.state
      end

      it 'post should not be set point' do
        @admin_user_post.reload
        assert_nil @admin_user_post.fee_point
      end
    end
  end
end
