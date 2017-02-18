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
