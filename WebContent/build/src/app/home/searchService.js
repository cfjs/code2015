angular.module('home.services', [])
	.factory('searchService', function(searchCriteria) {
		return {
			performSearch: function(searchCriteria) {
				console.log(searchCriteria);
			}
		};
	});