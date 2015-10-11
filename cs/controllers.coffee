saveData = (key, value)->
  window.localStorage['key'] = JSON.stringify(value)
  return JSON.parse(window.localStorage[key] or '{}')

settings = JSON.parse(window.localStorage.settings || '{}')
settings = {}

myApp = angular.module('starter.controllers', ['ionic'])

myApp.controller 'DashCtrl', ($scope, $ionicLoading) ->
  baseWeatherURL = 'http://api.openweathermap.org/data/2.5/weather'
  $scope.weatherData = JSON.parse(window.localStorage['weatherData'] or '[]')

  convertKelvinToFahrenheit = (K) ->
    return (K-273.15) * 1.8000 + 32.00

  convertKelvinToCelsius = (K) ->
    return K - 273.15

  processWeatherData = (data) ->
    temperature_mode = settings.fahrenheit || true

    if temperature_mode
      weatherData =
        name: data.name
        description: data.weather[0].description
        temp: convertKelvinToFahrenheit(data.main.temp)
        temp_min: convertKelvinToFahrenheit(data.main.temp_min)
        temp_max: convertKelvinToFahrenheit(data.main.temp_max)
    else
      weatherData =
        name: data.name
        description: data.weather[0].description
        temp: convertKelvinToCelsius(data.main.temp)
        temp_min: convertKelvinToCelsius(data.main.temp_min)
        temp_max: convertKelvinToCelsius(data.main.temp_max)
    return weatherData

  $scope.weatherPoll = (zip, region = 'us') ->
    $ionicLoading.show({
      template: 'Loading...'
    })
    $.ajax(
      url: baseWeatherURL
      type: 'get'
      data:
        zip: zip
        region: region
        APPID: 'dd9f3e622ff8e3dde48856f172b598d8'
      error: (error) ->
        $ionicLoading.hide()
        console.log(error)
      success: (data) ->
        $ionicLoading.hide()
        $scope.weatherData.push(processWeatherData(data))
        saveData('weatherData', $scope.weatherData)
    )



  $scope.weatherPoll('22314', 'us')

myApp.controller 'ChatsCtrl', ($scope, Chats) ->
  $scope.chats = Chats.all()
  $scope.remove = (chat) ->
    Chats.remove(chat)

myApp.controller 'ChatDetailCtrl', ($scope, $stateParams, Chats)->
  $scope.chat = Chats.get($stateParams.chatId)

myApp.controller 'AccountCtrl', ($scope) ->
  $scope.watchCollection 'settings', ->
    saveData('settings', $scope.settings)
    settings = $scope.settings
    console.log(settings)

  $scope.settings = JSON.parse(window.localStorage['settings'] || '{}')
  if not $scope.settings?
    $scope.settings =
      enableFriends: true
      fahrenheit: true









