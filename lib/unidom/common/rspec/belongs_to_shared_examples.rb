shared_examples 'belongs_to' do |model_attributes, association_name, association_class, association_attributes|

  describe "##{association_name}: #{association_class.name}" do

    model_instance       = described_class.new        model_attributes
    association_instance = association_class.new      association_attributes
    association          = model_instance.association association_name.to_sym
    association_writable = association.class==ActiveRecord::Associations::BelongsToAssociation

    methods = [ association_name, "#{association_name}=" ]
    methods = methods+[ "build_#{association_name}", "create_#{association_name}", "create_#{association_name}!" ] if association_writable

    methods.each do |method|
      describe "##{method}" do

        it 'is responded to' do expect(model_instance).to respond_to(association_name.to_sym) end

        case method

          when "#{association_name}="
            it 'assigns association successfully' do
              model_instance.send "#{association_name}=".to_sym, association_instance
              expect(model_instance.send association_name.to_sym).to eq(association_instance)
            end

          when association_name
            it 'saves successfully' do
              model_instance.send "#{association_name}=".to_sym, association_instance
              expect(model_instance.save).to be_truthy
            end
        end

      end
    end

  end

end
