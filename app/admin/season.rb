ActiveAdmin.register Season do
  # see https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md

  permit_params :name,
                :current

  filter :current

  index do
    column :id
    column :name
    column :current
  end

  form do |f|
    inputs do
      f.semantic_errors
      f.input :name
      f.input :current
      f.actions
    end
  end
end
