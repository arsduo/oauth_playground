set :application, "oauth_playground"
set :repository,  "git://github.com/arsduo/oauth_playground.git"
set :domain, "oauth.twoalex.com"
set :deploy_to, "$HOME/rails_apps/#{application}/"

# authentication
set :scm, "git"
set :user, "alexkm"
set :use_sudo, false
ssh_options[:forward_agent] = true

# web server
role :web, "oauth.twoalex.com"                          # Your HTTP server, Apache/etc
role :app, "oauth.twoalex.com"                          # This may be the same as your `Web` server
role :db,  "oauth.twoalex.com", :primary => true  # This is where Rails migrations will run


# other git-related commands
set :branch, "master"
default_run_options[:pty] = true
# cache the repository locally to speed updates
set :repository_cache, "git_cache" 
set :deploy_via, :remote_cache


# passenger-specific deploy tasks
namespace :deploy do
  task :start do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
  
  task :stop do
    # nothing
  end
  
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end