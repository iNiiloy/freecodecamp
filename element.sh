PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"
SYM=$1
if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
else
  
  #check input is a number
  if [[ $SYM =~ ^[0-9]+$ ]]; then
    #get data by atomic number
      EL_DATA=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements FULL JOIN properties USING(atomic_number) FULL JOIN types USING(type_id) WHERE atomic_number=$SYM")
  else
    #check if input is fewer than 2 letters
    if [[ ${#SYM} -le 2 ]]; then
        #get data by symbol
      EL_DATA=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements FULL JOIN properties USING(atomic_number) FULL JOIN types USING(type_id) WHERE symbol='$SYM'")
    else
          #get data by full name
      EL_DATA=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements FULL JOIN properties USING(atomic_number) FULL JOIN types USING(type_id) WHERE name='$SYM'")
    fi
  fi

  if [[ -z $EL_DATA ]]; then
    echo "I could not find that element in the database."
  else
    IFS='|' read -r ATOMIC_NUMBER NAME SYMBOL TYPE ATOMIC_MASS MELTING_POINT_CELSIUS BOILING_POINT_CELSIUS<<< "$EL_DATA"
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT_CELSIUS celsius and a boiling point of $BOILING_POINT_CELSIUS celsius."
  fi
fi
