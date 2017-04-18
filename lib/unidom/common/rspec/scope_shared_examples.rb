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
