require 'rails_helper'

RSpec.describe Fulfillment, type: :model do
  describe '#formatted_date' do
    context 'date present' do
      let!(:fulfillment) { Fulfillment.create(date: Date.new(2001, 1, 2)) }
      it 'should return date in format: -m/%d/%Y' do
        expect(fulfillment.formatted_date).to eq '1/02/2001'
      end
    end

    context 'date not present' do
      let!(:fulfillment) { Fulfillment.create(date: nil) }

      it 'should return nil' do
        expect(fulfillment.formatted_date).to eq nil
      end
    end
  end

  describe '#formatted_date=' do
    let!(:fulfillment) { Fulfillment.create(date: nil) }

    context 'right hand side is a valid date string in the form: %m/%d/%Y' do
      it 'should update date' do
        fulfillment.formatted_date = '02/01/2000'
        expect(fulfillment.date.to_date).to eq Date.new(2000, 2, 1)
      end
    end

    context 'right hand side is not a valid date string in the form: %m/%d/%Y' do
      it 'should set date to nil' do
        fulfillment.formatted_date = '13/01/2000'
        expect(fulfillment.date).to eq nil
      end
    end
  end

  describe '#within_date_range?' do
    context 'start_date nil' do
      let!(:fulfillment) { Fulfillment.create(date: Date.new(2001, 1, 2)) }
      it 'should return false' do
        expect(fulfillment.within_date_range?(nil, Date.new(2002, 1, 2))).to eq false
      end
    end

    context 'end_date nil' do
      let!(:fulfillment) { Fulfillment.create(date: Date.new(2001, 1, 2)) }
      it 'should return false' do
        expect(fulfillment.within_date_range?(Date.new(2000, 1, 2), nil)).to eq false
      end
    end

    context 'date nil' do
      let!(:fulfillment) { Fulfillment.create(date: nil) }
      it 'should return false' do
        expect(fulfillment.within_date_range?(Date.new(2000, 1, 2), Date.new(2001, 1, 2))).to eq false
      end
    end

    context 'start_date, end_date, and date are not nil' do
      let!(:fulfillment) { Fulfillment.create(date: nil) }
      before(:each) { @dates = [Date.new(2000, 1, 2), Date.new(2001, 1, 2), Date.new(2002, 1, 2)] * 2 }

      it 'should return true if Fulfillment date occurs on or after start date and occurs on or before end_date' do
        @dates.combination(3) do |start_date, date, end_date|
          fulfillment.update_attributes(date: date)
          expect(fulfillment.within_date_range?(start_date, end_date)).to eq(
            (date >= start_date) && (date <= end_date))
        end
      end
    end
  end
end
