package main

import (
	"log"
	"net/http"
	"os"
	"strings"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

func handler(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	var validateTokenUrl = os.Getenv("BACKEND_URL")
	var authorizationHeader = request.Headers["Authorization"]

	if authorizationHeader == "" {
		return events.APIGatewayProxyResponse{
			Body:       "Required Authorization header",
			StatusCode: 401,
		}, nil
	}

	requestBody := `{"access_token":"` + authorizationHeader + `"}`
	resp, err := http.Post(validateTokenUrl, "application/json", strings.NewReader(requestBody))
	if err != nil {
		log.Printf("Error validating access token: %v", err)
		return events.APIGatewayProxyResponse{
			Body:       "Error validating access token",
			StatusCode: 500,
		}, nil
	}

	return events.APIGatewayProxyResponse{
		StatusCode: resp.StatusCode,
	}, nil
}

func main() {
	lambda.Start(handler)
}
