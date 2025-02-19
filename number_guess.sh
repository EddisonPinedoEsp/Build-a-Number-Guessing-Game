#! /bin/bash
# Number Guessing Game
echo -e "\n\n~~Welcome to Number Guessing Game~~\n"

# Query database
PSQL="psql --username=freecodecamp --dbname=number_guess -Atc"

# Read username
echo "Enter your username:"
read USERNAME

# Allow usernames only between 3 and 22 characters (letters, digits, '-' and '_')
while ! [[ "$USERNAME" =~ ^[[:alpha:][:digit:]_-]{3,22}$ ]]
do
  echo "Sorry, '$USERNAME' name is not allowed, please try another one:"
  read USERNAME
done

# Search current user in database
USER_ID="$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")"

if [[ -z $USER_ID ]]
then
  # Insert new user
  INSERT_NEW_USER="$($PSQL "INSERT INTO users(username) VALUES('$USERNAME');")"
  # Get new user ID
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
else
  # Get data from existing user
  GET_USER_GAMES_DATA="$($PSQL "SELECT COUNT(*), MIN(result) FROM games WHERE user_id = $USER_ID;")"
  IFS="|" read GAMES_PLAYED BEST_GAME <<< "$GET_USER_GAMES_DATA"
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.\n"
fi

# Start game
# Generate a random number between 1 and 1000
SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))

# Get user's guess
echo -e "\nGuess the secret number between 1 and 1000:"
read USER_GUESS

# Initiate number of guesses
NUMBER_OF_GUESSES=1

while [[ "$USER_GUESS" != "$SECRET_NUMBER" ]]
do
  if ! [[ "$USER_GUESS" =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  else
    if [[ "$USER_GUESS" -gt "$SECRET_NUMBER" ]]
    then
      echo "It's lower than that, guess again:"
    else
      echo "It's higher than that, guess again:"
    fi
    ((NUMBER_OF_GUESSES++))
  fi
  read USER_GUESS
done

# Insert new game
INSERT_NEW_GAME="$($PSQL "INSERT INTO games(user_id, result) VALUES($USER_ID, $NUMBER_OF_GUESSES);")"

# Congratulation message
echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
