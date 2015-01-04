## TheComments. Devise based installation

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
