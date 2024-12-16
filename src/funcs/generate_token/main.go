package main

import (
	"io"
	"log"
	"net/http"
	"os"
	"strings"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

func handler(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	var postValidateTokenUrl = os.Getenv("BACKEND_URL")
	log.Printf("request-body: %v", request.Body)
	log.Printf("request-body-fmt: %v", strings.NewReader(request.Body))
	resp, err := http.Post(postValidateTokenUrl, "application/json", strings.NewReader(request.Body))
	if err != nil {
		log.Printf("Error getting access token: %v", err)
		return events.APIGatewayProxyResponse{
			Body:       "Error getting access token",
			StatusCode: 500,
		}, nil
	}

	//Get the access token from the response
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		log.Printf("Response: %s", body)
		log.Printf("Error reading access token response: %v", err)
		return events.APIGatewayProxyResponse{
			Body:       "Error reading access token response",
			StatusCode: 500,
		}, nil
	}
	defer resp.Body.Close()

	return events.APIGatewayProxyResponse{
		Body:       string(body),
		StatusCode: 200,
	}, nil
}

func main() {
	lambda.Start(handler)
}
