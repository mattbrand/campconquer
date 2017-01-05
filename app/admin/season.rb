ActiveAdmin.register Season do
  # see https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md

  permit_params :name,
                :current,
                :start_at

  filter :current

  index do
    column :id
    column :name
    column :current
    column :start_at
    actions defaults: false do |season|
      li link_to "Edit", edit_admin_season_path(season)
    end
  end

  form do |f|
    inputs do
      f.semantic_errors
      f.input :name
      f.input :current
      f.input :start_at
      f.actions
    end
  end
end
