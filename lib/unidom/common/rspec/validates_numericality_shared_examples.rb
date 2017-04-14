shared_examples 'validates numericality' do |model_attributes, attribute_name, options|

  attribute_name      = attribute_name.to_sym
  presence_validator  = described_class.validators.select { |v| v.is_a?(ActiveRecord::Validations::PresenceValidator)&&v.attributes.include?(attribute_name) }.first
  excluded_validators = described_class.validators.select { |v| v.attributes.include?(attribute_name)&&![ ActiveRecord::Validations::PresenceValidator, ActiveModel::Validations::NumericalityValidator ].include?(v.class) }

  if excluded_validators.present?
    raise ArgumentError.new("The validators on the #{attribute_name.inspect} attribute must be PresenceValidator or NumericalityValidator. The excluded validator#{excluded_validators.size>1 ? 's are' : ' is'}: #{excluded_validators.inspect}.")
  end

  attributes_collection = { {} => 0 }

  attributes_collection[ { attribute_name => nil } ] = presence_validator.present? ? 2 : 0
  attributes_collection[ { attribute_name => ''  } ] = presence_validator.present? ? 2 : 0

  minimum           = options[:range].min
  maximum           = options[:range].max
  minimum_inclusive = options[:minimum_inclusive]
  maximum_inclusive = options[:maximum_inclusive]
  only_integer      = options[:only_integer]
  scale             = described_class.columns_hash[attribute_name.to_s].scale.to_i
  unit              = only_integer ? 1 : (scale>0 ? (10**-scale).to_f : 0.01)

  attributes_collection[ { attribute_name => minimum-unit } ] = 1
  attributes_collection[ { attribute_name => minimum      } ] = minimum_inclusive ? 0 : 1
  attributes_collection[ { attribute_name => minimum+unit } ] = 0

  attributes_collection[ { attribute_name => maximum-unit } ] = 0
  attributes_collection[ { attribute_name => maximum      } ] = maximum_inclusive ? 0 : 1
  attributes_collection[ { attribute_name => maximum+unit } ] = 1

  average = (minimum+maximum)/(only_integer ? 2 : 2.0)
  attributes_collection[ { attribute_name => average } ] = 0

  if only_integer
    attributes_collection[ { attribute_name => minimum+0.01 } ] = 1
    attributes_collection[ { attribute_name => maximum-0.01 } ] = 1
  end

  letters = ('a'..'z').to_a+('A'..'Z').to_a
  symbols = '~`!@#$%^&*()-_=+{}[];:"\',.<>/?\\|'.chars

  (letters+symbols).each do |c| attributes_collection[ { attribute_name => c } ] = 1 end

  it_behaves_like 'validates', model_attributes, attribute_name, attributes_collection

end
