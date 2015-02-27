require 'rspec'
require 'pry'
require './lib/resque-sliders/kewatcher'

describe Resque::Plugins::ResqueSliders::KEWatcher do
  let(:kewatcher) {
    Resque::Plugins::ResqueSliders::KEWatcher
  }
  it 'exists' do
    expect(Resque::Plugins::ResqueSliders::KEWatcher).not_to be_nil
  end

  context "KEWatcher configuration" do
  end
end
