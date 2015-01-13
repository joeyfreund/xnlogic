require 'pathname'

module Xnlogic
  class CLI::Application
    attr_reader :options, :app_name, :thor, :base_name, :name, :app, :root

    def initialize(options, app_name, thor)
      @options = options
      @app_name = app_name
      @thor = thor

      @name = app_name.chomp("/").tr('-', '_') # remove trailing slash if present
      @root = options.fetch('root', @name)
      @app = Pathname.pwd.join(root)
    end

    def run
      namespaced_path = name
      constant_name = namespaced_path.split('_').map{|p| p[0..0].upcase + p[1..-1] }.join
      git_user_name = `git config user.name`.chomp
      git_user_email = `git config user.email`.chomp

      opts = {
        :name            => name,
        :namespaced_path => namespaced_path,
        :constant_name   => constant_name,
        :author          => git_user_name.empty? ? "TODO: Write your name" : git_user_name,
        :email           => git_user_email.empty? ? "TODO: Write your email address" : git_user_email,
        :vm_cpus         => options['cpus'],
        :vm_memory       => options['memory'],
        :xn_key          => options['key'],
      }

      base_templates = {
        "Vagrantfile.tt" => "Vagrantfile",
        "config/vagrant.provision.tt" => "config/vagrant.provision",
        "config/vagrant.settings.yml.tt" => "config/vagrant.settings.yml",
        "config/datomic.conf" => "config/datomic.conf",
        "config/transactor.properties" => "config/transactor.properties",
      }

      base_templates.each do |src, dst|
        thor.template("vagrant/#{src}", app.join(dst), opts)
      end

      templates = {
        "gitignore.tt" => ".gitignore",
        ".rspec.tt" => ".rspec",
        "gemspec.tt" => "#{namespaced_path}.gemspec",
        "Gemfile.tt" => "Gemfile",
        "Readme.md.tt" => "Readme.md",
        "config.ru.tt" => "config.ru",
        "dev/console.rb.tt" => "dev/console.rb",
        "torquebox.yml.tt" => "torquebox.yml",
        "torquebox_init.rb.tt" => "torquebox_init.rb",
        "lib/gemname.rb.tt" => "lib/#{namespaced_path}.rb",
        "lib/gemname/version.rb.tt" => "lib/#{namespaced_path}/version.rb",
        "lib/gemname/initializers/inflections.rb.tt" => "lib/#{namespaced_path}/initializers/inflections.rb",
        "lib/gemname/parts/has_notes.rb.tt" => "lib/#{namespaced_path}/parts/has_notes.rb",
        "lib/gemname/parts/note.rb.tt" => "lib/#{namespaced_path}/parts/note.rb",
        "lib/gemname/type/url.rb.tt" => "lib/#{namespaced_path}/type/url.rb",
        "lib/gemname/fixtures.rb.tt" => "lib/#{namespaced_path}/fixtures.rb",
        "lib/gemname/models.rb.tt" => "lib/#{namespaced_path}/models.rb",
        "lib/gemname/permissions.rb.tt" => "lib/#{namespaced_path}/permissions.rb",
        "lib/gemname/type.rb.tt" => "lib/#{namespaced_path}/type.rb",
        "lib/fixtures/sample_fixtures.rb.tt" => "lib/fixtures/sample_fixtures.rb",

        "spec/spec_helper.rb.tt" => "spec/spec_helper.rb",
        "spec/gemname/gemname_spec.rb.tt" => "spec/#{namespaced_path}/#{name}_spec.rb",
      }

      templates.each do |src, dst|
        thor.template("application/#{src}", app.join(dst), opts)
      end

      Xnlogic.ui.info "Creating Vagrant config."
      Xnlogic.ui.info ""
      Xnlogic.ui.info "Initializing git repo in #{app}"
      Dir.chdir(app) { `git init`; `git add .` }

      Xnlogic.ui.info ""
      Xnlogic.ui.info "Please ensure that the following dependencies are installed on your computer"
      Xnlogic.ui.info "to continue."
      Xnlogic.ui.info " - Vagrant:    https://www.vagrantup.com/"
      Xnlogic.ui.info " - VirtualBox: https://www.virtualbox.org/wiki/Downloads"
      Xnlogic.ui.info ""
      Xnlogic.ui.info "Then run the following:"
      Xnlogic.ui.info ""
      Xnlogic.ui.info "cd #{root}"
      Xnlogic.ui.info "vagrant up"
      Xnlogic.ui.info "vagrant ssh"
      Xnlogic.ui.info ""
      Xnlogic.ui.info "Once logged in to the server, the project directory is ~/xn.dev"
    end
  end
end

