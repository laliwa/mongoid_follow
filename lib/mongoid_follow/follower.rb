module Mongoid
  module Follower
    extend ActiveSupport::Concern

    included do |base|
      base.field    :ffeec, :type => Integer, :default => 0
      base.has_many :followees, :class_name => 'Follow', :as => :follower, :dependent => :destroy
    end

    # follow a model
    #
    # Example:
    # => @bonnie.follow(@clyde)
    def follow(model)
      if self.id != model.id && !self.follows?(model)

        model.before_followed_by(self) if model.respond_to?('before_followed_by')
        self.before_follow(model) if self.respond_to?('before_follow')
        model.followers.create!(:follower_type => self.class.name, :follower_id => self.id)
        model.inc(:fferc, 1)
        model.after_followed_by(self) if model.respond_to?('after_followed_by')
        self.inc(:ffeec, 1)
        self.after_follow(model) if self.respond_to?('after_follow')

      else
        return false
      end
    end

    # unfollow a model
    #
    # Example:
    # => @bonnie.unfollow(@clyde)
    def unfollow(model)
      if self.id != model.id && self.follows?(model)

        model.before_unfollowed_by(self) if model.respond_to?('before_unfollowed_by')
        self.before_unfollow(model) if self.respond_to?('before_unfollow')
        model.followers.where(:follower_type => self.class.name, :follower_id => self.id).destroy
        model.inc(:fferc, -1)
        model.after_unfollowed_by(self) if model.respond_to?('after_unfollowed_by')
        self.inc(:ffeec, -1)
        self.after_unfollow(model) if self.respond_to?('after_unfollow')

      else
        return false
      end
    end

    # know if self is already following model
    #
    # Example:
    # => @bonnie.follows?(@clyde)
    # => true
    def follows?(model)
      0 < self.followees.find(:all, conditions: {followee_id: model.id}).limit(1).count
    end

    # get followees count
    # Note: this is a cache counter
    #
    # Example:
    # => @bonnie.followees_count
    # => 1
    def followees_count
      self.ffeec
    end

    # get followees count by model
    #
    # Example:
    # => @bonnie.followees_count_by_model(User)
    # => 1
    def followees_count_by_model(model)
      self.followees.where(:followee_type => model.to_s).count
    end

    # view all selfs followees
    #
    # Example:
    # => @alec.all_followees
    # => [@bonnie]
    def all_followees
      get_followees_of(self)
    end

    # view all selfs followees by model
    #
    # Example:
    # => @clyde.all_followees_by_model
    # => [@bonnie]
    def all_followees_by_model(model)
      get_followees_of(self, model)
    end

    private
    def get_followees_of(me, model = nil)
      followees = !model ? me.followees : me.followees.where(:followee_type => model.to_s)

      followees.collect do |f|
        f.followee
      end
    end

    def method_missing(missing_method, *args, &block)
      if missing_method.to_s =~ /^(.+)_followees_count$/
        followees_count_by_model($1.camelize)
      elsif missing_method.to_s =~ /^all_(.+)_followees$/
        all_followees_by_model($1.camelize)
      else
        super
      end
    end
  end
end
