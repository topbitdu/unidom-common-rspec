# Unidom Common RSpec Unidom Common RSpec 库

[![Documentation](http://img.shields.io/badge/docs-rdoc.info-blue.svg)](http://www.rubydoc.info/gems/unidom-common-rspec/frames)
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

Assume we have the Person model, the Pet model, & the Identity Card model as the following:
```ruby
# person.rb
class Person < ApplicationRecord

  include Unidom::Common::Concerns::ModelExtension

  has_many :pets
  has_one  :identity_card

end

# pet.rb
class Pet < ApplicationRecord

  include Unidom::Common::Concerns::ModelExtension

  belongs_to :person

end

# identity_card.rb
class IdentityCard < ApplicationRecord

  include Unidom::Common::Concerns::ModelExtension

  belongs_to :person

end
```

### Scope shared examples Scope 共享用例

The ``person_spec.rb`` looks like the following:
If the ``count_diff`` is set to 'E', an error was expected to be raised.
```ruby
# The :all scope and the :none scope are the scopes defined by Rails.
# The :transited_to scope is defined by Model Extension.
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

The ``person_spec.rb`` looks like the following:
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

### Belongs To shared examples Belongs To 共享用例

The ``pet_spec.rb`` looks like the following:
```ruby
require 'rails_helper'

describe Pet, type: :model do

  context do

    cat_attributes = { name: 'Pearl', species: 'Persian' }
    tim_attributes = { name: 'Tim' }

    it_behaves_like 'belongs_to', cat_attributes, :person, Person, tim_attributes

  end

end
```

The ``identity_card_spec.rb`` looks like the following:
```ruby
require 'rails_helper'

describe IdentityCard, type: :model do

  context do

    tim_attributes = { name: 'Tim' }
    tim_identity_card_attributes = { name: 'Tim', gender_code: '1', birth_date: '1980-07-01' }

    it_behaves_like 'belongs_to', tim_identity_card_attributes, :person, Person, tim_attributes

  end

end
```

### Has Many shared examples Has Many 共享用例

The ``person_spec.rb`` looks like the following:
```ruby
require 'rails_helper'

describe Person, type: :model do

  context do

    tim_attributes = { name: 'Tim' }
    cat_attributes = { name: 'Pearl',  species: 'Persian'   }
    dog_attribtues = { name: 'Flower', species: 'Chihuahua' }

    it_behaves_like 'has_many', tim_attributes, :pets, Pet, [ cat_attributes, dog_attribtues ]

  end

end
```

### Has One shared examples Has Many 共享用例

The ``person_spec.rb`` looks like the following:
```ruby
require 'rails_helper'

describe Person, type: :model do

  context do

    tim_attributes = { name: 'Tim' }
    tim_identity_card_attributes = { name: 'Tim', gender_code: '1', birth_date: '1980-07-01' }

    it_behaves_like 'has_one', tim_attributes, :identity_card, IdentityCard, tim_identity_card_attributes

  end

end
```

### Model Extension shared examples Model Extension 共享用例

The ``person_spec.rb`` looks like the following:
```ruby
require 'rails_helper'

describe Person, type: :model do

  context do

    tim_attributes = { name: 'Tim' }

    it_behaves_like 'Unidom::Common::Concerns::ModelExtension', tim_attributes

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
