namespace :attendance do
  desc "Backfill meeting attendance based on existing ratings"
  task backfill: :environment do
    puts "Starting attendance backfill..."
    
    count = 0
    Rating.includes(bottle: :meeting).find_each do |rating|
      meeting = rating.bottle.meeting
      next unless meeting
      
      # Create attendance record if it doesn't exist
      attendance = meeting.meeting_attendees.find_or_create_by(user: rating.user)
      count += 1 if attendance.previously_new_record?
    end
    
    puts "✓ Created #{count} attendance records"
    puts "Done!"
  end
end
