class Vote < ActiveRecord::Base

  belongs_to :voteable, :polymorphic => true
  belongs_to :user
  after_create :increment_points_cache

  validates :voteable_id, uniqueness: { scope: [:user_id, :voteable_type] }

  protected

  def increment_points_cache
    self.voteable_type.constantize.update_counters(self.voteable_id, points: self.points)
  end


end
