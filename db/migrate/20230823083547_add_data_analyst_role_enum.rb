class AddDataAnalystRoleEnum < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      ALTER TYPE user_role ADD VALUE IF NOT EXISTS '#{Types::DATA_ANALYST_ROLE}';
    SQL
  end

  def down
    data_analysts = User.unscoped.where(role: Types::DATA_ANALYST_ROLE)
    puts "#{data_analysts.size} Data Analysts will be destroyed!"
    data_analysts.destroy_all

    execute <<-SQL
      DELETE FROM pg_enum
      WHERE enumlabel = 'data_analyst'
      AND enumtypid = (
        SELECT oid FROM pg_type WHERE typname = 'user_role'
      )
    SQL
  end
end
