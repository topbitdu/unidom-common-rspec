shared_examples 'assert_present!' do |model, method_name, arguments, required_argument_names|

  context "##{method_name}" do

    # argument
    required_argument_names.each do |required_argument_name|
      next unless required_argument_name.is_a? Hash #Numeric
      it "should reject the #{required_argument_name.values.first} argument = nil" do
        actual_arguments = arguments.dup
        actual_arguments[required_argument_name.keys.first] = nil
        expect { model.send method_name, *actual_arguments }.
          to raise_error(ArgumentError, Regexp.new("\s+#{required_argument_name.values.first}\s+"))
      end
    end

    # keywords argument
    required_argument_names.each do |required_argument_name|
      next unless required_argument_name.is_a? Symbol
      it "should reject the #{required_argument_name} argument = nil" do
        actual_arguments = arguments.dup
        actual_arguments[actual_arguments.length-1] = arguments.last.dup
        actual_arguments.last[required_argument_name] = nil
        expect { model.send method_name, *actual_arguments }.
          to raise_error(ArgumentError, Regexp.new("\s+#{required_argument_name}\s+"))
      end
    end

  end

end
