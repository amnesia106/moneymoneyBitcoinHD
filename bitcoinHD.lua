-- BitcoinHD Extension for MoneyMoney
-- Fetches balances from btchd.org API
--
-- Copyright (c) 2019 amnesia106
-- 3EmpsYNJqLcw61BpxgxASvxchmShvmgdc9
-- BURST-A4PZ-XVX8-RN9N-76HPE
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

WebBanking{
  version = 0.1,
  description = "Include your BitcoinHD as cryptoportfolio in MoneyMoney by providing BitcoinHD  addresses as usernme (comma seperated)",
  services= { "BitcoinHD" }
}

local bitcoinhdAddress
local connection = Connection()
local currency = "EUR"

function SupportsBank (protocol, bankCode)
  return protocol == ProtocolWebBanking and bankCode == "BitcoinHD"
end

function InitializeSession (protocol, bankCode, username, username2, password, username3)
  bitcoinhdAddress = username:gsub("%s+", "")
end

function ListAccounts (knownAccounts)
  local account = {
    name = "BitcoinHD",
    accountNumber = "BitcoinHD",
    currency = currency,
    portfolio = true,
    type = "AccountTypePortfolio"
  }

  return {account}
end

function RefreshAccount (account, since)
  local s = {}
  prices = requestBitcoinHDPrice()

  for address in string.gmatch(bitcoinhdAddress, '([^,]+)') do
    BitcoinHDQuantity = requestBitcoinHDQuantityForbitcoinhdAddress(address)

    s[#s+1] = {
      name = address,
      currency = nil,
      market = "cryptocompare",
      quantity = BitcoinHDQuantity,
      price = prices["price_eur"],
    }
  end

  return {securities = s}
end

function EndSession ()
end

function requestBitcoinHDPrice()
  response = connection:request("GET", cryptocompareRequestUrl(), {})
  json = JSON(response)

  return json:dictionary()[1]
end


function requestBitcoinHDQuantityForbitcoinhdAddress(bitcoinhdAddress)
  response = connection:request("GET", BitcoinHDRequestUrl(bitcoinhdAddress), {})
  json = JSON(response)
  BHD = json:dictionary()["balance"]
   return BHD
  end

function cryptocompareRequestUrl()
  return "https://api.coinmarketcap.com/v1/ticker/bitcoinhd/?convert=EUR"
end

function BitcoinHDRequestUrl(bitcoinhdAddress)
  return "http://www.btchd.org/explorer/api/v2/blockchain/address/" .. bitcoinhdAddress
end

-- SIGNATURE:

-- SIGNATURE: MC0CFQCPJcHe8zepDM2yQjsTIATwBY5DdQIUCEdZogJdSUSllbkkpyCHmD6hi5A=
