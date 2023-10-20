# frozen_string_literal: true

# Copyright (C) 2023 - present Instructure, Inc.
#
# This file is part of Canvas.
#
# Canvas is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, version 3 of the License.
#
# Canvas is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along
# with this program. If not, see <http://www.gnu.org/licenses/>.

class AddUniqueIndexOnUsersLtiId < ActiveRecord::Migration[7.0]
  tag :postdeploy
  disable_ddl_transaction!

  def up
    modify_non_deleted_users = Canvas::Plugin.value_to_boolean(ENV.fetch("AGGRESSIVE_UUID_CLEANUP", "0"))
    DataFixup::ResolveDuplicateUserUuids.run(column: :lti_id, modify_non_deleted_users:)

    add_index :users, :lti_id, unique: true, algorithm: :concurrently, if_not_exists: true, name: "index_users_on_unique_lti_id"
    remove_index :users, name: "index_users_on_lti_id", if_exists: true
  rescue ActiveRecord::RecordNotUnique
    # print an explanation that will appear after all the stack trace stuff
    at_exit do
      warn "\n** LTI ID conflicts exist for non-deleted users **\n" \
           "resolve these manually or rerun migrations with AGGRESSIVE_UUID_CLEANUP=1"
    end
    raise
  end

  def down
    add_index :users, :lti_id, algorithm: :concurrently, if_not_exists: true, name: "index_users_on_lti_id"
    remove_index :users, name: "index_users_on_unique_lti_id", if_exists: true
  end
end
