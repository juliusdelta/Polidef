# frozen_string_literal: true

module Polidef
  module Policies
    def with_fulfilled_policy(policy, dependencies:)
      policy_class = Policy.inline_policies.find { |p| p[:name] == policy }
      policy_class ||= Object.const_get(policy.to_sym.to_s.split("_").map(&:capitalize).join("")).new
      policy_class._assign_attrs(dependencies)

      result = policy_class._policy_try

      yield if result
    end

    def policy_fulfilled?(policy, dependencies:)
      policy_class = Object.const_get(policy.to_sym.to_s.split("_").map(&:capitalize).join("")).new
      policy_class._assign_attrs(dependencies)

      policy_class._policy_try
    end

    def policy_rejected?(policy, dependencies:)
      policy_class = Object.const_get(policy.to_sym.to_s.split("_").map(&:capitalize).join("")).new
      policy_class._assign_attrs(dependencies)

      result = policy_class._policy_try

      !result
    end

    module ClassMethods
      # extract to InlinePolicy class
      def defpolicy(policy_name, dependencies, &block)
        klass = Class.new(Policy) do
          def initialize(deps)
            deps[:dependencies].each do |dep|
              instance_variable_set(:"@#{dep}", nil)
              self.class.send(:attr_accessor, dep)
            end
          end

          def policy
            yield
          end
        end

        klass.include(Policies)
        klass.add_inline_policy({name: policy_name, policy: klass.new(dependencies)})
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end
