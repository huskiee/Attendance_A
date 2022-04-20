# coding: utf-8

User.create!(name: "Sample User",
             email: "sample@email.com",
             password: "password",
             password_confirmation: "password",
             admin: true)

60.times do |n|
  name  = Faker::Name.name
  email = "sample-#{n+1}@email.com"
  password = "password"
  User.create!(name: name,
               email: email,
               password: password,
               password_confirmation: password)
end
               
Base.create!(base_number: "0",
             base_name: "拠点0",
             base_type: "出勤") 

5.times do |n|
  base_number = "#{n+1}"
  base_name  = "拠点#{n+1}"
  base_type = "退勤"
  Base.create!(base_number: base_number,
               base_name: base_name,
               base_type: base_type)
end