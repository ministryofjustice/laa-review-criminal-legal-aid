class AddAuditorRoleToEnum < ActiveRecord::Migration[7.2]
  def up
    execute <<-SQL
      ALTER TYPE user_role ADD VALUE IF NOT EXISTS '#{Types::AUDITOR_ROLE}';
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration, 'STOP! Automatic removal of the `Auditor` role is not allowed'
  end
end
