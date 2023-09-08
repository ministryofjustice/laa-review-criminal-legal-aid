class AddDataAnalystRoleEnum < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      ALTER TYPE user_role ADD VALUE IF NOT EXISTS '#{Types::DATA_ANALYST_ROLE}';
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration, 'STOP! Automatic removal of the `Data Analyst` role is not allowed'
  end
end
