# frozen_string_literal: true

require 'cocoapods_packing_cubes'
require 'tmpdir'

RSpec.describe CocoaPodsPackingCubes do
  describe described_class::Type do
    let(:linkage) { :dynamic }
    let(:packaging) { :framework }

    subject(:type) { described_class.new(linkage: linkage, packaging: packaging) }

    context 'with an invalid linkage' do
      let(:linkage) { :foo }
      it { expect { subject }.to raise_error(Exception) }
    end

    context 'with an invalid packaging' do
      let(:packaging) { :foo }
      it { expect { subject }.to raise_error(Exception) }
    end
  end

  describe described_class::PodTargetMixin do
    let(:pod_name) { 'FooBar' }
    let(:plugin_options) { {} }
    let(:podfile) { Struct.new(:plugins).new('cocoapods-packing-cubes' => plugin_options) }
    let(:root_spec_static_framework) { false }
    let(:root_spec) { Struct.new(:static_framework).new(root_spec_static_framework) }
    let(:host_requires_frameworks) { false }

    let(:described_class) do
      mixin = super()
      Class.new do
        prepend mixin

        attr_reader :podfile, :type, :defines_module, :pod_name, :host_requires_frameworks, :root_spec
        alias_method :host_requires_frameworks?, :host_requires_frameworks
        def initialize(podfile, pod_name, host_requires_frameworks, root_spec)
          @podfile = podfile
          @pod_name = pod_name
          @host_requires_frameworks = host_requires_frameworks
          @root_spec = root_spec
        end
      end
    end

    let(:static_library) { CocoaPodsPackingCubes::Type.new(linkage: :static, packaging: :library) }
    let(:static_framework) { CocoaPodsPackingCubes::Type.new(linkage: :static, packaging: :framework) }
    let(:dynamic_framework) { CocoaPodsPackingCubes::Type.new(linkage: :dynamic, packaging: :framework) }

    subject(:pod_target) { described_class.new(podfile, pod_name, host_requires_frameworks, root_spec) }

    it 'has a packing_cube' do
      expect(pod_target.packing_cube).to eq({})
    end

    it 'has a type' do
      expect(pod_target.type).to eq static_library
    end

    context 'when host_requires_frameworks' do
      let(:host_requires_frameworks) { true }

      it 'defaults to a dynamic framework' do
        expect(pod_target.type).to eq dynamic_framework
      end

      context 'and linkage is static' do
        let(:plugin_options) { { pod_name => { 'linkage' => :static } } }

        it 'is a static framework' do
          expect(pod_target.type).to eq static_framework
        end
      end
    end
  end
end
