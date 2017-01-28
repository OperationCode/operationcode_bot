class ButtonPress::Greeted < ButtonPress
  def process
    updated_message = @data['original_message']
    updated_message['attachments'].first['text'] = "<@#{@user['id']}> has greeted the new user"
    updated_message['attachments'].first['actions'] = []

    @response = updated_message.to_json
  end
end

