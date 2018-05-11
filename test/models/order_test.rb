require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  describe ".settled_current_month_order" do
    before do
      @student = Student.first
      @order = @student.orders.first
      @order.update_attributes(state: "settled")
      @current_month = @student.current_month
      @next_month = SpentPointHistory.increase_current_month(@current_month)
    end
    it "今月分の確定orderを抽出する" do
      orders = Order.settled_current_month_order(@current_month, @next_month)
      assert_equal [@order], orders.to_a
    end
  end

  describe "#extend_to_the_next_month?" do
    describe "月をまたいでいる場合" do
      before do
        @student = Student.first
        @order = @student.orders.first
        @order.update_attributes(created_at: Date.today.prev_month)
      end

      it "trueを返す" do
        assert_equal true, @order.extend_to_the_next_month?
      end

      it "返ポイントされない" do
        assert_no_difference "@student.spent_point" do
          @order.cancel
        end
      end
    end

    describe "月をまたいでいない場合" do
      before do
        @student = Student.first
        @order = @student.orders.first
        @student.update_attributes(spent_point: 1000)
        @order.update_attributes(created_at: Date.today, total_point: 500)
      end
      it "返ポイントされる" do
        assert_difference "@student.spent_point", -500 do
          @order.cancel
          @student.reload
        end
      end
      it "falseを返す" do
        assert_equal false, @order.extend_to_the_next_month?
      end
    end
  end

  describe 'Studentがポイントを商品に引き替える' do
    before(:each) do
      Order.destroy_all
      LineItem.destroy_all
      @poor_student = Student.first
      @poor_student.update_attributes current_monthly_point: 2000, spent_point: 0
      @rich_student = Student.second
      @rich_student.update_attributes current_monthly_point: 4000, spent_point: 0
    end

    describe "注文が成功しない" do
      subject { @poor_student }

      describe '例外' do
        it "ポイントが足らなくて買えないという例外が発生する" do
          product = Product.find(2)#2300ptのが入ってるはず
          assert_raise(Exceptions::CurrentPointShortageError){ Order.execute(subject, [product]) }
        end
        it "購入できない商品を買おうとしたという例外が発生する" do
          product = Product.find(3)#state:standbyのが入ってるはず
          assert_raise(Exceptions::ProductAvailabilityError){ Order.execute(subject, [product]) }
        end
      end

      describe "トランザクション" do
        it "CurrentPointShortageError後にline_itemは存在しない" do
          product = Product.find(2)#2300ptのが入ってるはず
          begin
            Order.execute(subject, [product])
          rescue => CurrentPointShortageError
            assert_equal 0, LineItem.count
          end
        end
        it "ProductAvailabilityError後にline_itemは存在しない" do
          product = Product.find(3)
          begin
            Order.execute(subject, [product])
          rescue => ProductAvailabilityError
            assert_equal 0, LineItem.count
          end
        end
      end
    end

    describe "注文が成功する" do
      subject { @rich_student }

      describe "問題集を買う" do
        before(:each) do
          subject.update_attributes spent_point: 100
          product = Product.find(2)#2300ptの問題集が入ってるはず
          @order = Order.execute(subject, [product])
        end
        it "line_itemのpoint数が商品のポイント数と同じ" do
          assert_equal 2300, @order.line_items.first.point
        end
        it "消費ポイントが増える" do
          assert_equal 2400, subject.spent_point
        end
        it "categoryがtextbookになる" do
          assert_equal "textbook", @order.category
        end
        describe "キャンセルする" do
          it "返ポイントされる" do
            @order.cancel
            assert_equal 3900, subject.available_point
          end
        end
      end

      describe "質問を買う" do
        before(:each) do
          product = Product.find(1)#500ptの質問が入ってるはず
          @order = Order.execute(subject, [product])
        end
        it "line_itemのpoint数が商品のポイント数と同じ" do
          assert_equal 500, @order.line_items.first.point
        end
        it "消費ポイントが増える" do
          assert_equal 500, subject.spent_point
        end
        it "トータルポイントが減る" do
          assert_equal 3500, subject.available_point
        end
        it "categoryがquestionになる" do
          assert_equal "question", @order.category
        end
        describe "キャンセルする" do
          it "返ポイントされる" do
            @order.cancel
            assert_equal 4000, subject.available_point
          end
        end
      end
    end
  end

  describe 'initial state' do
    describe 'when product includes english exam textbook(school is c)' do
      before do
        @parent = Parent.first
        products = Product.where(category: "textbook", subject_name: "english", subject_type: "exam")
        @order = Order.execute(@parent, products)
      end
      it 'state retain ordered' do
        assert_equal "ordered", @order.state
      end
    end

    describe 'when product not includes english exam textbook(school is c)' do
      before do
        @parent = Parent.first
        products = Product.where(category: "textbook", subject_name: "english", subject_type: "regular")
        @order = Order.execute(@parent, products)
      end
      it 'state be unsettled ' do
        assert_equal "unsettled", @order.state
      end
    end
  end

  describe '#return_ordered' do
    before do
      @parent = Parent.first
      products = Product.where(category: "textbook", subject_name: "english", subject_type: "regular")
      @order = Order.execute(@parent, products)
    end
    it 'change state from unsettled to ordered' do
      @order.return_ordered
      @order.reload
      assert 'ordered', @order.state
    end

    it 'change english_schoolbook_code to nil' do
      @order.update_attributes english_schoolbook_code: "1"
      @order.return_ordered
      @order.reload
      assert_nil @order.english_schoolbook_code
    end
  end

  describe '#can_cancel?' do
    before do
      @parent = Parent.first
      products = Product.where(category: "textbook", subject_name: "english", subject_type: "regular")
      @order = Order.execute(@parent, products)
    end
    subject { @order.can_cancel? }

    describe 'when textbook order state is settled' do
      before { @order.update_attributes state: 'settled' }
      it 'should return false' do
        assert_equal false, subject
      end
    end

    describe 'when textbook order state is ordered' do
      before { @order.update_attributes state: 'ordered' }
      it 'should return true' do
        assert_equal true, subject
      end
    end

    describe 'when textbook order state is ordered' do
      before { @order.update_attributes state: 'unsettled' }
      it 'should return true' do
        assert_equal true, subject
      end
    end
  end

  describe '#failure' do
    before do
      @parent = Parent.first
      products = Product.where(category: "textbook", subject_name: "english", subject_type: "regular")
      @order = Order.execute(@parent, products)
    end

    subject { @order.failure }

    describe 'when order state is ordered' do
      before { @order.update_attributes(state: 'ordered') }
      it 'order state should become failed' do
        subject
        assert_equal 'failed', @order.state
      end
    end

    describe 'when order state is unsettled' do
      before { @order.update_attributes(state: 'unsettled') }
      it 'order state should become failed' do
        subject
        assert_equal 'failed', @order.state
      end
    end
  end

  describe '#data_for_csv' do
    before do
      @parent = Parent.first
      cart_items = CartItem.create
      english_products = Product.where(category: 'textbook',
                                       subject_name: 'english')
      mathematics_products = Product.where(category: 'textbook',
                                           subject_name: 'mathematics')
      english_products.each do |product|
        CartItem.create!(product_id: product.id,
                         quantity: 3,
                         checkoutable: @parent)
      end
      mathematics_products.each do |product|
        CartItem.create!(product_id: product.id,
                         quantity: 1,
                         checkoutable: @parent)
      end
      @cart_items = CartItem.where(checkoutable: @parent).includes(:product)
      @order = Order.checkout(@parent, @cart_items)
    end

    subject { @order.data_for_csv }
    let(:expected_return_array) do
      [3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 3, 1, 1, 1, 1]
    end

    it 'should return line_items array' do
      assert_equal(expected_return_array, subject)
    end
  end
end
