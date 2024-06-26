# frozen_string_literal: true

require_relative "cop_test"
require "minitest/autorun"
require "rubocop/cop/github/rails_view_render_shorthand"

class TestRailsViewRenderShorthand < CopTest
  def cop_class
    RuboCop::Cop::GitHub::RailsViewRenderShorthand
  end

  def test_render_string_no_offense
    offenses = erb_investigate cop, <<-ERB, "app/views/foo/index.html.erb"
      <%= render "foo/bar" %>
    ERB

    assert_equal 0, offenses.count
  end

  def test_render_string_with_locals_no_offense
    offenses = erb_investigate cop, <<-ERB, "app/views/foo/index.html.erb"
      <%= render "foo/bar", bar: 42 %>
    ERB

    assert_equal 0, offenses.count
  end

  def test_render_partial_offense
    offenses = erb_investigate cop, <<-ERB, "app/views/foo/index.html.erb"
      <%= render partial: "foo/bar" %>
    ERB

    assert_equal 1, offenses.count
    assert_equal "#{cop.name}: Use `render \"foo/bar\"` instead", offenses[0].message
  end

  def test_render_partial_with_locals_offense
    offenses = erb_investigate cop, <<-ERB, "app/views/foo/index.html.erb"
      <%= render partial: "foo/bar", locals: { bar: 42 } %>
    ERB

    assert_equal 1, offenses.count
    assert_equal "#{cop.name}: Use `render \"foo/bar\", { bar: 42 }` instead", offenses[0].message
  end

  def test_render_layout_no_offense
    offenses = erb_investigate cop, <<-ERB, "app/views/foo/index.html.erb"
      <%= render layout: "foo/bar" do %>
        Hello
      <% end %>
    ERB

    assert_equal 0, offenses.count
  end
end
