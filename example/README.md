# OpenWeatherApp

Demonstrates how to use the http_interceptor plugin. Due to CORS policies, this example does not fetch data when it is ran on Flutter Web, but it does work if you configure your own server properly or a proxy setup is used like the [CORS anywhere demo on Github](https://github.com/Rob--W/cors-anywhere).

## Getting Started

This app implements the usage of the http_interceptor plugin. It uses the OpenWeatherAPI and intercepts the requests done to add the App Id Key and the unit system desired for the response. Notice that this example is for **show purposes only, it is not intended as a full testable implementation**.

### Running the example

In order to run this example locally you will need to replace the API Key in the `credentials.dart`. You can get your own at <https://openweathermap.org/>
