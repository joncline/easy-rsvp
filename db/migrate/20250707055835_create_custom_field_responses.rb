class CreateCustomFieldResponses < ActiveRecord::Migration[7.2]
  def change
    create_table :custom_field_responses do |t|
      t.references :rsvp, null: false, foreign_key: true
      t.references :custom_field, null: false, foreign_key: true
      t.string :response_value, limit: 255

      t.timestamps
    end

    add_index :custom_field_responses, [:rsvp_id, :custom_field_id], unique: true
  end
end
