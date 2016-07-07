# for use by collection_select and friends, to link a human-readable label with a db-friendly symbolic value
# todo: ActiveRecord macros for setters (for allowing multiple values or just one)
# Usage:
# Table name: snacks
#  id                         :integer
#  ice_cream                  :string
# class Snack < ActiveRecord::Base
#   FLAVORS = Enum.new [
#       [:vanilla, "Vanilla"],
#       [:chocolate, "Chocolate"],
#       [:rocky_road, "Rocky Road"]
#       ])
#   ]
# end
# ...
# <%= simple_form_for @snack do |f| %>
# <%= f.collection_select :ice_cream, Snack::FLAVORS, :value, :label %>
# <% end %>

class Enum

  class Item
    attr_reader :value, :label

    def initialize value, label
      @value, @label = value.to_sym, label
    end

    def ==(other)
      other.is_a?(Enum::Item) and
        other.value == value and
        other.label == label
    end
  end

  include Enumerable

  attr_reader :items

  def initialize item_tuples
    @items = item_tuples.map do |item_tuple|
      Item.new(item_tuple[0], item_tuple[1])
    end
  end

  def each &block
    @items.each &block
  end

  def values
    @items.map {|item| item.value.to_s}
  end

  def validation_message
    "must be #{values.map(&:inspect).join(' or ')}"
  end

  def label_for(value)
    @items.detect do |item|
      item.value == value.to_sym
    end.label
  end
end
