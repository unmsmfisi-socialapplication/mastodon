# frozen_string_literal: true

if Rails.env.development?
  domain = ENV['LOCAL_DOMAIN'] || Rails.configuration.x.local_domain
  domain = domain.gsub(/:\d+$/, '')

  admin = Account.where(username: 'admin').first_or_initialize(username: 'admin')
  admin.save(validate: false)

  user = User.where(email: "admin@#{domain}").first_or_initialize(email: "admin@#{domain}", password: 'mastodonadmin', password_confirmation: 'mastodonadmin', confirmed_at: Time.now.utc, role: UserRole.find_by(name: 'Owner'), account: admin, agreement: true, approved: true)
  user.save!
  user.approve!


  classic_user = Account.where(username: 'user').first_or_initialize(username: 'user')
  classic_user.save(validate: false)

  user1 = User.where(email: "user@#{domain}").first_or_initialize(email: "user@#{domain}", password: 'mastodonuser', password_confirmation: 'mastodonuser', confirmed_at: Time.now.utc, account: classic_user, agreement: true, approved: true)
  user1.save!
  user1.approve!


  classic_user2 = Account.where(username: 'user2').first_or_initialize(username: 'user2')
  classic_user2.save(validate: false)

  user2 = User.where(email: "user2@#{domain}").first_or_initialize(email: "user2@#{domain}", password: 'mastodonuser', password_confirmation: 'mastodonuser', confirmed_at: Time.now.utc, account: classic_user2, agreement: true, approved: true)
  user2.save!
  user2.approve!



  mod_user_account = Account.where(username: 'moderator').first_or_initialize(username: 'moderator')
  mod_user_account.save(validate: false)

  mod_user1 = User.where(email: "moderator@#{domain}").first_or_initialize(email: "moderator@#{domain}", password: 'moderator', password_confirmation: 'moderator', confirmed_at: Time.now.utc,role: UserRole.find_by(name: 'Moderator'), account: mod_user_account, agreement: true, approved: true)
  mod_user1.save!
  mod_user1.approve!


  mod_user_account2 = Account.where(username: 'moderator2').first_or_initialize(username: 'moderator2')
  mod_user_account2.save(validate: false)

  mod_user2 = User.where(email: "moderator2@#{domain}").first_or_initialize(email: "moderator2@#{domain}", password: 'moderator', password_confirmation: 'moderator', confirmed_at: Time.now.utc,role: UserRole.find_by(name: 'Moderator'), account: mod_user_account2, agreement: true, approved: true)
  mod_user2.save!
  mod_user2.approve!
end