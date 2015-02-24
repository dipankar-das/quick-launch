(function(){
    var ItemService = function ($q, PageService) {
    	var folderItems = {};
    	
    	this.record = {item: {}, mode: 'new'};
    	
    	//save folder item sequence
    	this.saveItemSequence = function (folderType, modifiedItems) {
        	var deferred = $q.defer();
    		Visualforce.remoting.Manager.invokeAction(j$.QL.Remote.saveItemSequence, folderType, modifiedItems, function(result, event) {
        	    try {
                    console.log('<--saveItemSequence back with status = '+ event.status);
                    if (event.status) {
                    	folderItems[folderType] = result;
    	                deferred.resolve(folderItems[folderType]);
    	            	
    				} else {
    					deferred.reject(event);
    					
    				}
                    
    	        } catch(ex) {
    	            console.log('error1 : ' + ex);
    	              
    	        }}, 
                {buffer: false, escape: true, timeout: 60000}
            );
    		
    		return deferred.promise;
    		
        }
    	
    	//reset list, so that it is reloaded
    	this.reset = function () {
    		folderItems = undefined;
    	}
    	
    	//load folder with items
    	this.getFolderWithItems = function (folderType) {
    		if (folderItems[folderType]) {
    			return $q.when(folderItems[folderType]);
    		}

    		var deferred = $q.defer();
        	
        	Visualforce.remoting.Manager.invokeAction(j$.QL.Remote.getFolderWithItems, folderType, function(result, event) {
    	    	try {
                    console.log('VF Remote getFolderWithItems status = '+ event.status);
                    if (event.status) {
                    	folderItems[folderType] = result;
    	                deferred.resolve(folderItems[folderType]);
    	                
    				} else {
    					deferred.reject(event);
    				}
    				//$rootScope.$broadcast('datarecieved');
                    
    	        } catch(ex) {
    	            console.log('error1 : ' + ex);
    	              
    	        }}, 
                {buffer: false, escape: true, timeout: 60000}
             );
    		
    		return deferred.promise;
    		
    	};
    	    
    };
    
    ItemService.$inject = ['$q', 'PageService'];    

    angular.module('mainApp').service('ItemService', ItemService);
    
}());