# @note ActionDispatch::PublicExceptions の実装をベースに、エラーページを ERB で記述できるように改変している
# @see https://github.com/rails/rails/blob/v8.0.3/actionpack/lib/action_dispatch/middleware/public_exceptions.rb
class ExceptionsController < ApplicationController
  # @note HEAD リクエストを処理するための Rack ミドルウェア
  # @see https://github.com/rack/rack/blob/v3.2.3/lib/rack/head.rb
  class Head
    def initialize(app)
      @app = app
    end

    def call(env)
      _, _, body = response = @app.call(env)

      if env["action_dispatch.original_request_method"] == "HEAD"
        body.close if body.respond_to?(:close)
        response[2] = []
      end

      response
    end
  end

  use Head

  allow_unauthenticated_access only: %i[ show ]

  def show
    original_status = request.path_info[1..-1].to_i
    render "exceptions/#{original_status}", status: original_status
  rescue ActionView::MissingTemplate => e
    Rails.logger.error "#{e.class.name} (#{e.message})"
    render "exceptions/500", status: :internal_server_error
  end
end
