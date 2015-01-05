class Post < ActiveRecord::Base
  include ::TheCommentsBase::Commentable
  belongs_to :user
end
