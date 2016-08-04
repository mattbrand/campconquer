require 'rails_helper'

describe Enum do

  describe Enum::Item do
    subject { Enum::Item.new(:rocky_road, "Rocky Road") }

    it 'has a human-readable label' do
      expect(subject.label).to eq("Rocky Road")
    end

    it 'has a symbolic value' do
      expect(subject.value).to eq(:rocky_road)
    end

    context 'when missing a label' do
      subject { Enum::Item.new(:rocky_road) }
      it 'generates one based on the value' do
        expect(subject.label).to eq("Rocky Road")
      end
    end

    context 'when missing a value' do
      subject { Enum::Item.new(nil, "Rocky Road") }
      it 'generates one based on the label' do
        expect(subject.value).to eq(:rocky_road)
      end
    end

    context 'when missing both value and label' do
      it 'fails' do
        expect do
          Enum::Item.new(nil, nil)
        end.to raise_error(RuntimeError, Enum::Item::NEEDS_VALUE)
      end
    end

  end

  context "when initialized with a list of item tuples" do
    subject { Enum.new([
                         [:vanilla, "Vanilla"],
                         [:chocolate, "Chocolate"],
                         [:rocky_road, "Rocky Road"]
                       ]) }

    it "contains the items" do
      expect(subject.items[0]).to eq(Enum::Item.new(:vanilla, "Vanilla"))
      expect(subject.items[1]).to eq(Enum::Item.new(:chocolate, "Chocolate"))
      expect(subject.items[2]).to eq(Enum::Item.new(:rocky_road, "Rocky Road"))
    end

    it "implements enumerable (with each)" do
      array = subject.items.dup
      subject.each do |x|
        expect(x).to eq(array.shift)
      end
    end

    it "returns a list of just the item values as strings" do
      expect(subject.values).to eq(["vanilla", "chocolate", "rocky_road"])
    end

    it "has a Rails-ready failed validation message" do
      expect(subject.validation_message).to eq("must be \"vanilla\" or \"chocolate\" or \"rocky_road\"")
    end

    it "can look up the user-readable display name" do
      expect(subject.label_for("vanilla")).to eq("Vanilla")
      expect(subject.label_for("rocky_road")).to eq("Rocky Road")
      expect(subject.label_for(:rocky_road)).to eq("Rocky Road")
    end

  end

end
