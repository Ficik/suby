require_relative '../spec_helper'

describe Suby::Manager do

  before(:each) do
    @manager = Suby::Manager.new
  end

  it 'should initialize existing downloaders' do
    @manager.initialize_downloaders
    to_load = Suby::Manager::DOWNLOADERS.keys.length
    loaded =  @manager.instance_variable_get(:@loaded_downloaders).length
    expect(loaded).to eq to_load
  end

  it 'should find some subtitles' do
    filename = Path('Breaking.Bad.S05E09.Blood.Money.mp4')
    subtitles = @manager.find_available_subtitles(filename, :cs)
    expect(subtitles).not_to be_empty
  end

  it 'should get and encode subtitle' do
    filename = Path('Breaking.Bad.S05E09.Blood.Money.mp4')
    subtitles = @manager.get_subtitles(filename, :cs, true)
    p subtitles
    expect(subtitles).not_to be_nil
  end


end