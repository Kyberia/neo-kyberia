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

# TODO Limit the number of rows in the output.

setup_hook do

  # Be careful with column names. They are directly mapped to the protobuf message.
  # So their names must match.
  @statement = db.prepare(<<SQL
select
  mail.mail_id,
  if(mail.mail_read='no',0,1),
  userfrom.user_id,
  userfrom.login,
  date_format(mail.mail_timestamp, "%e.%c. %k:%i:%s"),
  mail.mail_text
from mail left join users as userfrom on
  mail_from=userfrom.user_id left join users as userto on mail_to=userto.user_id
where
  mail_user=? and mail_duplicate_id is not null and mail_read='no'
SQL
  ).column_names(:mail_id, :read, :from_user_id, :from_user_login, :timestamp, :body)

end

process_request do |request, response|

  @statement.execute(request.user_id)

  response[:mail] = []
  @statement.each_hash do |row|
    # Because row's column names are the same as protobuf message fields,
    # we can just pass the row hash.
    mail = Mail_mail.new row

    response[:mail] << mail
  end

end