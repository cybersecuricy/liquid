# frozen_string_literal: true

$LOAD_PATH.unshift(__dir__ + '/../../lib')
require_relative '../../lib/solid'

require_relative 'comment_form'
require_relative 'paginate'
require_relative 'json_filter'
require_relative 'money_filter'
require_relative 'shop_filter'
require_relative 'tag_filter'
require_relative 'weight_filter'

Solid::Template.register_tag('paginate', Paginate)
Solid::Template.register_tag('form', CommentForm)

Solid::Template.register_filter(JsonFilter)
Solid::Template.register_filter(MoneyFilter)
Solid::Template.register_filter(WeightFilter)
Solid::Template.register_filter(ShopFilter)
Solid::Template.register_filter(TagFilter)
