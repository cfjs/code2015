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

    var leftSideBarButton = L.easyButton('fa-bars', function() {
    	rightSidebar.hide();
        leftSidebar.toggle();
	}, 'Open side menu', '');
    
    $scope.controls.custom.push(leftSideBarButton);
    
    $scope.searching = false;
	$scope.performSearch = function() {
		$scope.searching = true;
//		$.ajax({
//			  url: "http://167.88.46.149/service/?keywords=" + $scope.keywords,
//			  type: "GET",
//			  crossDomain: true,
//			  success: callbackSuccess,
//			  error: callbackFailure,
//			  dataType: "jsonp",
//			  username: "user",
//			  password: "password123",
//			  contentType: "application/json"
//			});
		var query = "service/?keywords=" + $scope.keywords;
		$.get(query).success(callbackSuccess).fail(callbackFailure);
		
		function callbackSuccess(data, status) {
	        angular.extend($scope, {
	            geojson: {
	                data: data,
					pointToLayer: function(feature, latlng){
					/*
						return L.circleMarker(latlng, {
							radius:8,
							fillColor: "#000",
							color: "#000",
							opacity: 1,
							fillOpacity: 1
						});
						
					*/
						return L.marker(latlng, {
							icon: new L.icon({ 
								iconUrl: "assets/university.png",
								iconSize: [32, 32],
								iconAnchor: [16, 16]
							})
						});
					}
				}
	        });
			leftSidebar.hide();
			$scope.searching = false;
		}
		
		function callbackFailure(error) {
			// TODO message to user
			console.log(error);
			$scope.searching = false;
		}
	};


	$scope.selectedMarkerDetail = {};
	$scope.openMarkerDetail = function(marker) {		
		$scope.selectedMarkerDetail = {
			name: marker.name,
			address: marker.address,
			students: marker.students
		};

    	leftSidebar.hide();
    	rightSidebar.show();
	};
	
	 $scope.$on('leafletDirectiveMap.layeradd', function(scope, event){
		 event = event.leafletEvent;
		 
	     var marker = event.layer;

	     // http://leafletjs.com/reference.html#popup
	     if (marker) {
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
		    	 //console.log(e);
		     });
	     }
     });
	 
	 $scope.retrieveLinkedInSearchUrl = function(person) {
		 var names = person.name.split(',');
		 var lastName = names[0].trim();
		 var firstName = names.length > 1 ? names[1].trim() : '';
		 
		 return 'https://www.linkedin.com/pub/dir/?first=' + firstName + '&last=' + lastName + '&search=Search';
	 };
	 
	 $scope.selectYear = function(isStart, year) {
		 if (isStart) {
			 $scope.startYear = year;
		 }
		 else {
			 $scope.endYear = year;
		 }
	 };
	 
	 $scope.currentPage = 1;
	 $scope.pageSize = 10;
	 $scope.getCurrentStudents = function(currentPage, pageSize) {
		 if ($scope.selectedMarkerDetail.students && $scope.selectedMarkerDetail.students.length > 0) {
			 return $scope.selectedMarkerDetail.students.slice((currentPage-1)*pageSize, Math.min($scope.selectedMarkerDetail.students.length, (currentPage-1)*pageSize+pageSize));
		 }
		 else {
			 return [];
		 }
	 };
	 
	 $scope.retrieveStudentDisplay = function(student) {
		 return student.name + ' - ' + student.award + '$';
	 };
}])

;

