#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon -t -c"

echo -e "\n~~~~~ SALON ~~~~~\n"


MENU(){
  echo -e "$1"
  echo -e "Welcome to My Salon, how can I help you?\n0) Exit"
  SERVICE=$($PSQL "SELECT service_id, name FROM services")
  echo "$SERVICE" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME" 
  done
  PICK
}
PICK(){
  read SERVICE_ID_SELECTED
  if [[ $SERVICE_ID_SELECTED == 0 ]]
  then
  echo "Thank you for visiting! Goodbye!"
    exit 0  # Exit the script
  fi
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  SERVICE_NAME=$(echo $SERVICE_NAME | sed 's/^ *//;s/ *$//')
  if [[ ! $SERVICE_ID_SELECTED =~ ^[1-5]$ ]]
  then
    MENU "I could not find that service. What would you like today?"
  else
    VALID=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    if [[ -z $VALID ]]
    then
      # Invalid service ID, show menu again
      MENU "I could not find that service. What would you like today?"
    else
      # Valid service, proceed further
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      if [[ -z $CUSTOMER_ID ]]
      then  
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
        echo -e "\nWhat time would you like your service, $CUSTOMER_NAME?"
        read SERVICE_TIME
      else
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID")
        CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed 's/^ *//;s/ *$//')
        echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
        read SERVICE_TIME
      fi  
        
        INSERT_TIME=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED)")
        echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi
}

# Start the menu
MENU
