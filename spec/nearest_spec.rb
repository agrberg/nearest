# frozen_string_literal: true

# Adds methods like `minutes` to Numeric, producing an ActiveSupport::Duration.
require 'active_support/core_ext/numeric/time'

# rubocop:disable RSpec/SpecFilePathFormat
describe Time do
  # rubocop:enable RSpec/SpecFilePathFormat
  describe '#nearest' do
    def time_for(str)
      described_class.parse(str)
    end

    it 'returns a Time object' do
      expect(time_for('1:10pm').nearest(15 * 60)).to be_a(described_class)
    end

    it 'accepts an ActiveSupport::Duration' do
      expect(time_for('1:10pm').nearest(15.minutes)).to eq time_for('1:15pm')
    end

    describe 'preserving the time zone' do
      it 'preserves the local time zone' do
        local_time = time_for('1:10pm')
        expect(local_time.nearest(15 * 60).utc_offset).to eq local_time.utc_offset
      end

      it 'preserves the UTC time zone' do
        utc_time = time_for('1:10pm').utc
        expect(utc_time.nearest(15 * 60).zone).to eq 'UTC'
      end

      it 'preserves a fixed-offset time zone' do
        fixed_time = time_for('1:10pm').getlocal('+05:30')
        expect(fixed_time.nearest(15 * 60).utc_offset).to eq fixed_time.utc_offset
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
