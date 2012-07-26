require 'test_interface/constraint'

module TestInterface

  class Enforcer

    class MethodContract
      UNCONSTRAINED_METHOD = {:args => Constraint::UNCONSTRAINED_TYPE, :returns => Constraint::UNCONSTRAINED_TYPE}

      def initialize(specification)
        specification = UNCONSTRAINED_METHOD if specification == :allowed
        set_args_constraint(specification[:args])
        set_return_value_constraint(specification[:returns])
      end

      def valid_args?(args)
        @args_constraint.allows?(args)
      end

      def valid_return_value?(return_value)
        @return_value_constraint.allows?(return_value)
      end

      private

      def set_args_constraint(specification)
        @args_constraint = ArgsConstraint.new(specification)
      end

      def set_return_value_constraint(specification)
        @return_value_constraint = ReturnValueConstraint.new(specification)
      end

    end

  end

end
