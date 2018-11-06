# frozen_string_literal: true

module CocoaPodsPackingCubes
  if defined?(::Pod::Target::Type)
    Type = ::Pod::Target::Type
    NATIVE_TYPE_SUPPORT = true
  else
    class Type
      def initialize(linkage: :static, packaging: :library)
        @linkage = linkage
        @packaging = packaging

        case [linkage, packaging]
        when %i[static library], %i[static framework], %i[dynamic framework]
          # ok
          nil
        else
          raise ::Pod::Informative, "Unsupported target build type: #{inspect}"
        end
      end

      %i[static dynamic].each_with_index do |linkage, index|
        define_method("#{linkage}?") { linkage == @linkage }
        %i[library framework].each do |packaging|
          if index.zero?
            define_method("#{packaging}?") { packaging == @packaging }
          end

          define_method("#{linkage}_#{packaging}?") do
            linkage == @linkage && packaging == @packaging
          end
        end
      end
    end
    NATIVE_TYPE_SUPPORT = false
  end

  module PodTargetMixin
    attr_reader :type

    def initialize(*)
      super

      compute_packing_cube_override_type
      compute_packing_cube_override_defines_module
    end

    def packing_cube
      @packing_cube ||= podfile.plugins.fetch('cocoapods-packing-cubes', {}).fetch(pod_name, {})
    rescue
      raise ::Pod::Informative, 'The cocoapods-packing-cubes plugin requires a hash of option.'
    end

    def compute_packing_cube_override_type
      packaging = packing_cube.fetch('packaging') do
        host_requires_frameworks? ? :framework : :library
      end.to_sym
      linkage = packing_cube.fetch('linkage') do
        !host_requires_frameworks? || root_spec.static_framework ? :static : :dynamic
      end.to_sym

      @type = ::CocoaPodsPackingCubes::Type.new(linkage: linkage, packaging: packaging)
    end

    def compute_packing_cube_override_defines_module
      defines_module = packing_cube.fetch('defines_module')
      @defines_module = defines_module unless defines_module.nil?
    end

    def static_framework?
      type.static_framework?
    end

    def requires_frameworks?
      # HACK: needed because CocoaPods, pre-introduction of the `type` type/attr,
      # would check #requires_frameworks? instead of #host_requires_frameworks?
      # for finding the PodTarget to set as a dependency of another PodTarget.
      if !::CocoaPodsPackingCubes::NATIVE_TYPE_SUPPORT && !packing_cube.empty? &&
         caller_locations(1, 2).any? { |l| l.base_label == 'filter_dependencies' }

        return super
      end

      type.framework?
    end
  end
end

module Pod
  class PodTarget
    prepend ::CocoaPodsPackingCubes::PodTargetMixin
  end
end
