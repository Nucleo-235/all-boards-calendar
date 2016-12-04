class GeneralContact < MailForm::Base
  attribute :name,      :validate => true
  attribute :email,     :validate => /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
  attribute :message,   :validate => true

  # Declare the e-mail headers. It accepts anything the mail method
  # in ActionMailer accepts.
  def headers
    {
      :subject => "Gauss Website - Contato",
      :to => "ruy@gauss.com",
      :from => "ruy@gauss.com",
      :reply_to => %("#{name}" <#{email}>)
    }
  end
end