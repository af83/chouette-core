class ExportMailer < ApplicationMailer

  def finished export_id, user_id
    @export = Export::Base.find(export_id)
    @user = User.find(user_id)
    mail to: @user.email, subject: t('mailers.export_mailer.finished.subject')
  end
end