class AddRoleEnumToUsers < ActiveRecord::Migration[7.0]
  def up
    return unless FeatureFlags.basic_user_roles.enabled?

    execute <<-SQL
      CREATE TYPE user_role AS ENUM ('caseworker', 'supervisor', 'user_manager');
    SQL
    add_column :users, :role, :user_role, null: false, default: 'caseworker', index: true

    execute <<-SQL
      UPDATE users SET role = 'user_manager' where can_manage_others = true;
      UPDATE users SET role = 'caseworker' where can_manage_others = false;
    SQL
    remove_column :users, :can_manage_others
  end

  def down
    return unless FeatureFlags.basic_user_roles.enabled?

    add_column :users, :can_manage_others, :boolean, default: false, null: false, index: true

    execute <<-SQL
      UPDATE users SET can_manage_others = true where role = 'user_manager';
      UPDATE users SET can_manage_others = false where role <> 'user_manager';
    SQL
    remove_column :users, :role

    execute <<-SQL
      DROP TYPE user_role;
    SQL
  end
end
