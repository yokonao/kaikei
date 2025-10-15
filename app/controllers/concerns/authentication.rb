module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    before_action :require_company_selection
    helper_method :authenticated?, :company_selected?, :target_user, :target_company
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
      skip_before_action :require_company_selection, **options
    end

    def allow_no_company_access(**options)
      skip_before_action :require_company_selection, **options
    end
  end

  private
    def authenticated?
      resume_session
    end

    def require_authentication
      resume_session || request_authentication
    end

    def resume_session
      Current.session ||= find_session_by_cookie
    end

    def find_session_by_cookie
      session_id = cookies.signed[:session_id]
      return nil unless session_id

      session = Session.find_by(id: session_id).tap do |session|
        return unless session
        Current.user = user = session.user
        Current.company = user.companies.find_by(id: session.company_id) if user
      end
    end

    def request_authentication
      session[:return_to_after_authenticating] = request.url
      redirect_to new_session_path
    end

    def after_authentication_url
      session.delete(:return_to_after_authenticating) || root_url
    end

    def start_new_session_for(user, company: nil)
      company ||= user.companies.length == 1 ? user.companies.first : nil
      user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip, company: company).tap do |session|
        Current.session = session
        cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
      end
    end

    def terminate_session
      Current.session&.destroy
      cookies.delete(:session_id)
    end

    def company_selected?
      Current.company.present?
    end

    def select_company(company)
      resume_session.update!(company: company)
    end

    def require_company_selection
      return if company_selected?

      redirect_to companies_path
    end

    # 操作対象となるユーザー。認証済みユーザーとの一致を前提とする
    # 例外的に別ユーザーに対する操作が必要な場合は、適切な認可処理とともに個別実装する想定
    def target_user
      @target_user ||= User.where(id: Current.user&.id).find(params[:user_id])
    end

    # 操作対象となる事業所、ログインセッションの事業所との一致を前提とする
    # 例外的に別事業所に対する操作が必要な場合は、適切な認可処理とともに個別実装する想定
    def target_company
      @target_company ||= Company.where(id: Current.company&.id).find(params[:company_id])
    end
end
