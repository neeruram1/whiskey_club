require "rails_helper"

RSpec.describe MeetingNotifier do
  describe ".scheduled" do
    it "emails every member except the excepted one" do
      scheduler = create(:user)
      member1 = create(:user)
      _member2 = create(:user)
      meeting = create(:meeting, bottle_bringer: member1) # no extra user created

      expect do
        described_class.scheduled(meeting, except: scheduler)
      end.to have_enqueued_mail(MeetingMailer, :scheduled).twice
    end

    it "emails everyone when no one is excepted" do
      create(:user)
      member = create(:user)
      meeting = create(:meeting, bottle_bringer: member)

      expect do
        described_class.scheduled(meeting)
      end.to have_enqueued_mail(MeetingMailer, :scheduled).exactly(2).times
    end
  end
end
