shared_examples 'has_many' do |model_attributes, collection_name, item_class, item_attributes_collection|

  describe "##{collection_name}" do

    model_instance        = described_class.new model_attributes
    collection            = model_instance.send collection_name.to_sym
    item_instances        = item_attributes_collection.map do |item_attributes| item_class.new item_attributes end
    macro_definition      = model_instance.association collection_name.to_sym
    being_through         = macro_definition.is_a? ActiveRecord::Associations::ThroughAssociation
    reflection            = macro_definition.reflection
    association_readonly  = reflection.nested?
    #association_immutable = reflection.source_reflection.blank? ? false : (:belongs_to != reflection.source_reflection.macro)
    association_immutable = reflection.source_reflection.blank? ? false : being_through&&![ :belongs_to ].include?(reflection.source_reflection.macro)

    #[ collection_name, "#{collection_name}=", "#{collection_name.to_s.singularize}_ids", "#{collection_name.to_s.singularize}_ids=" ].each do |method|
    #  describe "##{method}" do
    #    it 'is responded to' do expect(model_instance).to respond_to(method.to_sym) end
    #  end
    #end

    %w{ << push concat build create create! size length count sum where empty? clear delete delete_all destroy destroy_all find exists? uniq reset }.each do |method|

      describe "##{method}" do

        before :each do collection.clear if collection.present? end
        after  :each do collection.clear if collection.present? end

        #it 'is responded to' do expect(collection).to respond_to(method.to_sym) end

        case method

          when '<<'
            if association_readonly || association_immutable
            #if association_immutable
              it 'nested association can not build' do
                error_class = association_readonly ? ActiveRecord::HasManyThroughNestedAssociationsAreReadonly : ActiveRecord::HasManyThroughCantAssociateThroughHasOneOrManyReflection
                expect { item_instances.each do |item_instance| collection << item_instance end }.to raise_error(error_class)
              end
            else
              it 'adds items' do
                expect(collection.size).to eq(0)
                item_instances.each       do |item_instance| collection << item_instance                            end
                item_instances.each_index do |index|         expect(collection[index]).to eq(item_instances[index]) end
                expect(collection.size).to eq(item_instances.size)
              end
            end

=begin
          when 'build'
            if association_readonly #or association_immutable
              it 'nested association can not build' do
                error_class = association_readonly ? ActiveRecord::HasManyThroughNestedAssociationsAreReadonly : ActiveRecord::HasManyThroughCantAssociateThroughHasOneOrManyReflection
                expect { collection.build }.to raise_error(error_class)
              end
            else
              it 'builds an item instance' do
                item_1 = collection.build
                expect(item_1).to     be_an_instance_of(item_class)
                expect(item_1).to     be_new_record
                item_2 = collection.build
                expect(item_2).to     be_an_instance_of(item_class)
                expect(item_2).to     be_new_record
                expect(item_1).to_not be(item_2)
              end
            end
=end

        end

      end
    end

    subject do described_class.new model_attributes end

    [ collection_name, "#{collection_name}=", "#{collection_name.to_s.singularize}_ids", "#{collection_name.to_s.singularize}_ids=" ].each do |method_name|
      it do is_expected.to respond_to(method_name.to_sym) end
    end

    %w{ << push concat build create create! size length count sum where empty? clear delete delete_all destroy destroy_all find exists? uniq reset }.each do |method_name|
      it "should respond to ##{collection_name}##{method_name}" do
        expect(subject.send collection_name).to respond_to(method_name.to_sym)
      end
    end

    describe "##{collection_name}#build" do
      if association_readonly
        it 'nested association can not build' do
          error_class = association_readonly ? ActiveRecord::HasManyThroughNestedAssociationsAreReadonly : ActiveRecord::HasManyThroughCantAssociateThroughHasOneOrManyReflection
          expect { collection.build }.to raise_error(error_class)
        end
      else
        let :item_1                          do collection.build                       end
        let :item_2                          do collection.build                       end
        it  "should be a #{item_class.name}" do expect(item_1).to     be_a(item_class) end
        it  'should not be a new record'     do expect(item_1).to     be_new_record    end
        it  "should be a #{item_class.name}" do expect(item_2).to     be_a(item_class) end
        it  'should not be a new record'     do expect(item_2).to     be_new_record    end
        it  'should not be identical'        do expect(item_1).to_not be(item_2)       end
      end
    end

    %w{ create create! }.each do |method_name|
      context "##{collection_name}##{method_name}" do
        subject do described_class.create! model_attributes end
        let :created_item_instance          do subject.send(collection_name).send   method_name, item_attributes_collection.first end
        it "should be a #{item_class.name}" do expect(created_item_instance).to     be_a(item_class)                              end
        it 'should not be a new record'     do expect(created_item_instance).to_not be_new_record                                 end
      end
    end

  end

end
