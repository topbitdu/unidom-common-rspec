##
# The ``belongs_to :associated_model`` macro uses the ActiveRecord::Associations::BelongsToAssociation.
# This association generates the following 5 methods:
# #associated_model, #associated_model=, #build_associated_model, #create_associated_model, and #create_associated_model!.
#
# The ``belongs_to :associated_model, polymorphic: true`` macro uses the ActiveRecord::Associations::BelongsToPolymorphicAssociation.
# This association generates the 2 methods: #associated_model and #associated_model=.
# It does not generate the 3 methods: #build_associated_model, #create_associated_model, and #create_associated_model!

shared_examples 'belongs_to' do |model_attributes, association_name, association_class, association_attributes|

  describe "##{association_name}: #{association_class.name}" do

    model_instance       = described_class.new        model_attributes
    association_instance = association_class.new      association_attributes
    association          = model_instance.association association_name.to_sym
    association_writable = [ ActiveRecord::Associations::BelongsToAssociation ].include? association.class

    gained_methods = [ association_name.to_sym ]
    gained_methods << [ :"#{association_name}=", :"build_#{association_name}", :"create_#{association_name}", :"create_#{association_name}!" ] if association_writable
    gained_methods.flatten!

    subject do described_class.new model_attributes end

    gained_methods.each do |method|
      it do is_expected.to respond_to(method.to_sym) end
    end

    describe "#{association_name}=" do
      before :each do
        subject.send "#{association_name}=", nil
        subject.send "#{association_name}=", association_instance
      end
      it 'should return the assigned association' do
        expect(subject.send association_name.to_sym).to eq(association_instance)
      end
    end

    if association_writable

      context "#build_#{association_name}" do
        let :association_instance_1                 do subject.send                          "build_#{association_name}" end
        let :association_instance_2                 do subject.send                          "build_#{association_name}" end
        it  "should be a #{association_class.name}" do expect(association_instance_1).to     be_a(association_class)     end
        it  'should not be a new record'            do expect(association_instance_1).to     be_new_record               end
        it  "should be a #{association_class.name}" do expect(association_instance_2).to     be_a(association_class)     end
        it  'should not be a new record'            do expect(association_instance_2).to     be_new_record               end
        it  'should not be identical'               do expect(association_instance_1).to_not be(association_instance_2)  end
      end

      [ "create_#{association_name}", "create_#{association_name}!" ].each do |method_name|
        context "##{method_name}" do
          subject do described_class.create! model_attributes end
          let :created_association_instance do subject.send method_name, association_attributes end
          it "should be a #{association_class.name}" do expect(created_association_instance).to     be_an_instance_of(association_class) end
          it 'should not be a new record'            do expect(created_association_instance).to_not be_new_record                        end
        end
      end

    end

  end

end
