#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ Harry's House of Hair ~~~~~\n"
echo -e "Welcome to Harry's, how can I help you?\n"

GET_SERVICES_ID() {
if [[ $1 ]]
then
  echo -e "\n$1"
fi

LIST_SERVICES=$($PSQL "SELECT * FROM services")
echo "$LIST_SERVICES" | while read -r SERVICE_ID BAR SERVICE
do
  ID=$(echo $SERVICE_ID | sed 's/ //g')
  NAME=$(echo $SERVICE | sed 's/ //g')
  echo "$ID) $NAME"
done

read SERVICE_ID_SELECTED
case $SERVICE_ID_SELECTED in
  [1-5]) NEXT ;;
  *) GET_SERVICES_ID "I could not find that service. What would you like today?" ;;
esac
}

NEXT() {
# get customer info
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
# if customer not found
if [[ -z $CUSTOMER_NAME ]] 
then
  # get new customer name
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  #insert new customer
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
fi

# get service name
GET_SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
SERVICE_NAME=$(echo $GET_SERVICE_NAME | sed 's/ //g')
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
# get service time
echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

# insert appointment
INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]
then
  echo -e "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
fi
}


GET_SERVICES_ID
