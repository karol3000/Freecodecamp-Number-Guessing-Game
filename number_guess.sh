#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
echo "Enter your username:"
read USERNAME

BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games INNER JOIN users USING(user_id) WHERE users.name='$USERNAME'")
if [[ ! -z $BEST_GAME ]]
then
  GAMES_PLAYES=$($PSQL "SELECT COUNT(*) FROM games INNER JOIN users USING(user_id) WHERE users.name='$USERNAME'")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYES games, and your best game took $BEST_GAME guesses."
else
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_RESULT=$($PSQL "INSERT INTO users(name) VALUES('$USERNAME')")
fi

echo -e "\nGuess the secret number between 1 and 1000:"
RANDOM_NUMBER=$((1 + $RANDOM % 1000))
read GUESS
NO_GUESSES=1
while [[ $GUESS != $RANDOM_NUMBER ]]
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  fi

  if [[ $GUESS > $RANDOM_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  fi

  if [[ $GUESS < $RANDOM_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
  fi
  read GUESS
  (( NO_GUESSES++ ))
done

USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME'")
INSERT_RESULT=$($PSQL "INSERT INTO games(user_id, guesses) VALUES ($USER_ID, $NO_GUESSES)")

echo "You guessed it in $NO_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"
