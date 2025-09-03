# License Manager

Manage liceses for a group of Users

## Tech
- Ruby 3.4.5, Rails 8.0.2.1, Postgres, PG search.


## How to run Docker locally 

This project is fully Dockerized. To run first bundle then run the web service **exposing the 8080 port**:

```bash
docker compose run --rm web bundle
docker compose run --rm --service-ports web
```

The Docker entrypoint will prepare the database which will run the seeds.


## How to open a bash terminal

This command will build containers if not built before:

```bash
docker compose run --rm web bash
```


## Lint

Rubocop for code linting:

```bash
bundle exec rubocop
```


Bundler-audit for known vulnerabilities:

```bash
bundle exec bundler-audit check --update
```


Brakeman for static code analysis:

```bash
bundle exec brakeman
```


## Run tests

This project uses rspec ran through rake

```bash
bundle exec rake spec
```

