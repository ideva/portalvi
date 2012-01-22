require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  set_table_name 'users'
  belongs_to :f_user_level, :foreign_key => "iduser_level"

  validates :login, :presence   => true,
                    :uniqueness => true,
                    :length     => { :within => 3..40 },
                    :format     => { :with => Authentication.login_regex, :message => Authentication.bad_login_message }

  validates :name,  :format     => { :with => Authentication.name_regex, :message => Authentication.bad_name_message },
                    :length     => { :maximum => 100 },
                    :allow_nil  => true

  validates :email, :presence   => true,
                    :uniqueness => true,
                    :format     => { :with => Authentication.email_regex, :message => Authentication.bad_email_message },
                    :length     => { :within => 6..100 }

  

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :name, :password, :password_confirmation



  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find_by_login(login.downcase) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  # ------------ added by Riza -----------------
  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end

  def is_active?
    if current_user.state == "active"
      true
    else
      false
    end
  end

  #reset methods
  def self.create_reset_code(user)
    @reset = true
    user.reset_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    user.save
  end

  def self.recently_reset?
    @reset
  end

  def delete_reset_code
    self.attributes = {:reset_code => nil}
    save(false)
  end

  #------------------- FB ----------------------

    #find the user in the database, first by the facebook user id and if that fails through the email hash
    def self.find_by_fb_user(fb_user)
      #User.find_by_fb_user_id(fb_user.id) || User.find_by_email_hash(fb_user.email)
      User.find_by_fb_user_id(fb_user.id)
    end

    #Take the data returned from facebook and create a new user from it.
    #We don't get the email from Facebook and because a facebooker can only login through Connect we just generate a unique login name for them.
    #If you were using username to display to people you might want to get them to select one after registering through Facebook Connect
    def self.create_from_fb_connect(fb_user)
      new_facebooker = User.new(:name => fb_user.name, :login => "facebooker_#{fb_user.uid}", :password => "", :email => "")
      new_facebooker.fb_user_id = fb_user.uid.to_i
      #We need to save without validations
      new_facebooker.save(false)
      new_facebooker.register_user_to_fb

    end

    def self.create_from_fb_connect(fb_user, user_email)
      new_user = false
      user = User.find_by_email(user_email)
      if user.nil?
        new_user = true
        user = User.new
        user.full_name = fb_user.name
        user.email = user_email
        # do not need to assign this value, because Authentication use State machine
        # Initial value is passive
        # Force the state become active after new user succesfully created
        #user.state = 'active'
        user.activated_at = Time.now.utc
        user.iduser_level = FUserLevel.find_by_is_default(true).id
      end
      user.fb_user_id = fb_user.id
      #We need to save without validations
      user.save(false)
      #user.register_user_to_fb

      #Create user detail if new user
      if new_user
        # Force the state become active after new user succesfully created
        user.force_activate!

        d_user_detail = DUserDetail.new
        d_user_detail.iduser = user.id
        d_user_detail.save
      end

      #register_user_to_fb
      return user
    end

    #We are going to connect this user object with a facebook id. But only ever one account.
    def link_fb_connect(fb_user_id)
      unless fb_user_id.nil?
        #check for existing account
        existing_fb_user = User.find_by_fb_user_id(fb_user_id)
        #unlink the existing account
        unless existing_fb_user.nil?
          existing_fb_user.fb_user_id = nil
          existing_fb_user.save(false)
        end
        #link the new one
        self.fb_user_id = fb_user_id
        save(false)
      end
    end

    #The Facebook registers user method is going to send the users email hash and our account id to Facebook
    #We need this so Facebook can find friends on our local application even if they have not connect through connect
    #We hen use the email hash in the database to later identify a user from Facebook with a local user
    def self.register_user_to_fb
      users = {:email => self.email, :account_id => self.id}
      Facebooker::User.register([users])
      self.email_hash = Facebooker::User.hash_email(self.email)
      save(false)
    end

    def facebook_user?
      return !fb_user_id.nil? && fb_user_id > 0
    end

     #------------------- END FB ----------------------

# ------------ Finish added by Riza -----------

  protected
    


end
