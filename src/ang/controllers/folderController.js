(function(){
    var FolderController = function ($scope, $routeParams, $modal, PageService, FolderService) {
    	$scope.dragData = {};
    	$scope.folders = [];
        $scope.hideTabs = {};
        $scope.folderType = $routeParams.folderType;
        //$scope.folder = {}; //selected folder 
        $scope.record = {folder: {}, mode: 'new', folderType: 'App'};
        
        $scope.newFolder = function (folderIndex) {
        	$scope.record.folder = {'Label__c': 'New Folder', 'Type__c': $scope.folderType};
        	$scope.record.mode = 'new';
        	$scope.record.folderType = $scope.folderType;
        	
        	FolderService.record = $scope.record;
        	$scope.open();//opens dialog
        }
        
        $scope.editFolder = function (folderIndex) {
        	$scope.record.folder = $scope.folders[folderIndex];
        	$scope.record.mode = 'edit';
        	console.log($scope.record);

        	FolderService.record = $scope.record;
        	$scope.open();//opens dialog
        }
        
        $scope.deleteFolder = function (folderIndex) {
        	$scope.record.folder = $scope.folders[folderIndex];
        	$scope.record.mode = 'delete';

        	FolderService.deleteFolder($scope.folderType, JSON.stringify($scope.folders[folderIndex]));
        	$scope.folders.splice(folderIndex, 1);
        	//$scope.open();//opens dialog
        }
        
        //modal dialog open function
    	$scope.open = function (size) {
    		var modalInstance = $modal.open({
                templateUrl: PageService.editFolderTemplate,
                controller: 'EditFolderController',
                size: size,
                resolve: {
                  folder: function () {
                    return $scope.folder;
                  }
                }
            });

    		modalInstance.result.then(function (updatedFolder) {
                $scope.updated = updatedFolder;
                console.log('Updated folder: ' + updatedFolder);
                
    		}, function () {
    			console.log('Modal dismissed at: ' + new Date());
                
    		});
    	};
                
        /*
         * get folders
         */
        $scope.getFolders = function () {
        	console.log('$scope.folderType = ' + $scope.folderType);
        	
        	FolderService.getFolders($scope.folderType).then(function(result){
        		$scope.folders = result;
        		console.log(JSON.stringify(result));
    		},
            function (error) {
    			console.log(error);
            });
    	};
        
        /**
         *  saves folder sequence
         */
        $scope.saveSequence = function () {
        	console.log('attempt to save sequence');
    		var modifiedItems = JSON.stringify($scope.dragData); //send only modified lines to save, reduce upload data size 
    		$scope.dragData = {};//clear data
    		
        	FolderService.saveFolderSequence($scope.folderType, modifiedItems).then(function(result){
        		$scope.folders = result;
    		},
            function (error) {
    			console.log(error);
            });
        	
        };
        
        // at the bottom of your controller
    	var init = function () {
    		$scope.getFolders();
    		
    	};
    	// and fire it after definition
    	init();
        
    };

    FolderController.$inject = ['$scope', '$routeParams', '$modal', 'PageService', 'FolderService'];    

    angular.module('mainApp').controller('FolderController', FolderController);
    
    
}());

    