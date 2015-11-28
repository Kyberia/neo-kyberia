#    This file is part of Kybcapi.
#
#    Kybcapi is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Kybcapi is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with Kybcapi.  If not, see <http://www.gnu.org/licenses/>.
#
#    Author: Peter Vrabel <kybu@kybu.org>
require 'digest'
require 'uuidtools'

module Auth extend self
  def digest_with_secret(secret, data, salt = nil)
    # Salt'n'Pepper!
    salt ||= get_salt
    interleave_salt_hash(salt, Digest::SHA1.hexdigest(salt + data + secret))
  end

  def get_salt ; Digest::SHA1.hexdigest(UUIDTools::UUID.random_create) end

  def interleave_salt_hash(salt, hash)
    salt[0,20] + hash[0,20] + salt[20,20] + hash[20,20]
  end

  def get_salt_hash(data)
    [data[0,20] + data[40,20], data[20,20] + data[60,20]]
  end

  class Token
    LENGTH = 124

    class TokenException < StandardError ; end

    def initialize(secret)
      @secret = secret
    end

    def generate(user_id)
      # 10 is max digits number of integer in Mysql(2147483647).
      @token = (Time.new.strftime("%Y%m%d%H%M") + "%010d" % user_id).to_hex
      @token += Auth::digest_with_secret(@secret, @token)
      self
    end

    def assign(token_string)
      raise TokenException("Wrong token length!") if token_string.size != LENGTH
      @token = token_string
      self
    end

    # Check, if token is valid.
    def valid?
      salt, _ = Auth::get_salt_hash(@token[-80..-1])

      return true if Auth::digest_with_secret(@secret, @token[0,44], salt) == @token[-80..-1]
      return false
    end

    def expired?(lifetime)
      if valid?
        time = @token[0,24].from_hex

        time_delta = Time.now - Time.local(time[0,4], time[4,2], time[6,2], time[8,2], time[10,2])
        return true if time_delta >= lifetime*60
      end

      return false
    end

    def to_s ; @token end
    def empty? ; @token.nil? end

  end
end

class String
  def to_hex ; each_byte.map { |i| "%02x" % i }.join end
  def from_hex ; chars.each_slice(2).map { |hh, hl| (hh+hl).hex.chr }.join end
end