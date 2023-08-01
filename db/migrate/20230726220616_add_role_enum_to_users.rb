class AddRoleEnumToUsers < ActiveRecord::Migration[7.0]
  def up
    roles = Types::UserRole.values.map { |r| "'#{r}'" }.join(', ')

    execute <<-SQL
      CREATE TYPE user_role AS ENUM (#{roles});
    SQL

    add_column :users, :role, :user_role, null: false, default: 'caseworker', index: true
  end

  def down
    remove_column :users, :role

    execute <<-SQL
      DROP TYPE user_role;
    SQL
  end
end
