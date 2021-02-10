# frozen_string_literal: true

require 'test_helper'

class TemplateFactoryUnitTest < Minitest::Test
  include Solid

  def test_for_returns_solid_template_instance
    template = TemplateFactory.new.for("anything")
    assert_instance_of(Solid::Template, template)
  end
end
