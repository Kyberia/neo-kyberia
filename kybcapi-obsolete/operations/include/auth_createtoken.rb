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

module Auth_createtoken_inc
  def check_sha1_convert(passwd, data)
    # Positions 0..19 and 40..59 constitutes a salt. Rest is a password hash.
    return false if passwd.empty? or data.length != 80
    salt, hash = get_salt_hash(data)
    if Digest::SHA1.hexdigest(salt + Digest::MD5.hexdigest(passwd)) == hash
      return true end
    return false
  end

  def check_md5(passwd, hash)
    return true if Digest::MD5.hexdigest(passwd) == hash
    return false
  end
end