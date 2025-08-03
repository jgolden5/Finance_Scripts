#!/bin/bash
get_state_house_inflation() {
  case $1 in
    alabama)
      echo 0.6370
      ;;
    alaska)
      echo 1.0051
      ;;
    arizona)
      echo 1.2271
      ;;
    arkansas)
      echo 0.5718
      ;;
    california)
      echo 2.2006
      ;;
    colorado)
      echo 1.5505
      ;;
    connecticut)
      echo 1.1051
      ;;
    delaware)
      echo 1.0763
      ;;
    dc)
      echo 1.7559
      ;;
    florida)
      echo 1.1282
      ;;
    georgia)
      echo 0.9255
      ;;
    hawaii)
      echo 2.4129
      ;;
    idaho)
      echo 1.2755
      ;;
    illinois)
      echo 0.7226
      ;;
    indiana)
      echo 0.6659
      ;;
    iowa)
      echo 0.6004
      ;;
    kansas)
      echo 0.6250
      ;;
    kentucky)
      echo 0.5653
      ;;
    louisiana)
      echo 0.5588
      ;;
    maine)
      echo 1.1003
      ;;
    maryland)
      echo 1.1672
      ;;
    massachusetts)
      echo 1.7152
      ;;
    michigan)
      echo 0.6687
      ;;
    minnesota)
      echo 0.9290
      ;;
    mississippi)
      echo 0.4935
      ;;
    missouri)
      echo 0.6848
      ;;
    montana)
      echo 1.2891
      ;;
    nebraska)
      echo 0.7228
      ;;
    nevada)
      echo 1.2259
      ;;
    new_hampshire)
      echo 1.3084
      ;;
    new_jersey)
      echo 1.4478
      ;;
    new_mexico)
      echo 0.8406
      ;;
    new_york)
      echo 1.3032
      ;;
    north_carolina)
      echo 0.9276
      ;;
    north_dakota)
      echo 0.7133
      ;;
    ohio)
      echo 0.6261
      ;;
    oklahoma)
      echo 0.5734
      ;;
    oregon)
      echo 1.4013
      ;;
    pennsylvania)
      echo 0.7350
      ;;
    rhode_island)
      echo 1.2617
      ;;
    south_carolina)
      echo 0.8279
      ;;
    south_dakota)
      echo 0.8414
      ;;
    tennessee)
      echo 0.8959
      ;;
    texas)
      echo 0.8588
      ;;
    utah)
      echo 1.4651
      ;;
    vermont)
      echo 1.0727
      ;;
    virgina)
      echo 1.0862
      ;;
    washington)
      echo 1.6562
      ;;
    west_virginia)
      echo 0.4472
      ;;
    wisconsin)
      echo 0.8236
      ;;
    wyoming)
      echo 0.9628
      ;;
    *)
      echo "State not recognized"
      exit 1
  esac
}

house_price_conversion() { #$1 = state 1; $2 state 2; $3 = dollar amount in state 1; output = dollar conversion of $3 from state 1 ($1) to state 2 ($2)
  local state_1="$(get_state_house_inflation $1)"
  local state_2="$(get_state_house_inflation $2)"
  local house_1_price="$3"
  echo "$1 = $state_1"
  echo "$2 = $state_2"
  echo "Average House Price in $1 = \$$house_1_price"
  #for example, house_1_price_conversion california mississippi 10000000
  local house_2_price="$(echo "scale=2; $house_1_price * $state_2 / $state_1" | bc)"
  if [[ $house_2_price == .* ]]; then
    house_2_price="\$0$house_2_price"
  else
    house_2_price="\$$house_2_price"
  fi
  echo "Price in $2 = $house_2_price"
}

price_of_good_in_state() {
  #note that each of the base prices of the following items are based on their average price in the state of Maine, which is the exact middle of states when it comes to inflated vs deflated usd
  good="$1"
  state="$2"
  state_amount=$(get_state_house_inflation $state)
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
