require_relative '../spec_helper'

describe Suby::Manager do

  it 'should create subtitle type class' do
    cls = Suby::SubtitlePromise.create { 10 }
    inst = cls.new
    expect(inst.calculate_rank).to eq 10
  end

end