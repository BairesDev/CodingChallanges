# Building and running

Make sure you have docker and docker compose on your machine, so build everything with
```
$ docker-compose build
```

and run the tests with
```
$ docker-compose run --rm fooda rspec
```

if you want to run as a executable, try
```
$ docker-compose run --rm fooda rake reward spec/fixtures/sample_input.json
```

and if you want run it using a `irb` interface, just follow the steps on `bin/runner`

# Code structure

There's a [service](app/services/json_parser_service.rb) responsible for handle the JSON of input and respond with another JSON, containing the customer, the total of points and the number of orders.

In order to provide an exact response, based on the required format, there's a [representer](app/representers/rewards_representer.rb) responsible to parse the JSON received by the service and print in human format.

Everything is covered by tests and the final report can be checked on [here](coverage/index.html)

# Questions to answer

An initial problem could be a huge JSON because it's loaded in memory. Process the whole JSON everytime we want to know the rewards is also a kind of issue.
- Get data paginated filtering by a initial date could help with size and repeated registers.
- Use redis and ranked list could improve the process.

# 
