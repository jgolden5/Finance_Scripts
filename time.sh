#!/bin/bash
commute_and_work() {
  local waking_hours_per_week=112 #16 * 7
  local total_hours_commute_plus_work=0
  read -n1 -p "How many days do you work per week? " days_per_week
  echo
  for n in $(seq 1 $days_per_week); do
    read -p "Day $n: How many hours do you work? " hours_on_day_n
    read -p "How long is the average commute (each way, in minutes)? " commute_each_way_in_minutes
    local hours_commute_plus_work_on_day_n="$(echo "scale=2; $hours_on_day_n + $commute_each_way_in_minutes / 60 * 2" | bc)"
    echo "Day $n: Total hours commute + work = $hours_commute_plus_work_on_day_n hours"
    total_hours_commute_plus_work="$(echo "scale=2; $total_hours_commute_plus_work + $hours_commute_plus_work_on_day_n" | bc)"
  done
  echo "Total hours commute + work = $total_hours_commute_plus_work"
  local percent_time_awake_spent_on_work_and_commute="$(echo "scale=4; $total_hours_commute_plus_work / $waking_hours_per_week * 100" | bc)%"
  echo "Percent of time awake spent on work/commute = $percent_time_awake_spent_on_work_and_commute"
}
