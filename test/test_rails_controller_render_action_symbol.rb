# frozen_string_literal: true

require_relative "cop_test"
require "minitest/autorun"
require "rubocop/cop/github/rails_controller_render_action_symbol"

class TestRailsControllerRenderActionSymbol < CopTest
  def cop_class
    RuboCop::Cop::GitHub::RailsControllerRenderActionSymbol
  end

  def test_render_string_no_offense
    offenses = investigate cop, <<-RUBY, "app/controllers/foo_controller.rb"
      class FooController < ActionController::Base
        def show
          render "show"
        end

        def edit
          render template: "edit"
        end

        def update
          render action: "edit"
        end
      end
    RUBY

    assert_equal 0, offenses.count
  end

  def test_render_inline_offense
    offenses = investigate cop, <<-RUBY, "app/controllers/foo_controller.rb"
      class FooController < ActionController::Base
        def show
          render :show
        end

        def edit
          render template: :edit
        end

        def update
          render action: :edit
        end
      end
    RUBY

    assert_equal 3, offenses.count
    expected_message = "#{cop.name}: Prefer `render` with string instead of symbol"
    assert_equal expected_message, offenses[0].message
    assert_equal expected_message, offenses[1].message
    assert_equal expected_message, offenses[2].message
  end
end
