class EventsController < ApplicationController
  before_action :set_event, only: [:show]
  before_action :set_placeholders, only: [:new]

  def show
    @rsvp = @event.rsvps.new
    @rsvps = @event.rsvps.persisted.order(created_at: :asc)

    @user_rsvp_hashids = session[@event.hashid] || []
    @responded = @rsvps.any? { |rsvp| rsvp.hashid.in? @user_rsvp_hashids }
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)

    if @event.save
      create_custom_fields if custom_fields_params.present?
      redirect_to event_admin_path(@event, @event.admin_token)
    else
      set_placeholders
      render :new
    end
  end

  private

  def set_event
    hashid = hashid_from_param(params[:id])
    @event = Event.find_by_hashid!(hashid)

    unless @event.published?
      redirect_to root_path, alert: 'This event is no longer viewable.'
    end
  end

  def set_placeholders
    @placeholders = {
      title: 'BBQ party in our backyard 🏡🍔🍻',
      body: "Hey everyone, summer is finally here so let's celebrate with some grilled food and cold beers! Our address: 1000 Hart Street in Brooklyn."
    }
  end

  def event_params
    params.require(:event).permit(:title, :date, :body)
  end

  def hashid_from_param(parameterized_id)
    parameterized_id.to_s.split('-').first
  end

  def custom_fields_params
    params[:custom_fields] || {}
  end

  def create_custom_fields
    return if custom_fields_params.blank?
    
    custom_fields_params.each.with_index do |(key, field_data), index|
      next if field_data[:field_name].blank? || field_data[:field_type].blank?
      
      custom_field = @event.custom_fields.build(
        field_name: field_data[:field_name],
        field_type: field_data[:field_type],
        required: field_data[:required] == '1',
        position: index
      )
      
      if field_data[:field_type] == 'dropdown' && field_data[:options].present?
        # Parse textarea input (one option per line)
        options_array = field_data[:options].split("\n").map(&:strip).reject(&:blank?)
        custom_field.options_array = options_array
      end
      
      custom_field.save!
    end
  end
end
