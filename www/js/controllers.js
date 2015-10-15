var myApp;

myApp = angular.module('starter.controllers', ['ionic']);

myApp.saveData = function(key, value) {
  window.localStorage[key] = JSON.stringify(value);
  return JSON.parse(window.localStorage[key] || '{}');
};

myApp.settings = JSON.parse(window.localStorage.settings || '{}');

myApp.controller('DashCtrl', function($scope, $ionicLoading, $ionicPopup) {
  var baseWeatherURL, convertKelvinToCelsius, convertKelvinToFahrenheit, processWeatherData, saveWeatherData;
  baseWeatherURL = 'http://api.openweathermap.org/data/2.5/weather';
  $scope.cityNotFound = function(zip) {
    var alertPopup;
    alertPopup = $ionicPopup.alert({
      title: "City not found!",
      template: "We failed to find a city at " + zip
    });
    return alertPopup;
  };
  convertKelvinToFahrenheit = function(K) {
    return Math.floor((K - 273.15) * 1.8000 + 32.00);
  };
  convertKelvinToCelsius = function(K) {
    return Math.floor(K - 273.15);
  };
  saveWeatherData = function(data) {
    debugger;
    var datum, i, len, weatherData;
    weatherData = JSON.parse(window.localStorage['weatherData'] || '[]');
    if (weatherData.length > 0) {
      for (i = 0, len = weatherData.length; i < len; i++) {
        datum = weatherData[i];
        if (data.name === datum.name) {
          weatherData[datum] = data;
          myApp.saveData('weatherData', weatherData);
          return $scope.weatherData = weatherData;
        }
      }
    }
    weatherData.push(data);
    myApp.saveData('weatherData', weatherData);
    return $scope.weatherData = weatherData;
  };
  processWeatherData = function(data, zip, region) {
    var temperature_mode, weatherData;
    if (region == null) {
      region = 'us';
    }
    myApp.settings = JSON.parse(window.localStorage.settings || '{}');
    temperature_mode = myApp.settings.fahrenheit;
    weatherData = {
      zip: zip,
      region: region,
      name: data.name,
      description: data.weather[0].description,
      date_time: data.dt * 1000,
      original_data: data
    };
    if (temperature_mode) {
      weatherData.temp = convertKelvinToFahrenheit(data.main.temp);
      weatherData.temp_min = convertKelvinToFahrenheit(data.main.temp_min);
      weatherData.temp_max = convertKelvinToFahrenheit(data.main.temp_max);
    } else {
      weatherData.temp = convertKelvinToCelsius(data.main.temp);
      weatherData.temp_min = convertKelvinToCelsius(data.main.temp_min);
      weatherData.temp_max = convertKelvinToCelsius(data.main.temp_max);
    }
    return weatherData;
  };
  $scope.weatherPoll = function(zip, region) {
    if (region == null) {
      region = 'us';
    }
    $ionicLoading.show({
      template: 'Loading...'
    });
    return $.ajax({
      url: baseWeatherURL,
      type: 'get',
      data: {
        zip: zip,
        region: region,
        APPID: 'dd9f3e622ff8e3dde48856f172b598d8'
      },
      error: function(error) {
        $ionicLoading.hide();
        return console.log(error);
      },
      success: function(data) {
        debugger;
        var weatherData;
        if (data.cod === '404') {
          $scope.cityNotFound(zip);
        } else {
          weatherData = processWeatherData(data, zip, region);
          $scope.weatherData = saveWeatherData(weatherData);
        }
        return $ionicLoading.hide();
      }
    });
  };
  $scope.initializeDash = function() {
    var i, len, location, ref, results;
    $scope.weatherData = JSON.parse(window.localStorage['weatherData'] || '[]');
    ref = $scope.weatherData;
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      location = ref[i];
      console.debug("polling weather data for " + location.zip + ": " + location.region);
      results.push($scope.weatherPoll(location.zip, location.region));
    }
    return results;
  };
  return $scope.initializeDash();
});

myApp.controller('ChatsCtrl', function($scope, Chats) {
  $scope.chats = Chats.all();
  return $scope.remove = function(chat) {
    return Chats.remove(chat);
  };
});

myApp.controller('ChatDetailCtrl', function($scope, $stateParams, Chats) {
  return $scope.chat = Chats.get($stateParams.chatId);
});

myApp.controller('AccountCtrl', function($scope) {
  $scope.$watchCollection('settings', function() {
    var settings;
    myApp.saveData('settings', $scope.settings);
    settings = $scope.settings;
    return console.log(settings);
  });
  $scope.settings = JSON.parse(window.localStorage['settings'] || '{}');
  if ($scope.settings == null) {
    return $scope.settings = {
      enableFriends: true,
      fahrenheit: true
    };
  }
});
