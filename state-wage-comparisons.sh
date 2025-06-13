#!/bin/bash
get_state_amount() {
  case $1 in
    arkansas)
      echo 1.17
      ;;
    mississippi)
      echo 1.16
      ;;
    alabama)
      echo 1.16
      ;;
    west_virginia)
      echo 1.14
      ;;
    kentucky)
      echo 1.14
      ;;
    south_dakota)
      echo 1.14
      ;;
    oklahoma)
      echo 1.13
      ;;
    ohio)
      echo 1.13
      ;;
    missouri)
      echo 1.13
      ;;
    louisiana)
      echo 1.12
      ;;
    iowa)
      echo 1.12
      ;;
    indiana)
      echo 1.12
      ;;
    nebraska)
      echo 1.12
      ;;
    kansas)
      echo 1.11
      ;;
    north_dakota)
      echo 1.10
      ;;
    south_carolina)
      echo 1.10
      ;;
    new_mexico)
      echo 1.10
      ;;
    north_carolina)
      echo 1.09
      ;;
    wisconsin)
      echo 1.09
      ;;
    michigan)
      echo 1.08
      ;;
    idaho)
      echo 1.08
      ;;
    wyoming)
      echo 1.08
      ;;
    georgia)
      echo 1.08
      ;;
    montana)
      echo 1.07
      ;;
    arizona)
      echo 1.04
      ;;
    utah)
      echo 1.04
      ;;
    texas)
      echo 1.03
      ;;
    nevada)
      echo 1.03
      ;;
    minnesota)
      echo 1.03
      ;;
    pennsylvania)
      echo 1.03
      ;;
    illinois)
      echo 1.02
      ;;
    delaware)
      echo 1.01
      ;;
    rhode_island)
      echo 1.01
      ;;
    maine)
      echo 1.00
      ;;
    florida)
      echo 0.99
      ;;
    oregon)
      echo 0.99
      ;;
    colorado)
      echo 0.98
      ;;
    virginia)
      echo 0.98
      ;;
    vermont)
      echo 0.97
      ;;
    alaska)
      echo 0.95
      ;;
    new_hampshire)
      echo 0.94
      ;;
    connecticut)
      echo 0.94
      ;;
    washington)
      echo 0.93
      ;;
    maryland)
      echo 0.92
      ;;
    massachusetts)
      echo 0.91
      ;;
    new_jersey)
      echo 0.87
      ;;
    california)
      echo 0.87
      ;;
    dc)
      echo 0.86
      ;;
    new_york)
      echo 0.86
      ;;
    hawaii)
      echo 0.85
      ;;
    *)
      echo "State not recognized"
      exit 1
  esac
}

price_of_good_in_state() {
  #note that each of the base prices of the following items are based on their average price in the state of Maine, which is the exact middle of states when it comes to inflated vs deflated usd
  good="$1"
  state="$2"
  state_amount=$(get_state_amount $state)
  case "$good" in
    egg|eggs|dozen_eggs)
      name_of_good="A dozen eggs"
      amount=5.84
      ;;
    *)
      echo "Sorry, the good \"$good\" was not recognized"
      ;;
  esac
  if [[ $name_of_good && $cost_in_state ]]; then
    cost_in_state=$(echo "scale=2; $amount / $state_amount" | bc)
    echo "In $2, the average price of $name_of_good is \$$cost_in_state"
  else
    echo "Please specify the name of the good (\$1) AND the state for which you want to know the price of said good (\$2)"
  fi
}
