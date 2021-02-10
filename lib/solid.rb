# frozen_string_literal: true

# Copyright (c) 2005 Tobias Luetke
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module Solid
  FilterSeparator             = /\|/
  ArgumentSeparator           = ','
  FilterArgumentSeparator     = ':'
  VariableAttributeSeparator  = '.'
  WhitespaceControl           = '-'
  TagStart                    = /\{\%/
  TagEnd                      = /\%\}/
  VariableSignature           = /\(?[\w\-\.\[\]]\)?/
  VariableSegment             = /[\w\-]/
  VariableStart               = /\{\{/
  VariableEnd                 = /\}\}/
  VariableIncompleteEnd       = /\}\}?/
  QuotedString                = /"[^"]*"|'[^']*'/
  QuotedFragment              = /#{QuotedString}|(?:[^\s,\|'"]|#{QuotedString})+/o
  TagAttributes               = /(\w+)\s*\:\s*(#{QuotedFragment})/o
  AnyStartingTag              = /#{TagStart}|#{VariableStart}/o
  PartialTemplateParser       = /#{TagStart}.*?#{TagEnd}|#{VariableStart}.*?#{VariableIncompleteEnd}/om
  TemplateParser              = /(#{PartialTemplateParser}|#{AnyStartingTag})/om
  VariableParser              = /\[[^\]]+\]|#{VariableSegment}+\??/o

  RAISE_EXCEPTION_LAMBDA = ->(_e) { raise }

  singleton_class.send(:attr_accessor, :cache_classes)
  self.cache_classes = true
end

require "solid/version"
require 'solid/parse_tree_visitor'
require 'solid/lexer'
require 'solid/parser'
require 'solid/i18n'
require 'solid/drop'
require 'solid/tablerowloop_drop'
require 'solid/forloop_drop'
require 'solid/extensions'
require 'solid/errors'
require 'solid/interrupts'
require 'solid/strainer_factory'
require 'solid/strainer_template'
require 'solid/expression'
require 'solid/context'
require 'solid/parser_switching'
require 'solid/tag'
require 'solid/tag/disabler'
require 'solid/tag/disableable'
require 'solid/block'
require 'solid/block_body'
require 'solid/document'
require 'solid/variable'
require 'solid/variable_lookup'
require 'solid/range_lookup'
require 'solid/file_system'
require 'solid/resource_limits'
require 'solid/template'
require 'solid/standardfilters'
require 'solid/condition'
require 'solid/utils'
require 'solid/tokenizer'
require 'solid/parse_context'
require 'solid/partial_cache'
require 'solid/usage'
require 'solid/register'
require 'solid/static_registers'
require 'solid/template_factory'

# Load all the tags of the standard library
#
Dir["#{__dir__}/solid/tags/*.rb"].each { |f| require f }
