require "spec_helper"

describe CC::Config do
  describe "#merge" do
    it "merges analysis paths" do
      config1 = described_class.new(analysis_paths: ["foo", "bar", "baz"])
      config2 = config1.merge(described_class.new(analysis_paths: ["foo", "sup", "bar"]))
      expect(config2.analysis_paths.count).to eq(4)
      expect(config2.analysis_paths).to include("foo")
      expect(config2.analysis_paths).to include("bar")
      expect(config2.analysis_paths).to include("baz")
      expect(config2.analysis_paths).to include("sup")
    end

    it "uses right-hand boolean for development" do
      config1 = described_class.new(development: true)
      config2 = config1.merge(described_class.new(development: false))
      expect(config2.development?).to eq(false)

      config1 = described_class.new(development: false)
      config2 = config1.merge(described_class.new(development: true))
      expect(config2.development?).to eq(true)
    end

    it "merges engines and uses right-hand config" do
      config1 = described_class.new(
        engines: [
          CC::Config::Engine.new("foo", enabled: true, channel: "foo", config: { foo: "bar" }),
        ].to_set,
      )
      config2 = config1.merge(
        described_class.new(
          engines: [
            CC::Config::Engine.new("foo", enabled: false, channel: "bar", config: { foo: "baz" }),
          ].to_set,
        ),
      )

      expect(config2.engines.count).to eq(1)

      config2.engines.to_a.first.tap do |engine|
        expect(engine.name).to eq("foo")
        expect(engine.enabled?).to eq(false)
        expect(engine.channel).to eq("bar")
        expect(engine.config).to eq(foo: "baz")
      end
    end
  end
end
