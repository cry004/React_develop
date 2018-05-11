class ParentMailer < ParentApplicationMailer
  def thank_for_checkout(parent, order)
    @parent = parent
    @order  = order
    mail(to: parent.email, subject: 'ご購入ありがとうございました')
  end
end
