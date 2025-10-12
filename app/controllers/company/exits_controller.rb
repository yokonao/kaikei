class Company::ExitsController < ApplicationController
  def create
    user, company = Current.user, Current.company
    user.exit!(company)

    redirect_to companies_path, notice: "事業所（#{company.name}）から脱退しました。"
  end
end
