package main

import (
	"encoding/json"
	"io"
	"log"
	"net/http"
	"os"
	"strings"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/go-playground/validator/v10"
)

func handler(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	var postValidateTokenUrl = os.Getenv("POST_GENERATE_TOKEN_URL")
	requestBody := struct {
		Document string `json:"document"`
	}{}
	err := json.Unmarshal([]byte(request.Body), &requestBody)
	if err != nil {
		log.Printf("Error parsing request body: %v", err)
		return events.APIGatewayProxyResponse{
			Body:       "Error parsing request body",
			StatusCode: 500,
		}, nil
	}

	if requestBody.Document == "" {
		return events.APIGatewayProxyResponse{
			Body:       "Please provide a document parameter",
			StatusCode: 400,
		}, nil
	}

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

	// Validate the response before returning it
	accessTokenResponse := struct {
		AccessToken string `json:"access_token" validate:"required"`
		Profile     string `json:"profile" validate:"required"`
	}{}
	err = json.Unmarshal(body, &accessTokenResponse)
	if err != nil || validator.New().Struct(accessTokenResponse) != nil {
		log.Printf("Response: %s", body)
		log.Printf("Error parsing access token: %v", err)
		return events.APIGatewayProxyResponse{
			Body:       "Error parsing access token",
			StatusCode: 500,
		}, nil
	}

	return events.APIGatewayProxyResponse{
		Body:       string(body),
		StatusCode: 200,
	}, nil
}

func main() {
	lambda.Start(handler)
}
