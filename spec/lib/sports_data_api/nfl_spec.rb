require 'spec_helper'

describe SportsDataApi::Nfl, vcr: {
    cassette_name: 'sports_data_api_nfl',
    record: :new_episodes,
    match_requests_on: [:uri]
} do

  context 'invalid API key' do
    before(:each) do
      SportsDataApi.key = 'invalid_key'
      SportsDataApi.access_level = 't'
    end
    describe '.schedule' do
      it { expect { subject.schedule(2013, :REG) }.to raise_error(SportsDataApi::Exception) }
    end
    describe '.boxscore' do
      it { expect { subject.boxscore(2012, :REG, 9, 'IND', 'MIA') }.to raise_error(SportsDataApi::Exception) }
    end
  end

  context 'no response from the api' do
    before(:each) { stub_request(:any, /api\.sportsdatallc\.org.*/).to_timeout }
    describe '.schedule' do
      it { expect { subject.schedule(2013, :REG) }.to raise_error(SportsDataApi::Exception) }
    end
    describe '.boxscore' do
      it { expect { subject.boxscore(2012, :REG, 9, 'IND', 'MIA') }.to raise_error(SportsDataApi::Exception) }
    end
  end

  context 'create valid URLs' do
    let(:schedule_url) { 'http://api.sportsdatallc.org/nfl-t1/2012/REG/schedule.xml' }
    let(:boxscore_url) { 'http://api.sportsdatallc.org/nfl-t1/2012/REG/9/MIA/IND/boxscore.xml' }
    before(:each) do
      SportsDataApi.key = 'invalid_key'
      SportsDataApi.access_level = 't'
      @schedule_xml = RestClient.get("#{schedule_url}?api_key=#{api_key}")
      @boxscore_xml = RestClient.get("#{boxscore_url}?api_key=#{api_key}")
    end
    describe '.schedule' do
      it 'creates a valid Sports Data LLC url' do
        params = { params: { api_key: SportsDataApi.key } }
        RestClient.should_receive(:get).with(schedule_url, params).and_return(@schedule_xml)
        subject.schedule(2012, :REG)
      end
    end

    describe '.boxscore' do
      it 'creates a valid Sports Data LLC url' do
        params = { params: { api_key: SportsDataApi.key } }
        RestClient.should_receive(:get).with(boxscore_url, params).and_return(@boxscore_xml)
        subject.boxscore(2012, :REG, 9, 'IND', 'MIA')
      end
    end
  end

  describe "team based class methods" do
    before do
      SportsDataApi.key = api_key
      SportsDataApi.access_level = 't'
    end

    context "#team_season_stats" do
      it "returns the team id" do
        expect(subject.team_season_stats("BUF", 2013, "REG").id).to eq "BUF"
      end

      it "returns an array of stats" do
        expect(subject.team_season_stats("BUF", 2013, "REG").stats.kind_of?(Array)).to be true
      end
    end

    context "#team_roster" do
      it "returns an array" do
        expect(subject.team_roster('MIA').players.kind_of?(Array)).to be true
      end
    end
  end

  describe "player based class methods" do
    before do
      SportsDataApi.key = api_key
      SportsDataApi.access_level = 't'
    end

    context "#player_season_stats" do
      it "responds to players" do
        expect(subject.player_season_stats("BUF", 2013, "REG")).to respond_to :players
      end

      it "returns an array" do
        expect(subject.player_season_stats("BUF", 2013, "REG").players.kind_of?(Array)).to be true
      end
    end
  end
end
