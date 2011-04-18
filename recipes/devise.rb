# Application template recipe for the rails3_devise_wizard. Check for a newer version here:
# https://github.com/fortuity/rails3_devise_wizard/blob/master/recipes/devise.rb

if config['devise']
  gem "devise", ">= 1.3.0"
else
  recipes.delete('devise')
end


if config['devise']
  after_bundler do
    
    say_wizard "Devise recipe running 'after bundler'"
    
    # Run the Devise generator
    generate 'devise:install'

    if recipes.include? 'mongo_mapper'
      gem 'mm-devise'
      gsub_file 'config/initializers/devise.rb', 'devise/orm/', 'devise/orm/mongo_mapper_active_model'
      generate 'mongo_mapper:devise User'
    elsif recipes.include? 'mongoid'
      # Nothing to do (Devise changes its initializer automatically when Mongoid is detected)
      # gsub_file 'config/initializers/devise.rb', 'devise/orm/active_record', 'devise/orm/mongoid'
    end
  
    # Prevent logging of password_confirmation
    gsub_file 'config/application.rb', /:password/, ':password, :password_confirmation'

    # Generate models and routes for a User
    generate 'devise user'
    
  end

  after_everything do

    say_wizard "Devise recipe running 'after everything'"

    if recipes.include? 'rspec'
      say_wizard "Copying RSpec files from the rails3-mongoid-devise examples"
      # copy all the RSpec specs files from the rails3-mongoid-devise example app
      inside 'spec' do
        get 'https://github.com/fortuity/rails3-mongoid-devise/raw/master/spec/factories.rb', 'factories.rb'
      end
      remove_file 'spec/controllers/home_controller_spec.rb'
      remove_file 'spec/controllers/users_controller_spec.rb'
      inside 'spec/controllers' do
        get 'https://github.com/fortuity/rails3-mongoid-devise/raw/master/spec/controllers/home_controller_spec.rb', 'home_controller_spec.rb'
        get 'https://github.com/fortuity/rails3-mongoid-devise/raw/master/spec/controllers/users_controller_spec.rb', 'users_controller_spec.rb'
      end
      remove_file 'spec/models/user_spec.rb'
      inside 'spec/models' do
        get 'https://github.com/fortuity/rails3-mongoid-devise/raw/master/spec/models/user_spec.rb', 'user_spec.rb'
      end
      remove_file 'spec/views/home/index.html.erb_spec.rb'
      remove_file 'spec/views/home/index.html.haml_spec.rb'
      remove_file 'spec/views/users/show.html.erb_spec.rb'
      remove_file 'spec/views/users/show.html.haml_spec.rb'
      remove_file 'spec/helpers/home_helper_spec.rb'
      remove_file 'spec/helpers/users_helper_spec.rb'
    end

  end
end

__END__

name: Devise
description: Utilize Devise for authentication, automatically configured for your selected ORM.
author: fortuity

category: authentication
exclusive: authentication

config:
  - devise:
      type: boolean
      prompt: Would you like to use Devise for authentication?