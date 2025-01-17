require 'rails_helper'

RSpec.describe SignedUpTeam, type: :model do
  let (:topic) {create(:signup_topic)}
  let (:team) {create(:team)}
  let (:signed_up_team) {create(:signed_up_team, team:team, signup_topic:topic)}  
  

  describe "Test Associations" do
    subject { create(:signed_up_team, team:team, signup_topic:topic) }

    it "belongs to the sign up topic" do
      should belong_to(:signup_topic)
    end

    it "belongs to the signed up team" do
      should belong_to(:team)
    end
  end

  describe "Tests the functionality of the methods of the class" do
    it "Returns the team participants for a signed_up_topic" do
      expect(signed_up_team.team_participants()).to eq(true)
    end

    it "Signs up a team for the topic if the topic is available and checks if the record exists in the database" do
      expect(SignedUpTeam.all.count). to eq(0)
      expect(SignedUpTeam.create( topic["id"], team["id"]))
      expect(SignedUpTeam.all.count). to eq(1)      
    end

    it "Waitlists a team for the topic if the topic is not available and checks if the record exists in the database" do
      expect(SignedUpTeam.all.count). to eq(0)
      expect(SignedUpTeam.create(topic["id"], team["id"]))
      expect(SignedUpTeam.all.count). to eq(1)
      expect(SignupTopic.count_waitlisted_teams(topic["id"])).to eq(0)
      
      team2 = Team.create
      expect(SignedUpTeam.create(topic["id"], team2["id"]))
      expect(SignedUpTeam.all.count). to eq(2)
      expect(SignupTopic.count_waitlisted_teams(topic["id"])).to eq(1)
    end

    it 'Creates a signed up team if the topic is available and checks the count increment in the database' do
      expect{SignedUpTeam.create(topic["id"], team["id"])}.to change{SignedUpTeam.count}.by(1)
    end

    it "Deletes the signed_up_team for the topic assigned and checks if the record exists in the database" do
      SignedUpTeam.find(signed_up_team['id']).destroy
      expect(SignedUpTeam.exists?(signed_up_team['id'])).to be false
    end

    it 'Deletes the signed up team for a topic and delegates any required changes and checks the count decrement in the database' do
      expect(signed_up_team).to be_valid
      expect { SignedUpTeam.find(signed_up_team["id"]).destroy }.to change(SignedUpTeam, :count).by(-1)
    end
    
  end
end
