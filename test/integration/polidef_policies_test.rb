# frozen_string_literal: true

require "ostruct"
require "test_helper"

class OrderPolicy < Polidef::Policy
  policy_dependencies :user, :credit_card

  def policy
    user_can_purchase? && credit_card_accepted?
  end

  private

  def user_can_purchase?
    user.in_good_standing? && user.has_email?
  end

  def credit_card_accepted?
    credit_card.valid? && credit_card.accepted_type?
  end
end

class Order # < ApplicationRecord
  include Polidef::Policies

  attr_reader :submitted

  def initialize
    @submitted = false
  end

  def place(user, credit_card)
    with_fulfilled_policy(:order_policy, dependencies: {user: user, credit_card: credit_card}) do
      submit_order!
    end
  end

  def submit_order!
    @submitted = true
  end
end

class PolidefPoliciesTest < Minitest::Test
  def test_placing_order
    good_user = OpenStruct.new(in_good_standing?: true, has_email?: true)
    good_credit_card = OpenStruct.new(valid?: true, accepted_type?: true)

    order = Order.new
    order.place(good_user, good_credit_card)

    assert order.submitted
  end

  # def test_fulfill_assertions_even_when_fail
  #   bad_user = OpenStruct.new(in_good_standing?: false, has_email?: true)
  #   bad_credit_card = OpenStruct.new(valid?: false, accepted_type?: true)

  #   order = Order.new
  #   assert_with_fulfilled_policy(:order_policy) do
  #     order.place(bad_user, bad_credit_card)
  #   end

  #   assert order.submitted
  # end
end
