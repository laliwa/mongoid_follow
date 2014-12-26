class Follow
  include Mongoid::Document
  include Mongoid::Timestamps	
  belongs_to :follower, :polymorphic => true
  belongs_to :followee, :polymorphic => true
end
