# [OperationCodeBot](https://github.com/OperationCode/operationcode_bot)

[![Build Status](https://travis-ci.org/OperationCode/operationcode_bot.svg?branch=master)](https://travis-ci.org/OperationCode/operationcode_bot)
[![Code Climate](https://codeclimate.com/github/OperationCode/operationcode_bot/badges/gpa.svg)](https://codeclimate.com/github/OperationCode/operationcode_bot)
[![Test Coverage](https://codeclimate.com/github/OperationCode/operationcode_bot/badges/coverage.svg)](https://codeclimate.com/github/OperationCode/operationcode_bot/coverage)

OperationCode Bot is a bot built to deal with the [Slack Events API](https://api.slack.com/events).
When a subscribed event occurs:
  * Slack sends a POST to this bot
  * The bot processes the event and calls a method with the same name as the event passed in
  * The event named method does whatever tasks are needed

## Installation

* Clone this repo
* Run

    $ bundle
* Run the tests with

    $ rake

## Usage

To create a new event simply define a new method with the same name as the method you want to handle.
For example, if you wanted to write some code any time someone [pins an item](https://api.slack.com/events/pin_added) (the ```pin_added``` event) you would define
a new method like so:

```ruby
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

Bug reports and pull requests are welcome on GitHub at https://github.com/OperationCode/operation_code_bot. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


