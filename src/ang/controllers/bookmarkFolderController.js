(function(){
    var BookmarkController = function($scope, sharedData) {
        $scope.lineItems = [];
        
        /*
         * load cart line items
         */
        function loadBookmarks() {
            console.log('attempt to load tab items');
            
            Visualforce.remoting.Manager.invokeAction(j$.QL.Remote.getBookmarks, function(result, event) {
                try {
                    console.log('VF Remote back with status = '+ event.status);
                    if (event.status) {
                        $scope.folderJSON = result;
                        var len = $scope.folderJSON.length;
                        console.log('folders returned = ' + len);
                    }
                    //$rootScope.$broadcast('datarecieved');
                    $scope.$digest(); 
                } catch(ex) {
                    console.log('error1 : ' + ex);
                      
                }}, 
                {buffer: false, escape: true, timeout: 120000}
             );
        }
        
        /**
         *  saves cart data
         */
        function saveSequence2() {
            console.log('attempt to save sequence');
            var modifiedItems = []; //send only modified lines to save, reduce upload data size 
            Visualforce.remoting.Manager.invokeAction(j$.QL.Remote.saveSequence, mofiedItems, function(result, event) {
                try {
                    console.log('saveSequence back with status = '+ event.status);
                    if (event.status) {
                        $scope.folderJSON = result; //returns all data to refresh page
                    }
                    //$rootScope.$broadcast('datarecieved');
                    $scope.$digest(); 
                } catch(ex) {
                    console.log('error1 : ' + ex);
                      
                }}, 
                {buffer: false, escape: true, timeout: 120000}
             );
            
        }
        
        
        $scope.loadBookmarks = loadBookmarks;
        $scope.saveSequence2 = saveSequence2;//TBD, do we really need second controller
        
        // at the bottom of your controller
        var init = function () {
            loadBookmarks();
            
        };
        // and fire it after definition
        init();
        
    };

    BookmarkController.$inject = ['$scope', 'sharedData'];    

    angular.module('mainApp').controller('BookmarkController', BookmarkController);
    
}());

    