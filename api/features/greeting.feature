Feature:
  In order to prove that the default installation runs properly I want a test for the default entity

  Scenario: Greeting is accessible
    When I send a "GET" request to "greetings"
    Then the response status code should be 200