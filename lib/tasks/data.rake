namespace :data do
  task create: :environment do

    # technicians and cashiers in chungcu's database have id from 1 to 38
    # User.bulk_insert do |worker|
    #   (1..38).each do |uid|
    #     worker.add(name: Faker::Name.name, uid: uid)
    #   end
    # end

    Topic.bulk_insert do |worker|
      60.times {
        worker.add(name: Faker::StarWars.quote, user_id: 1, building_id: 1, posts_count: 1)
      }
    end

    Post.bulk_insert do |worker|
      Topic.all.each do |topic|
        worker.add(body: Faker::GameOfThrones.quote, user_id: 1, topic_id: topic.id)
      end
    end
  end
end
