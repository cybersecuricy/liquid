# frozen_string_literal: true

require 'test_helper'

class CaseTagUnitTest < Minitest::Test
  include Solid

  def test_case_nodelist
    template = Solid::Template.parse('{% case var %}{% when true %}WHEN{% else %}ELSE{% endcase %}')
    assert_equal(['WHEN', 'ELSE'], template.root.nodelist[0].nodelist.map(&:nodelist).flatten)
  end
end
