namespace :ticket do
  desc "TODO"
  task update_deadline: :environment do
    Topic.where("not current_status = 'out of date' and topics.deadline is not null and topics.deadline < NOW()")
        .update_all(current_status: Settings.ticket_status.out_of_date)
  end

end
