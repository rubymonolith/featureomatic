require "featureomatic/version"
require "featureomatic/engine"

module Featureomatic
  def self.plan(&block)
    Class.new(Featureomatic::Plan, &block)
  end

  class Feature
    delegate :enabled?, :disabled?, to: :limit

    attr_reader :plan, :limit, :name

    def initialize(plan:, limit:, name:)
      @plan = plan
      @limit = limit
      @name = name
    end

    def upgrade
      Upgrade.new(plan)
    end

    def downgrade
      Downgrade.new(plan)
    end

    def limit
      Limit.new
    end
  end

  module Limit
    class Base
      def enabled?
        false
      end

      def disabled?
        not enabled?
      end
    end

    class HardLimit < Base
      attr_accessor :quantity, :maximum

      def initialize(quantity: , maximum: )
        @quantity = quantity
        @maximum = maximum
      end

      def remaining
        maximum - quantity
      end

      def exceeded?
        quantity > maximum if quantity and maximum
      end

      def enabled?
        not exceeded?
      end
    end

    class SoftLimit < HardLimit
      attr_accessor :quantity, :soft_limit, :hard_limit

      def initialize(quantity: , soft_limit: , hard_limit: )
        @quantity = quantity
        @soft_limit = soft_limit
        @hard_limit = hard_limit
      end

      def maximum
        @soft_limit
      end
    end

    # Unlimited is treated like a SoftLimit, initialized with infinity values.
    # It is recommended to set a `soft_limit` value based on the technical limitations
    # of your application unless you're running a theoritcal Turing Machine.
    #
    # See https://en.wikipedia.org/wiki/Turing_machine for details.
    class Unlimited < SoftLimit
      INFINITY = Float::INFINITY

      def initialize(quantity: nil, hard_limit: INFINITY, soft_limit: INFINITY, **kwargs)
        super(quantity: quantity, hard_limit: hard_limit, soft_limit: soft_limit, **kwargs)
      end
    end

    class BooleanLimit < Base
      def initialize(enabled:)
        @enabled = enabled
      end

      def enabled?
        @enabled
      end
    end
  end

  class Plan
    def upgrade
    end

    def downgrade
    end

    private
      def hard_limit(**)
        Limit::HardLimit.new(**)
      end

      def soft_limit(**)
        Limit::SoftLimit.new(**)
      end

      def unlimited(**)
        Limit::Unlimited.new(**)
      end

      def enabled(value = true, **)
        Limit::BooleanLimit.new enabled: value, **
      end

      def disabled(value = true)
        enabled !value
      end
  end
end
