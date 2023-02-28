class CreateReceivedOnReports < ActiveRecord::Migration[7.0]
  def change
    create_table :received_on_reports, id: false do |t|
      t.date :business_day, primary_key: true
      t.integer :total_received, default: 0, null: false
      t.integer :total_closed, default: 0, null: false

      t.timestamps
    end
  end
end
