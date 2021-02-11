# frozen_string_literal: true

require 'test_helper'

class DocumentTest < Minitest::Test
  include Solid

  def test_unexpected_outer_tag
    exc = assert_raises(SyntaxError) do
      Template.parse("{{% else %}}")
    end
    assert_equal(exc.message, "Solid syntax error: Unexpected outer 'else' tag")
  end

  def test_unknown_tag
    exc = assert_raises(SyntaxError) do
      Template.parse("{{% foo %}}")
    end
    assert_equal(exc.message, "Solid syntax error: Unknown tag 'foo'")
  end
end
