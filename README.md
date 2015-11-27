# AWS API-Gateway Test Harness

This project contains a Rspec test harness that executes integration tests on the AWS API-Gateway created by project

## Building the Container
```
compose build harness
```

## Running the tests
These tests are run against a live instance of the Stockflare stack and expects to have real data available.

The Harness is configured through a `.env` file in the root path that requires the following environment variables


| Variable               | Example                                                         | Purpose                                                             |
|:-----------------------|:----------------------------------------------------------------|:--------------------------------------------------------------------|
| AWS_REGION             | us-east-1                                                       | AWS Region of the stack                                             |
| API_ENDPOINT           | https://xwivffe5jh.execute-api.us-east-1.amazonaws.com          | The base endpopint of the API, does not include the Stage           |
| API_STAGE              | staging                                                         | The stage that you want to test                                     |
| AUTHENTICATED_ROLE_ARN | arn:aws:iam::318741577598:role/UsersAPICognitoAuthenticatedRole | The Cognito Role that represents an Authenticated user              |
| TEST_USER              | name@example.com                                                | The user id that will log in for all tests, must exist and be valid |
| TEST_PASSWORD          | XXXXXX                                                          | The Test password that will be used to login.                       |

### Run all tests
```
compose run harness rspec
```
