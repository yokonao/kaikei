# frozen_string_literal: true

use_sentry = !Rails.env.local?

use_sentry && Sentry.init do |config|
  config.dsn = Rails.application.credentials.sentry_dsn
  config.breadcrumbs_logger = [ :active_support_logger, :http_logger ]
end
