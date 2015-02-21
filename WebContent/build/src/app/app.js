angular.module( 'cfjs', [
  'templates-app',
  'templates-common',
  'cfjs.home',
  'cfjs.about',
  'ui.router',
  'leaflet-directive'
])

.config( function myAppConfig ( $stateProvider, $urlRouterProvider ) {
  $urlRouterProvider.otherwise( '/home' );
})

.run( function run () {
})

.controller( 'AppCtrl', function AppCtrl ( $scope, $location ) {
  $scope.$on('$stateChangeSuccess', function(event, toState, toParams, fromState, fromParams){
    if ( angular.isDefined( toState.data.pageTitle ) ) {
      $scope.pageTitle = toState.data.pageTitle + ' | Youth Deployment Locator' ;
    }
  });
})

;

