class RsvpsController < ApplicationController
  before_action :set_event

  def create
    response = Rsvp::RESPONSES.find { |r| r == params[:commit].downcase.to_sym }
    @rsvp = @event.rsvps.new(rsvp_params.merge(response: response))

    if @rsvp.save
      if create_custom_field_responses
        session[@event.hashid] ||= []
        session[@event.hashid] << @rsvp.hashid
        redirect_to @event, notice: 'Thank you for responding!'
      else
        @rsvp.destroy
        redirect_to @event, alert: 'Please complete all required fields'
      end
    else
      redirect_to @event, alert: 'Please complete all required fields'
    end
  end

  def destroy
    @rsvp = @event.rsvps.find(params[:id])

    event_session = session[@event.hashid]

    if @rsvp.hashid.in?(event_session)
      @rsvp.destroy
      event_session -= [@rsvp.hashid]
    end

    redirect_to @event
  end

  private

  def set_event
    hashid = hashid_from_param(params[:event_id])
    @event = Event.find_by_hashid!(hashid)
  end

  def rsvp_params
    params.require(:rsvp).permit(:name)
  end

  def hashid_from_param(parameterized_id)
    parameterized_id.to_s.split('-').first
  end

  def custom_field_responses_params
    params[:custom_field_responses] || {}
  end

  def create_custom_field_responses
    # Check if all required fields have responses
    @event.custom_fields.each do |custom_field|
      if custom_field.required?
        response_value = custom_field_responses_params[custom_field.id.to_s]
        if response_value.blank?
          return false
        end
      end
    end

    # Create responses for all provided fields
    custom_field_responses_params.each do |custom_field_id, response_value|
      next if response_value.blank?
      
      custom_field = @event.custom_fields.find(custom_field_id)
      custom_field_response = @rsvp.custom_field_responses.build(
        custom_field: custom_field,
        response_value: response_value
      )
      
      unless custom_field_response.save
        return false
      end
    end
    
    true
  rescue ActiveRecord::RecordNotFound, ActiveRecord::RecordInvalid
    false
  end
end
