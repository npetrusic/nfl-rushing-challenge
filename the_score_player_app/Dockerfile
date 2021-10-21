FROM elixir:1.12-alpine as build

#Copy the source folder into the Docker image
RUN mkdir /the_score_player_app
COPY . /the_score_player_app
WORKDIR /the_score_player_app

#Install hex and rebar
RUN mix local.hex --force && \
    mix local.rebar --force

#Install dependencies and compile
RUN export MIX_ENV=dev && \
    rm -Rf _build && \
    rm -Rf deps && \
    mix deps.get && \
    mix compile

CMD ["sh", "/the_score_player_app/entrypoint.sh"]