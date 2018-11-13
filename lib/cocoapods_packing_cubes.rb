# frozen_string_literal: true

module CocoaPodsPackingCubes
  def self.warn_for_outdated_cocoapods
    @warn_for_outdated_cocoapods ||= begin
      Pod::UI.warn '[cocoapods-packing-cubes] Pod::Target::BuildType must be defined, either:',
                   ['Update to CocoaPods master or 1.6.0+', 'Downgrade to packing cubes < 0.3']
      true
    end
  end

  module PodTargetMixin
    def initialize(*)
      super

      return CocoaPodsPackingCubes.warn_for_outdated_cocoapods unless defined?(::Pod::Target::BuildType) && !packing_cube.empty?
      compute_packing_cube_override_type
      compute_packing_cube_override_defines_module
    end

    def packing_cube
      @packing_cube ||= podfile.plugins.fetch('cocoapods-packing-cubes', {}).fetch(pod_name, {})
    rescue
      raise ::Pod::Informative, 'The cocoapods-packing-cubes plugin requires a hash of options.'
    end

    def compute_packing_cube_override_type
      return if packing_cube.empty?

      linkage = packing_cube.fetch('linkage') { build_type.linkage }.to_sym
      packaging = packing_cube.fetch('packaging') { build_type.packaging }.to_sym

      @build_type = ::Pod::Target::BuildType.new(linkage: linkage, packaging: packaging)
    end

    def compute_packing_cube_override_defines_module
      return unless packing_cube.key?('defines_module')

      @defines_module = packing_cube['defines_module']
    end
  end
end

module Pod
  class PodTarget
    prepend ::CocoaPodsPackingCubes::PodTargetMixin
  end
end
