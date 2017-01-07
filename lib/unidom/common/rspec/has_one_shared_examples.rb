shared_examples 'has_one' do |model_attributes, association_name, association_class, association_attributes|

  describe "##{association_name}" do

    model_instance       = described_class.new   model_attributes
    association_instance = association_class.new association_attributes
    reflection           = model_instance.association(association_name.to_sym).reflection
    association_writable = reflection.class==ActiveRecord::Reflection::HasOneReflection
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
          let :created_association_instance          do subject.send method_name, association_attributes                                 end
          it "should be a #{association_class.name}" do expect(created_association_instance).to     be_an_instance_of(association_class) end
          it 'should not be a new record'            do expect(created_association_instance).to_not be_new_record                        end
        end
      end

      # Pending
=begin
      context "#create_#{association_name}" do
        subject do described_class.create! model_attributes end
        it 'should return false with {}' do
          expect { subject.send "create_#{association_name}", {} }.to be_falsey
        end
      end

      context "#create_#{association_name}!" do
        subject do described_class.create! model_attributes end
        it 'should raise error with {}' do
          expect { subject.send "create_#{association_name}!", {} }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end
=end

    end

  end

end
