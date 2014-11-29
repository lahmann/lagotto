# encoding: UTF-8
# Load admin user
admin_user = User.where(authentication_token: ENV["API_KEY"]).first_or_create(
                        name: ENV["ADMIN_EMAIL"],
                        username: ENV["ADMIN_EMAIL"],
                        email: ENV["ADMIN_EMAIL"])
