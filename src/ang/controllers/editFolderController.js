(function(){
	//editFolderController
	var EditFolderController = function($scope, $modalInstance, $log, FolderService) {
		$log.log('EditFolderController-->');
		var record = FolderService.record;
		$log.log(record);
		$scope.folder = record.folder;
		$scope.folderType = record.folderType;
		$scope.editMode = record.mode;
		  
		$scope.ok = function () {
			$log.info('saving record ' + record);
		    FolderService.saveFolder($scope.folderType, JSON.stringify($scope.folder));
		    $modalInstance.close($scope.folder);
		};
	
		$scope.cancel = function () {
		    $modalInstance.dismiss('cancel');
		};
	  
	};

	EditFolderController.$inject = ['$scope', '$modalInstance', '$log', 'FolderService'];    
	
	angular.module('mainApp').controller('EditFolderController', EditFolderController);

    
    
}());

    