(function(){
	//EditItemController
	var EditItemController = function($scope, $modalInstance, $log, ItemService) {
		$log.log('EditItemController-->');
		var record = ItemService.record;
		$log.log(record);
		$scope.item = record.item;
		$scope.folderType = record.folderType;
		$scope.editMode = record.mode;
		  
		$scope.ok = function () {
			$log.info('saving record ' + record);
		    ItemService.saveItem($scope.folderType, JSON.stringify($scope.item));
		    $modalInstance.close($scope.item);
		};
	
		$scope.cancel = function () {
		    $modalInstance.dismiss('cancel');
		};
	  
	};

	EditItemController.$inject = ['$scope', '$modalInstance', '$log', 'ItemService'];    
	
	angular.module('mainApp').controller('EditItemController', EditItemController);

    
    
}());

    