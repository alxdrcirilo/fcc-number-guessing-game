#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=numbers -t -c"

NUMBER_TO_GUESS=$((RANDOM % 1000 + 1))

echo "Enter your username:"
read USERNAME

if [[ -z $USERNAME ]]; then
    echo "No username input given."
    exit 1
else
    USER=$($PSQL "SELECT * FROM users WHERE name = '$USERNAME'")

    # Insert USER in database if new
    if [[ -z $USER ]]; then
        USER_INSERT=$($PSQL "INSERT INTO users(name) VALUES('$USERNAME')")
        echo "Welcome, $USERNAME! It looks like this is your first time here."
    else
        echo $USER | while read USER BAR USERNAME BAR GAMES_PLAYED BAR BEST_GAME; do
            echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
        done
    fi
fi

GUESSES=0

GUESS() {
    read USER_INPUT
    # Check if the input is an integer
    if [[ $USER_INPUT =~ ^[0-9]+$ ]]; then
        if [[ "$USER_INPUT" -gt "$NUMBER_TO_GUESS" ]]; then
            echo "It's lower than that, guess again:"
            ((GUESSES++))
            GUESS
        elif [[ "$USER_INPUT" -lt "$NUMBER_TO_GUESS" ]]; then
            echo "It's higher than that, guess again:"
            ((GUESSES++))
            GUESS
        else
            ((GUESSES++))
            echo "You guessed it in $GUESSES tries. The secret number was $NUMBER_TO_GUESS. Nice job!"

            # Increment number of games played
            RESULT=$($PSQL "UPDATE users SET games_played = games_played +1")

            # Update best game score if necessary
            BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE name = '$USERNAME'")

            if [[ "$GUESSES" -lt "$BEST_GAME" ]]; then
                RESULT=$($PSQL "UPDATE users SET best_game = $GUESSES WHERE name = '$USERNAME'")
            fi
        fi
    else
        echo "That is not an integer, guess again:"
        GUESS
    fi
}

# Run the number guessing game
echo "Guess the secret number between 1 and 1000:"
GUESS
