namespace :data do
  task create: :environment do

    # technicians and cashiers in chungcu's database have id from 1 to 38
    User.bulk_insert do |worker|
      (1..38).each do |uid|
        worker.add(name: Faker::Name.name, uid: uid)
      end
    end

    Topic.bulk_insert do |worker|
      User.all[0..(User.count-6)].each do |user|
        worker.add(name: Faker::GameOfThrones.quote, user_id: user.id)
      end
    end
  end
end
