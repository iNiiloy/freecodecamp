#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

# Validate username length
if [[ ${#USERNAME} -gt 22 ]]; then
  echo "Username cannot exceed 22 characters."
  exit 1
fi

RESULT=$($PSQL "SELECT username, games_played, best_game FROM number_guess WHERE username='$USERNAME'")
IFS='|' read -r DB_USERNAME GAMES_PLAYED BEST_GAME <<< "$RESULT"

if [[ -z $DB_USERNAME ]]; then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER=$($PSQL "INSERT INTO number_guess(username) VALUES('$USERNAME')")
  if [[ $? -ne 0 ]]; then
    echo "Error: Could not add user to the database."
    exit 1
  fi
  GAMES_PLAYED=0
  BEST_GAME=1000
else
  echo "Welcome back, $DB_USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi
# Generate secret number
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
echo "Guess the secret number between 1 and 1000:"
NUMBER_OF_GUESSES=0

# Guessing loop
while true; do
  read GUESS

  # Validate input
  if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi
# Increment guess count
  NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES + 1))

  # Compare guess with secret number
  if [[ $GUESS -lt $SECRET_NUMBER ]]; then
    echo "It's higher than that, guess again:"
  elif [[ $GUESS -gt $SECRET_NUMBER ]]; then
    echo "It's lower than that, guess again:"
  else
    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    break
  fi
done
# Update game statistics
GAMES_PLAYED=$((GAMES_PLAYED + 1))
if [[ $NUMBER_OF_GUESSES -lt $BEST_GAME ]]; then
  BEST_GAME=$NUMBER_OF_GUESSES
fi

# Update database
UPDATE_RESULT=$($PSQL "UPDATE number_guess SET games_played=$GAMES_PLAYED, best_game=$BEST_GAME WHERE username='$USERNAME'")
if [[ $? -ne 0 ]]; then
  echo "Error: Could not update user data in the database."
  exit 1
fi
