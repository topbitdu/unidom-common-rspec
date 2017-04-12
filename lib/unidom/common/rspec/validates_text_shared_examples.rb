shared_examples 'validates text' do |model_attributes, attribute_name, options|

  attribute_name      = attribute_name.to_sym
  presence_validator  = described_class.validators.select { |v| v.is_a?(ActiveRecord::Validations::PresenceValidator)&&v.attributes.include?(attribute_name) }.first
  excluded_validators = described_class.validators.select { |v| v.attributes.include?(attribute_name)&&![ ActiveRecord::Validations::PresenceValidator, ActiveRecord::Validations::LengthValidator ].include?(v.class) }

  if excluded_validators.present?
    raise ArgumentError.new("The validators on the #{attribute_name.inspect} attribute must be PresenceValidator or LengthValidator. The excluded validator#{excluded_validators.size>1 ? 's are' : ' is'}: #{excluded_validators.inspect}.")
  end

  attributes_collection = { {} => 0 }

  attributes_collection[ { attribute_name => nil } ] = presence_validator.present? ? 2 : 0
  attributes_collection[ { attribute_name => ''  } ] = presence_validator.present? ? 2 : 0

  minimum_length = options[:length].min
  maximum_length = options[:length].max

  numbers = ('0'..'9').to_a
  letters = ('a'..'z').to_a+('A'..'Z').to_a
  symbols = '~`!@#$%^&*()-_=+{}[];:"\',.<>/?\\|'.chars
  chars   = numbers+letters+symbols

  if minimum_length==maximum_length
    length = maximum_length
    chars.each do |c| attributes_collection[ { attribute_name => c*(length-1) } ] = 1 end
    chars.each do |c| attributes_collection[ { attribute_name => c*length     } ] = 0 end
    chars.each do |c| attributes_collection[ { attribute_name => c*(length+1) } ] = 1 end
  else
    chars.each do |c| attributes_collection[ { attribute_name => c                    } ] = 0 end if 1==minimum_length
    chars.each do |c| attributes_collection[ { attribute_name => c*(minimum_length-1) } ] = 1 end if minimum_length>1
    chars.each do |c| attributes_collection[ { attribute_name => c*minimum_length     } ] = 0 end
    chars.each do |c| attributes_collection[ { attribute_name => c*(minimum_length+1) } ] = 0 end if minimum_length<maximum_length
    chars.each do |c| attributes_collection[ { attribute_name => c*(maximum_length-1) } ] = 0 end
    chars.each do |c| attributes_collection[ { attribute_name => c*maximum_length     } ] = 0 end
    chars.each do |c| attributes_collection[ { attribute_name => c*(maximum_length+1) } ] = 1 end
  end

  it_behaves_like 'validates', model_attributes, attribute_name, attributes_collection

end
