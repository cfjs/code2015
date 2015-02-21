/**
 * Each section of the site has its own module. It probably also has
 * submodules, though this boilerplate is too simple to demonstrate it. Within
 * `src/app/home`, however, could exist several additional folders representing
 * additional modules that would then be listed as dependencies of this one.
 * For example, a `note` section could have the submodules `note.create`,
 * `note.delete`, `note.edit`, etc.
 *
 * Regardless, so long as dependencies are managed correctly, the build process
 * will automatically take take of the rest.
 *
 * The dependencies block here is also where component dependencies should be
 * specified, as shown below.
 */
angular.module( 'cfjs.home', [
  'ui.router',
  'plusOne'
])

/**
 * Each section or module of the site can also have its own routes. AngularJS
 * will handle ensuring they are all available at run-time, but splitting it
 * this way makes each module more "self-contained".
 */
.config(function config( $stateProvider ) {
  $stateProvider.state( 'home', {
    url: '/home',
    views: {
      "main": {
        controller: 'HomeCtrl',
        templateUrl: 'home/home.tpl.html'
      }
    },
    data:{ pageTitle: 'Home' }
  });
})

/**
 * And of course we define a controller for our route.
 */
.controller('HomeCtrl', ['$scope', '$timeout', function HomeController( $scope, $timeout ) {
	$scope.keywords = '';
	$scope.startYear = 2012;
	$scope.endYear = 2012;
	$scope.years = [];
	// NSERC, SSHRC
	for (var i = 1991; i <= 2012; i++) {
		$scope.years.push(i);
	}
	$scope.years.reverse();
	
	$scope.height = $(document).height();
	angular.extend($scope, {
        center: {
            lat: 57.776061,
            lng: -101.712890,
            zoom: 3
        },
        defaults: {
            tileLayer: "http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            tileLayerOptions: {
                attribution: '© <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
            },
            icon: {
                url: 'http://cdn.leafletjs.com/leaflet-0.6.4/images/marker-icon.png',
                retinaUrl: 'http://cdn.leafletjs.com/leaflet-0.6.4/images/marker-icon@2x.png',
                size: [25, 41],
                anchor: [12, 40],
                popup: [0, -40],
                shadow: {
                    url: 'http://cdn.leafletjs.com/leaflet-0.6.4/images/marker-shadow.png',
                    retinaUrl: 'http://cdn.leafletjs.com/leaflet-0.6.4/images/marker-shadow.png',
                    size: [41, 41],
                    anchor: [12, 40]
                }
            }
        },
        events: {
            map: {
                enable: ['layeradd'],
                logic: 'emit'
            }
        }
    });
	
	var leftSidebar = L.control.sidebar('leftSidebar');
	$scope.controls = {
		custom: []	
	};
    $scope.controls.custom.push(leftSidebar);
    
    $timeout(function() {
        leftSidebar.show();
    }, 500);

    var rightSidebar = L.control.sidebar('rightSidebar', {
        position: 'right'
    });
    
    $scope.controls.custom.push(rightSidebar);
    
//    $timeout(function() {
//    	leftSidebar.hide();
//        rightSidebar.show();
//    }, 3500);
    
	$scope.performSearch = function() {
		console.log('search performed');
		leftSidebar.hide();

		var geoJson = {
			"type": "FeatureCollection",
			"features": [{
			    "type": "Feature",
			    "id": '0',
			    "properties": {
			        "name": "Université Laval",
			        "address": "123 Fake Street",
			        "popupContent": "To Be Determined"
			    },
			    "geometry": {
			        "type": "Point",
			        "coordinates": [-104.99404, 39.75621]
			    }
			}]
		};
		
		// TODO Center map on results
		if (geoJson.features.length > 0) {
			var lat = geoJson.features[0].geometry.coordinates[1];
			var lng = geoJson.features[0].geometry.coordinates[0];
			$scope.center = {
				lat: lat,
				lng: lng,
				zoom: 3
			};
			
			angular.extend($scope, {
				geojson: {
					data: geoJson,
					style: {
						fillColor: "green",
						weight: 2,
						opacity: 1,
						color: "white",
						dashArray: '3',
						fillOpacity: 0.7
					}
				}
			});
		}
		
//		// Get the countries geojson data from a JSON
//	    $http.get("examples/json/JPN.geo.json").success(function(data, status) {
//	        angular.extend($scope, {
//	            geojson: {
//	                data: data,
//	                style: {
//	                    fillColor: "green",
//	                    weight: 2,
//	                    opacity: 1,
//	                    color: 'white',
//	                    dashArray: '3',
//	                    fillOpacity: 0.7
//	                }
//	            }
//	        });
//	    });
	};
	
	$scope.selectedMarkerDetail = {};
	$scope.openMarkerDetail = function(marker) {		
		$scope.selectedMarkerDetail = {
			name: "Université Laval",
			address: "123 Fake Street",
			partners: [{
				name: "ETS"
			}],
			students: [{
				name: "JS",
				award: '400k'
			}]
		};

    	leftSidebar.hide();
    	rightSidebar.show();
	};
	
	 $scope.$on('leafletDirectiveMap.layeradd', function(scope, event){
		 event = event.leafletEvent;
		 console.log(event);
		 
	     var marker = event.layer;

	     // http://leafletjs.com/reference.html#popup
	     if (marker){
//		     marker.bindPopup(popupContent,{
//		         closeButton: false,
//		         minWidth: 320
//		     });
		     marker.on('click', function(e) {
		    	 if (e.target.feature) {
		    		 $scope.openMarkerDetail(e.target.feature.properties);
		    	 }
		     });
		     marker.on('mouseover', function(e) {
		    	 //$scope.openMarkerDetail(e.target.feature.properties);
		    	 console.log(e);
		     });
	     }
     });
}])

;

