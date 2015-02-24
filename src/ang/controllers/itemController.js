(function(){
    var ItemController = function ($scope, $routeParams, $modal, PageService, ItemService) {
    	$scope.dragData = {};
    	$scope.folderType = $routeParams.folderType;
        $scope.folderWithItems = [];
        
        $scope.hideTabs = {};
        
        //$scope.folder = {}; //selected folder 
        $scope.record = {item: {}, mode: 'new'};
        
        $scope.newItem = function (folderIndex) {
        	var folder = $scope.folderWithItems[folderIndex];
        	$scope.record.item = {'Label__c': 'New Bookmark', 'TargtUrl__c': '', 'FolderId__c': folder.Id};
        	$scope.record.mode = 'new';
        	
        	ItemService.record = $scope.record;
        	$scope.open();//opens dialog
        }
        
        $scope.editItem = function (folderIndex, itemIndex) {
        	console.log('folderIndex = '+folderIndex + ',itemIndex = '+itemIndex);
        	var folder = $scope.folderWithItems[folderIndex];
        	$scope.record.item = folder.Items__r[itemIndex];
        	$scope.record.mode = 'edit';
        	console.log($scope.record);

        	ItemService.record = $scope.record;
        	$scope.open();//opens dialog
        }
        
        $scope.deleteItem = function (folderIndex, itemIndex) {
        	var folder = $scope.folderWithItems[folderIndex];
        	$scope.record.mode = 'delete';

        	FolderService.deleteFolder($scope.folderType, JSON.stringify(folder.Items__r[itemIndex]));
        	folder.Items__r.splice(itemIndex, 1);
        	//$scope.open();//opens dialog
        }
        
        //modal dialog open function
    	$scope.open = function (size) {
    		var modalInstance = $modal.open({
                templateUrl: PageService.editItemTemplate,
                controller: 'EditItemController',
                size: size,
                resolve: {
                  folder: function () {
                    return $scope.folder;
                  }
                }
            });

    		modalInstance.result.then(function (updatedItem) {
                $scope.updated = updatedItem;
                console.log('Updated Item: ' + updatedItem);
                
    		}, function () {
    			console.log('Modal dismissed at: ' + new Date());
                
    		});
    	};
        
        /**
         * returns true if the tab should be hidden
         */
        $scope.isShowTab = function (tabName) {
        	if($scope.hideTabs[tabName] === undefined || $scope.hideTabs[tabName] === false ) {
        		return true;
        	} else {
        		return false;
        	}
        	
        }
        
        /**
         * toggles tab hide property 
         */
        $scope.toggleTab = function (tabName) {
        	if($scope.isShowTab(tabName)) {
        		$scope.hideTabs[tabName] = true;
        	} else {
        		$scope.hideTabs[tabName] = false;
        	}
        	
        }
         
        /*
         * load folder with items
         */
        $scope.getFolderWithItems = function () {
        	ItemService.getFolderWithItems($scope.folderType).then(function(result){
        		$scope.folderWithItems = result;
    		},
            function (error) {
    			console.log(error);
            });
    	}
        
        /**
         *  saves folder item sequence
         */
        $scope.saveSequence = function () {
        	var modifiedItems = JSON.stringify($scope.dragData); //send only modified lines to save, reduce upload data size 
    		$scope.dragData = {};//clear data
    		ItemService.saveItemSequence($scope.folderType, modifiedItems).then(function(result){
        		$scope.folderWithItems = result;
    		},
            function (error) {
    			console.log(error);
            });
        	
        }
        
        // at the bottom of your controller
    	var init = function () {
    		$scope.getFolderWithItems();
    		
    	};
    	// and fire it after definition
    	init();
        
    };

    ItemController.$inject = ['$scope', '$routeParams', '$modal', 'PageService', 'ItemService'];     

    angular.module('mainApp').controller('ItemController', ItemController);
    
}());

    