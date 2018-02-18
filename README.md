# [OperationCodeBot](https://github.com/OperationCode/operationcode_bot)

## Notice
This Slackbot is not currently in use on Operation Code's Slack organization. Please see https://github.com/OperationCode/operation_code_pybot for the current Slackbot in use.

[![Build Status](https://travis-ci.org/OperationCode/operationcode_bot.svg?branch=master)](https://travis-ci.org/OperationCode/operationcode_bot)
[![Code Climate](https://codeclimate.com/github/OperationCode/operationcode_bot/badges/gpa.svg)](https://codeclimate.com/github/OperationCode/operationcode_bot)
[![Test Coverage](https://codeclimate.com/github/OperationCode/operationcode_bot/badges/coverage.svg)](https://codeclimate.com/github/OperationCode/operationcode_bot/coverage)

OperationCode Bot is a bot built to deal with the [Slack Events API](https://api.slack.com/events).
When a subscribed event occurs:
  * Slack sends a POST to this bot
  * The bot processes the event and calls a method with the same name as the event passed in
  * The event named method does whatever tasks are needed

It also handles interactive message button presses. When a button click clicked:
  * Slack send us a POST with the buttom params
  * The bot calls the `process` method on an instance of the callback_id of the button
  * If `@response` is set we reply with the response and slack updates the message.
    This can be just text or a an entire message payload.

## Installation

* Clone this repo
* Run

    $ bundle
* Run the tests with

    $ rake

## Usage

### Adding New Button Responses

Button Presses are called by as a class by way of the `callback_id`
passed in from the slack API. To handle a new action define a new class
in `lib/button_press`. The `#process` method must be defined. See the existing
classes for more help.

### Adding new help menu items

To add a new item to the help menu simply create a new class in `lib/help_menu`.
See existing help menu classes for more help.
Then you'll just need to add the messages template with $CLASS_NAME_message.txt.erb in `views/help_menu/`.

### Adding A New Event

To create a new event, within the [operationcode_bot.rb](https://github.com/OperationCode/operationcode_bot/blob/master/operationcode_bot.rb) file, simply define a new `private` method with the same name as the method you want to handle.

For example, if you wanted to write some code any time someone [pins an item](https://api.slack.com/events/pin_added) (the ```pin_added``` event) you would define
a new method like so:

```ruby
private

def pin_added(data, token: nil)
  logger.add "Got pin_added event with data: #{data}"
  empty_response
end
```

You can now write your business logic inside of this method.
If your logic is complex (more than a 5-10 lines) I'd recommend using a ruby object.
There is an Event class that can be inherited from to make your life a bit easier.
See ```Event::TeamJoin``` as a reference.


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/OperationCode/operationcode_bot. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


