total_wage=0

read -p "Enter hourly wage here: " hourly_wage
secondly_wage="$(echo "scale=6; $hourly_wage / 60 / 60" | bc)"
number_of_seconds=0
echo "Hourly wage = $hourly_wage"
echo "Secondly wage = $secondly_wage"

update_wage() {
  total_wage="$(echo "scale=4; $total_wage + $secondly_wage" | bc)"
}

while true; do
  clear
  number_of_seconds="$(($number_of_seconds + 1))"
  update_wage
  if [[ $number_of_seconds == 1 ]]; then
    echo -n "$number_of_seconds second has passed. "
  else
    echo -n "$number_of_seconds seconds have passed. "
  fi
  echo "Current wage = \$$total_wage"
  sleep 0.75
done
