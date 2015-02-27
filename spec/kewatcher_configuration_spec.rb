require 'rspec'
require 'pry'
require './lib/resque-sliders/kewatcher'

describe Resque::Plugins::ResqueSliders::KEWatcher::Configuration do
  let(:configuration) {
    Resque::Plugins::ResqueSliders::KEWatcher::Configuration
  }

  it 'exists' do
    expect(Resque::Plugins::ResqueSliders::KEWatcher::Configuration).not_to be_nil
  end

  context "KEWatcher configuration" do
    it 'has a default configuration' do
      config = configuration.new
      expect(config.to_hash).to be_a(Hash)
    end

    it 'has default values' do
      config = configuration.new
      expect(config.to_hash[:verbosity]).to eq(0)
    end

    it 'overrides configuration with provided options' do
      config = configuration.new({verbosity: 10})
      expect(config.to_hash[:verbosity]).to eq(10)
    end

    it 'sets file paths from options' do
      allow(File).to receive(:exists?).and_return(true)
      config = configuration.new({poolfile: 'test/me.yml'})
      expect(config.to_hash[:poolfile]).to eq(File.expand_path('test/me.yml'))
    end
  end
end
