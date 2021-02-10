#!/usr/bin/env ruby
# frozen_string_literal: true

ENV["MT_NO_EXPECTATIONS"] = "1"
require 'minitest/autorun'

$LOAD_PATH.unshift(File.join(File.expand_path(__dir__), '..', 'lib'))
require 'solid.rb'
require 'solid/profiler'

mode = :strict
if (env_mode = ENV['SOLID_PARSER_MODE'])
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
      assert_equal(expected, Template.parse(template, line_numbers: true).render!(assigns), message)
    end

    def assert_template_result_matches(expected, template, assigns = {}, message = nil)
      return assert_template_result(expected, template, assigns, message) unless expected.is_a?(Regexp)

      assert_match(expected, Template.parse(template, line_numbers: true).render!(assigns), message)
    end

    def assert_match_syntax_error(match, template, assigns = {})
      exception = assert_raises(Solid::SyntaxError) do
        Template.parse(template, line_numbers: true).render(assigns)
      end
      assert_match(match, exception.message)
    end

    def assert_usage_increment(name, times: 1)
      old_method = Solid::Usage.method(:increment)
      calls = 0
      begin
        Solid::Usage.singleton_class.send(:remove_method, :increment)
        Solid::Usage.define_singleton_method(:increment) do |got_name|
          calls += 1 if got_name == name
          old_method.call(got_name)
        end
        yield
      ensure
        Solid::Usage.singleton_class.send(:remove_method, :increment)
        Solid::Usage.define_singleton_method(:increment, old_method)
      end
      assert_equal(times, calls, "Number of calls to Usage.increment with #{name.inspect}")
    end

    def with_global_filter(*globals)
      original_global_filters = Solid::StrainerFactory.instance_variable_get(:@global_filters)
      Solid::StrainerFactory.instance_variable_set(:@global_filters, [])
      globals.each do |global|
        Solid::StrainerFactory.add_global_filter(global)
      end

      Solid::StrainerFactory.send(:strainer_class_cache).clear

      globals.each do |global|
        Solid::Template.register_filter(global)
      end
      yield
    ensure
      Solid::StrainerFactory.send(:strainer_class_cache).clear
      Solid::StrainerFactory.instance_variable_set(:@global_filters, original_global_filters)
    end

    def with_error_mode(mode)
      old_mode = Solid::Template.error_mode
      Solid::Template.error_mode = mode
      yield
    ensure
      Solid::Template.error_mode = old_mode
    end

    def with_custom_tag(tag_name, tag_class)
      old_tag = Solid::Template.tags[tag_name]
      begin
        Solid::Template.register_tag(tag_name, tag_class)
        yield
      ensure
        if old_tag
          Solid::Template.tags[tag_name] = old_tag
        else
          Solid::Template.tags.delete(tag_name)
        end
      end
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

class StubFileSystem
  attr_reader :file_read_count

  def initialize(values)
    @file_read_count = 0
    @values          = values
  end

  def read_template_file(template_path)
    @file_read_count += 1
    @values.fetch(template_path)
  end
end

class StubTemplateFactory
  attr_reader :count

  def initialize
    @count = 0
  end

  def for(_template_name)
    @count += 1
    Solid::Template.new
  end
end
