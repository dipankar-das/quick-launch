(function(){
  //angular module
  angular.module('mainApp', ['ngRoute', 'ui.bootstrap']); 
  
  var MainController = function($scope, PageService){
	$scope.loading = "loading....";

	// at the bottom of your controller
	var init = function () {
		
		//loadBundles($scope.priceListId);
		//loadCartLineItems();
		
	};
	// and fire it after definition
	init();
      
  };
 
  MainController.$inject = ['$scope', 'PageService'];    
  angular.module('mainApp').controller('MainController', MainController);

  //end of controller
  angular.module('mainApp').directive('draggable', function() {
	  return function(scope, element) {
	    // this gives us the native JS object
		var el = element[0];
	    el.draggable = true;
	    
	    el.addEventListener(
	      'dragstart',
	      function(e) {
	        e.dataTransfer.effectAllowed = 'move';
	        e.dataTransfer.setData('Text', this.id);
	        this.classList.add('drag');
	        //console.log('this.id = ' + this.id);
	        return false;
	      },
	      false
	    );
	    
	    el.addEventListener(
	      'dragend',
	      function(e) {
	        this.classList.remove('drag');
	        return false;
	      },
	      false
	    );
	  }
	});

  angular.module('mainApp').directive('droppable', function() {
	  return {
	    link: function(scope, element) {
	      // again we need the native object
	      var el = element[0];
	      
	      el.addEventListener(
	        'dragover',
	        function(e) {
	          e.dataTransfer.dropEffect = 'move';
	          // allows us to drop
	          if (e.preventDefault){ e.preventDefault(); }
	          this.classList.add('over');
	          return false;
	        },
	        false
	      );
	      
	      el.addEventListener(
	        'dragenter',
	        function(e) {
	          this.classList.add('over');
	          return false;
	        },
	        false
	      );
	      
	      el.addEventListener(
	        'dragleave',
	        function(e) {
	          this.classList.remove('over');
	          return false;
	        },
	        false
	      );
	      
	      el.addEventListener(
	        'drop',
	        function(e) {
	          // Stops some browsers from redirecting.
	          if (e.stopPropagation) { e.stopPropagation(); }
	          
	          this.classList.remove('over');
	          
	          var item = document.getElementById(e.dataTransfer.getData('Text'));
	          //console.log('droped item id ' + item.id);
	          scope.dragData[item.id] = this.id;
	          //console.log(scope.dragData);
	          this.parentNode.insertBefore(item, this);
	          
	          // call the drop passed drop function
	          scope.$apply('drop()');
	          scope.saveSequence();
	          return false;
	        },
	        false
	      );
	    }
	  }
	});  
})();
