package main

import (
	"net/http"
	"net/http/httptest"
	"os"
	"testing"

	"github.com/aws/aws-lambda-go/events"
	"github.com/stretchr/testify/assert"
)

func TestHandler(t *testing.T) {
	os.Setenv("VALIDATE_TOKEN_URL", "http://example.com/validate")

	tests := []struct {
		name           string
		headers        map[string]string
		mockResponse   string
		mockStatusCode int
		expectedBody   string
		expectedStatus int
	}{
		{
			name:           "Valid Authorization header",
			headers:        map[string]string{"Authorization": "valid_token"},
			mockResponse:   `{"status":"valid"}`,
			mockStatusCode: http.StatusOK,
			expectedBody:   "",
			expectedStatus: http.StatusOK,
		},
		{
			name:           "Missing Authorization header",
			headers:        map[string]string{},
			expectedBody:   "Required Authorization header",
			expectedStatus: http.StatusUnauthorized,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// Mock HTTP server
			server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				w.WriteHeader(tt.mockStatusCode)
				w.Write([]byte(tt.mockResponse))
			}))
			defer server.Close()

			// Override the VALIDATE_TOKEN_URL with the mock server URL
			os.Setenv("VALIDATE_TOKEN_URL", server.URL)

			request := events.APIGatewayProxyRequest{
				Headers: tt.headers,
			}

			response, err := handler(request)
			assert.NoError(t, err)
			assert.Equal(t, tt.expectedStatus, response.StatusCode)
			assert.Equal(t, tt.expectedBody, response.Body)
		})
	}
}
