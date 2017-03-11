shared_examples 'validates' do |model_attributes, attribute_name, error_attributes_collection|

  attribute_name = attribute_name.to_sym

  describe "##{attribute_name}" do

    it 'is responded to' do expect(described_class.new).to respond_to(attribute_name) end

    error_attributes_collection.each do |error_attributes, error_count|

      title_attributes = error_attributes.clone
      title_attributes.each { |k, v|
        value_length = v.is_a?(String) ? v.length : 0
        title_attributes[k] = "#{v[0..7]}...#{v[value_length-7..value_length]} (#{value_length} characters)" if (value_length>64)
      }

      describe title_attributes.inspect do

        error_instance = described_class.new model_attributes.merge(error_attributes)
        #error_instance.attributes = error_attributes
        error_instance.valid?
        count_errors = "has #{error_count} error#{error_count>1 ? 's' : ''}"

        if error_count>0
          it 'is invalid' do expect(error_instance).to be_invalid end
          it count_errors do expect(error_instance.errors[attribute_name].size).to eq(error_count), "expected: #{error_count} error#{1!=error_count ? 's' : ''}\n     got: #{error_instance.errors[attribute_name].size} error#{1!=error_instance.errors[attribute_name].size ? 's' : ''}: #{error_instance.errors[attribute_name].map(&:inspect).join ', '}" end
        else
          it 'is valid' do expect(error_instance).to be_valid end
        end

      end
    end

  end

end



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

  chars.each do |c| attributes_collection[ { attribute_name => c                    } ] = 0 end if 1==minimum_length
  chars.each do |c| attributes_collection[ { attribute_name => c*(minimum_length-1) } ] = 1 end if minimum_length>1
  chars.each do |c| attributes_collection[ { attribute_name => c*minimum_length     } ] = 0 end
  chars.each do |c| attributes_collection[ { attribute_name => c*(minimum_length+1) } ] = 0 end if minimum_length<maximum_length
  chars.each do |c| attributes_collection[ { attribute_name => c*(maximum_length-1) } ] = 0 end
  chars.each do |c| attributes_collection[ { attribute_name => c*maximum_length     } ] = 0 end
  chars.each do |c| attributes_collection[ { attribute_name => c*(maximum_length+1) } ] = 1 end

  it_behaves_like 'validates', model_attributes, attribute_name, attributes_collection

end



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
