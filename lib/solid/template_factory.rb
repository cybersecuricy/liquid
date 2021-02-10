# frozen_string_literal: true

module Solid
  class TemplateFactory
    def for(_template_name)
      Solid::Template.new
    end
  end
end
