class CreateGeneratedReports < ActiveRecord::Migration[7.2]
  def change
    create_table :generated_reports, id: :uuid do |t|
      t.string :report_type
      t.string :interval
      t.datetime :period_start_date
      t.datetime :period_end_date
      t.timestamps
    end
  end
end
