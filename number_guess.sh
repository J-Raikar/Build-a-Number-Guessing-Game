#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

#Number Game
#___________

#Generate random number
NUMBER=$(($RANDOM % 1000))
NUMBER=$(($NUMBER + 1))

#Enter and check username
echo Enter your username:
read USERNAME_ENTERED
USER_INFO=$($PSQL "SELECT * FROM user_info WHERE username = '$USERNAME_ENTERED'")
if [[ -z $USER_INFO ]]
then
  IS_NEW=true
  USERNAME=$USERNAME_ENTERED
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  USERNAME=$($PSQL "SELECT username FROM user_info WHERE username = '$USERNAME_ENTERED'")
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM user_info WHERE username = '$USERNAME_ENTERED'")
  BEST_GAME=$($PSQL "SELECT best_game FROM user_info WHERE username = '$USERNAME_ENTERED'")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

#Start guessing game
echo "Guess the secret number between 1 and 1000:"
read GUESS
NUMBER_OF_GUESSES=1
while [[ $NUMBER != $GUESS ]]
do
  if [[ ! $GUESS =~ ^[0-9]*$ ]]
  then
    echo "That is not an integer, guess again:"
  else
    if [[ $GUESS > $NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    else
      echo "It's higher than that, guess again:"
    fi
  fi
  read GUESS
  NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES + 1))
done

#dubskiz
echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $NUMBER. Nice job!"

#update database
if [[ $IS_NEW ]]
then
  INSERT=$($PSQL "INSERT INTO user_info(username, games_played, best_game) VALUES('$USERNAME', 1, $NUMBER_OF_GUESSES)")
else 
  GAMES_PLAYED_NEW=$((GAMES_PLAYED + 1))
  INSERT=$($PSQL "UPDATE user_info SET games_played = $GAMES_PLAYED_NEW WHERE username = '$USERNAME'")
  if [[ $NUMBER_OF_GUESSES < $BEST_GAME ]]
  then
    INSERT=$($PSQL "UPDATE user_info SET best_game = $NUMBER_OF_GUESSES WHERE username = '$USERNAME'")
  fi
fi
