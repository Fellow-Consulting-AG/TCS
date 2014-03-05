package gadget.sync.tasklists {
	import gadget.dao.Database;
	import gadget.service.UserService;
	import gadget.sync.WSProps;
	import gadget.sync.incoming.IncomingObject;
	import gadget.sync.incoming.MSExchangeService;
	import gadget.sync.incoming.ModificationTracking;
	import gadget.sync.incoming.WebServiceIncoming;
	import gadget.util.SodUtils;
	import gadget.util.SodUtilsTAO;
	
	import mx.collections.ArrayCollection;

	public function IncomingTasks():Array {

//		function transactionFilter(t:SodUtilsTAO, index:int, arr:Array):Boolean {
//			if (t.sod_name == "User") {
//				return true;
//			}
			
//			
//			var transaction:Object = Database.transactionDao.find(t.sod_name);
//			return transaction!=null && transaction.enabled == 1;
//		}
//		
//		return [].concat(
//			SodUtils.transactionsTAOif("top_level")
//			.filter(transactionFilter)
//			.map(function (t:SodUtilsTAO, i:int,a:Array):WebServiceIncoming {
//				return new IncomingObject(t.our_name);
//			})
//		);
		
		var enablesTrans:ArrayCollection=Database.transactionDao.listEnabledTransaction();
		var incomings:Array =new Array();
		//always read users
		incomings.push(new IncomingObject(Database.allUsersDao.entity));
		for each(var obj:Object in enablesTrans){
			
			if(UserService.DIVERSEY==UserService.getCustomerId()){
				if(obj.entity==Database.productDao.entity || obj.entity==Database.customObject3Dao.entity ||
				   obj.entity==Database.serviceDao.entity || obj.entity==Database.customObject1Dao.entity ||
				   obj.entity==Database.customObject2Dao.entity){
					continue;
				}
				
			}
			
			incomings.push(new IncomingObject(obj.entity));
			//			if(obj.entity==Database.contactDao.entity){
			//				outs.push(new OutgoingTeam(obj.entity));
			//			}
		}
		
		return incomings;
		
	}
}
