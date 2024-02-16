# Polidef

**Still a WIP v1.0.0 is planned for early March 2024**

Polidef allows you to create easily testable policy objects that can be very generic for use in multiple objects or be very very specific all while avoiding heavy scaffolding in code.

## Who is this for?
This gem isn't recommended for newer applications that are still working through determining their domain as something like this can end up complicating features more so than it can help. The target audience is for those who have inherited a more mature codebase where the code design is not always ideal. The abstraction here can help provide you with ways of naming important "conditional based" concepts in your domain, especially those that tend to grow with more and more `&&`s or `||`s. 

The techniques here are certainly implementable with POROs (Plain Old Ruby Objects) but the convinence of these abstractions, especially for testing maybe useful.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'polidef'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install polidef

## Usage
**As of Feb 2024, this project is still a WIP. I've tried to notate available API's as they are on the `main` branch but it may not always be accurate.**

### Simple Policies
The simpilest way to implement a `Polidef::Policy` is to create a class which implements a `#policy` method that evaluates to the _truthy_ version of your logic. Think along the lines of:

> "ThisObject can_do_this if Policy is fulfilled"

**Policy Object**

``` ruby
class NotificationPolicy < Polidef::Policy
  dependencies :user, :subject, :channel
  
  def policy
    policy_chain([:user_can_recieve?, :channel_usable?])
      .or_policy(:subject_overrides_preferences?)
  end
  
  private
  
  def user_can_recieve?
    user.prefences.notifications_enabled? && !user.notifications_muted?
  end
  
  def channel_usable?
    channel.state == 'active'
  end
  
  def subject_overrides_preferences?
    subject.overrides_notification_policy?
  end
end
```

We can then use `NotificationPolicy` where ever we need to in a few different ways:

``` ruby
# ...
include Polidef::Policies
## a block
def send_notification_to(recipient, notifier: NotificationService)
  with_fulfilled_policy(:notification_policy, dependencies: {user: recipient, subject: self, channel: channel}) do
    notifier.send_notification_to(recipient, subject: subject)
  end
end

## a method
def send_notification_to(recipient, notifier: NotificationService)
  if policy_fulfilled?(:notification_policy, user: recipient, subject: self, channel: channel)
    notifier.send_notification_to(recipient, subject: subject)
  else # policy implicitely rejected
    notifier.perform_later(current_user.time_till_unmute, user_id: current_user.id subject_id: subject.id, channel_id: channel.id)
  end
end
```

Testing the `NotificationPolicy` is simple with the provided assertions. Since we want to know if the `#send_notification` works and don't care about the specifics of the `NotificationPolicy` and/or we don't want to have to mock/stub (or worse, persist) each dependency for the test we can instead, use `asserts_with_policy`.

``` ruby
# ...
include Polidef::PolicyAssertions

# ...

def test_send_notification_for
  message = build(:message_in_default_channel, content: "Test")

  mock_notification_service = Minitest::Mock.new
  mock_notification_service.expects(:send_notification_to, nil, [User], subject: message)
  
  # Forces Policy fulfilled
  assert_with_fulfilled_policy :notification_policy do
    message.send_notification_to(@user, notifier: mock_notification_service)
  end
  
  assert_mock mock_notification_service
end

def test_send_notification_for
  message = build(:message_in_default_channel, content: "Test")

  mock_notification_service = Minitest::Mock.new
  mock_notification_service.expects(:perform_later, 'job-id-123', [Time], Hash)
  
  # Forces Policy rejected
  assert_with_rejected_policy :notification_policy do
    message.send_notification_to(@user, notifier: mock_notification_service)
  end

  assert_mock mock_notification_service
end
```

## Plans & Todos
### Planned features
- Support for inline Policy declarations (50% complete)
- Support for `policy_rejected` inverse of fulfilled methods
- Support for decorators using `SimpleDelegator` for very generic policies
- Useful testing API to test individual Policies
- Support for `rails generate policy --deps dep_1, dep_2 ...`
- "Conditional chaining" API for readability

### Planned Housekeeping
- More thorough examples
- Integrate a documentation framework (RDoc and Yard maybe?)
- A small static site
- Issue & PR templates

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/juliusdelta/polidef. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/juliusdelta/polidef/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Polidef project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/juliusdelta/polidef/blob/master/CODE_OF_CONDUCT.md).
