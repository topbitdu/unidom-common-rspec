shared_examples 'has_one' do |model_attributes, association_name, association_class, association_attributes|

  describe "##{association_name}" do

    model_instance       = described_class.new   model_attributes
    association_instance = association_class.new association_attributes
    reflection           = model_instance.association(association_name.to_sym).reflection
    association_writable = reflection.class==ActiveRecord::Reflection::HasOneReflection
    gained_methods = [ association_name.to_sym ]
    gained_methods << [ :"#{association_name}=", :"build_#{association_name}", :"create_#{association_name}", :"create_#{association_name}!" ] if association_writable
    gained_methods.flatten!

    #subject :model_instance       do described_class.new   model_attributes                         end
    #let     :association_instance do association_class.new association_attributes                   end
    #let     :reflection           do model_instance.association(association_name.to_sym).reflection end
    #let     :association_writable do reflection.class==ActiveRecord::Reflection::HasOneReflection   end

    before :each do
      subject do
        described_class.new model_attributes
      end
    end

    after :each do
      subject do
        nil
      end
    end

    #describe do
      gained_methods.each do |method|
        it do is_expected.to respond_to(method.to_sym) end
      end
    #end

    it 'assigns association successfully' do
      model_instance.send "#{association_name}=", association_instance
      expect(model_instance.send association_name.to_sym).to eq(association_instance)
    end
=begin
    if association_writable
      context do
      it 'builds an association instance' do
        item_1 = model_instance.send "build_#{association_name}"
        expect(item_1).to     be_an_instance_of(association_class)
        expect(item_1).to     be_new_record
        item_2 = model_instance.send "build_#{association_name}"
        expect(item_2).to     be_an_instance_of(association_class)
        expect(item_2).to     be_new_record
        expect(item_1).to_not be(item_2)
      end
      end
      context do
        before :each do
          puts '---- before each...'
          subject do described_class.new   model_attributes                         end
            puts "----!!!! subject = #{subject.inspect}"
            puts "subject.clear_text = #{subject.clear_text}"
            puts "model_attributes = #{model_attributes.inspect}"
        end
      it 'creates an association instance' do
subject do described_class.new   model_attributes                         end
subject.valid?
        puts "---- errors = #{subject.errors.inspect}"
puts "---- **** subject = #{subject.inspect}"

        expect(subject.save).to be_truthy

        created_association_instance = subject.send "create_#{association_name}", association_attributes
        expect(created_association_instance).to     be_an_instance_of(association_class)
        expect(created_association_instance).to_not be_new_record
      end
      end
    end
=end
=begin
    [ association_name, "#{association_name}=".to_sym, "build_#{association_name}".to_sym, "create_#{association_name}".to_sym ].each do |method|
      association_writable = #model_instance.reflections[association_name].class==::ActiveRecord::Reflection::AssociationReflection
        #model_instance._reflections[association_name].class==ActiveRecord::Reflection::AssociationReflection
        model_instance.association(association_name)._reflections.class==ActiveRecord::Reflection::AssociationReflection
      describe ".#{method}" do

        if association_writable
          it 'is responded to' do expect(model_instance).to respond_to(method.to_sym) end
        else
          unless [ "build_#{association_name}".to_sym, "create_#{association_name}".to_sym ].include? method
            it 'is responded to' do expect(model_instance).to respond_to(method.to_sym) end
          end
        end

        case method
          when "build_#{association_name}".to_sym
            if association_writable
              it 'builds an association instance' do
                item_1 = model_instance.send method
                expect(item_1).to     be_an_instance_of(association_class)
                expect(item_1).to     be_new_record
                item_2 = model_instance.send method
                expect(item_2).to     be_an_instance_of(association_class)
                expect(item_2).to     be_new_record
                expect(item_1).to_not be(item_2)
              end
            end
          when "create_#{association_name}".to_sym
            if association_writable
              it 'creates an association instance' do
                pending 'Can not create association instance.'
                created_association_instance = model_instance.send method, association_attributes
                expect(created_association_instance).to     be_an_instance_of(association_class)
                expect(created_association_instance).to_not be_new_record
              end
            end
          when "#{association_name}=".to_sym
            it 'assigns association successfully' do
              model_instance.send method, association_instance
              expect(model_instance.send association_name.to_sym).to eq(association_instance)
            end
        end
      end
    end
=end

  end

end
