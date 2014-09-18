# Paysto gem


Ruby wrapper for Paysto paymentGate  API


## Installation

Add to Gemfile:

```ruby

gem 'paysto'

```
## Usage

Anywhere in your application use gem in following way:

```ruby

  api = Paysto.new(shop_id, secret)

  api.create_request('bill', options) # creates request to transfer money to bank account

  api.balance   # checks balance

```