shared_examples 'scope' do |scope_name, fixtures|

  describe ".#{scope_name}" do
    it 'exists' do expect(described_class).to respond_to(scope_name.to_sym) end
  end

  fixtures.select { |fixture| 'E'!=fixture[:count_diff] } .each do |fixture|
    describe ".#{scope_name}(#{fixture[:args].blank? ? '' : (fixture[:args].map &:inspect).join(', ')})" do
      before :each do
        @count = fixture[:args].present? ? described_class.send(scope_name, *fixture[:args]).count : described_class.send(scope_name).count
        @model_instances = []
        fixture[:attributes_collection].each do |attributes| @model_instances << (described_class.create! attributes) end
      end
      after :each do
        @count = 0
        @model_instances.each do |model_instance| model_instance.destroy end if @model_instances.present?
      end
      it "has #{fixture[:count_diff]} added" do
        actual_count = fixture[:args].present? ? described_class.send(scope_name, *fixture[:args]).count : described_class.send(scope_name).count
        expect(actual_count).to eq(fixture[:count_diff]+@count)
      end
    end
  end

  fixtures.select { |fixture| 'E'==fixture[:count_diff] } .each do |fixture|
    describe ".#{scope_name}(#{fixture[:args].blank? ? '' : (fixture[:args].map &:inspect).join(', ')}) denies the parameters" do
      expect { fixture[:args].present? ? described_class.all.send(scope_name, *fixture[:args]).count : described_class.all.send(scope_name).count }.to raise_error
    end
  end

end



shared_examples 'monomorphic scope' do |model_attributes, scope_name, association_name|

  attribute_name       = :"#{association_name}_id"
  reflection           = described_class.reflections[association_name.to_s]
  association_class    = reflection.options[:class_name].safe_constantize
  association_id       = model_attributes[attribute_name]
  association_instance = association_class.new id: association_id
  variant_attribtues   = model_attributes.merge attribute_name => Unidom::Common::NULL_UUID

  it_behaves_like 'scope', scope_name, [
    { attributes_collection: [ model_attributes   ], count_diff: 1, args: [ association_id       ] },
    { attributes_collection: [ model_attributes   ], count_diff: 1, args: [ association_instance ] },
    { attributes_collection: [ variant_attribtues ], count_diff: 0, args: [ association_id       ] },
    { attributes_collection: [ variant_attribtues ], count_diff: 0, args: [ association_instance ] }
  ]

end



shared_examples 'polymorphic scope' do |model_attributes, scope_name, association_name, association_class_list|

  attribute_name = :"#{association_name}_id"
  reflection     = described_class.reflections[association_name.to_s]
  association_id = model_attributes[attribute_name]

  association_class_list.each do |association_class|

    association_instance = association_class.new id: association_id
    variant_instance     = association_class.new id: Unidom::Common::NULL_UUID
    model_attributes     = model_attributes.merge :"#{association_name}_type" => association_class.name
    variant_attribtues   = model_attributes.merge attribute_name => Unidom::Common::NULL_UUID

    it_behaves_like 'scope', scope_name, [
      { attributes_collection: [ model_attributes   ], count_diff: 1, args: [ association_instance ] },
      { attributes_collection: [ model_attributes   ], count_diff: 0, args: [ variant_instance     ] },
      { attributes_collection: [ variant_attribtues ], count_diff: 0, args: [ association_instance ] },
      { attributes_collection: [ variant_attribtues ], count_diff: 1, args: [ variant_instance     ] }
    ]

  end

end
