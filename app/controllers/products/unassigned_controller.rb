# frozen_string_literal: true

class Products::UnassignedController < ApplicationController
  before_action :require_staff_login
  def index
    @product_deadline_day = Product::PRODUCT_DEADLINE
  end
end
