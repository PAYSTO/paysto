require 'net/http'
require 'net/https'
require "paysto/exception"

class Paysto
  API_URL = 'https://paysto.com'

  def initialize(shop_id, secret)
    @shop_id = shop_id
    @secret = secret
    @uri = URI('https://paysto.com')
  end

  def create_request(type, options)
    response = api_call "/api/paymentGate/#{type}", options
    status, message = response.split ','
    if status != 'RES_RESERVED'
      raise PaystoException, "#{status}: #{message}"
    end
    true
  end

  def payment_info(invoice_id)
    options = {
        PAYSTO_INVOICE_ID: invoice_id
    }
    api_call '/api/Payment/GetByInvoiceId', options
  end

  def check_payment_status(invoice_id)
    response = payment_info invoice_id
    data = response.split ','
    if data[0] == 'RES_ERROR'
      raise PaystoException, "#{data[0]}: #{data[1]}"
    end
    data.try :[], 5
  end

  def balance
    response = api_call "/api/Common/Balance"
    response.to_f
  end

  private

  def api_call(path, options = {})
    @uri.path = path
    http = Net::HTTP.new(@uri.host, @uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(@uri.request_uri)
    request.set_form_data(prepare_params(options))
    response = http.request(request)
    response.body.force_encoding 'UTF-8'
  end

  def prepare_params(options = {})
    params = {PAYSTO_SHOP_ID: @shop_id}.merge options
    params[:PAYSTO_REQUEST_NO] = Time.now.to_i
    params[:PAYSTO_MD5] = sign params
    params
  end

  def sign(params)
    q = params.sort.map{ |k, v| "#{k}=#{v}" }.join('&')
    Digest::MD5.hexdigest(q + "&#{@secret}").upcase
  end

end