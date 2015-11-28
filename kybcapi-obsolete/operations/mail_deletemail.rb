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

  @stm_read = db.prepare(<<SQL
select mail_read, mail_to from mail where mail_id=? and mail_from=?
SQL
  ).column_names :read, :mail_to
  @stm_del_dup = db.prepare(<<SQL
delete from mail where mail_duplicate_id=? and mail_from=?
SQL
  )
  @stm_update_user = db.prepare "update users set user_mail=user_mail-1 where user_id=?"
  @stm_del = db.prepare "delete from mail where mail_id=? and mail_user=?"

end

process_request do |request, response|

  response.deleted_mails = 0
  request.mail_id.each do |mail_id|
    read = @stm_read.execute(mail_id, request.user_id).fetch_hash
    next if not read

    if read[:read] == 'no'
      @stm_del_dup.execute mail_id, request.user_id
      @stm_update_user.execute request.user_id
    end

    @stm_del.execute mail_id, request.user_id
    response.deleted_mails += @stm_del.affected_rows
  end

end
