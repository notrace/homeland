# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require 'factory_girl'
FactoryGirl.definition_file_paths = [File.expand_path('../factories', __FILE__)]

require 'simplecov'
if ENV['CI']=='true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end
SimpleCov.start 'rails' do
  add_filter 'lib/homeland/version'
end

require File.expand_path("../dummy/config/environment", __FILE__)
ActiveRecord::Migrator.migrations_paths = [
  File.expand_path('../../db/migrate', __FILE__),
  File.expand_path("../dummy/db/migrate", __FILE__)
]

require "rails/test_help"
require 'minitest/mock'

FactoryGirl.find_definitions

Homeland.configure do
  self.user_avatar_method = 'avatar_url'
end

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

# Load fixtures from the engine
class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods
end

class ActionView::TestCase
  include Rails.application.routes.url_helpers

  # Fix Helper homeland.root_path
  def homeland
    Homeland::Engine.routes.url_helpers
  end
end

class ActionDispatch::IntegrationTest
  def sign_in(user)
    post user_session_path \
          "user[email]"    => user.email,
          "user[password]" => user.password
  end

  def sign_in_session(user)
    open_session do |app|
      app.post user_session_path,
        params: {
          'user[email]' => user.email,
          'user[password]' => user.password
        }
      assert app.controller.user_signed_in?, "login_with_session #{user.email} 没有成功, #{app.flash[:alert]}"
    end
  end
end
