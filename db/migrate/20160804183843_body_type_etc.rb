class BodyTypeEtc < ActiveRecord::Migration
  def change
    remove_column :pieces, :job, :string
    rename_column :pieces, :hit_points, :health
    add_column :pieces, :body_type, :string
  end
end
