class ButtonPress::Greeted < ButtonPress
  def process
    # Update airtables?
    @response = "@#{@user['name']} has greeted the new user"
  end
end

