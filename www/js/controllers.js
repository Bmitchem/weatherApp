var saveData = function(key, value){
  window.localStorage['key'] = JSON.stringify(value);
  return JSON.parse(window.localStorage[key] || '{}');
};

var settings = JSON.parse(window.localStorage['settings'] || '{}');

angular.module('starter.controllers', ['ionic'])


.controller('DashCtrl', function($scope, $ionicLoading){
    var baseWeatherUrl = 'http://api.openweathermap.org/data/2.5/weather';

    $scope.weatherData = JSON.parse(window.localStorage['weatherData'] || '[]');
    $scope.settings = settings;
    var convertKelvinToFahrenheit = function(K){
      return (K - 273.15)* 1.8000 + 32.00;
    };

    var convertKelvinToCelsius = function(K){
      return (K - 273.15);
    };

    var processWeatherData = function(data){
      var temperature_mode = settings.fahrenheit;
      if(temperature_mode == true || temperature_mode == undefined){
        return {
          'name': data.name,
          'description': data.weather[0].description,
          'temp': convertKelvinToFahrenheit(data.main.temp),
          'temp_min': convertKelvinToFahrenheit(data.main.temp_min),
          'temp_max': convertKelvinToFahrenheit(data.main.temp_max)
        }
      }else{
        return {
          'name': data.name,
          'description': data.weather[0].description,
          'temp': convertKelvinToCelsius(data.main.temp),
          'temp_min': convertKelvinToCelsius(data.main.temp_min),
          'temp_max': convertKelvinToCelsius(data.main.temp_max)
        }
      }



    };



    $scope.weatherPoll = function(zip, region){
        $ionicLoading.show({
          template: 'Loading...'
        });
        $.ajax({
          url: baseWeatherUrl,
          type: 'get',
          data: {'zip':zip+','+region},
        }).then(function(data){
          if(data.cod == 404){
            console.debug(data);
            console.debug("Zip: "+zip +", region: " + region);
          }else{
            //i want the newest information at the top
            $ionicLoading.hide();
            $scope.weatherData.push(processWeatherData(data));
            saveData('weatherData', $scope.weatherData);
          }

        });

    };
    //load some initial data
    $scope.weatherPoll('22314', 'us');


  })

.controller('ChatsCtrl', function($scope, Chats) {
  // With the new view caching in Ionic, Controllers are only called
  // when they are recreated or on app start, instead of every page change.
  // To listen for when this page is active (for example, to refresh data),
  // listen for the $ionicView.enter event:
  //
  //$scope.$on('$ionicView.enter', function(e) {
  //});

  $scope.chats = Chats.all();
  $scope.remove = function(chat) {
    Chats.remove(chat);
  };
})

.controller('ChatDetailCtrl', function($scope, $stateParams, Chats) {
  $scope.chat = Chats.get($stateParams.chatId);
})

.controller('AccountCtrl', function($scope) {
    $scope.$watchCollection('settings', function(){
      saveData('settings', $scope.settings);
    });

    $scope.settings = JSON.parse(window.localStorage['settings'] || '{}');
    if($scope.settings.enableFriends == undefined){
      $scope.settings = {
        enableFriends: true,
        fahrenheit: true,
      };
    }

    $scope.$watchCollection('settings', function(){
      console.log('changed');
      saveData('settings', $scope.settings);
      settings = $scope.settings;
    });
})
