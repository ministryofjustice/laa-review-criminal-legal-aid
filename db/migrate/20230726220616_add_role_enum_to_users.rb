class AddRoleEnumToUsers < ActiveRecord::Migration[7.0]
  def up
    return unless FeatureFlags.basic_user_roles.enabled?

    execute <<-SQL
      CREATE TYPE user_role AS ENUM ('caseworker', 'supervisor');
    SQL

    add_column :users, :role, :user_role, null: false, default: 'caseworker', index: true
  end

  def down
    return unless FeatureFlags.basic_user_roles.enabled?

    remove_column :users, :role

    execute <<-SQL
      DROP TYPE user_role;
    SQL
  end
end
