## TheComments Install

### Base case

```sh
rails generate devise user

rails g model post user_id:integer title:string content:text
```

```ruby
class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :posts
end

class Post < ActiveRecord::Base
  belongs_to :user
end
```

### Install migrations

```sh
rake the_comments_base_engine:install:migrations
rake the_comments_subscriptions_engine:install:migrations
rake the_comments_antispam_services_engine:install:migrations
```

OPEN MIGRATION FILE `xxx_the_comments_change_commentable.the_comments_base_engine.rb` AND FOLLOW AN INSTRUCTIONS!

**only Post model will be commentable in this case**

```ruby
class TheCommentsChangeCommentable < ActiveRecord::Migration
  def change
    # Uncomment this. Add fields to Commentable Models

    [:posts].each do |table_name|
      change_table table_name do |t|
        t.integer :draft_comments_count,     default: 0
        t.integer :published_comments_count, default: 0
        t.integer :deleted_comments_count,   default: 0
      end
    end
  end
end
```

```sh
rake db:migrate
```

### Change your commentable Model

Commentable model have to looks like this

```ruby
class Post < ActiveRecord::Base
  include ::TheCommentsBase::Commentable

  belongs_to :user
end
```

### Install Base Models/Controllers/Initializer

```sh
rails g the_comments_base install
```

### Install Subscriptions Models/Controllers

```sh
rails g the_comments_subscriptions install
```

### Configurate your commenting platform

`config/initializers/the_comments_base.rb`

```ruby
TheCommentsBase.configure do |config|
  config.max_reply_depth     = 5                   # comments tree depth
  config.tolerance_time      = 5                   # sec - after this delay user can post a comment
  config.default_state       = :draft              # default state for comment
  config.default_owner_state = :published          # default state for comment for Moderator
  config.empty_inputs        = [:commentBody]      # array of spam trap fields
  config.default_title       = 'Undefined title'   # default commentable_title for denormalization

  config.empty_trap_protection     = true
  config.tolerance_time_protection = true

  # config.yandex_cleanweb_api_key  = nil
  # config.akismet_api_key          = nil
  # config.akismet_blog             = nil

  config.default_mailer_email = 'the-comments@for-ruby-on-rails.domain'
  config.async_processing     = false
end
```

### Change your Application Controller

add `include ::TheCommentsBase::ViewToken` into `app/controllers/application_contoller.rb`

```ruby
class ApplicationController < ActionController::Base
  include ::TheCommentsBase::ViewToken

  protect_from_forgery with: :exception
end
```

### Add Assets

add following strings into `app/assets/javascripts/application.js.coffee`

```coffee
#= require jquery
#= require jquery_ujs

#= require jquery.data-role-block

#= require the_notification/vendors/toastr
#= require the_notification

#= require the_comments/base

$ ->
  notificator = TheCommentsDefaultNotificator
  TheComments.init(notificator)
  TheCommentsHighlight.init()
```

add following strings into `app/assets/stylesheets/application.css`

```css
/*
  *= require the_notification/vendors/toastr
  *= require the_comments/base
*/
```

### Change your Posts controller

Select `@comments` for current Post (`show` method)

`app/controllers/posts_controller.rb`

```ruby
class PostsController < ApplicationController
  def index
    @posts = Post.includes(:user).all
  end

  def show
    @post     = Post.find(params[:id])
    @comments = @post.comments.with_state([:draft, :published]).nested_set
  end
end
```

### Change your View template

```erb
<h3><%= @post.title %></h3>
<p><%= @post.content %></p>

<p>
  Comments count:
  <span data-role='comments_sum'>
    <%= @post.comments_sum %>
  </span>
</p>

<%=
  render partial: comment_template('tree'),
  locals: { commentable: @post, comments_tree: @comments }
%>
```

### Change your `route.rb`

Add routing mixins into your `config/routes.rb`

```ruby
Rails.application.routes.draw do
  devise_for :users
  root to: 'posts#index'

  resources :posts
  resources :users

  # Add following lines into your routes.en

  TheCommentsBase::Routes.mixin(self)
  TheCommentsManager::Routes.mixin(self)
  TheCommentsSubscriptions::Routes.mixin(self)
end
```





















===
## TheComments. Devise based pre-installation
===

`Gemfile`

```ruby
gem 'devise'

gem 'slim'
gem 'slim-rails'
```

```sh
rails generate devise:install
```

```txt
      create  config/initializers/devise.rb
      create  config/locales/devise.en.yml
===============================================================================

Some setup you must do manually if you haven't yet:

  1. Ensure you have defined default url options in your environments files. Here
     is an example of default_url_options appropriate for a development environment
     in config/environments/development.rb:

       config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

     In production, :host should be set to the actual host of your application.

  2. Ensure you have defined root_url to *something* in your config/routes.rb.
     For example:

       root to: "home#index"

  3. Ensure you have flash messages in app/views/layouts/application.html.erb.
     For example:

       <p class="notice"><%= notice %></p>
       <p class="alert"><%= alert %></p>

  4. If you are deploying on Heroku with Rails 3.2 only, you may want to set:

       config.assets.initialize_on_precompile = false

     On config/application.rb forcing your application to not access the DB
     or load models when precompiling your assets.

  5. You can copy Devise views (for customization) to your app by running:

       rails g devise:views
```

```sh
rails generate devise user
```

```sh
rake db:migrate
```

`config/environments/application.rb`

```
config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
```

```sh
rails g model post user_id:integer title:string content:text
```

```sh
rake db:migrate
```

```ruby
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :posts
end
```

```ruby
class Post < ActiveRecord::Base
  belongs_to :user
end
```

`/db/seeds.rb`

```ruby
10.times do |i|
  User.create!(
    email: "email_#{ i }@mail.com",
    password: "Password123",
    password_confirmation: "Password123"
  )

  puts "User #{ i } created"
end

users = User.all

100.times do |i|
  Post.create!(
    user: users.sample,
    title:   "Post title: #{ i }",
    content: "Post content: #{ i }"
  )

  puts "Post #{ i } created"
end
```

```sh
rake db:seed
```

```
User 0 created
...
User 9 created
Post 0 created
...
Post 99 created
```

`config/routes.rb`

```ruby
Rails.application.routes.draw do
  devise_for :users

  root to: 'posts#index'
  resources :posts
end
```

```sh
rails g controller posts index show
```

`app/controllers/posts_controller.rb`

```ruby
class PostsController < ApplicationController
  def index
    @posts = Post.includes(:user).all
  end

  def show
    @post = Post.find(params[:id])
  end
end
```

`app/views/posts/index.html.slim`

```slim
h1 Posts#index

- @posts.each do |post|
  p
    = link_to post.title, post
    '
    ' |
    '
    = post.user.email
```

`app/views/posts/show.html.slim`

```slim
p = link_to 'post#index', root_path

h1= @post.title
p=  @post.content
```
