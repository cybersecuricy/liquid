# frozen_string_literal: true

require 'test_helper'

class ContextDrop < Solid::Drop
  def scopes
    @context.scopes.size
  end

  def scopes_as_array
    (1..@context.scopes.size).to_a
  end

  def loop_pos
    @context['forloop.index']
  end

  def solid_method_missing(method)
    @context[method]
  end
end

class ProductDrop < Solid::Drop
  class TextDrop < Solid::Drop
    def array
      ['text1', 'text2']
    end

    def text
      'text1'
    end
  end

  class CatchallDrop < Solid::Drop
    def solid_method_missing(method)
      "catchall_method: #{method}"
    end
  end

  def texts
    TextDrop.new
  end

  def catchall
    CatchallDrop.new
  end

  def context
    ContextDrop.new
  end

  protected

  def callmenot
    "protected"
  end
end

class EnumerableDrop < Solid::Drop
  def solid_method_missing(method)
    method
  end

  def size
    3
  end

  def first
    1
  end

  def count
    3
  end

  def min
    1
  end

  def max
    3
  end

  def each
    yield 1
    yield 2
    yield 3
  end
end

class RealEnumerableDrop < Solid::Drop
  include Enumerable

  def solid_method_missing(method)
    method
  end

  def each
    yield 1
    yield 2
    yield 3
  end
end

class DropsTest < Minitest::Test
  include Solid

  def test_product_drop
    tpl = Solid::Template.parse('  ')
    assert_equal('  ', tpl.render!('product' => ProductDrop.new))
  end

  def test_drop_does_only_respond_to_whitelisted_methods
    assert_equal("", Solid::Template.parse("{{{ product.inspect }}}").render!('product' => ProductDrop.new))
    assert_equal("", Solid::Template.parse("{{{ product.pretty_inspect }}}").render!('product' => ProductDrop.new))
    assert_equal("", Solid::Template.parse("{{{ product.whatever }}}").render!('product' => ProductDrop.new))
    assert_equal("", Solid::Template.parse('{{{ product | map: "inspect" }}}').render!('product' => ProductDrop.new))
    assert_equal("", Solid::Template.parse('{{{ product | map: "pretty_inspect" }}}').render!('product' => ProductDrop.new))
    assert_equal("", Solid::Template.parse('{{{ product | map: "whatever" }}}').render!('product' => ProductDrop.new))
  end

  def test_drops_respond_to_to_solid
    assert_equal("text1", Solid::Template.parse("{{{ product.to_solid.texts.text }}}").render!('product' => ProductDrop.new))
    assert_equal("text1", Solid::Template.parse('{{{ product | map: "to_solid" | map: "texts" | map: "text" }}}').render!('product' => ProductDrop.new))
  end

  def test_text_drop
    output = Solid::Template.parse(' {{{ product.texts.text }}} ').render!('product' => ProductDrop.new)
    assert_equal(' text1 ', output)
  end

  def test_catchall_unknown_method
    output = Solid::Template.parse(' {{{ product.catchall.unknown }}} ').render!('product' => ProductDrop.new)
    assert_equal(' catchall_method: unknown ', output)
  end

  def test_catchall_integer_argument_drop
    output = Solid::Template.parse(' {{{ product.catchall[8] }}} ').render!('product' => ProductDrop.new)
    assert_equal(' catchall_method: 8 ', output)
  end

  def test_text_array_drop
    output = Solid::Template.parse('{{% for text in product.texts.array %}} {{{text}}} {{% endfor %}}').render!('product' => ProductDrop.new)
    assert_equal(' text1  text2 ', output)
  end

  def test_context_drop
    output = Solid::Template.parse(' {{{ context.bar }}} ').render!('context' => ContextDrop.new, 'bar' => "carrot")
    assert_equal(' carrot ', output)
  end

  def test_context_drop_array_with_map
    output = Solid::Template.parse(' {{{ contexts | map: "bar" }}} ').render!('contexts' => [ContextDrop.new, ContextDrop.new], 'bar' => "carrot")
    assert_equal(' carrotcarrot ', output)
  end

  def test_nested_context_drop
    output = Solid::Template.parse(' {{{ product.context.foo }}} ').render!('product' => ProductDrop.new, 'foo' => "monkey")
    assert_equal(' monkey ', output)
  end

  def test_protected
    output = Solid::Template.parse(' {{{ product.callmenot }}} ').render!('product' => ProductDrop.new)
    assert_equal('  ', output)
  end

  def test_object_methods_not_allowed
    [:dup, :clone, :singleton_class, :eval, :class_eval, :inspect].each do |method|
      output = Solid::Template.parse(" {{{ product.#{method} }}} ").render!('product' => ProductDrop.new)
      assert_equal('  ', output)
    end
  end

  def test_scope
    assert_equal('1', Solid::Template.parse('{{{ context.scopes }}}').render!('context' => ContextDrop.new))
    assert_equal('2', Solid::Template.parse('{{%for i in dummy%}}{{{ context.scopes }}}{{%endfor%}}').render!('context' => ContextDrop.new, 'dummy' => [1]))
    assert_equal('3', Solid::Template.parse('{{%for i in dummy%}}{{%for i in dummy%}}{{{ context.scopes }}}{{%endfor%}}{{%endfor%}}').render!('context' => ContextDrop.new, 'dummy' => [1]))
  end

  def test_scope_though_proc
    assert_equal('1', Solid::Template.parse('{{{ s }}}').render!('context' => ContextDrop.new, 's' => proc { |c| c['context.scopes'] }))
    assert_equal('2', Solid::Template.parse('{{%for i in dummy%}}{{{ s }}}{{%endfor%}}').render!('context' => ContextDrop.new, 's' => proc { |c| c['context.scopes'] }, 'dummy' => [1]))
    assert_equal('3', Solid::Template.parse('{{%for i in dummy%}}{{%for i in dummy%}}{{{ s }}}{{%endfor%}}{{%endfor%}}').render!('context' => ContextDrop.new, 's' => proc { |c| c['context.scopes'] }, 'dummy' => [1]))
  end

  def test_scope_with_assigns
    assert_equal('variable', Solid::Template.parse('{{% assign a = "variable"%}}{{{a}}}').render!('context' => ContextDrop.new))
    assert_equal('variable', Solid::Template.parse('{{% assign a = "variable"%}}{{%for i in dummy%}}{{{a}}}{{%endfor%}}').render!('context' => ContextDrop.new, 'dummy' => [1]))
    assert_equal('test', Solid::Template.parse('{{% assign header_gif = "test"%}}{{{header_gif}}}').render!('context' => ContextDrop.new))
    assert_equal('test', Solid::Template.parse("{{% assign header_gif = 'test'%}}{{{header_gif}}}").render!('context' => ContextDrop.new))
  end

  def test_scope_from_tags
    assert_equal('1', Solid::Template.parse('{{% for i in context.scopes_as_array %}}{{{i}}}{{% endfor %}}').render!('context' => ContextDrop.new, 'dummy' => [1]))
    assert_equal('12', Solid::Template.parse('{{%for a in dummy%}}{{% for i in context.scopes_as_array %}}{{{i}}}{{% endfor %}}{{% endfor %}}').render!('context' => ContextDrop.new, 'dummy' => [1]))
    assert_equal('123', Solid::Template.parse('{{%for a in dummy%}}{{%for a in dummy%}}{{% for i in context.scopes_as_array %}}{{{i}}}{{% endfor %}}{{% endfor %}}{{% endfor %}}').render!('context' => ContextDrop.new, 'dummy' => [1]))
  end

  def test_access_context_from_drop
    assert_equal('123', Solid::Template.parse('{{%for a in dummy%}}{{{ context.loop_pos }}}{{% endfor %}}').render!('context' => ContextDrop.new, 'dummy' => [1, 2, 3]))
  end

  def test_enumerable_drop
    assert_equal('123', Solid::Template.parse('{{% for c in collection %}}{{{c}}}{{% endfor %}}').render!('collection' => EnumerableDrop.new))
  end

  def test_enumerable_drop_size
    assert_equal('3', Solid::Template.parse('{{{collection.size}}}').render!('collection' => EnumerableDrop.new))
  end

  def test_enumerable_drop_will_invoke_solid_method_missing_for_clashing_method_names
    ["select", "each", "map", "cycle"].each do |method|
      assert_equal(method.to_s, Solid::Template.parse("{{{collection.#{method}}}}").render!('collection' => EnumerableDrop.new))
      assert_equal(method.to_s, Solid::Template.parse("{{{collection[\"#{method}\"]}}}").render!('collection' => EnumerableDrop.new))
      assert_equal(method.to_s, Solid::Template.parse("{{{collection.#{method}}}}").render!('collection' => RealEnumerableDrop.new))
      assert_equal(method.to_s, Solid::Template.parse("{{{collection[\"#{method}\"]}}}").render!('collection' => RealEnumerableDrop.new))
    end
  end

  def test_some_enumerable_methods_still_get_invoked
    [:count, :max].each do |method|
      assert_equal("3", Solid::Template.parse("{{{collection.#{method}}}}").render!('collection' => RealEnumerableDrop.new))
      assert_equal("3", Solid::Template.parse("{{{collection[\"#{method}\"]}}}").render!('collection' => RealEnumerableDrop.new))
      assert_equal("3", Solid::Template.parse("{{{collection.#{method}}}}").render!('collection' => EnumerableDrop.new))
      assert_equal("3", Solid::Template.parse("{{{collection[\"#{method}\"]}}}").render!('collection' => EnumerableDrop.new))
    end

    assert_equal("yes", Solid::Template.parse("{{% if collection contains 3 %}}yes{{% endif %}}").render!('collection' => RealEnumerableDrop.new))

    [:min, :first].each do |method|
      assert_equal("1", Solid::Template.parse("{{{collection.#{method}}}}").render!('collection' => RealEnumerableDrop.new))
      assert_equal("1", Solid::Template.parse("{{{collection[\"#{method}\"]}}}").render!('collection' => RealEnumerableDrop.new))
      assert_equal("1", Solid::Template.parse("{{{collection.#{method}}}}").render!('collection' => EnumerableDrop.new))
      assert_equal("1", Solid::Template.parse("{{{collection[\"#{method}\"]}}}").render!('collection' => EnumerableDrop.new))
    end
  end

  def test_empty_string_value_access
    assert_equal('', Solid::Template.parse('{{{ product[value] }}}').render!('product' => ProductDrop.new, 'value' => ''))
  end

  def test_nil_value_access
    assert_equal('', Solid::Template.parse('{{{ product[value] }}}').render!('product' => ProductDrop.new, 'value' => nil))
  end

  def test_default_to_s_on_drops
    assert_equal('ProductDrop', Solid::Template.parse("{{{ product }}}").render!('product' => ProductDrop.new))
    assert_equal('EnumerableDrop', Solid::Template.parse('{{{ collection }}}').render!('collection' => EnumerableDrop.new))
  end

  def test_invokable_methods
    assert_equal(%w(to_solid catchall context texts).to_set, ProductDrop.invokable_methods)
    assert_equal(%w(to_solid scopes_as_array loop_pos scopes).to_set, ContextDrop.invokable_methods)
    assert_equal(%w(to_solid size max min first count).to_set, EnumerableDrop.invokable_methods)
    assert_equal(%w(to_solid max min sort count first).to_set, RealEnumerableDrop.invokable_methods)
  end
end # DropsTest
