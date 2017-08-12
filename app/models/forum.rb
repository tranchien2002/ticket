class Forum < ActiveRecord::Base

  include SentenceCase

  has_many :topics, :dependent => :delete_all
  has_many :posts, :through => :topics

  scope :alpha, -> { order('name ASC') }

  # provided both public and private instead of one method, for code readability
  scope :isprivate, -> { where(private: true)}
  scope :ispublic, -> { where(private: false)}
  scope :for_docs, -> { where(name: 'Doc comments') }

  validates :name, presence: true, length: { maximum: 255 }
  validates :description, presence: true, length: { maximum: 1000 }

  def total_posts
    self.posts.count
  end

  def to_param
    "#{id}-#{name.parameterize}" unless name.nil?
  end

end
