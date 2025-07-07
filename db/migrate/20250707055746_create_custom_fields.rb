class CreateCustomFields < ActiveRecord::Migration[7.2]
  def change
    create_table :custom_fields do |t|
      t.references :event, null: false, foreign_key: true
      t.string :field_name, null: false, limit: 255
      t.string :field_type, null: false
      t.boolean :required, default: false, null: false
      t.text :options
      t.integer :position, default: 0, null: false

      t.timestamps
    end

    add_index :custom_fields, [:event_id, :position]
  end
end
