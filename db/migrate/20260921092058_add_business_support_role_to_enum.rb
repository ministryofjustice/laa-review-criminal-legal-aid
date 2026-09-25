class AddBusinessSupportRoleToEnum < ActiveRecord::Migration[7.2]
  def up
    execute <<~SQL.squish
      ALTER TYPE user_role ADD VALUE IF NOT EXISTS '#{Types::BUSINESS_SUPPORT_ROLE}';
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration, 'STOP! Automatic removal of the `Business Support` role is not allowed'
  end
end
