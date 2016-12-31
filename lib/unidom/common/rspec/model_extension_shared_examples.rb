shared_examples 'Unidom::Common::Concerns::ModelExtension' do |model_attributes|

  # scopes for the #id column

  describe '.included_by' do

    id = SecureRandom.uuid

    it_behaves_like 'scope', :included_by, [
      { attributes_collection: [ model_attributes.merge(id: id) ], count_diff: 1, args: [ id                        ] },
      { attributes_collection: [ model_attributes.merge(id: id) ], count_diff: 0, args: [ Unidom::Common::NULL_UUID ] }
    ]

  end

  describe '.excluded_by' do

    id = SecureRandom.uuid

    it_behaves_like 'scope', :excluded_by, [
      { attributes_collection: [ model_attributes.merge(id: id) ], count_diff: 0, args: [ id                        ] },
      { attributes_collection: [ model_attributes.merge(id: id) ], count_diff: 1, args: [ Unidom::Common::NULL_UUID ] }
    ]

  end

  # validations & scopes for the #state column

  describe '#state' do

    it 'column exists'           do expect(described_class.columns_hash['state']).to       be_present end
    it 'column length must be 1' do expect(described_class.columns_hash['state'].limit).to eq(1)      end

    it_behaves_like 'validates', model_attributes, :state,
      {             } => 0,
      { state: nil  } => 2,
      { state: ''   } => 2,
      { state: 'A'  } => 0,
      { state: 'AA' } => 1

  end

  describe '.transited_to' do

    it_behaves_like 'scope', :transited_to, [
      { attributes_collection: [ model_attributes                   ], count_diff: 1, args: [ 'C' ] },
      { attributes_collection: [ model_attributes                   ], count_diff: 0, args: [ 'A' ] },
      { attributes_collection: [ model_attributes.merge(state: 'A') ], count_diff: 0, args: [ 'C' ] },
      { attributes_collection: [ model_attributes.merge(state: 'A') ], count_diff: 1, args: [ 'A' ] }
    ]

  end

  # scopes for the #opened_at column & the #closed_at column

  describe '#opened_at' do
    it 'column exists' do expect(described_class.columns_hash['opened_at']).to be_present end
  end

  describe '#closed_at' do
    it 'column exists' do expect(described_class.columns_hash['closed_at']).to be_present end
  end

  describe '.valid_at' do

    opened_at = Time.utc described_class.columns_hash['opened_at'].default
    closed_at = Time.utc described_class.columns_hash['closed_at'].default

    it_behaves_like 'scope', :valid_at, [
      { attributes_collection: [ model_attributes ], count_diff: 1, args: [] },
      { attributes_collection: [ model_attributes ], count_diff: 0, args: [ { now: opened_at-1.second } ] },
      { attributes_collection: [ model_attributes ], count_diff: 1, args: [ { now: opened_at          } ] },
      { attributes_collection: [ model_attributes ], count_diff: 1, args: [ { now: opened_at+1.second } ] },
      { attributes_collection: [ model_attributes ], count_diff: 1, args: [ { now: closed_at-1.second } ] },
      { attributes_collection: [ model_attributes ], count_diff: 1, args: [ { now: closed_at          } ] },
      { attributes_collection: [ model_attributes ], count_diff: 0, args: [ { now: closed_at+1.second } ] }
    ]

    it_behaves_like 'scope', :valid_duration, [
      { attributes_collection: [ model_attributes ], count_diff: 0, args: [ opened_at-2.second..opened_at-1.second ] },
      { attributes_collection: [ model_attributes ], count_diff: 1, args: [ opened_at-1.second..closed_at-1.second ] },
      { attributes_collection: [ model_attributes ], count_diff: 1, args: [ opened_at-1.second..closed_at          ] },
      { attributes_collection: [ model_attributes ], count_diff: 1, args: [ opened_at-1.second..closed_at+1.second ] },
      { attributes_collection: [ model_attributes ], count_diff: 1, args: [ opened_at..closed_at-1.second          ] },
      { attributes_collection: [ model_attributes ], count_diff: 1, args: [ opened_at..closed_at                   ] },
      { attributes_collection: [ model_attributes ], count_diff: 1, args: [ opened_at..closed_at+1.second          ] },
      { attributes_collection: [ model_attributes ], count_diff: 0, args: [ opened_at+1.second..closed_at-1.second ] },
      { attributes_collection: [ model_attributes ], count_diff: 1, args: [ opened_at+1.second..closed_at          ] },
      { attributes_collection: [ model_attributes ], count_diff: 1, args: [ opened_at+1.second..closed_at+1.second ] },
      { attributes_collection: [ model_attributes ], count_diff: 0, args: [ closed_at+1.second..closed_at+2.second ] }
    ]

  end

  # scopes for the #defunct column

  describe '#defunct' do
    it 'column exists' do expect(described_class.columns_hash['defunct']).to be_present end
  end

  describe '.alive' do

    it_behaves_like 'scope', :alive, [
      { attributes_collection: [ model_attributes                      ], count_diff: 1, args: [] },
      { attributes_collection: [ model_attributes                      ], count_diff: 1, args: [ { living: true  } ] },
      { attributes_collection: [ model_attributes                      ], count_diff: 0, args: [ { living: false } ] },
      { attributes_collection: [ model_attributes.merge(defunct: true) ], count_diff: 0, args: [] },
      { attributes_collection: [ model_attributes.merge(defunct: true) ], count_diff: 0, args: [ { living: true  } ] },
      { attributes_collection: [ model_attributes.merge(defunct: true) ], count_diff: 1, args: [ { living: false } ] }
    ]

  end

  describe '.dead' do

    it_behaves_like 'scope', :dead, [
      { attributes_collection: [ model_attributes                      ], count_diff: 0, args: [] },
      { attributes_collection: [ model_attributes                      ], count_diff: 0, args: [ { defunct: true  } ] },
      { attributes_collection: [ model_attributes                      ], count_diff: 1, args: [ { defunct: false } ] },
      { attributes_collection: [ model_attributes.merge(defunct: true) ], count_diff: 1, args: [] },
      { attributes_collection: [ model_attributes.merge(defunct: true) ], count_diff: 1, args: [ { defunct: true  } ] },
      { attributes_collection: [ model_attributes.merge(defunct: true) ], count_diff: 0, args: [ { defunct: false } ] }
    ]

  end

  # validations & scopes for the #ordinal column

  ordinal_column = described_class.columns_hash['ordinal']

  if ordinal_column.present?&&:integer==ordinal_column.type

    it_behaves_like 'validates', model_attributes, :ordinal,
      {               } => 3,
      { ordinal: nil  } => 3,
      { ordinal: ''   } => 3,
      { ordinal: 'A'  } => 2,
      { ordinal: 'AA' } => 2,
      { ordinal: '0'  } => 1,
      { ordinal: 0    } => 1,
      { ordinal: -1   } => 1,
      { ordinal: -11  } => 1,
      { ordinal: 1.1  } => 1,
      { ordinal: '1'  } => 0,
      { ordinal: '11' } => 0,
      { ordinal: 1    } => 0,
      { ordinal: 11   } => 0

    it_behaves_like 'scope', :ordinal_is, [
      { attributes_collection: [ model_attributes ], count_diff: 0, args: [ model_attributes[:ordinal]-1 ] },
      { attributes_collection: [ model_attributes ], count_diff: 1, args: [ model_attributes[:ordinal]   ] },
      { attributes_collection: [ model_attributes ], count_diff: 0, args: [ model_attributes[:ordinal]+1 ] }
    ]

  end

  # validations & scopes for the #uuid column

  uuid_column = described_class.columns_hash['uuid']

  if uuid_column.present?

    it_behaves_like 'validates', model_attributes, :uuid,
      {            } => 2,
      { uuid: nil  } => 2,
      { uuid: ''   } => 2,
      { uuid: 'A'  } => 1,
      { uuid: 'AA' } => 1,
      { uuid: Unidom::Common::NULL_UUID[0..34] } => 1,
      { uuid: Unidom::Common::NULL_UUID        } => 1,
      { uuid: "#{Unidom::Common::NULL_UUID}1"  } => 1

    it_behaves_like 'scope', :uuid_is, [
      { attributes_collection: [ model_attributes ], count_diff: 0, args: [ model_attributes[:uuid] ] },
      { attributes_collection: [ model_attributes ], count_diff: 1, args: [ model_attributes[:uuid] ] },
      { attributes_collection: [ model_attributes ], count_diff: 0, args: [ model_attributes[:uuid] ] }
    ]

  end

  # scopes for the #elemental column

  elemental_column = described_class.columns_hash['elemental']

  if elemental_column.present?

    it_behaves_like 'scope', :primary, [
      { attributes_collection: [ model_attributes.merge(elemental: true ) ], count_diff: 1, args: [ true  ] },
      { attributes_collection: [ model_attributes.merge(elemental: true ) ], count_diff: 0, args: [ false ] },
      { attributes_collection: [ model_attributes.merge(elemental: false) ], count_diff: 0, args: [ true  ] },
      { attributes_collection: [ model_attributes.merge(elemental: false) ], count_diff: 1, args: [ false ] }
    ]

  end

  # validations & scopes for the #grade column

  grade_column = described_class.columns_hash['grade']

  if grade_column.present?&&:integer==grade_column.type

    it_behaves_like 'validates', model_attributes, :grade,
      #{             } => 3,
      { grade: nil  } => 2,
      { grade: ''   } => 2,
      { grade: 'A'  } => 1,
      { grade: 'AA' } => 1,
      { grade: -1   } => 1,
      { grade: -11  } => 1,
      { grade: 1.1  } => 1,
      { grade: '0'  } => 0,
      { grade: '1'  } => 0,
      { grade: '11' } => 0,
      { grade: 0    } => 0,
      { grade: 1    } => 0,
      { grade: 11   } => 0

    it_behaves_like 'scope', :grade_is, [
      { attributes_collection: [ model_attributes ], count_diff: 0, args: [ model_attributes[:grade]-1 ] },
      { attributes_collection: [ model_attributes ], count_diff: 1, args: [ model_attributes[:grade]   ] },
      { attributes_collection: [ model_attributes ], count_diff: 0, args: [ model_attributes[:grade]+1 ] }
    ]

    it_behaves_like 'scope', :grade_higher_than, [
      { attributes_collection: [ model_attributes ], count_diff: 1, args: [ model_attributes[:grade]-1 ] },
      { attributes_collection: [ model_attributes ], count_diff: 0, args: [ model_attributes[:grade]   ] },
      { attributes_collection: [ model_attributes ], count_diff: 0, args: [ model_attributes[:grade]+1 ] }
    ]

    it_behaves_like 'scope', :grade_lower_than, [
      { attributes_collection: [ model_attributes ], count_diff: 0, args: [ model_attributes[:grade]-1 ] },
      { attributes_collection: [ model_attributes ], count_diff: 0, args: [ model_attributes[:grade]   ] },
      { attributes_collection: [ model_attributes ], count_diff: 1, args: [ model_attributes[:grade]+1 ] }
    ]

  end

  # validations & scopes for the #priority column

  priority_column = described_class.columns_hash['priority']

  if priority_column.present?&&:integer==priority_column.type

    it_behaves_like 'validates', model_attributes, :priority,
      #{                } => 3,
      { priority: nil  } => 2,
      { priority: ''   } => 2,
      { priority: 'A'  } => 1,
      { priority: 'AA' } => 1,
      { priority: -1   } => 1,
      { priority: -11  } => 1,
      { priority: 1.1  } => 1,
      { priority: '0'  } => 0,
      { priority: '1'  } => 0,
      { priority: '11' } => 0,
      { priority: 0    } => 0,
      { priority: 1    } => 0,
      { priority: 11   } => 0

    it_behaves_like 'scope', :priority_is, [
      { attributes_collection: [ model_attributes ], count_diff: 0, args: [ model_attributes[:priority]-1 ] },
      { attributes_collection: [ model_attributes ], count_diff: 1, args: [ model_attributes[:priority]   ] },
      { attributes_collection: [ model_attributes ], count_diff: 0, args: [ model_attributes[:priority]+1 ] }
    ]

    it_behaves_like 'scope', :priority_higher_than, [
      { attributes_collection: [ model_attributes ], count_diff: 1, args: [ model_attributes[:priority]-1 ] },
      { attributes_collection: [ model_attributes ], count_diff: 0, args: [ model_attributes[:priority]   ] },
      { attributes_collection: [ model_attributes ], count_diff: 0, args: [ model_attributes[:priority]+1 ] }
    ]

    it_behaves_like 'scope', :priority_lower_than, [
      { attributes_collection: [ model_attributes ], count_diff: 0, args: [ model_attributes[:priority]-1 ] },
      { attributes_collection: [ model_attributes ], count_diff: 0, args: [ model_attributes[:priority]   ] },
      { attributes_collection: [ model_attributes ], count_diff: 1, args: [ model_attributes[:priority]+1 ] }
    ]

  end

  # scopes for the #slug column

  slug_column = described_class.columns_hash['slug']

  if slug_column.present?

    slug = SecureRandom.uuid+SecureRandom.uuid

    it_behaves_like 'scope', :slug_is, [
      #{ attributes_collection: [ model_attributes.merge(slug: slug) ], count_diff: 1, args: [ slug        ] },
      { attributes_collection: [ model_attributes.merge(slug: slug) ], count_diff: 0, args: [ "#{slug}1"  ] },
      { attributes_collection: [ model_attributes.merge(slug: slug) ], count_diff: 0, args: [ slug[0..34] ] }
    ]

  end

  # Active Record default scopes

  context '.scope' do

    it_behaves_like 'scope', :all, [
      { attributes_collection: [ model_attributes                            ], count_diff: 1, args: [] },
      { attributes_collection: [ model_attributes.merge(defunct:   true)     ], count_diff: 1, args: [] },
      { attributes_collection: [ model_attributes.merge(closed_at: Time.now) ], count_diff: 1, args: [] }
    ]

    it_behaves_like 'scope', :none, [
      { attributes_collection: [ model_attributes                            ], count_diff: 0, args: [] },
      { attributes_collection: [ model_attributes.merge(defunct:   true)     ], count_diff: 0, args: [] },
      { attributes_collection: [ model_attributes.merge(closed_at: Time.now) ], count_diff: 0, args: [] }
    ]

  end

end
