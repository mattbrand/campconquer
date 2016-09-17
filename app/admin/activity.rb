ActiveAdmin.register Activity do
  belongs_to :player
  permit_params :date,
                :steps, :steps_claimed,
                :active_minutes,
                :active_minutes_claimed

end
