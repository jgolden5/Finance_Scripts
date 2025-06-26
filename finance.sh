#!/bin/bash

wages_from_annual() {
  if [[ ! "$1" ]]; then
    read -p "Enter annual wage: " a
    if [[ $a ]]; then
      annual=$a
    fi
  else
    a="$1"
  fi
  get_monthly_from_annual $a
  get_biweekly_from_annual $a
  get_weekly_from_annual $a
  get_daily_from_annual $a
  get_hourly_from_annual $a
}

get_monthly_from_annual() {
  monthly_from_annual="$(echo "$1 / 12" | bc)"
  echo "Monthly ~= \$$monthly_from_annual"
}

get_biweekly_from_annual() {
  biweekly_from_annual="$(echo "$1 / 26" | bc)"
  echo "Bi-weekly ~= \$$biweekly_from_annual"
}

get_weekly_from_annual() {
  weekly_from_annual="$(echo "$1 / 52" | bc)"
  echo "Weekly ~= \$$weekly_from_annual"
}

get_daily_from_annual() {
  daily_from_annual="$(echo "scale=2; $1 / 52 / 5" | bc)"
  echo "Daily ~= \$$daily_from_annual"
}

get_hourly_from_annual() {
  hourly_from_annual="$(echo "scale=2; $1 / 52 / 40" | bc)"
  echo "Hourly ~= \$$hourly_from_annual"
}

overtime() {
  wage="$1"
  if [[ "$2" ]]; then
    hours="$2"
  else
    hours=60
  fi
  overtime_hours=$(echo "scale=2; $hours - 40" | bc)
  overtime_calculation="$(echo "scale=2; $wage * 40 + $wage * 1.5 * $overtime_hours" | bc)"
  echo "Overtime for \$$wage an hour at $hours hours a week = $overtime_calculation"
}

hours_per_day_per_week() { #40 8 5; (hours per week, hours per day, days per week)
  hours_per_week="$1"
  hours_per_day="$2"
  days_per_week="$3"
  if [[ ! $1 =~ [0-9] ]]; then
    hours_per_week="$(echo "scale=2; $hours_per_day * $days_per_week" | bc)"
    echo "Working $hours_per_day hours a day for $days_per_week days per week means you're working $hours_per_week hours per week"
  elif [[ ! $2 =~ [0-9] ]]; then
    hours_per_day="$(echo "scale=2; $hours_per_week / $days_per_week" | bc)"
    echo "Working for $hours_per_week hours a week for $days_per_week days per week means you must work $hours_per_day hours per day"
  elif [[ ! $3 =~ [0-9] ]]; then
    days_per_week="$(echo "scale=2; $hours_per_week / $hours_per_day" | bc)"
    echo "Working for $hours_per_week hours a week for $hours_per_day hours per day means you must work $days_per_week days per week"
  fi
}

math_bash() {
  echo "scale=2; $@" | bc
}

add_weekly_wages() {
  local weekly_wage=
  for wage in "$@"; do
    read -p "How many hours a week will you work at \$$wage an hour? " hours_a_week
    local overtime=
    if [[ $hours_a_week -gt 40 ]]; then
      overtime="$((hours_a_week - 40))"
      hours_a_week=40
    fi
    if [[ $weekly_wage ]]; then
      weekly_wage="$(echo "scale=2; $weekly_wage + $hours_a_week * $wage" | bc)"
    else
      weekly_wage="$(echo "scale=2; $hours_a_week * $wage" | bc)"
    fi
    if [[ "$overtime" ]]; then
      weekly_wage="$(echo "scale=2; $weekly_wage + $overtime * $wage * 1.5" | bc)"
    fi
    echo "weekly wage = $weekly_wage"
  done
  echo "Total weekly wage is $weekly_wage"
}

rank_wage() {
  read -n1 -p "Which type of wage do you want to rank? (a)nnual/(y)early, (m)onthly, (b)iweekly, (w)eekly, (d)aily, or (h)ourly: " wage_type
  echo
  case $wage_type in
    a|y) column=2; echo -n "Annual: ";;
    m)   column=3; echo -n "Monthly: ";;
    b)   column=4; echo -n "Bi-weekly: ";;
    w)   column=5; echo -n "Weekly: ";;
    d)   column=6; echo -n "Daily: ";;
    h)   column=7; echo -n "Hourly: ";;
    *)
      echo "Sorry, wage type \"$wage_type\" is not recognized. Exiting this function now."
      return 1
      ;;
  esac
  awk -v limit="$1" -v col="$column" '
  {
    if ($(col) <= limit) {
      wage_letter = $9
      prev_line = $0
    } else {
      print wage_letter
      print prev_line
      exit
    }
  }
  ' gross_wages.txt | tee output.txt
  local letter="$(awk '{ print $NF }' output.txt)"
  grep " $letter" net_wages.txt
  rm output.txt
}
