ActiveAdmin.register Player do
  # see https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md

  permit_params :name,
                :password,
                :team_name,
                :coins,
                :gems,
                :embodied,
                :admin

  filter :name
  filter :team_name, as: :select

  index do
    selectable_column
    column :id
    column :name
    column :team_name
    column :coins
    column :gems
    column :password_set? do |p|
      status_tag p.password_set?
    end
    column :embodied
    column :admin
    column :created_at
    column :updated_at
    column :activities_synced_at

    column "Fitbit User" do |player|
      if player.authenticated?
        span raw("&check;") + player.fitbit_token_hash['user_id'], style: 'display: inline-block; width: 3em'
        auth_label = "Re-Auth"
      else
        span "-", style: 'display: inline-block; width: 3em'
        auth_label = "Auth"
      end
      div do
        link_to auth_label, auth_player_path(player) + "?token=#{params[:token]}"  # todo: split out a web player controller and use auth_player_path
      end
    end
    actions defaults: false do |player|
      li link_to "Edit", edit_admin_player_path(player)
      # link_to "Delete", delete_admin_player_path(player) # no route? huh?
      li link_to "Activities",    admin_player_activities_path(player)
    end
  end

  form do |f|
    readonly = {readonly: true, style: 'background: #ddd'}
    inputs do
      f.semantic_errors
      f.input :name
      f.input :password_set?, as: :string, input_html: readonly
      f.input :password
      f.input :team_name, :as => :select, :collection => Team::ALL.values
      # https://github.com/justinfrench/formtastic/issues/171
      f.input :activities_synced_at, as: :string, input_html: readonly
      f.input :fitbit_token_hash, as: :string, input_html: readonly
      f.input :anti_forgery_token, input_html: readonly
      f.input :session_token, input_html: readonly
      f.input :coins
      f.input :gems
      f.input :embodied, as: :boolean
      f.input :admin, as: :boolean
      f.actions
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

# # https://github.com/justinfrench/formtastic/issues/171#issuecomment-174265846
# class ReadonlyInput < Formtastic::Inputs::StringInput
#   def to_html
#     puts "method=#{method}"
#     stuff = object.send(method)
#     wrapper_classes_raw
#     h = raw("<div>#{stuff.inspect}</div>")
#     input_wrapping do
#       label_html << h
#     end
#   end
#
#   def input_html_options
#     super + {readonly:
#   end
# end
