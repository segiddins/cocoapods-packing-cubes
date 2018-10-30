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
end
