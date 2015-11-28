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
require_relative '../kybcapi_operation'
require_relative 'shared/auth'
require_relative 'include/auth_createtoken'
require 'date'

include Auth
include Auth_createtoken_inc

setup_hook do

  columns = [:user_id, :user_login, :passwd, :passwd_old, :header_id, :acc_lockout, :locked_out]
  @stmt_user_by_id = db.prepare(<<SQL
select user_id, login, password, password_old, header_id,
       acc_lockout, if(acc_lockout and acc_lockout>now(), 1, 0)
from users where user_id=?
SQL
  ).column_names(*columns)

  @stmt_user_by_login = db.prepare(<<SQL
select user_id, login, password, password_old, header_id,
       acc_lockout, if(acc_lockout and acc_lockout>now(), 1, 0)
from users where login=? or login=?
SQL
  ).column_names(*columns)

end

process_request do |request, response|

  user = nil
  if not request.user_id.nil?
    user = @stmt_user_by_id.execute(request.user_id).fetch_hash
  elsif not request.user_login.nil?
    user = @stmt_user_by_login.execute(request.user_login, request.user_login + '[Locked_OUT]').fetch_hash
  else
    response.set_error 1, "user_id or user_login has to be set."
    next
  end

  if user.nil?
    response.set_error 2, "No such user has been found."
    next
  end

  if user[:header_id] == 2091520
    response.set_error 3, "Registration request hasn't been accepted yet."
    next
  end

  if user[:locked_out] == 1
    response.set_error 4, "Account is locked out until #{user[:acc_lockout].to_s}"
    next
  end

  # User's credentials are correct.
  if check_sha1_convert(request.passwd, user[:passwd]) or
      check_md5(request.passwd, user[:passwd_old]) or
      check_md5(request.passwd, user[:passwd])

    response.token = Auth::Token.new(cfg.params['auth']['secret']).generate(request.user_id).to_s

  else
    response.set_error 5, "Supplied credentials do not match. Tough night out?"
    next
  end

end