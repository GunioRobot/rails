require 'active_record_unit'
require 'active_record/railties/controller_runtime'
require 'fixtures/project'
require 'rails/log_subscriber/test_helper'
require 'action_controller/railties/log_subscriber'

ActionController::Base.send :include, ActiveRecord::Railties::ControllerRuntime

class ControllerRuntimeLogSubscriberTest < ActionController::TestCase
  class LogSubscriberController < ActionController::Base
    def show
      render :inline => "<%= Project.all %>"
    end
  end

  include Rails::LogSubscriber::TestHelper
  tests LogSubscriberController

  def setup
    @old_logger = ActionController::Base.logger
    Rails::LogSubscriber.add(:action_controller, ActionController::Railties::LogSubscriber.new)
    super
  end

  def teardown
    super
    Rails::LogSubscriber.log_subscribers.clear
    ActionController::Base.logger = @old_logger
  end

  def set_logger(logger)
    ActionController::Base.logger = logger
  end

  def test_log_with_active_record
    get :show
    wait

    assert_equal 2, @logger.logged(:info).size
    assert_match /\(Views: [\d\.]+ms | ActiveRecord: [\d\.]+ms\)/, @logger.logged(:info)[1]
  end
end