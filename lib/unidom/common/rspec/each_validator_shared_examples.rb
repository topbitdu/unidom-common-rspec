shared_examples 'ActiveModel::EachValidator' do |validator, valid_values, invalid_values|

  class EachValidatorMockModel

    include ActiveModel::Model

    attr_accessor :attribute

    #validates :attribute, :allow_blank => true, validator.to_sym => true

  end

  EachValidatorMockModel.validates :attribute, :allow_blank => true, validator.to_sym => true

  subject(:model) do EachValidatorMockModel.new end

  describe '#validate_each' do

    valid_values.each do |value|
      it "should validate valid #{value}" do
        model.attribute = value
        expect(model.valid?).to be_truthy
      end
    end

    invalid_values.each do |value|
      it "should validate invalid #{value}" do
        model.attribute = value
        expect(model.valid?).to be_falsey
      end
    end

  end

end
