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
