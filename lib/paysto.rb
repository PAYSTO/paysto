class Paysto
  PAYMENT_GATE_URL = 'https://paysto.com/api/paymentGate/'
  API_URL = 'https://paysto.com/api/Common/'
  PAYMENT_STATUS_URL = 'https://paysto.com/api/Payment/GetByInvoiceId'

  def initialize(shop_id, secret)
    @shop_id = shop_id
    @secret = secret
  end

  def create_request(type, options)
    params = {PAYSTO_SHOP_ID: @shop_id}.merge(options)
    params[:PAYSTO_MD5] = sign params
    response = api_call "#{PAYMENT_GATE_URL}/#{type}", params
    status, message = response.split ','
    if status != 'RES_RESERVED'
      raise PaystoException, "#{status}: #{message}"
    end
    true
  end

  def check_payment_status(invoice_id)
    params = {
        PAYSTO_SHOP_ID: @shop_id,
        PAYSTO_INVOICE_ID: invoice_id,
        PAYSTO_REQUEST_NO: Time.now.to_i
    }
    params[:PAYSTO_MD5] = sign params
    response = api_call PAYMENT_STATUS_URL, params

  end

  def balance
    params = {
        PAYSTO_SHOP_ID: @shop_id,
        PAYSTO_REQUEST_NO: Time.now.to_i
    }
    params[:PAYSTO_MD5] = sign params
    response = api_call "#{API_URL}/Balance", params
    response.to_f
  end

  private

  def api_call(url, params)
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data(params)
    response = http.request(request)
    response.body.force_encoding 'UTF-8'
  end

  def sign(params)
    q = params.sort.map{ |k, v| "#{k}=#{v}" }.join('&')
    Digest::MD5.hexdigest(q + "&#{@secret}").upcase
  end
end




