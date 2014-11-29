namespace :ember do

  desc "Build Ember frontend"
  task :build => :environment do
    Dir.chdir("ember-app") { sh "ember build --output-path=../public --environment=#{ENV['RAILS_ENV']}" }
  end

  desc "Serve Ember frontend"
  task :serve => :environment do
    # using the Rails application has API backend
    Dir.chdir("ember-app") { sh "ember serve --proxy=#{ENV['SERVERNAME']}" }
  end

  desc "Test Ember frontend"
  task :test => :environment do
    Dir.chdir("ember-app") { sh "ember test" }
  end

  namespace :npm do

    desc "Install npm packages for Ember frontend"
    task :install => :environment do
      Dir.chdir("ember-app") { sh "npm install" }
    end

  end

  namespace :bower do

    desc "Install bower packages for Ember frontend"
    task :install => :environment do
      Dir.chdir("ember-app") { sh "bower install" }
    end

  end
end
