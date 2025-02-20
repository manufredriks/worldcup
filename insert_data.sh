#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
# Limpiar las tablas antes de insertar nuevos datos
echo $($PSQL "TRUNCATE TABLE games, teams RESTART IDENTITY")

# Leer el archivo CSV y procesar los datos
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Omitir la primera línea (encabezado)
  if [[ $YEAR != "year" ]]
  then
    # Verificar si el equipo ganador ya está en la base de datos y obtenemos team_id
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    if [[ -z $TEAM_ID ]] #vemos si la variable team_id esta vacia
    then
      # Insertar el equipo ganador
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      echo "Inserted team: $WINNER"
    fi

    # Verificar si el equipo oponente ya está en la base de datos
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    if [[ -z $TEAM_ID ]] #vemos si la variable team_id esta vacia o no
    then
      #Insertar el equipo ganador
      INSERT_TEAM_OPPONENT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      echo "Inserted team: $OPPONENT"
    fi 
    # Obtener los IDs de los equipos
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
  # Insertar el juego en la tabla games
  INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year,round,winner_goals,opponent_goals,winner_id,opponent_id) VALUES($YEAR,'$ROUND',$WINNER_GOALS,$OPPONENT_GOALS,$WINNER_ID,$OPPONENT_ID)")
  echo "Inserted game: $YEAR, $ROUND, $WINNER vs $OPPONENT ($WINNER_GOALS-$OPPONENT_GOALS)"
  fi  
done