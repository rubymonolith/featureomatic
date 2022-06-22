require "featureomatic/version"
require "featureomatic/engine"

module Featureomatic
  class BasePlan

    def feature
      Feature.new
    end

    private
    def hard_limit(**kwargs)
      HardLimit.new(**kwargs)
    end

    def soft_limit(**kwargs)
      SoftLimit.new(**kwargs)
    end

    def enabled(value = true)
      BooleanLimit.new enabled: value
    end

    def disabled(value = true)
      enabled !value
    end

    class Upgrade
      def initialize(plan, feature)
        @plan = plan
        @feature = feature
      end

      def upgradable?
        plan.next.present?
      end
    end

    class Downgrade
      def initialize(plan, feature)
        @plan = plan
        @feature = feature
      end

      def downgradable?
        plan.previous.present?
      end
    end

    class Feature
      def initialize(plan)
        @plan = plan
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

    class Limit
      def enabled?
        false
      end

      def disabled?
        not enabled?
      end
    end

    class HardLimit < Limit
      attr_accessor :quantity, :maximum

      def initialize(quantity: , maximum: )
      end

      def exceeded?
        quantity > maximum if quantity and maximum
      end

      def enabled?
        not exceeded?
      end
    end

    class SoftLimit < Limit
      attr_accessor :quantity, :soft_limit, :hard_limit

      def initialize(quantity: , soft_limit: , hard_limit: )
        @quantity = quantity
        @soft_limit = soft_limit
        @hard_limit = hard_limit
      end

      def exceeded?
        quantity > hard_limit
      end

      def enabled?
        not exceeded?
      end
    end

    class BooleanLimit < Limit
      def initialize(enabled:)
        @enabled = enabled
      end

      def enabled?
        @enabled
      end
    end
  end
end
