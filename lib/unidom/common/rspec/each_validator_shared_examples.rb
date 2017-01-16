shared_examples 'ActiveModel::EachValidator' do |valid_values, invalid_values|

  mock_model_class_name = "#{described_class.name}MockModel"
  mock_model_namespace  = mock_model_class_name.deconstantize.constantize
  mock_model_name       = mock_model_class_name.demodulize
  validator_name        = described_class.to_s.underscore.chomp('_validator').to_sym
  mock_model_namespace.const_set mock_model_name, Class.new
  class_instance        = mock_model_namespace.const_get mock_model_name

  class_instance.class_eval do
    include       ActiveModel::Model
    attr_accessor :mock_attribute
    validates     :mock_attribute, :allow_blank => true, validator_name => true
  end

  subject(:model) do class_instance.new end

  describe '#validate_each' do

    valid_values.each do |value|
      it "should validate valid #{value}" do
        model.mock_attribute = value
        expect(model.valid?).to be_truthy
      end
    end

    invalid_values.each do |value|
      it "should validate invalid #{value}" do
        model.mock_attribute = value
        expect(model.valid?).to be_falsey
      end
    end

  end

end
