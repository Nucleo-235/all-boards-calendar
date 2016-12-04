ActionMailer::Base.smtp_settings = {
  :address              => "mail.inda.org.br",
  :port                 => 587,
  :user_name            => "scinda@inda.org.br",
  :password             => "inda@2016",
  :authentication       => :login,
  :enable_starttls_auto => true,
  :openssl_verify_mode  => 'none'
}