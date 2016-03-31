class UmlautSupporedCollation < ActiveRecord::Migration
  def up
    execute("ALTER TABLE `blurbs` MODIFY `key` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin;")
  end

  def down
    execute("ALTER TABLE `blurbs` MODIFY `key` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci;")
  end
end
