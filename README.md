# Bowling score api app

Live demo: https://bowling-scoreboard.herokuapp.com/documentation#/v1

# Guide to use:
1. Create a game using POST `/api/v1/games` api

2. Use PUT `/api/v1/:id/add_score` to add score continuously.
Server will calculate and give updated response after each successful request.

3. After all throws are done, server will mark the game as finished and won't accept any further update requet


# Gem / Technology used

1. PostgreSQL as database
2. Grape for Api framework
3. Swagger for Api doucumentation
4. Rspec, Airborne for test


# Project Structure

1. Api controllers located inside `app/controllers/api/v1` folder.
2. Only one model Game, score_info column responsible for storing game score as a json object
3. Logic for updating and calculating scores handled by a service class "Game::UpdateScore" (app/services/game/)
2. Rspec tests can be found inside `spec/models`,  `spec/requests/api/v1/` & `spec/services/game/` folders.
