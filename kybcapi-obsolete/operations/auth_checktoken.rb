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

no_database

process_request do |request, response|

  begin
    token = Auth::Token.new(cfg.params['auth']['secret']).assign(request.token)
  rescue Token::TokenException
    response.set_error error_codes(:invalid_token), error_messages(:invalid_token)
    next
  end

  response.is_expired = token.expired?(cfg.params['auth']['token_lifetime']) ?
      1 : 0
end
