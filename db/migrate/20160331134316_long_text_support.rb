class LongTextSupport < ActiveRecord::Migration
  def up
    execute("ALTER TABLE `text_caches` MODIFY `data` LONGTEXT CHARACTER SET utf8 COLLATE utf8_general_ci;")
  end

  def down
    execute("ALTER TABLE `text_caches` MODIFY `data` TEXT CHARACTER SET utf8 COLLATE utf8_general_ci;")
  end
end
