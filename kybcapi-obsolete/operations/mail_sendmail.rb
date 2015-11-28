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
require 'cgi'

setup_hook do

  @stm_blocked_by = db.prepare(<<SQL
select user_id
from user_relation
where node_id = ? and relation_type = -3
SQL
  ).column_names(:user_id, :user_login)

  @stm_get_user_by_id = db.prepare("select u.user_id, u.login from users u where u.user_id = ?").
      column_names(:user_id, :user_login)
  @stm_get_user_by_login = db.prepare("select u.user_id, u.login from users u where u.login = ?").
      column_names(:user_id, :user_login)
  @stm_mail1 = db.prepare(<<SQL
insert into mail
set mail_user = ?, mail_read = 'no',
    mail_from = ?, mail_text = ?,
    mail_to = ?, mail_timestamp = NOW()
SQL
  )
  @stm_mail2 = db.prepare(<<SQL
insert into mail
set mail_duplicate_id = ?, mail_read = 'no',
    mail_user = ?, mail_from = ?, mail_text = ?,
    mail_to = ?, mail_timestamp = NOW()
SQL
  )
  @stm_user_mail = db.prepare(<<SQL
update users
set user_mail = user_mail + 1,
    user_mail_id = ?,
    last_action = last_action
where user_id = ?
SQL
  )

end

process_request do |request, response|

  delivery_receipts = []
  users_to = []

  # Lambda function which handles variety by parametrisation.
  # Sort of like template method design pattern, but in the Ruby's way.
  fill_users_to = ->(request_user_key, stm, delivery_key) {
    request[request_user_key].each do |u|
      if user = stm.execute(u).fetch_hash
        users_to << user
      else
        delivery_receipts << Mail_delivery_receipt.new(
            delivery_key => u,
            :status_code => Mail_delivery_receipt::Status_code::NO_SUCH_USER
        )
      end
    end }

  # Sending mail by user's id has a higher priority.
  if !request.user_id_to.nil? and !request.user_id_to.empty?
    fill_users_to.call(:user_id_to, @stm_get_user_by_id, :user_id)

  elsif !request.user_login_to.nil? and !request.user_login_to.empty?
    fill_users_to.call(:user_login_to, @stm_get_user_by_login, :user_login)

  else
    response.set_error 1, "user_id_to or user_login_to has to be set."
    next
  end

  users_to.uniq!

  blocked_by = @stm_blocked_by.execute(request.user_id_from).fetch_all_hash
  users_to.delete_if do |user_to|
    if blocked_by.find { |u| u[:user_id] == user_to[:user_id] }
      delivery_receipts << Mail_delivery_receipt.new(
          :user_id => users_to[:ui][:user_id],
          :user_login => users_to[:ui][:user_login],
          :status_code => Mail_delivery_receipt::Status_code::BLOCKED
      )
    else
      ; false
    end
  end

  users_to.each do |user_to|
    body = CGI::escape_html(request.body)
    @stm_mail1.execute(request.user_id_from, request.user_id_from,
                       body, user_to[:user_id])
    duplicate_id = @stm_mail1.insert_id
    @stm_mail2.execute(duplicate_id, user_to[:user_id],
                       request.user_id_from, body, user_to[:user_id])
    @stm_user_mail.execute(request.user_id_from, user_to[:user_id])

    delivery_receipts << Mail_delivery_receipt.new(
        :user_id => user_to[:user_id],
        :user_login => user_to[:user_login],
        :status_code => Mail_delivery_receipt::Status_code::OK
    )
  end

  response.delivery_receipt = delivery_receipts

end
