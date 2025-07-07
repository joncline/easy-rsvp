class Rsvp < ApplicationRecord
  include Hashid::Rails

  RESPONSES = [
    :yes,
    :maybe,
    :no
  ]

  belongs_to :event
  has_many :custom_field_responses, dependent: :destroy

  validates :name, presence: true
  validates :response, presence: true

  # Use this to avoid including new (unsaved) records
  scope :persisted, -> { where.not(id: nil) }

  def session_key
    [:event, event_id, :rsvp, id].join(':')
  end

  def custom_field_response_for(custom_field)
    custom_field_responses.find_by(custom_field: custom_field)
  end

  def custom_field_value_for(custom_field)
    custom_field_response_for(custom_field)&.response_value
  end
end
