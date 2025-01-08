#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to my Salon, how can I help you?\n"

LIST_SERVICES() {
  echo -e "\nHere are the services we offer:"
  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo "$SERVICES" | while IFS="|" read SERVICE_ID NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
}

CREATE_APPOINTMENT() {
  
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  
  CUST_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  if [[ -z $CUST_ID ]]; then
    
    echo -e "\nI don't have a record for that phone number. What's your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    CUST_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  fi

  
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed -E 's/^ +| +$//g')

  
  echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED, $(echo $CUSTOMER_NAME | sed -E 's/^ +| +$//g')?"
  read SERVICE_TIME

  
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUST_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -E 's/^ +| +$//g')."
}

MAIN_MENU() {
  LIST_SERVICES
  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]; then
    echo -e "\nInvalid input. Please select a service by number."
    MAIN_MENU
  else
    SERVICE_EXISTS=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_EXISTS ]]; then
      echo -e "\nInvalid service ID. Please select again."
      MAIN_MENU
    else
      CREATE_APPOINTMENT
    fi
  fi
}

MAIN_MENU