class CustomField < ApplicationRecord
  belongs_to :event
  has_many :custom_field_responses, dependent: :destroy

  FIELD_TYPES = %w[text dropdown].freeze

  validates :field_name, presence: true, length: { maximum: 255 }
  validates :field_type, presence: true, inclusion: { in: FIELD_TYPES }
  validates :position, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :options, presence: true, if: :dropdown?

  scope :ordered, -> { order(:position) }

  def dropdown?
    field_type == 'dropdown'
  end

  def text?
    field_type == 'text'
  end

  def required?
    required
  end

  def options_array
    return [] unless dropdown? && options.present?
    
    begin
      JSON.parse(options)
    rescue JSON::ParserError
      []
    end
  end

  def options_array=(array)
    self.options = array.to_json if array.is_a?(Array)
  end
end
