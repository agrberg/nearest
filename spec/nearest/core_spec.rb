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

      it 'raises ArgumentError for invalid anchor value' do
        expect { described_class.new(Time.parse('1:10pm')).nearest(15 * 60, anchor: :invalid) }
          .to raise_error(ArgumentError, /anchor/)
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

    describe 'non-dividing interval warning' do
      before { described_class.reset_warnings! }

      it 'warns once for intervals that do not divide 3600', :aggregate_failures do
        expect { described_class.new(Time.parse('1:10pm')).nearest(7 * 60) }
          .to output(/does not evenly divide 3600/).to_stderr

        expect { described_class.new(Time.parse('1:10pm')).nearest(7 * 60) }
          .not_to output.to_stderr
      end

      it 'does not warn for intervals that divide 3600' do
        expect { described_class.new(Time.parse('1:10pm')).nearest(15 * 60) }
          .not_to output.to_stderr
      end

      it 'does not warn when anchor: is explicitly passed' do
        expect { described_class.new(Time.parse('1:10pm')).nearest(7 * 60, anchor: :hour) }
          .not_to output.to_stderr
      end
    end

    describe 'anchor: :epoch' do
      it 'matches the default behavior' do
        time = Time.parse('1:10pm')
        default = suppress_warnings { described_class.new(time).nearest(7 * 60) }
        expect(described_class.new(time).nearest(7 * 60, anchor: :epoch)).to eq default
      end

      it 'does not warn when explicitly passed' do
        described_class.reset_warnings!
        expect { described_class.new(Time.parse('1:10pm')).nearest(7 * 60, anchor: :epoch) }
          .not_to output.to_stderr
      end
    end

    describe 'anchor: :hour' do
      it 'produces clock-aligned results for 7-minute intervals' do
        expect(described_class.new(Time.parse('1:10pm')).nearest(7 * 60, anchor: :hour))
          .to eq Time.parse('1:07pm')
      end

      it 'rounds to the top of the hour at :00' do
        expect(described_class.new(Time.parse('1:02pm')).nearest(7 * 60, anchor: :hour))
          .to eq Time.parse('1:00pm')
      end

      it 'round: :prev at the top of the hour crosses into the previous hour' do
        # offset = 0 at :00, :prev → slot -1 → base - 420s = 12:53pm
        expect(described_class.new(Time.parse('1:00pm')).nearest(7 * 60, round: :prev, anchor: :hour))
          .to eq Time.parse('12:53pm')
      end

      it 'round: :next near end of hour crosses into the next hour' do
        expect(described_class.new(Time.parse('1:56pm')).nearest(7 * 60, round: :next, anchor: :hour))
          .to eq Time.parse('2:03pm')
      end
    end

    describe 'anchor: :day' do
      it 'produces day-aligned results for 45-minute intervals' do
        # Grid: 12:00am, 12:45am, 1:30am, 2:15am, 3:00am, ...
        # 1:10pm = 13h10m = 790 min. 790 / 45 = 17 remainder 25. 25*2 >= 45? 50 >= 45 yes → slot 18
        # slot 18 * 45 = 810 min = 13:30 = 1:30pm
        expect(described_class.new(Time.parse('1:10pm')).nearest(45 * 60, anchor: :day))
          .to eq Time.parse('1:30pm')
      end

      it 'round: :prev at midnight crosses into the previous day' do
        # offset = 0 at midnight, :prev → slot -1 → base - 420s = 23:53 previous day
        expect(described_class.new(Time.parse('2026-02-28 00:00:00')).nearest(7 * 60, round: :prev, anchor: :day))
          .to eq Time.parse('2026-02-27 23:53:00')
      end

      it 'round: :next near end of day crosses into the next day' do
        # 23:58 = 86280s into day. 86280 / 420 = 205 remainder 180. :next → slot 206.
        # 206 * 420 = 86520s = 24h + 120s = 00:02 next day
        expect(described_class.new(Time.parse('2026-02-28 23:58:00')).nearest(7 * 60, round: :next, anchor: :day))
          .to eq Time.parse('2026-03-01 00:02:00')
      end
    end
  end
end
