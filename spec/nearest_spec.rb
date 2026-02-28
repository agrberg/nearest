# frozen_string_literal: true

# rubocop:disable RSpec/SpecFilePathFormat
describe Time do
  # rubocop:enable RSpec/SpecFilePathFormat
  describe '#nearest' do
    it 'returns a Time object' do
      expect(described_class.parse('1:10pm').nearest(15 * 60)).to be_a(described_class)
    end

    it 'rounds to the nearest interval' do
      expect(described_class.parse('1:10pm').nearest(15 * 60)).to eq described_class.parse('1:15pm')
    end

    it 'rounds down when closer to the earlier interval' do
      expect(described_class.parse('1:06pm').nearest(15 * 60)).to eq described_class.parse('1:00pm')
    end

    it 'returns the exact time when already on an interval boundary' do
      expect(described_class.parse('1:00pm').nearest(15 * 60)).to eq described_class.parse('1:00pm')
    end

    it 'forces the nearest time to be in the future' do
      expect(described_class.parse('1:06pm').nearest(15 * 60, force: :future)).to eq described_class.parse('1:15pm')
    end

    it 'forces the nearest time to be in the past' do
      expect(described_class.parse('1:10pm').nearest(15 * 60, force: :past)).to eq described_class.parse('1:00pm')
    end

    it 'preserves local timezone' do
      local_time = described_class.parse('1:10pm')
      expect(local_time.nearest(15 * 60).zone).to eq local_time.zone
    end

    it 'preserves UTC timezone' do
      utc_time = described_class.parse('1:10pm').utc
      expect(utc_time.nearest(15 * 60).zone).to eq 'UTC'
    end

    it 'works with 10-minute intervals' do
      expect(described_class.parse('1:08pm').nearest(10 * 60)).to eq described_class.parse('1:10pm')
    end

    it 'works with 30-minute intervals' do
      expect(described_class.parse('1:23pm').nearest(30 * 60)).to eq described_class.parse('1:30pm')
    end
  end
end
