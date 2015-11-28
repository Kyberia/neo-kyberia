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

setup_hook do

  @statement = db.prepare(<<SQL
select
  t1.mail_from, t2.login
from
  mail t1, users t2
where
  t1.mail_user=? and t1.mail_to=? and t1.mail_read='no' and t1.mail_from=t2.user_id
SQL
  ).column_names(:id, :login)

end

process_request do |request, response|

  @statement.execute(request.user_id, request.user_id)

  response[:count] = 0
  response[:from_whom] = []
  @statement.each_hash do |row|
    response[:count] += 1
    from_whom = Mail_newmail_resp_from_whom.new(row)

    response[:from_whom] << from_whom
  end

end

