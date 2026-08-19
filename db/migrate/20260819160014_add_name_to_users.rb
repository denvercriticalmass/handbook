class AddNameToUsers < ActiveRecord::Migration[8.1]
  def up
    add_column :users, :name, :string

    # Accounts predating the column: the local part of the address is the
    # closest thing to a name they have.
    execute "UPDATE users SET name = initcap(split_part(email_address, '@', 1))"

    change_column_null :users, :name, false
  end

  def down
    remove_column :users, :name
  end
end
