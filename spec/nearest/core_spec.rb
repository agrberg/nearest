# frozen_string_literal: true

describe Nearest do # rubocop:disable RSpec/SpecFilePathFormat
  describe '#nearest' do
    context 'with a Time' do
      it 'returns a Time' do
        expect(described_class.new(Time.parse('1:10pm')).nearest(15 * 60)).to be_a(Time)
      end

      it 'rounds to the nearest interval' do
        expect(described_class.new(Time.parse('1:10pm')).nearest(15 * 60)).to eq Time.parse('1:15pm')
      end

      it 'preserves the local time zone' do
        local_time = Time.parse('1:10pm')
        expect(described_class.new(local_time).nearest(15 * 60).utc_offset).to eq local_time.utc_offset
      end

      it 'preserves a fixed-offset time zone' do
        fixed_time = Time.parse('1:10pm').getlocal('+05:30')
        expect(described_class.new(fixed_time).nearest(15 * 60).utc_offset).to eq fixed_time.utc_offset
      end

      it 'preserves the UTC time zone' do
        utc_time = Time.parse('1:10pm').utc
        expect(described_class.new(utc_time).nearest(15 * 60).zone).to eq 'UTC'
      end
    end

    context 'with a DateTime' do
      it 'returns a DateTime' do
        expect(described_class.new(DateTime.parse('1:10pm')).nearest(15 * 60)).to be_a(DateTime)
      end

      it 'rounds to the nearest interval' do
        expect(described_class.new(DateTime.parse('1:10pm')).nearest(15 * 60)).to eq DateTime.parse('1:15pm')
      end

      it 'preserves the offset' do
        dt = DateTime.parse('1:10pm +05:30')
        expect(described_class.new(dt).nearest(15 * 60).offset).to eq dt.offset
      end
    end

    context 'with an ActiveSupport::TimeWithZone' do
      before { Time.zone = 'Eastern Time (US & Canada)' }

      it 'returns an ActiveSupport::TimeWithZone' do
        expect(described_class.new(Time.zone.parse('1:10pm')).nearest(15 * 60)).to be_a(ActiveSupport::TimeWithZone)
      end

      it 'rounds to the nearest interval' do
        expect(described_class.new(Time.zone.parse('1:10pm')).nearest(15 * 60)).to eq Time.zone.parse('1:15pm')
      end

      it 'preserves the time zone' do
        zone_time = Time.zone.parse('1:10pm')
        expect(described_class.new(zone_time).nearest(15 * 60).time_zone).to eq zone_time.time_zone
      end
    end

    describe 'validating the arguments' do
      it 'raises ArgumentError for zero seconds' do
        expect { described_class.new(Time.parse('1:10pm')).nearest(0) }
          .to raise_error(ArgumentError, /positive/)
      end

      it 'raises ArgumentError for negative seconds' do
        expect { described_class.new(Time.parse('1:10pm')).nearest(-60) }
          .to raise_error(ArgumentError, /positive/)
      end

      it 'raises ArgumentError for invalid round value' do
        expect { described_class.new(Time.parse('1:10pm')).nearest(15 * 60, round: :invalid) }
          .to raise_error(ArgumentError, /round/)
      end
    end

    describe 'rounding modes' do
      it 'rounds up with round: :up' do
        expect(described_class.new(Time.parse('1:06pm')).nearest(15 * 60, round: :up)).to eq Time.parse('1:15pm')
      end

      it 'rounds down with round: :down' do
        expect(described_class.new(Time.parse('1:10pm')).nearest(15 * 60, round: :down)).to eq Time.parse('1:00pm')
      end

      it 'advances with round: :next' do
        expect(described_class.new(Time.parse('1:00pm')).nearest(15 * 60, round: :next)).to eq Time.parse('1:15pm')
      end

      it 'retreats with round: :prev' do
        expect(described_class.new(Time.parse('1:00pm')).nearest(15 * 60, round: :prev)).to eq Time.parse('12:45pm')
      end
    end
  end
end
