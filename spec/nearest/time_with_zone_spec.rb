# frozen_string_literal: true

describe ActiveSupport::TimeWithZone do # rubocop:disable RSpec/SpecFilePathFormat
  describe '#nearest' do
    before { Time.zone = 'Eastern Time (US & Canada)' }

    def time_for(str)
      Time.zone.parse(str)
    end

    it 'returns an ActiveSupport::TimeWithZone object' do
      expect(time_for('1:10pm').nearest(15 * 60)).to be_a(described_class)
    end

    it 'accepts an ActiveSupport::Duration' do
      expect(time_for('1:10pm').nearest(15.minutes)).to eq time_for('1:15pm')
    end

    describe 'preserving the time zone' do
      it 'preserves the default time zone' do
        zone_time = time_for('1:10pm')
        expect(zone_time.nearest(15 * 60).time_zone).to eq zone_time.time_zone
      end

      it 'preserves a different time zone' do
        Time.use_zone('Asia/Tokyo') do
          zone_time = Time.zone.parse('1:10pm')
          expect(zone_time.nearest(15 * 60).time_zone).to eq zone_time.time_zone
        end
      end

      it 'preserves the UTC time zone' do
        Time.use_zone('UTC') do
          zone_time = Time.zone.parse('1:10pm')
          expect(zone_time.nearest(15 * 60).time_zone).to eq zone_time.time_zone
        end
      end
    end

    describe 'across a DST boundary' do
      it 'rounds forward across spring-forward' do
        # 2026-03-08 1:53am EST; clocks spring forward at 2:00am to 3:00am EDT
        zone_time = Time.zone.parse('2026-03-08 01:53:00')
        expect(zone_time.nearest(15 * 60)).to eq Time.zone.parse('2026-03-08 03:00:00')
      end

      it 'rounds backward across spring-forward' do
        # 2026-03-08 3:00am EDT; round: :prev should retreat to 1:45am EST
        zone_time = Time.zone.parse('2026-03-08 03:00:00')
        expect(zone_time.nearest(15 * 60, round: :prev)).to eq Time.zone.parse('2026-03-08 01:45:00')
      end

      it 'rounds forward across fall-back' do
        # 2026-11-01 1:53am EDT; advancing crosses fall-back to 1:00am EST
        zone_time = Time.zone.parse('2026-11-01 01:53:00')
        # parse would pick 1:00am EDT (first occurrence), so construct via UTC
        expected = Time.utc(2026, 11, 1, 6, 0, 0).in_time_zone(Time.zone)
        expect(zone_time.nearest(15 * 60)).to eq expected
      end

      it 'rounds backward across fall-back' do
        # 2026-11-01 1:00am EST (second occurrence); round: :prev crosses back to 1:45am EDT
        zone_time = Time.utc(2026, 11, 1, 6, 0, 0).in_time_zone(Time.zone)
        expect(zone_time.nearest(15 * 60, round: :prev)).to eq Time.zone.parse('2026-11-01 01:45:00')
      end
    end

    describe 'validating the arguments' do
      it 'raises ArgumentError for zero seconds' do
        expect { time_for('1:10pm').nearest(0) }.to raise_error(ArgumentError, /positive/)
      end

      it 'raises ArgumentError for negative seconds' do
        expect { time_for('1:10pm').nearest(-60) }.to raise_error(ArgumentError, /positive/)
      end

      it 'raises ArgumentError for invalid round value' do
        expect { time_for('1:10pm').nearest(15 * 60, round: :invalid) }
          .to raise_error(ArgumentError, /round/)
      end
    end

    describe 'the default behavior is round: :nearest' do
      it 'advances when closer to the next interval' do
        expect(time_for('1:10pm').nearest(15 * 60)).to eq time_for('1:15pm')
      end

      it 'retreats when closer to the earlier interval' do
        expect(time_for('1:06pm').nearest(15 * 60)).to eq time_for('1:00pm')
      end

      it 'remains when on an exact boundary' do
        expect(time_for('1:00pm').nearest(15 * 60)).to eq time_for('1:00pm')
      end

      {
        30 => '1:00pm',
        20 => '1:20pm',
        15 => '1:15pm',
        12 => '1:12pm',
        10 => '1:10pm',
        6 => '1:12pm',
        5 => '1:15pm',
        4 => '1:16pm',
        3 => '1:15pm',
        2 => '1:14pm'
      }.each do |interval, expected|
        it "rounds 1:14 to #{expected} for #{interval}-minute intervals" do
          expect(time_for('1:14pm').nearest(interval * 60)).to eq time_for(expected)
        end
      end
    end

    describe 'specifying the round' do
      context 'with round: :next' do
        it 'advances to the next interval' do
          expect(time_for('1:06pm').nearest(15 * 60, round: :next)).to eq time_for('1:15pm')
        end

        it 'advances when on an exact boundary' do
          expect(time_for('1:00pm').nearest(15 * 60, round: :next)).to eq time_for('1:15pm')
        end
      end

      context 'with round: :up' do
        it 'advances to the next interval' do
          expect(time_for('1:06pm').nearest(15 * 60, round: :up)).to eq time_for('1:15pm')
        end

        it 'remains when on an exact boundary' do
          expect(time_for('1:00pm').nearest(15 * 60, round: :up)).to eq time_for('1:00pm')
        end
      end

      context 'with round: :down' do
        it 'retreats to the previous interval' do
          expect(time_for('1:10pm').nearest(15 * 60, round: :down)).to eq time_for('1:00pm')
        end

        it 'remains when on an exact boundary' do
          expect(time_for('1:00pm').nearest(15 * 60, round: :down)).to eq time_for('1:00pm')
        end
      end

      context 'with round: :prev' do
        it 'retreats to the previous interval' do
          expect(time_for('1:10pm').nearest(15 * 60, round: :prev)).to eq time_for('1:00pm')
        end

        it 'retreats when on an exact boundary' do
          expect(time_for('1:00pm').nearest(15 * 60, round: :prev)).to eq time_for('12:45pm')
        end
      end
    end
  end
end
