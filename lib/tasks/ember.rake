namespace :ember do

  desc "Build Ember frontend"
  task :build => :environment do
    Dir.chdir("ember") { sh "ember build --output-path=../public --environment=#{ENV['RAILS_ENV']}" }
  end

  desc "Serve Ember frontend"
  task :serve => :environment do
    # using the Rails application has API backend
    Dir.chdir("ember") { sh "ember serve --proxy=#{ENV['SERVERNAME']}" }
  end
end
