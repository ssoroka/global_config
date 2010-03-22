class CreateGlobalConfigs < ActiveRecord::Migration
  def self.up
    create_table :global_configs do |t|
      t.string :key, :value
      t.timestamps
    end
  end

  def self.down
    drop_table :global_configs
  end
end
