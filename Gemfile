source "https://rubygems.org"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "~> 3.1.7"
# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"
# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false
# HTTP client library that's fun to use
gem "http"
# Pagination utilities
gem "kaminari"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma"
# Web application framework
gem "rails", "~> 8.0.2", ">= 8.0.2.1"
# Localization (Japanese) support
gem "rails-i18n"
# Email API for developers
gem "resend"
# PDF generation
gem "prawn"
gem "prawn-table"
# Use the database-backed adapters for Rails.cache and Active Job
gem "solid_cache"
gem "solid_queue"
# Use sqlite3 as the database for Active Record
gem "sqlite3"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"
# Use Tailwind CSS [https://github.com/rails/tailwindcss-rails]
gem "tailwindcss-rails"
# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]
# Parse and Compare HTTP User Agents
gem "useragent"
# Makes your Ruby/Rails web server become a functional WebAuthn Relying Party.
# https://www.w3.org/TR/webauthn/#webauthn-relying-party
gem "webauthn"

group :development, :test do
  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false
  # Audits gems for known security defects (use config/bundler-audit.yml to ignore issues)
  gem "bundler-audit", require: false
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false
end

group :development do
  # Browsing sent emails
  gem "letter_opener_web"
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
end
