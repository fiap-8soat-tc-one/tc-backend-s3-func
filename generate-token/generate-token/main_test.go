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
	os.Setenv("GENERATE_TOKEN_URL", "http://example.com/token")

	tests := []struct {
		name           string
		requestBody    string
		mockResponse   string
		mockStatusCode int
		expectedBody   string
		expectedStatus int
	}{
		{
			name:           "Valid request",
			requestBody:    `{"document":"test"}`,
			mockResponse:   `{"access_token":"token123","profile":"profile123"}`,
			mockStatusCode: http.StatusOK,
			expectedBody:   `{"access_token":"token123","profile":"profile123"}`,
			expectedStatus: http.StatusOK,
		},
		{
			name:           "Invalid request body",
			requestBody:    `Not Found`,
			expectedBody:   "Error parsing request body",
			expectedStatus: http.StatusInternalServerError,
		},
		{
			name:           "Missing document parameter",
			requestBody:    `{"document":""}`,
			expectedBody:   "Please provide a document parameter",
			expectedStatus: http.StatusBadRequest,
		},
		{
			name:           "Error in parsing access token",
			requestBody:    `{"document":"test"}`,
			mockResponse:   `{"invalid_token":"token123"}`,
			mockStatusCode: http.StatusOK,
			expectedBody:   "Error parsing access token",
			expectedStatus: http.StatusInternalServerError,
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

			// Override the GENERATE_TOKEN_URL with the mock server URL
			os.Setenv("GENERATE_TOKEN_URL", server.URL)

			request := events.APIGatewayProxyRequest{
				Body: tt.requestBody,
			}

			response, err := handler(request)
			assert.NoError(t, err)
			assert.Equal(t, tt.expectedStatus, response.StatusCode)
			assert.Equal(t, tt.expectedBody, response.Body)
		})
	}
}
