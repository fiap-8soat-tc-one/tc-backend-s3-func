package main

import (
	"log"
	"net/http"
	"os"
	"strings"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

func handler(request events.APIGatewayCustomAuthorizerRequest) (events.APIGatewayCustomAuthorizerResponse, error) {
	validateTokenUrl := os.Getenv("BACKEND_URL")
	log.Printf("validation-toke-url: %v", validateTokenUrl)

	// Extrai o método e caminho do recurso da requisição
	resourcePath := request.MethodArn // ARN do recurso inclui o método e o path
	log.Printf("Resource ARN: %v", resourcePath)

	// Critério: Se o path contiver "/api/private/*", negar acesso imediatamente
	if strings.Contains(resourcePath, "/api/private/") {
		log.Printf("Access denied for path: %v", resourcePath)
		return events.APIGatewayCustomAuthorizerResponse{
			PrincipalID: "user",
			PolicyDocument: events.APIGatewayCustomAuthorizerPolicy{
				Version: "2012-10-17",
				Statement: []events.IAMPolicyStatement{
					{
						Action:   []string{"execute-api:Invoke"},
						Effect:   "Deny",
						Resource: []string{"*"}, // Nega acesso global
					},
				},
			},
		}, nil
	}

	// Extração do token
	authorizationToken := request.AuthorizationToken
	requestBody := `{"access_token": "` + authorizationToken + `" }`
	log.Printf("validation-toke-body: %v", requestBody)

	// Validação do token no backend
	_, err := http.Post(validateTokenUrl, "application/json", strings.NewReader(requestBody))

	if err != nil {
		log.Printf("Error validating access token: %v", err)
		return events.APIGatewayCustomAuthorizerResponse{
			PrincipalID: "user",
			PolicyDocument: events.APIGatewayCustomAuthorizerPolicy{
				Version: "2012-10-17",
				Statement: []events.IAMPolicyStatement{
					{
						Action:   []string{"execute-api:Invoke"},
						Effect:   "Deny",
						Resource: []string{"*"}, // Nega acesso global
					},
				},
			},
		}, nil
	}

	// Token válido - permite acesso
	return events.APIGatewayCustomAuthorizerResponse{
		PrincipalID: "user",
		PolicyDocument: events.APIGatewayCustomAuthorizerPolicy{
			Version: "2012-10-17",
			Statement: []events.IAMPolicyStatement{
				{
					Action:   []string{"execute-api:Invoke"},
					Effect:   "Allow",
					Resource: []string{"*"}, // Permite acesso global
				},
			},
		},
	}, nil
}

func main() {
	lambda.Start(handler)
}
