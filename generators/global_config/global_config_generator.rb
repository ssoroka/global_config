class GlobalConfigGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.migration_template 'create_global_configs.rb', "db/migrate", {
        :migration_file_name => "create_global_configs"
      }
    end
  end
end