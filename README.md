# Unidom Common RSpec Unidom Common RSpec 库

[![License](https://img.shields.io/badge/license-MIT-green.svg)](http://opensource.org/licenses/MIT)
[![Gem Version](https://badge.fury.io/rb/unidom-common-rspec.svg)](https://badge.fury.io/rb/unidom-common-rspec)
[![Dependency Status](https://gemnasium.com/badges/github.com/topbitdu/unidom-common-rspec.svg)](https://gemnasium.com/github.com/topbitdu/unidom-common-rspec)

Unidom Common RSpec is a RSpec-based Shared Example for the Unidom Common-based models. Unidom Common RSpec 是为 Unidom Common 设计的基于 RSpec 的共享测试用例。



## Recent Update

Check out the [Road Map](ROADMAP.md) to find out what's the next.
Check out the [Change Log](CHANGELOG.md) to find out what's new.



## Installation

Add this line to your application's Gemfile:

```ruby
gem 'unidom-common-rspec'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install unidom-common-rspec



## Usage

### Scope shared examples Scope 共享用例

Assume the model class is ``Person``, the ``person_spec.rb`` looks like the following:
If the ``count_diff`` is set to 'E', an error was expected to be raised.
```ruby
require 'rails_helper'

describe Person, type: :model do

  context '.scope' do

    model_attributes = { name: 'Tim' }

    it_behaves_like 'scope', :all, [
      { attributes_collection: [ model_attributes                            ], count_diff: 1, args: [] },
      { attributes_collection: [ model_attributes.merge(defunct:   true)     ], count_diff: 1, args: [] },
      { attributes_collection: [ model_attributes.merge(closed_at: Time.now) ], count_diff: 1, args: [] }
    ]

    it_behaves_like 'scope', :none, [
      { attributes_collection: [ model_attributes                            ], count_diff: 0, args: [] },
      { attributes_collection: [ model_attributes.merge(defunct:   true)     ], count_diff: 0, args: [] },
      { attributes_collection: [ model_attributes.merge(closed_at: Time.now) ], count_diff: 0, args: [] }
    ]

    it_behaves_like 'scope', :transited_to, [
      { attributes_collection: [ model_attributes                   ], count_diff: 1, args: [ 'C' ] },
      { attributes_collection: [ model_attributes                   ], count_diff: 0, args: [ 'A' ] },
      { attributes_collection: [ model_attributes.merge(state: 'A') ], count_diff: 0, args: [ 'C' ] },
      { attributes_collection: [ model_attributes.merge(state: 'A') ], count_diff: 1, args: [ 'A' ] }
    ]

  end

end
```

### Validates shared examples Validates 共享用例

Assume the model class is ``Person``, the ``person_spec.rb`` looks like the following:
```ruby
require 'rails_helper'

describe Person, type: :model do

  context '.validates' do

    tim_attributes = { name: 'Tim' }

    it_behaves_like 'validates', tim_attributes, :name,
      {            } => 0,
      { name: nil  } => 2,
      { name: ''   } => 2,
      { name: 'A'  } => 1,
      { name: 'AA' } => 0,
      { name: '0'  } => 1,
      { name: '00' } => 0,
      { name: 0    } => 1

  end

end
```

### Model Extension shared examples Model Extension 共享用例

Assume the model class is ``Person``, and the model alread extend the ``Unidom::Common::Concerns::ModelExtension``, the ``person_spec.rb`` looks like the following:
```ruby
require 'rails_helper'

describe Person, type: :model do

  context do

    tim_attributes = { name: 'Tim' }

    it_behaves_like 'Unidom::Common::Concerns::ModelExtension', tim_attributes

  end

end
```

### Has Many shared examples Has Many 共享用例

Assume the model class is ``Person``, and the model alread defined the ``has_many :pets``, the ``person_spec.rb`` looks like the following:
```ruby
require 'rails_helper'

describe Person, type: :model do

  context do

    tim_attributes = { name: 'Tim' }
    cat_attributes = { name: 'Pearl',  species: 'Persian'   }
    dog_attribtues = { name: 'Flower', species: 'Chihuahua' }

    it_behaves_like 'has_many', tim_attributes, :pets, 'Pet', [ cat_attributes, dog_attribtues ]

  end

end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).



## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/unidom-common-rspec. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.



## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
