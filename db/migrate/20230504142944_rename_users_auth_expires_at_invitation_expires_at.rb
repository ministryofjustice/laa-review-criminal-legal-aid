class RenameUsersAuthExpiresAtInvitationExpiresAt < ActiveRecord::Migration[7.0]
  def change
    rename_column :users, :auth_expires_at, :invitation_expires_at
  end
end
