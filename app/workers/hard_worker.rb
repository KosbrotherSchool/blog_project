class HardWorker
  include Sidekiq::Worker
  sidekiq_options queue: "movie"

  def perform(name, count)
    puts 'Doing hard work'
  end
end