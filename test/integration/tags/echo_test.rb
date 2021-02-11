# frozen_string_literal: true

require 'test_helper'

class EchoTest < Minitest::Test
  include Solid

  def test_echo_outputs_its_input
    assert_template_result('BAR', <<~SOLID, 'variable-name' => 'bar')
      {{%- echo variable-name | upcase -%}}
    SOLID
  end
end
