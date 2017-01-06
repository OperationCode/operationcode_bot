# [OperationCodeBot](https://github.com/OperationCode/operationcode_bot)

[![Build Status](https://travis-ci.org/OperationCode/operationcode_bot.svg?branch=master)](https://travis-ci.org/OperationCode/operationcode_bot)
[![Code Climate](https://codeclimate.com/github/OperationCode/operationcode_bot/badges/gpa.svg)](https://codeclimate.com/github/OperationCode/operationcode_bot)
[![Test Coverage](https://codeclimate.com/github/OperationCode/operationcode_bot/badges/coverage.svg)](https://codeclimate.com/github/OperationCode/operationcode_bot/coverage)

OperationCode Bot is a bot built to deal with the [Slack Events API](https://api.slack.com/events).
When a subscribed event occurs:
  * Slack sends a POST to this bot
  * The bot processes the event and calls a method with the same name as the event passed in
  * The event named method does whatever tasks are needed

In the current case when a new user signs up they are sent a welcome message with keywords.
The user can respond to this message with one of the keywords to get more info on that subject.
In the one specific case of joining our mentorship program if the user replies in the affirmative
they are invited to a mentorship squad and added to our airtables base.

## Installation

* Clone this repo
* Run

    $ bundle
* Run the tests with

    $ rake

## Usage

### Adding New Keywords

When a user messages the bot the code in `lib/event/message.rb` is executed.
To add a new keyword we'll start there.

Add your new keyword to the `KEYWORDS` constant. The `name` key is what the user will type to access this keyword,
and the `help_text` key will be displayed when someone types 'help' and in the welcome message.

Next navigate to `views/event/message`. Create a new file called `$NAME_message.txt.erb`, where $NAME is the name of your
keyword above. Now just create the text you'd like to be sent to the user in this file and create a PR with your changes.
The text in this file can use the features of the Slack [message formatting](https://api.slack.com/docs/message-formatting) guide.

### Adding A New Event

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


