#!/usr/bin/env ruby

ENV["MT_NO_EXPECTATIONS"] = "1"
require 'minitest/autorun'

$LOAD_PATH.unshift(File.join(File.expand_path(__dir__), '..', 'lib'))
require 'solid.rb'
require 'solid/profiler'

mode = :strict
if env_mode = ENV['LIQUID_PARSER_MODE']
  puts "-- #{env_mode.upcase} ERROR MODE"
  mode = env_mode.to_sym
end
Solid::Template.error_mode = mode

if Minitest.const_defined?('Test')
  # We're on Minitest 5+. Nothing to do here.
else
  # Minitest 4 doesn't have Minitest::Test yet.
  Minitest::Test = MiniTest::Unit::TestCase
end

module Minitest
  class Test
    def fixture(name)
      File.join(File.expand_path(__dir__), "fixtures", name)
    end
  end

  module Assertions
    include Solid

    def assert_template_result(expected, template, assigns = {}, message = nil)
      assert_equal expected, Template.parse(template).render!(assigns), message
    end

    def assert_template_result_matches(expected, template, assigns = {}, message = nil)
      return assert_template_result(expected, template, assigns, message) unless expected.is_a? Regexp

      assert_match expected, Template.parse(template).render!(assigns), message
    end

    def assert_match_syntax_error(match, template, assigns = {})
      exception = assert_raises(Solid::SyntaxError) do
        Template.parse(template).render(assigns)
      end
      assert_match match, exception.message
    end

    def with_global_filter(*globals)
      original_global_strainer = Solid::Strainer.class_variable_get(:@@global_strainer)
      Solid::Strainer.class_variable_set(:@@global_strainer, Class.new(Solid::Strainer) do
        @filter_methods = Set.new
      end)
      Solid::Strainer.class_variable_get(:@@strainer_class_cache).clear

      globals.each do |global|
        Solid::Template.register_filter(global)
      end
      yield
    ensure
      Solid::Strainer.class_variable_get(:@@strainer_class_cache).clear
      Solid::Strainer.class_variable_set(:@@global_strainer, original_global_strainer)
    end

    def with_taint_mode(mode)
      old_mode = Solid::Template.taint_mode
      Solid::Template.taint_mode = mode
      yield
    ensure
      Solid::Template.taint_mode = old_mode
    end

    def with_error_mode(mode)
      old_mode = Solid::Template.error_mode
      Solid::Template.error_mode = mode
      yield
    ensure
      Solid::Template.error_mode = old_mode
    end
  end
end

class ThingWithToSolid
  def to_solid
    'foobar'
  end
end

class ErrorDrop < Solid::Drop
  def standard_error
    raise Solid::StandardError, 'standard error'
  end

  def argument_error
    raise Solid::ArgumentError, 'argument error'
  end

  def syntax_error
    raise Solid::SyntaxError, 'syntax error'
  end

  def runtime_error
    raise 'runtime error'
  end

  def exception
    raise Exception, 'exception'
  end
end
