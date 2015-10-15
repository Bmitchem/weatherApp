

myApp = angular.module('starter.controllers', ['ionic'])

myApp.saveData = (key, value)->
  window.localStorage[key] = JSON.stringify(value)
  return JSON.parse(window.localStorage[key] or '{}')

myApp.settings = JSON.parse(window.localStorage.settings || '{}')

myApp.controller 'DashCtrl', ($scope, $ionicLoading, $ionicPopup) ->
  baseWeatherURL = 'http://api.openweathermap.org/data/2.5/weather'

  $scope.cityNotFound = (zip)->
    alertPopup = $ionicPopup.alert({
      title: "City not found!",
      template: "We failed to find a city at #{zip}",
    })
    return alertPopup


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

  processWeatherData = (data, zip, region='us') ->
    myApp.settings = JSON.parse(window.localStorage.settings || '{}')
    temperature_mode = myApp.settings.fahrenheit
    weatherData =
      zip: zip
      region: region
      name: data.name
      description: data.weather[0].description
      date_time: data.dt * 1000 #angular wants ms dates so lets give it some fucking ms dates
      original_data: data
    if temperature_mode
      weatherData.temp= convertKelvinToFahrenheit(data.main.temp)
      weatherData.temp_min= convertKelvinToFahrenheit(data.main.temp_min)
      weatherData.temp_max= convertKelvinToFahrenheit(data.main.temp_max)
    else
      weatherData.temp= convertKelvinToCelsius(data.main.temp)
      weatherData.temp_min= convertKelvinToCelsius(data.main.temp_min)
      weatherData.temp_max= convertKelvinToCelsius(data.main.temp_max)
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
        debugger
        if data.cod == '404'
          $scope.cityNotFound(zip)
        else
          weatherData = processWeatherData(data, zip, region)
          $scope.weatherData = saveWeatherData(weatherData)
        $ionicLoading.hide()
    )

  $scope.initializeDash = ->
    $scope.weatherData = JSON.parse(window.localStorage['weatherData'] or '[]')
    for location in $scope.weatherData
      console.debug "polling weather data for #{location.zip}: #{location.region}"
      $scope.weatherPoll(location.zip, location.region)

  $scope.initializeDash()

myApp.controller 'ChatsCtrl', ($scope, Chats) ->
  $scope.chats = Chats.all()
  $scope.remove = (chat) ->
    Chats.remove(chat)

myApp.controller 'ChatDetailCtrl', ($scope, $stateParams, Chats)->
  $scope.chat = Chats.get($stateParams.chatId)

myApp.controller 'AccountCtrl', ($scope) ->
  $scope.$watchCollection 'settings', ->
    myApp.saveData('settings', $scope.settings)
    settings = $scope.settings
    console.log(settings)

  $scope.settings = JSON.parse(window.localStorage['settings'] || '{}')
  if not $scope.settings?
    $scope.settings =
      enableFriends: true
      fahrenheit: true









