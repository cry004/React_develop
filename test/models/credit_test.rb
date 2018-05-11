require 'test_helper'

class CreditTest < ActiveSupport::TestCase
  before do
    @parent = Parent.first
    products = Product.where(category: "textbook", subject_name: "english", subject_type: "regular")
    @order = Order.execute(@parent, products)
    @credit = Credit.create(parent: @parent, reserved_amount: 6000, order: @order)
  end

  describe 'after_transition failure' do
    describe 'request_credit is failure' do
      subject { @credit.failure }

      it 'should be call Order#failure' do
        mock = MiniTest::Mock.new.expect(:try, true, [:failure])
        Credit.stub_any_instance(:order, mock) do
          subject
        end
        assert mock.verify
      end

      it '@order state is failed' do
        subject
        assert_equal 'failed', @order.state
      end
    end
  end

  describe 'Credit.reserve' do
    subject { Credit.reserve(params) }
    describe 'when reserve result is failed' do
      let(:params) { { parent: Parent.first, reserved_amount: 6400, order: @order } }

      it 'credit and order state are failed' do
        assert_equal 'unsettled', @order.state
        SBPS::Credit.stub_any_instance(:request_credit, false) do
          subject
        end
        assert_equal 'failed', @order.state
      end
    end
  end
end
