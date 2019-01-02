require 'test_helper'

class BlockUnitTest < Minitest::Test
  include Solid

  def test_blankspace
    template = Solid::Template.parse("  ")
    assert_equal ["  "], template.root.nodelist
  end

  def test_variable_beginning
    template = Solid::Template.parse("{{{funk}}}  ")
    assert_equal 2, template.root.nodelist.size
    assert_equal Variable, template.root.nodelist[0].class
    assert_equal String, template.root.nodelist[1].class
  end

  def test_variable_end
    template = Solid::Template.parse("  {{{funk}}}")
    assert_equal 2, template.root.nodelist.size
    assert_equal String, template.root.nodelist[0].class
    assert_equal Variable, template.root.nodelist[1].class
  end

  def test_variable_middle
    template = Solid::Template.parse("  {{{funk}}}  ")
    assert_equal 3, template.root.nodelist.size
    assert_equal String, template.root.nodelist[0].class
    assert_equal Variable, template.root.nodelist[1].class
    assert_equal String, template.root.nodelist[2].class
  end

  def test_variable_many_embedded_fragments
    template = Solid::Template.parse("  {{{funk}}} {{{so}}} {{{brother}}} ")
    assert_equal 7, template.root.nodelist.size
    assert_equal [String, Variable, String, Variable, String, Variable, String],
      block_types(template.root.nodelist)
  end

  def test_with_block
    template = Solid::Template.parse("  {{% comment %}} {{% endcomment %}} ")
    assert_equal [String, Comment, String], block_types(template.root.nodelist)
    assert_equal 3, template.root.nodelist.size
  end

  def test_with_custom_tag
    Solid::Template.register_tag("testtag", Block)
    assert Solid::Template.parse("{{% testtag %}} {{% endtesttag %}}")
  ensure
    Solid::Template.tags.delete('testtag')
  end

  private

  def block_types(nodelist)
    nodelist.collect(&:class)
  end
end # VariableTest
