require File.join(File.dirname(__FILE__), 'spec_helper')

describe Time do
  describe '#nearest' do
    it 'should return the closet interval of time using rounding' do
      Time.parse('1:10pm').nearest(15 * 60).should == Time.parse('1:15pm')
    end

    it 'should round down when necessary' do
      Time.parse('1:06pm').nearest(15 * 60).should == Time.parse('1:00pm')
    end

    it 'should be able to force the nearest time to be in the future' do
      Time.parse('1:06pm').nearest(15 * 60, :force => :future).should == Time.parse('1:15pm')
    end

    it 'should be able to force the nearest time to be in the past' do
      Time.parse('1:10pm').nearest(15 * 60, :force => :past).should == Time.parse('1:00pm')
    end
  end
end
