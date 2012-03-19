class Follow
  include Mongoid::Document

  belongs_to :follower, :polymorphic => true
  belongs_to :followee, :polymorphic => true
end
