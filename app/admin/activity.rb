ActiveAdmin.register Activity do
  belongs_to :player
  permit_params :date,
                :steps, :steps_claimed,
                :vigorous_minutes, :moderate_minutes,
                :moderate_minutes_claimed, :vigorous_minutes_claimed

end
