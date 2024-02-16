# frozen_string_literal: true

module Polidef
  class Policy
    def self.policy_dependencies(*args)
      @policy_dependencies ||= args
    end

    def self.inline_policies
      @inline_policies ||= []
    end

    def self.add_inline_policy(policy_hash)
      inline_policies << policy_hash
    end

    def initialize
      _generate_attrs
    end

    def policy
      raise NotImplementedError
    end

    def policy_chain(policies_collection)
      _policy_chain(policies_collection)
    end

    def or_policy(single_policy)
      _or_policy(single_policy)
    end

    def _policy_chain(policies_collection)
      @_policy_state = nil

      policies_collection.each do |chain_link|
        break unless @_policy_state
        @_policy_state = send(:chain_link)
      end

      itself
    end

    def _or_policy(single_policy)
      return if @_policy_state
      @_policy_state = send(:single_policy)

      itself
    end

    def _policy_try
      send(:policy)
    end

    def _generate_attrs
      self.class.policy_dependencies.each do |dep|
        instance_variable_set(:"@#{dep}", nil)
        self.class.send(:attr_accessor, dep)
      end
    end

    def _assign_attrs(dependencies)
      dependencies.each do |key, value|
        send(:"#{key}=", value)
      end
    end
  end
end
