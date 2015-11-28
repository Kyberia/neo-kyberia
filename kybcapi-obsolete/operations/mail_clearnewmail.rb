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

  @stm_newmails = db.prepare(<<SQL
select mail_id, mail_duplicate_id
from mail
where mail_user=? and mail_to=? and mail_read='no'
SQL
  ).column_names(:mail_id, :mail_duplicate_id)
  @stm_mark_read = db.prepare(<<SQL
update mail set mail_read='yes' where mail_id=?
SQL
  )
  @stm_update_user = db.prepare(<<SQL
update users set user_mail=if(user_mail-?<0, 0, user_mail-?) where user_id=?
SQL
  )

end

process_request do |request, response|

  @stm_newmails.execute(request.user_id, request.user_id)
  affected_mails = 0
  @stm_newmails.each_hash do |mail|
    @stm_mark_read.execute(mail[:mail_id])
    @stm_mark_read.execute(mail[:mail_duplicate_id])
    affected_mails += 1
  end
  @stm_update_user.execute(affected_mails, affected_mails, request.user_id)

  response.affected_mails = affected_mails

end
