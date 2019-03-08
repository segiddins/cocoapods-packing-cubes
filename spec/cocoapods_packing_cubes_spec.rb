# frozen_string_literal: true

require 'cocoapods_packing_cubes'
require 'tmpdir'

RSpec.describe CocoaPodsPackingCubes do
  describe described_class::PodTargetMixin do
    Spec = Struct.new(:static_framework) do
      def root
        self
      end
    end

    let(:pod_name) { 'FooBar' }
    let(:plugin_options) { {} }
    let(:podfile) { Struct.new(:plugins).new('cocoapods-packing-cubes' => plugin_options) }
    let(:root_spec_static_framework) { false }
    let(:root_spec) { Spec.new(root_spec_static_framework) }
    let(:host_requires_frameworks) { false }

    let(:described_class) do
      mixin = super()
      Class.new do
        prepend mixin

        attr_reader :podfile, :type, :defines_module, :pod_name, :host_requires_frameworks, :root_spec, :build_type
        alias_method :host_requires_frameworks?, :host_requires_frameworks
        def initialize(podfile, pod_name, host_requires_frameworks, root_spec)
          @podfile = podfile
          @pod_name = pod_name
          @host_requires_frameworks = host_requires_frameworks
          @build_type = ::Pod::Target::BuildType.infer_from_spec(root_spec, host_requires_frameworks: host_requires_frameworks)
          @root_spec = root_spec
        end
      end
    end

    let(:static_library) { ::Pod::Target::BuildType.static_library }
    let(:static_framework) { ::Pod::Target::BuildType.static_framework }
    let(:dynamic_library) { ::Pod::Target::BuildType.dynamic_library }
    let(:dynamic_framework) { ::Pod::Target::BuildType.dynamic_framework }

    subject(:pod_target) { described_class.new(podfile, pod_name, host_requires_frameworks, root_spec) }

    it 'has a packing_cube' do
      expect(pod_target.packing_cube).to eq({})
    end

    it 'has a build type' do
      expect(pod_target.build_type).to eq static_library
    end

    context 'when host_requires_frameworks' do
      let(:host_requires_frameworks) { true }

      it 'defaults to a dynamic framework' do
        expect(pod_target.build_type).to eq dynamic_framework
      end

      context 'and linkage is static' do
        let(:plugin_options) { { pod_name => { 'linkage' => :static } } }

        it 'is a static framework' do
          expect(pod_target.build_type).to eq static_framework
        end
      end
    end

    context 'when * is specified' do
      let(:plugin_options) { { '*' => { 'linkage' => :static, 'packaging' => :framework } } }

      it 'uses the default' do
        expect(pod_target.build_type).to eq static_framework
      end

      context 'and the per-pod configuration is specified' do
        let(:plugin_options) { super().merge(pod_name => { 'linkage' => 'dynamic' }) }
        it 'uses the per-pod configuration' do
          expect(pod_target.build_type).to eq dynamic_library
        end
      end
    end
  end
end
