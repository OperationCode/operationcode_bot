require_relative '../../test_helper'

class ButtonPress::HelpMenuTest < Minitest::Test
  def test_it_delivers_messages
    mock_data = {
      'user' => { 'name' => 'test_user', 'id' => 'test_id' },
      'actions' => [ 'name' => 'test_action' ]
    }

    mock_help_menu_item = mock()
    mock_help_menu_item.stubs(:text).returns('Mock test item text')
    String.any_instance.stubs(:constantize).returns(mock_help_menu_item)

    mock_im = mock()
    mock_im.stubs(:deliver).returns(true)

    Operationcode::Slack::Im.expects(:new).with(user: 'test_id', text: 'Mock test item text').returns(mock_im)
    Operationcode::Slack::Im.expects(:new).with(channel: 'G3MD48QTD', text: 'User test_user has just clicked the test_action button').returns(mock_im)

    ButtonPress::HelpMenu.new(mock_data).process
  end
end
