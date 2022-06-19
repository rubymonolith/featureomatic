# Featureomatic

Features are simple boolean flags that say whether or not they're enabled, right? RIGHT!? WRONG! Features can get quite complicated.

This gem makes reasoning through those complexities much more sane by isolating them all into the `app/features` folder as plain 'ol Ruby objects (POROS), that way your team can reason through the features available in an app much better, test them, and do really complicated stuff when needed.

# Use cases

Here's why you'd want to use Featureomatic:

## Turbo app built by a solopreneur deployed to the Apple App Store

If you're deploying a simple Rails Turbo application to the web you might have 20 features that are available for purchase, but when deployed to the Apple App Store, you have to disable certain parts of your website to comply with their draconian app store policies. Featureomatic could disable the features that upset Apple, like links to your support and pricing, so that your app can get approved and stay in compliance.

## B2B Rails app built by a 50 person engineering team for multinational enterprises

Enterprise use-cases are even more complicated. If a package is sold to a multi-national customer with 200 features, they may want to disable 30 of those features for certain teams/groups within that organization for compliance reasons. You end up with a hierarchy that can get as complicated as, "The Zig Bang feature is available to MegaCorp on the Platimum plan, but only for their US entities if their team administrators turn that feature on because of weird compliance reasons".

## Installation

Install the gem by executing the following from your Rails root:

```bash
$ bundle add featureomatic
```

Then run

```bash
$ rails generate featureomatic:install
```

Restart your server and it's off to the races!

First thing you'll want to checkout is the `./app/features/application_feature.rb` file:

```ruby
class ApplicationFeature < Featureomatic::Base
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def enabled?
    user.paid?
  end
end
```

## Usage

Ready to add a new feature? Sweet! Just run this:

```bash
$ rails generate featureomatic:new ModerationFeature
```

This creates the following file:

```ruby
# ./app/features/my_kewl_feature.rb
class ModerationFeature < ApplicationFeature
  def name
    "Moderation"
  end
end
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
