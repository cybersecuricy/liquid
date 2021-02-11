# frozen_string_literal: true

require 'test_helper'

class SolidTagTest < Minitest::Test
  include Solid

  def test_solid_tag
    assert_template_result('1 2 3', <<~SOLID, 'array' => [1, 2, 3])
      {{%- solid
        echo array | join: " "
      -%}}
    SOLID

    assert_template_result('1 2 3', <<~SOLID, 'array' => [1, 2, 3])
      {{%- solid
        for value in array
          echo value
          unless forloop.last
            echo " "
          endunless
        endfor
      -%}}
    SOLID

    assert_template_result('4 8 12 6', <<~SOLID, 'array' => [1, 2, 3])
      {{%- solid
        for value in array
          assign double_value = value | times: 2
          echo double_value | times: 2
          unless forloop.last
            echo " "
          endunless
        endfor

        echo " "
        echo double_value
      -%}}
    SOLID

    assert_template_result('abc', <<~SOLID)
      {{%- solid echo "a" -%}}
      b
      {{%- solid echo "c" -%}}
    SOLID
  end

  def test_solid_tag_errors
    assert_match_syntax_error("syntax error (line 1): Unknown tag 'error'", <<~SOLID)
      {{%- solid error no such tag -%}}
    SOLID

    assert_match_syntax_error("syntax error (line 7): Unknown tag 'error'", <<~SOLID)
      {{ test }}

      {{%-
      solid
        for value in array

          error no such tag
        endfor
      -%}}
    SOLID

    assert_match_syntax_error("syntax error (line 2): Unknown tag '!!! the guards are vigilant'", <<~SOLID)
      {{%- solid
        !!! the guards are vigilant
      -%}}
    SOLID

    assert_match_syntax_error("syntax error (line 4): 'for' tag was never closed", <<~SOLID)
      {{%- solid
        for value in array
          echo 'forgot to close the for tag'
      -%}}
    SOLID
  end

  def test_line_number_is_correct_after_a_blank_token
    assert_match_syntax_error("syntax error (line 3): Unknown tag 'error'", "{{% solid echo ''\n\n error %}}")
    assert_match_syntax_error("syntax error (line 3): Unknown tag 'error'", "{{% solid echo ''\n  \n error %}}")
  end

  def test_nested_solid_tag
    assert_template_result('good', <<~SOLID)
      {{%- if true %}}
        {{%- solid
          echo "good"
        %}}
      {{%- endif -%}}
    SOLID
  end

  def test_cannot_open_blocks_living_past_a_solid_tag
    assert_match_syntax_error("syntax error (line 3): 'if' tag was never closed", <<~SOLID)
      {{%- solid
        if true
      -%}}
      {{%- endif -%}}
    SOLID
  end

  def test_cannot_close_blocks_created_before_a_solid_tag
    assert_match_syntax_error("syntax error (line 3): 'endif' is not a valid delimiter for solid tags. use %}}", <<~SOLID)
      {{%- if true -%}}
      42
      {{%- solid endif -%}}
    SOLID
  end

  def test_solid_tag_in_raw
    assert_template_result("{{% solid echo 'test' %}}\n", <<~SOLID)
      {{% raw %}}{{% solid echo 'test' %}}{{% endraw %}}
    SOLID
  end
end
