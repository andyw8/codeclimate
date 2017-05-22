require "cc/config/default"
require "cc/config/engine"
require "cc/config/prepare"
require "cc/config/yaml"
require "cc/config/yaml/validator"

module CC
  class Config
    attr_reader \
      :analysis_paths,
      :development,
      :engines,
      :exclude_patterns,
      :prepare

    def self.load
      new.merge(Default.new).
          merge(YAML.new)
    end

    def initialize(analysis_paths: [], development: false, engines: Set.new, exclude_patterns: [], prepare: Prepare::NoPrepareNeeded.new)
      @analysis_paths = analysis_paths
      @development = development
      @engines = engines
      @exclude_patterns = exclude_patterns
      @prepare = prepare
    end

    def merge(other)
      Merge.new(self, other).config
    end

    def development?
      @development
    end

    class Merge
      class Engines
        def initialize(left, right)
          @left = left
          @right = right
        end

        # FIXME: This needs to work as follows:
        # - Return one Engine object per engine name (use #eql?)
        # - Merge their config attributes.
        # - Use right-hand attributes for everything else.
        def merge
          left.merge(right)
        end

        private

        attr_reader :left, :right
      end

      def initialize(left, right)
        @left = left
        @right = right
      end

      def config
        @config ||= Config.new(
          analysis_paths: analysis_paths,
          development: development?,
          engines: engines,
          exclude_patterns: exclude_patterns,
          prepare: prepare,
        )
      end

      private

      attr_reader :left, :right

      def analysis_paths
        left.analysis_paths | right.analysis_paths
      end

      def development?
        right.development?
      end

      def engines
        Engines.new(left.engines, right.engines).merge
      end

      def exclude_patterns
        left.exclude_patterns | right.exclude_patterns
      end

      # This could also be moved into the Prepare class itself.
      def prepare
        Prepare.new(
          fetch: left.prepare.fetch | right.prepare.fetch,
        )
      end
    end
  end
end
