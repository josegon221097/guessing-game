#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
echo "Enter your username:"
read NAME
#read username's length
len=${#NAME}
#generate random number
RAN=$(( $RANDOM % 1000 + 1 ))

#check username length
if [[ $len -gt 22 ]]
then
  echo "Please, enter an username with less than 22 characters"

else
  #check if the username is already registered

  GET_USER=$($PSQL "SELECT username FROM users WHERE username='$NAME'")
  GET_GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$NAME'")
  GET_BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$NAME'")
  #if not registered
  if [[ -z $GET_USER ]]
  then

    echo "Welcome, $NAME! It looks like this is your first time here."
    CREATE_NEW_USER=$($PSQL "INSERT INTO users(username,games_played) VALUES('$NAME',1)")
    echo "Guess the secret number between 1 and 1000:"
    read GUESS
    if [[ $GUESS =~ ^[0-9]*$ ]]
    then
      cont=1
      #check if the input is an integer
      while [ $GUESS -ne $RAN ]
      do
        if [[ $GUESS =~ ^[0-9]*$ ]]
        then

          if [[ $GUESS -gt $RAN ]]
          then

            echo "It's lower than that, guess again:"
            read GUESS
            cont=$(( $cont + 1 ))

          elif [[ $GUESS -le $RAN ]]
          then

            echo "It's higher than that, guess again:"
            read GUESS
            cont=$(( $cont + 1 ))

          fi

          if [[ $GUESS -eq $RAN ]]
          then

            echo "You guessed it in $cont tries. The secret number was $RAN. Nice job!"
            CREATE_BEST_GAME=$($PSQL "UPDATE users SET best_game=$cont WHERE username='$NAME'")

          fi
      
        else
          echo "That is not an integer, guess again:"
        fi
      done
    else
      echo "That is not an integer, guess again:"
    fi
  else
    echo "Welcome back, $GET_USER! You have played $GET_GAMES_PLAYED games, and your best game took $GET_BEST_GAME guesses."
    echo "Guess the secret number between 1 and 1000:"
    read GUESS
    if [[ $GUESS =~ ^[0-9]*$ ]]
    then
      cont=1
    
      #check if the input is an integer
      while [ $GUESS -ne $RAN ]
      do
        if [[ $GUESS =~ ^[0-9]*$ ]]
        then

          if [[ $GUESS -gt $RAN ]]
          then

            echo "It's lower than that, guess again:"
            read GUESS
            cont=$(( $cont + 1 ))

          elif [[ $GUESS -le $RAN ]]
          then

            echo "It's higher than that, guess again:"
            read GUESS
            cont=$(( $cont + 1 ))

          fi

          if [[ $GUESS -eq $RAN ]]
          then

            echo "You guessed it in $cont tries. The secret number was $RAN. Nice job!"
            GAMES_PLAYED=$(( $GET_GAMES_PLAYED + 1 ))
            UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED WHERE username='$GET_USER'")
            PREVIOUS_BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$GET_USER'")
            if [[ $cont -le $PREVIOUS_BEST_GAME ]]
            then
              CHANGE_BEST_GAME=$($PSQL "UPDATE users SET best_game=$cont WHERE user='$GET_USER'")
            fi
          fi
        else
          echo "That is not an integer, guess again:"  
        fi
      done
    else
      echo "That is not an integer, guess again:"
    fi
  fi
fi
