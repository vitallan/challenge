require_relative '../product/order'
require_relative '../infra/topic'
require_relative '../infra/pub_sub'
require_relative './invoice.rb'

class Customer
  attr_accessor :active_order, :first_name, :vouchers, :payment_method

  def initialize(first_name)
    @vouchers = Array.new
    @first_name = first_name
  end

  def add_product_to_order(product)
    if @active_order == nil
      @active_order = Order.new(self)
    end
    @active_order.add_product(product)
  end

  def set_payment_method(payment_method)
    @payment_method = payment_method
  end

  def select_shipping_address(address)
    @active_order.ship_to(address)
  end

  def add_voucher(voucher)
    @vouchers << voucher
  end

  def pay_active_order
    @payment_method.pay(@active_order)
    invoice = Invoice.new(@payment_method.billing_address, @active_order)
    PubSub.instance.publish(Topics::PAID_INVOICE, invoice)
  end 

  def to_s
    @first_name
  end

end