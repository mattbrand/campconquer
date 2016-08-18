ActiveAdmin.register Player do

  permit_params :name, :team
  filter :name
  filter :team, as: :select

  index do
    selectable_column
    column :id
    column :name
    column :team
    column :created_at
    column :updated_at
    column "FitBit" do |player|
      if player.authenticated?
        span raw("&check;"), style: 'display: inline-block; width: 3em'
      else
        span "-", style: 'display: inline-block; width: 3em'
      end
      link_to "Auth", auth_player_path(player)
    end
    actions do |player|
    end
  end


# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end


end
