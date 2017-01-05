ActiveAdmin.register Game do

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
  permit_params :state, :scheduled_start

  filter :created_at
  filter :updated_at
  filter :state

  index do
    id_column
    column :created_at
    column :updated_at
    column :state
    # column :pieces  # todo: show pieces for this game only -- how? 
    column :scheduled_start
    # column :played_at
    actions
  end

#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end


end
