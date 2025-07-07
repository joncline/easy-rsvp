class CustomFieldResponse < ApplicationRecord
  belongs_to :rsvp
  belongs_to :custom_field

  validates :response_value, presence: true, if: :required_field?
  validates :response_value, length: { maximum: 255 }
  validates :response_value, inclusion: { in: :valid_options }, if: :dropdown_field?

  private

  def required_field?
    custom_field&.required?
  end

  def dropdown_field?
    custom_field&.dropdown?
  end

  def valid_options
    custom_field&.options_array || []
  end
end
