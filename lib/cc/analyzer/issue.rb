module CC
  module Analyzer
    class Issue
      DEFAULT_SEVERITY = "minor".freeze
      SPEC_ISSUE_ATTRIBUTES = %w[
        categories
        check_name
        content
        description
        location
        other_locations
        remediation_points
        severity
        type
      ]

      def initialize(output)
        @output = output
      end

      def as_json(*)
        parsed_output.reverse_merge!(
          "fingerprint" => fingerprint,
          "severity" => severity,
        )
      end

      def fingerprint(expect_valid_locations: true)
        parsed_output.fetch("fingerprint") { default_fingerprint(expect_valid_locations: expect_valid_locations) }
      end

      # Allow access to hash keys as methods
      SPEC_ISSUE_ATTRIBUTES.each do |key|
        define_method(key) do
          parsed_output[key]
        end
      end

      def path
        parsed_output.fetch("location", {}).fetch("path", "")
      end

      private

      attr_reader :output

      def default_fingerprint(expect_valid_locations: true)
        SourceFingerprint.new(self).compute
      rescue SourceExtractor::InvalidLocation
        raise if expect_valid_locations
      end

      def severity
        parsed_output.fetch("severity", DEFAULT_SEVERITY)
      end

      def parsed_output
        @parsed_output ||= JSON.parse(output)
      end
    end
  end
end
