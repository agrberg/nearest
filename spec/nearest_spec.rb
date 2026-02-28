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

    it 'advances to the next interval' do
      expect(described_class.parse('1:06pm').nearest(15 * 60, round: :next)).to eq described_class.parse('1:15pm')
    end

    it 'advances past an exact boundary' do
      expect(described_class.parse('1:00pm').nearest(15 * 60, round: :next)).to eq described_class.parse('1:15pm')
    end

    it 'rounds up to the next interval' do
      expect(described_class.parse('1:06pm').nearest(15 * 60, round: :up)).to eq described_class.parse('1:15pm')
    end

    it 'returns the same time when rounding up on an exact boundary' do
      expect(described_class.parse('1:00pm').nearest(15 * 60, round: :up)).to eq described_class.parse('1:00pm')
    end

    it 'rounds down to the previous interval' do
      expect(described_class.parse('1:10pm').nearest(15 * 60, round: :down)).to eq described_class.parse('1:00pm')
    end

    it 'returns the same time when rounding down on an exact boundary' do
      expect(described_class.parse('1:00pm').nearest(15 * 60, round: :down)).to eq described_class.parse('1:00pm')
    end

    it 'retreats to the previous interval' do
      expect(described_class.parse('1:10pm').nearest(15 * 60, round: :prev)).to eq described_class.parse('1:00pm')
    end

    it 'retreats past an exact boundary' do
      expect(described_class.parse('1:00pm').nearest(15 * 60, round: :prev)).to eq described_class.parse('12:45pm')
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

    it 'raises ArgumentError for zero seconds' do
      expect { described_class.parse('1:10pm').nearest(0) }.to raise_error(ArgumentError, /positive/)
    end

    it 'raises ArgumentError for negative seconds' do
      expect { described_class.parse('1:10pm').nearest(-60) }.to raise_error(ArgumentError, /positive/)
    end

    it 'raises ArgumentError for invalid round value' do
      expect { described_class.parse('1:10pm').nearest(15 * 60, round: :invalid) }
        .to raise_error(ArgumentError, /round/)
    end
  end
end
