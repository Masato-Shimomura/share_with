# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Admin.find_or_create_by!(email: "shimo7777777777@gmail.com") do |admin|
  admin.password = "shimo789"
  admin.password_confirmation = "shimo789"
  admin.confirmed_at = Time.current
end
