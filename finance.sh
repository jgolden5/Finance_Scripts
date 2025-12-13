#!/bin/bash

wages_from_annual() {
  if [[ ! "$1" ]]; then
    read -p "Enter annual wage: " a
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
    if (( $(echo "$hours_a_week > 40" | bc -l) )); then
      overtime="$(echo "scale=2; $hours_a_week - 40" | bc)"
      hours_a_week=40
    fi
    if [[ $weekly_wage ]]; then
      weekly_wage="$(echo "scale=2; $weekly_wage + $hours_a_week * $wage" | bc)"
    else
      weekly_wage="$(echo "scale=2; $hours_a_week * $wage" | bc)"
    fi
    if [[ "$overtime" ]]; then
      overtime_wage="$(echo "scale=2; $overtime * $wage * 1.5" | bc)"
      echo "$overtime hours of overtime were added [\$$overtime_wage]"
      weekly_wage="$(echo "scale=2; $weekly_wage + $overtime_wage" | bc)"
    fi
    echo "weekly wage = $weekly_wage"
  done
  echo "Total weekly wage is $weekly_wage"
}

compare_hourly_wage_difference_per_month() {
  read -p "Please enter constant wage, followed by number of weekly hours at said wage: " constant_wage constant_hours
  read -p "Please enter current wage (before increase), followed by hours: " before_var_wage before_var_hours
  read -p "Please enter imagined wage (after increase), followed by hours: " after_var_wage after_var_hours
  constant_hours=${constant_hours:-40}
  before_var_hours=${before_var_hours:-40}
  after_var_hours=${after_var_hours:-40}
  before="$(echo "scale=2; ($before_var_wage * $before_var_hours + $constant_wage * $constant_hours) * 4.33" | bc)"
  after="$(echo "scale=2; ($after_var_wage * $after_var_hours + $constant_wage * $constant_hours) * 4.33" | bc)"
  difference="$(echo "scale=2; $after - $before" | bc)"
  echo "Before = $before"
  echo "After = $after"
  color=
  if (( $(echo "$difference >= 0" | bc -l) )); then
    color="\e[32m"
  else
    color="\e[31m"
  fi
  echo -e "${color}Difference = \$$difference\e[0m per month"
}

annual_gross_to_net_single() {
  local gross="$1"
  local percentage_kept=
  if [[ $gross -le 11000 ]]; then
    percentage_kept="0.875"
  elif [[ $gross -le 44725 ]]; then
    percentage_kept="0.855"
  elif [[ $gross -le 95375 ]]; then
    percentage_kept="0.755"
  elif [[ $gross -le 182100 ]]; then
    percentage_kept="0.735"
  elif [[ $gross -le 231250 ]]; then
    percentage_kept="0.655"
  elif [[ $gross -le 578125 ]]; then
    percentage_kept="0.625"
  else
    percentage_kept="0.605"
  fi
  net=$(echo "scale=2; $gross * $percentage_kept" | bc)
  taxes=$(echo "scale=2; $gross - $net" | bc)
  echo "Gross = \$$gross"
  echo "Taxes =~ \$$taxes"
  echo
  echo "Take home pay summary (Net Income):"
  echo "Annual =~ \$$net"
  wages_from_annual $net
}

annual_gross_to_net_married_filing_jointly() {
  local gross="$1"
  local percentage_kept=
  if [[ $gross -le 22000 ]]; then
    percentage_kept="0.875"
  elif [[ $gross -le 89450 ]]; then
    percentage_kept="0.855"
  elif [[ $gross -le 190750 ]]; then
    percentage_kept="0.755"
  elif [[ $gross -le 364200 ]]; then
    percentage_kept="0.735"
  elif [[ $gross -le 462500 ]]; then
    percentage_kept="0.655"
  elif [[ $gross -le 693750 ]]; then
    percentage_kept="0.625"
  else
    percentage_kept="0.605"
  fi
  net=$(echo "scale=2; $gross * $percentage_kept" | bc)
  taxes=$(echo "scale=2; $gross - $net" | bc)
  echo "Gross = \$$gross"
  echo "Taxes =~ \$$taxes"
  echo
  echo "Take home pay summary (Net Income):"
  echo "Annual =~ \$$net"
  wages_from_annual $net
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

four_walls_percentage_of_net_monthly_income() {
  if [[ $1 ]]; then
    local net_income="$1"
    local food=450
    local utilities=125
    local transportation=662
    local shelter=1650.59
    local four_walls_total=$(math_bash "$food + $utilities + $transportation + $shelter")
    local four_walls_decimal="$(echo "scale=4; $four_walls_total / $net_income" | bc)"
    local margin_decimal="$(math_bash "1 - $four_walls_decimal")"
    local margin_total="$(math_bash "$net_income - $four_walls_total")"
    local four_walls_percentage="$(math_bash "$four_walls_decimal * 100")"
    local margin_percentage="$(math_bash "$margin_decimal * 100")"
    echo "Net monthly:  100% = \$$net_income"
    echo "Four walls: ${four_walls_percentage::-2}% = \$$four_walls_total"
    echo "Margin:     ${margin_percentage::-2}% = \$$margin_total"
  else
    echo "Please enter an income as parameter 1 for this function"
  fi
}

baby_steps() { #$1 = margin in budget per month; $2 = dollars remaining till goal. Also note that the month calculations are assuming the current month was ALREADY paid for, so subtract difference from this month BEFORE running calucations
  if [[ "$1" ]] && [[ "$2" ]]; then
    local margin="$1"
    local dollars_remaining="$2"
    local quotient_before_rounding="$(echo "scale=2; $dollars_remaining / $margin" | bc)"
    local months_to_goal="$(echo "scale=2; $quotient_before_rounding + 1" | bc | sed 's/\(.*\)\..*/\1/')"
    if [[ "$(($dollars_remaining % $margin))" == 0 ]]; then
      ((months_to_goal--))
    fi
  else
    echo "2 parameters are required"
    echo "\$1 = margin in budget per month; \$2 = dollars remaining till goal. For example, if I have \$500 margin in my budget per month and I have \$2,500 remaining on my baby step goal, I would run this function like this: \"baby_steps 500 2500\""
  fi
  echo "Months to goal = $months_to_goal ($quotient_before_rounding)"
  echo "At a pace of \$$margin per month, goal of \$$dollars_remaining will be achieved by $(get_months_from_now $months_to_goal)"
}

get_months_from_now() {
  local n="$1"
  local current_month="$(date +%-m)"
  local current_year="$(date +%Y)"
  local months_from_current_year_start="$((n + current_month))"
  local target_month=$((months_from_current_year_start % 12))
  local target_year=$((months_from_current_year_start / 12 + current_year))
  if [[ $target_month == 0 ]]; then
    target_month=12
    $((--target_year))
  fi
  date -d "$target_month/1/$target_year" +"%B %Y"
}

raise() {
  if [[ $1 ]] && [[ $2 ]]; then
    local original_wage="$1"
    local percent_raise="$2"
    local raise="$(echo "scale=2; $original_wage + $original_wage * $percent_raise" | bc)"
    echo "From \$$original_wage to \$$raise"
  else
    echo "Please enter: raise \$original_wage \$percent_raise"
  fi
}

compound_interest() { #$1 = amount invested per year; $2 = interest rate; $3 = number of years; $4 = continuous contributions? t/f - true by default
  if [[ $1 ]] && [[ $2 ]] && [[ $3 ]]; then
    local amount_invested_per_year="$1"
    local current_investment=$amount_invested_per_year
    local continuous_contributions="$4"
    for i in $(seq $3); do
      if [[ $i == 1 ]] && [[ $continuous_contributions != f ]] && [[ $continuous_contributions != n ]]; then
        echo "Year 1 = $current_investment"
      else
        local amount_added="$(echo "scale=2; $current_investment * ($2 / 100)" | bc)"
        current_investment="$(echo "scale=2; $current_investment + $amount_added" | bc)"
        if [[ $continuous_contributions != f ]]; then
          current_investment="$(echo "scale=2; $current_investment + $amount_invested_per_year" | bc)"
        fi
        echo "Year $i = $current_investment"
      fi
    done
  else
    echo "Expected parameters: \$1 = amount invested per year; \$2 = interest rate (in terms of the percentage. E.g. 10 = 10%); \$3 = number of years; \$4 = continuous contributions? t/f - true by default"
  fi
}

time_equivalence_for_different_wages() { #$1 = original wage, $2 = other wage, $3 = number of hours
  local original_wage=$1
  local other_wage=$2
  local number_of_hours=$3
  if [[ $1 ]] && [[ $2 ]] && [[ $3 ]]; then
    local before="$(echo "scale=2; $original_wage * $number_of_hours" | bc)"
    local after="$(echo "scale=2; $other_wage * $number_of_hours" | bc)"
    local difference="$(echo "scale=2; $after - $before" | bc)"
    echo "\$$original_wage an hour for $number_of_hours hours = \$$before"
    echo "\$$other_wage an hour for $number_of_hours hours = \$$after"
    color=
    if (( $(echo "$difference >= 0" | bc -l) )); then
      color="\e[32m"
    else
      color="\e[31m"
    fi
    echo -e "${color}Difference = \$$difference\e[0m"
  else
    echo "\$1 = original wage, \$2 = other wage, \$3 = number of hours"
  fi
}

print_remaining_pay_days() { #$1 = any payday date (in format "YYYY-MM-DD"); $2 (optional) = -f flag which removes the limit on the year, causing the pay days to continue to be printed forever until the user quits the program
  local pay_day="$1"
  local flag="$2"
  local next_pay_day=$pay_day
  local original_pay_year="$(echo $pay_day | sed 's/\([0-9][0-9][0-9][0-9]\).*/\1/')"
  if [[ $flag == '-f' ]]; then
    echo "Remaining pay days:"
  else
    echo "Remaining pay days for $original_pay_year:"
  fi
  local pay_year=$original_pay_year
  while [[ $pay_year == "$original_pay_year" ]] || [[ $flag == '-f' ]]; do
    echo "$next_pay_day"
    next_pay_day="$(date -I -d "$next_pay_day + 2 weeks")"
    pay_year="$(echo $next_pay_day | sed 's/\([0-9][0-9][0-9][0-9]\).*/\1/')"
  done
}

check_third_paycheck() { #equal to print_remaining_pay_days parameters
  local remaining_pay_days=$(print_remaining_pay_days $1)
  local months=("01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12")
  for month in "${months[@]}"; do
    local number_of_paychecks_this_month=$(echo "$remaining_pay_days" | grep -- "-${month}-" | wc -l)
    local month_name=
    case $month in
      01)
        month_name=January
        ;;
      02)
        month_name=February
        ;;
      03)
        month_name=March
        ;;
      04)
        month_name=April
        ;;
      05)
        month_name=May
        ;;
      06)
        month_name=June
        ;;
      07)
        month_name=July
        ;;
      08)
        month_name=August
        ;;
      09)
        month_name=September
        ;;
      10)
        month_name=October
        ;;
      11)
        month_name=November
        ;;
      12)
        month_name=December
        ;;
    esac
    if [[ $number_of_paychecks_this_month -gt 0 ]]; then
      echo "$number_of_paychecks_this_month paychecks in $month_name"
    fi
  done
}

equalize_wage() { #$1 = original hourly wage; $2 = number of hours; $3 = compared hourly wage; return value = number of hours required to equalize wage
  if [[ $1 && $2 && $3 ]]; then
    local original_hourly_wage="$1"
    local original_number_of_hours="$2"
    local original_total_wage="$(echo "scale=2; $original_hourly_wage * $original_number_of_hours" | bc)"
    local compared_hourly_wage="$3"
    local number_of_hours_to_equalize="$(echo "scale=2; $original_total_wage / $compared_hourly_wage" | bc)"
    ORANGE="\e[33m"
    YELLOW="\e[93m"
    GREEN="\e[32m"
    PURPLE="\e[35m"
    BLUE="\e[34m"
    NOCOLOR="\e[0m"
    echo -e "total     = ${ORANGE}\$$original_total_wage ${NOCOLOR}"
    echo -e "before    = ${YELLOW}\$$original_hourly_wage ${NOCOLOR}for ${PURPLE}$original_number_of_hours ${NOCOLOR}hours"
    echo -e "equalized = ${GREEN}\$$compared_hourly_wage ${NOCOLOR}for ${BLUE}${number_of_hours_to_equalize} ${NOCOLOR}hours" 
  else
    echo 'Please enter paramaters as follows: $1 = original hourly wage; $2 = number of hours; $3 = compared hourly wage; return value = number of hours required to equalize wage'
  fi
}

view_functions() {
  grep '()' finance.sh | grep -v 'grep'
}

alias vf="view_functions"
