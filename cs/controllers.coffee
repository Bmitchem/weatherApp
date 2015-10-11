

myApp = angular.module('starter.controllers', ['ionic'])

myApp.saveData = (key, value)->
  window.localStorage[key] = JSON.stringify(value)
  return JSON.parse(window.localStorage[key] or '{}')

myApp.settings = JSON.parse(window.localStorage.settings || '{}')

myApp.controller 'DashCtrl', ($scope, $ionicLoading) ->
  baseWeatherURL = 'http://api.openweathermap.org/data/2.5/weather'
  $scope.weatherData = JSON.parse(window.localStorage['weatherData'] or '[]')
  console.log($scope.weatherData)

  convertKelvinToFahrenheit = (K) ->
    return Math.floor((K-273.15) * 1.8000 + 32.00)

  convertKelvinToCelsius = (K) ->
    return Math.floor(K - 273.15)

  saveWeatherData = (data) ->
    debugger
    weatherData = JSON.parse(window.localStorage['weatherData'] or '[]')
    if weatherData.length > 0
      for datum in weatherData
        if data.name == datum.name
          weatherData[datum] = data
          myApp.saveData('weatherData', weatherData)
          return $scope.weatherData = weatherData

    weatherData.push(data)
    myApp.saveData('weatherData', weatherData)
    $scope.weatherData = weatherData




  processWeatherData = (data) ->
    temperature_mode = myApp.settings.fahrenheit || true

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
        weatherData = processWeatherData(data)
        $scope.weatherData = saveWeatherData(weatherData)
    )

myApp.controller 'ChatsCtrl', ($scope, Chats) ->
  $scope.chats = Chats.all()
  $scope.remove = (chat) ->
    Chats.remove(chat)

myApp.controller 'ChatDetailCtrl', ($scope, $stateParams, Chats)->
  $scope.chat = Chats.get($stateParams.chatId)

myApp.controller 'AccountCtrl', ($scope) ->
  $scope.watchCollection 'settings', ->
    myApp.saveData('settings', $scope.settings)
    settings = $scope.settings
    console.log(settings)

  $scope.settings = JSON.parse(window.localStorage['settings'] || '{}')
  if not $scope.settings?
    $scope.settings =
      enableFriends: true
      fahrenheit: true









