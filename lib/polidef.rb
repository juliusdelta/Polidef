# frozen_string_literal: true

module Polidef
  class Error < StandardError; end
end

require_relative "polidef/version"
require_relative "polidef/policy"
require_relative "polidef/policies"
