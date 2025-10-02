class OtpMailer < ApplicationMailer
  default from: "Authorizer <auto@kaikei.yokonao.xyz>"

  def otp_login(user, otp)
    @user = user
    @otp = otp
    mail subject: "ログイン用ワンタイムパスワード", to: user.email_address
  end
end
