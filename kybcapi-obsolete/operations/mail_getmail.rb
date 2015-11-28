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

  pager = " order by mail_id desc limit ?, ?"

  sql_base = <<SQL
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
  mail_user=?
SQL
  base_columns = [:mail_id, :read, :from_user_id, :from_user_login, :timestamp, :body]
  @stm_base = db.prepare(sql_base + pager).column_names(*base_columns)
  @stm_by_content = db.prepare(sql_base + " and mail_text like ?" + pager).column_names(*base_columns)
  @stm_by_user_from = db.prepare(sql_base + " and mail_from=?" + pager).column_names(*base_columns)
  @stm_by_user_to = db.prepare(sql_base + "and mail_to=?" + pager).column_names(*base_columns)
  @stm_by_user_both = db.prepare(sql_base + "and (mail_to=? or mail_from=?)" + pager).column_names(*base_columns)

end

process_request do |request, response|

  stm = nil
  if request.no_filter?
    @stm_base.execute(request[:user_id], request[:pager_offset], request[:pager_limit])
    stm = @stm_base

  elsif request.by_content?
    @stm_by_content.execute(request[:user_id], "%#{request[:filter_by_content]}%",
                            request[:pager_offset], request[:pager_limit])
    stm = @stm_by_content

  elsif request.by_user_from?
    @stm_by_user_from.execute(request[:user_id], request[:filter_by_user],
                              request[:pager_offset], request[:pager_limit])
    stm = @stm_by_user_from

  elsif request.by_user_to?
    @stm_by_user_to.execute(request[:user_id], request[:filter_by_user],
                            request[:pager_offset], request[:pager_limit])
    stm = @stm_by_user_to

  elsif request.by_user_both?
    @stm_by_user_both.execute(request[:user_id], request[:filter_by_user], request[:filter_by_user],
                              request[:pager_offset], request[:pager_limit])
    stm = @stm_by_user_both

  else
    response.set_error 1, "Incorrect filtering options."
    next
  end

  response[:mail] = []
  stm.each_hash do |row|
    mail = Mail_mail.new(row)

    response[:mail] << mail
  end

end
