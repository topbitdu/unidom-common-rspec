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
