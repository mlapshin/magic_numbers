# encoding: utf-8
require 'active_support/concern'
require 'active_support/core_ext/class/attribute'
require 'rails/railtie'

module MagicNumbers
  require 'magic_numbers/version'
  require 'magic_numbers/base'
  require 'magic_numbers/railtie'
end