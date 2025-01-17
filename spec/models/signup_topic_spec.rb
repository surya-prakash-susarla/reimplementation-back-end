require 'rails_helper'

RSpec.describe SignupTopic, type: :model do
  let (:topic) { create(:signup_topic) }
  let (:team) { create(:team) }
  let (:signed_up_team) { create(:signed_up_team, team: team, signup_topic:topic) }

  describe "Test Associations" do
    it "belongs to the assignment" do
      should belong_to(:assignment)
    end

    it "has many signed up teams" do
      should have_many(:signed_up_teams)
    end
  end

  describe "Test Functionality" do
    it "Returns the team participants of signed_up_team for topic" do
      expect(topic.get_team_participants(signed_up_team.id)).to eq(true)
    end

    it "Updates the attributes of the sign up topic" do
      expect(topic.update_topic(2, "desc2", "category2")).to eq(true)
    end

    it "Returns number of available slots for teams to sign up for the topic" do
      expect(topic.num_available_slots).to eq(topic.max_choosers - topic.signed_up_teams.count)
    end

    describe "Returns number of filled slots for the topic" do
      it "Returns 0 if no teams signed up for the topic" do
        expect(topic.count_filled_slots).to eq(0)
      end

      it "Returns 1 if there is one signed up team for the topic" do
        expect(SignedUpTeam.create(topic["id"], team["id"])).to be_valid
        expect(topic.count_filled_slots).to eq(1)
      end
    end

    it "Method used to release team from the topic" do
      expect(topic.promote_waitlisted_team).to eq([])
    end

    it "Method used to validate if the topic is assigned to signed up team" do
      expect(topic.is_assigned_to_team(signed_up_team.id)).to eq(true)
    end

    it "Returns whether the topic is available" do
      expect(topic.is_available?).to eq(true)
    end

    it "Returns all the signed up teams for the topic" do
      expect(SignedUpTeam.create(topic["id"], team["id"])).to be_valid
      expect(topic.all_assigned_teams.collect { |signed_team| signed_team.team_id }).to eq([team.id])
    end

    it "Returns JSON object that holds the signup topic data" do
      expect(SignedUpTeam.create(topic["id"], team["id"])).to be_valid
      expected_json = SignupTopicSerializer.new(topic).serializable_hash.to_json
      expect(topic.as_json).to eq(expected_json)
    end

    it "Destroy the topic and delegates any required changes" do
      expect(topic).to be_valid
      expect { topic.destroy_topic }.to change(SignupTopic, :count).by(-1)
    end

  end
end
