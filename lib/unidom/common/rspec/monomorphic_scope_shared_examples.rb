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
