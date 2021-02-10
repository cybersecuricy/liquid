# frozen_string_literal: true

require 'test_helper'

class PartialCacheUnitTest < Minitest::Test
  def test_uses_the_file_system_register_if_present
    context = Solid::Context.build(
      registers: {
        file_system: StubFileSystem.new('my_partial' => 'my partial body'),
      }
    )

    partial = Solid::PartialCache.load(
      'my_partial',
      context: context,
      parse_context: Solid::ParseContext.new
    )

    assert_equal('my partial body', partial.render)
  end

  def test_reads_from_the_file_system_only_once_per_file
    file_system = StubFileSystem.new('my_partial' => 'some partial body')
    context     = Solid::Context.build(
      registers: { file_system: file_system }
    )

    2.times do
      Solid::PartialCache.load(
        'my_partial',
        context: context,
        parse_context: Solid::ParseContext.new
      )
    end

    assert_equal(1, file_system.file_read_count)
  end

  def test_cache_state_is_stored_per_context
    parse_context      = Solid::ParseContext.new
    shared_file_system = StubFileSystem.new(
      'my_partial' => 'my shared value'
    )
    context_one = Solid::Context.build(
      registers: {
        file_system: shared_file_system,
      }
    )
    context_two = Solid::Context.build(
      registers: {
        file_system: shared_file_system,
      }
    )

    2.times do
      Solid::PartialCache.load(
        'my_partial',
        context: context_one,
        parse_context: parse_context
      )
    end

    Solid::PartialCache.load(
      'my_partial',
      context: context_two,
      parse_context: parse_context
    )

    assert_equal(2, shared_file_system.file_read_count)
  end

  def test_cache_is_not_broken_when_a_different_parse_context_is_used
    file_system = StubFileSystem.new('my_partial' => 'some partial body')
    context     = Solid::Context.build(
      registers: { file_system: file_system }
    )

    Solid::PartialCache.load(
      'my_partial',
      context: context,
      parse_context: Solid::ParseContext.new(my_key: 'value one')
    )
    Solid::PartialCache.load(
      'my_partial',
      context: context,
      parse_context: Solid::ParseContext.new(my_key: 'value two')
    )

    # Technically what we care about is that the file was parsed twice,
    # but measuring file reads is an OK proxy for this.
    assert_equal(1, file_system.file_read_count)
  end

  def test_uses_default_template_factory_when_no_template_factory_found_in_register
    context = Solid::Context.build(
      registers: {
        file_system: StubFileSystem.new('my_partial' => 'my partial body'),
      }
    )

    partial = Solid::PartialCache.load(
      'my_partial',
      context: context,
      parse_context: Solid::ParseContext.new
    )

    assert_equal('my partial body', partial.render)
  end

  def test_uses_template_factory_register_if_present
    template_factory = StubTemplateFactory.new
    context = Solid::Context.build(
      registers: {
        file_system: StubFileSystem.new('my_partial' => 'my partial body'),
        template_factory: template_factory,
      }
    )

    partial = Solid::PartialCache.load(
      'my_partial',
      context: context,
      parse_context: Solid::ParseContext.new
    )

    assert_equal('my partial body', partial.render)
    assert_equal(1, template_factory.count)
  end
end
