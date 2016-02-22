require 'spec_helper'

describe Warp::Dir::Commands::Base do
  let(:base) { Warp::Dir::Commands::Base }

  before :each do
    base.installed_commands.clear
  end

  it 'should start with a blank list' do
    expect(base.installed_commands).to be_empty
  end

  it 'should add a subclass command to the list of installed commands' do
    class Warp::Dir::Commands::MyCommand < Warp::Dir::Commands::Base;
      def run
      end
    end
    expect(base.installed_commands.keys).to eql([:mycommand])
    expect(base.installed_commands.values).to eql([Warp::Dir::Commands::MyCommand])
  end

  it 'should raise exception when subclass command does not have a run method ' do
    class Warp::Dir::Commands::Random < Warp::Dir::Commands::Base;
    end
    expect {
      Warp::Dir::Commands::Base.validate!
    }.to raise_error(Warp::Dir::Errors::InvalidCommand)
  end

end
