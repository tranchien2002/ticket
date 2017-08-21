class User < ActiveRecord::Base
  INVALID_NAME_CHARACTERS = /\A('|")|('|")\z/

  include RailsSettings::Extend

  TEMP_EMAIL_PREFIX = 'change@me'

  attr_accessor :opt_in

  validates :name, presence: true, format: { with: /\A\D+\z/ }
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create }, allow_blank: true

  include PgSearch
  pg_search_scope :user_search,
                  against: [:name, :login, :email, :company, :account_number, :phone, :phone2]

  has_and_belongs_to_many :roles
  has_many :topics
  has_many :posts
  has_many :votes
  has_many :docs
  # is_gravtastic

  # after_invitation_accepted :set_role_on_invitation_accept
  after_create :enable_notifications_for_admin
  before_save :reject_invalid_characters_from_name
  acts_as_taggable_on :teams

  ROLES = %w[admin agent editor user]

  # TODO: Will want to refactor this using .or when upgrading to Rails 5
  scope :admins, -> { where('admin = ? OR role = ?',true,'admin').order('name asc') }
  scope :agents, -> { where('admin = ? OR role = ? OR role = ?',true,'admin','agent').order('name asc') }
  scope :team, -> { where('admin = ? OR role = ? OR role = ? OR role = ?',true,'admin','agent','editor').order('name asc') }
  scope :active, -> { where('active = ?', true)}
  scope :by_role, -> (role) { where('role = ?', role) }

  def set_role_on_invitation_accept
    if self.role.nil?
      self.role = "agent"
    end
    self.active = true
    self.save
  end

  def enable_notifications_for_admin
    if self.role == "admin"
      self.notify_on_private = true
      self.notify_on_public = true
      self.notify_on_reply = true
    end
  end

  def self.notifiable_on_public
    User.agents.where(notify_on_public: true).reorder('id asc')
  end

  def self.notifiable_on_private
    User.agents.where(notify_on_private: true).reorder('id asc')
  end

  def self.notifiable_on_reply
    User.agents.where(notify_on_reply: true).reorder('id asc')
  end

  def active_assigned_count
    Topic.where(assigned_user_id: self.id).active.count
  end

  def is_restricted?
    self.team_list.count > 0 && !self.is_admin?
  end

  def self.create_password
    ApplicationHelper.friendly_token
  end

  def thumbnail_url
    self.thumbnail.blank? ? self.gravatar_url(size: 60) : self.thumbnail
  end

  def image_url
    self.medium_image || self.gravatar_url(size: 60)
  end

  def self.find_for_oauth(auth)
    user = find_by(email: auth.info.email)
    if user
      user.tap do |u|
        u.provider = auth.provider
        u.uid = auth.uid
        u.save!
      end
    else
      # NOTE: this stopped working with the test, not sure why. Replaced with
      # find_or_create_by and everything passed again:

      # where(provider: auth.provider, uid: auth.uid).first_or_create do |u|
      # it turns out that is not part of the public rails api, despite being
      # used in the wild. https://github.com/rails/rails/issues/23495

      find_or_create_by(provider: auth.provider, uid: auth.uid) do |u|
        u.email = auth.info.email.present? ? auth.info.email : u.temp_email(auth)
        u.name = auth.info.name.present? ? auth.info.name : "Name Missing"
        u.role = 'user'
        u.thumbnail = auth.info.image
        u.password = ApplicationHelper.friendly_token[0,20]
      end
    end
  end

  def temp_email(auth)
    "#{TEMP_EMAIL_PREFIX}-#{auth.uid}-#{auth.provider}.com"
  end

  def to_param
    "#{id}-#{name.parameterize}"
  end

  def signup_guest
    enc = ApplicationHelper.generate_token(User, :reset_password_token)
    self.reset_password_token = enc
    self.reset_password_sent_at = Time.now.utc

    self.login = self.email.split("@")[0]
    self.password = User.create_password
    self.save
  end


  # NOTE: Could have user AR Enumerables for this, but the field was already in the database as a string
  # and changing it could be painful for upgrading installed users. These are three
  # Utility methods for checking the role of an admin:

  def is_admin?
    self.role == 'admin'
  end

  def is_agent?
    %w( agent admin ).include?(self.role)
  end

  def is_editor?
    %w( editor agent admin ).include?(self.role)
  end

  def self.bulk_invite(emails, message, role)
    #below line merge comma saperated emails as well as emails saperated by new lines
    emails = emails.each_line.reject { |l| l =~ /^\s+$/ }.map { |l| l.strip.split(', ') }.flatten

    emails.each do |email|
      is_valid_email = email.match('^.+@.+$')
      if is_valid_email
        User.invite!({email: email}) do |user|
          user.invitation_message = message
          user.name = "Invited User: #{email}"
          user.role = role
          user.active = false
        end
      end
    end
  end

  #when using deliver_later attr_accessor :message becomes nil on mailer view
  # def send_devise_notification(notification, *args)
  #   devise_mailer.send(notification, self, *args).deliver_later
  # end

  # check if user is active or not
  def active_for_authentication?
    super && self.active?
  end

  # message to the user that is not allowed to login
  def inactive_message
    "You are not allowed to log in!"
  end

  def self.register email, user_name
    # this method is very similar to email_processor#create_user
    # actually it was copyied from there.
    # it should create an issue to properly refactor and
    # preserve the DRY principle.

    # create user
    usr = User.new

    token, enc = ApplicationHelper.generate_token(User, :reset_password_token)
    usr.reset_password_token = enc
    usr.reset_password_sent_at = Time.now.utc

    usr.email = email
    usr.name = user_name
    usr.password = User.create_password
    if usr.save
      UserMailer.new_user(usr.id, token).deliver_later
    end

    return usr
  end

  private

  def reject_invalid_characters_from_name
    self.name = name.gsub(INVALID_NAME_CHARACTERS, '') if !!name.match(INVALID_NAME_CHARACTERS)
  end

end
