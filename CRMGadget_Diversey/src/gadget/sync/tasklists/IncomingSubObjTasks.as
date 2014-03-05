package gadget.sync.tasklists {
	import gadget.dao.Database;
	import gadget.sync.WSProps;
	import gadget.sync.incoming.IncomingAttachment;
	import gadget.sync.incoming.IncomingSubActivity;
	import gadget.sync.incoming.IncomingSubobjects;
	import gadget.sync.incoming.ScoopObjectActivity;
	import gadget.sync.incoming.WebServiceIncoming;
	import gadget.util.SodUtils;
	import gadget.util.SodUtilsTAO;
	
	import mx.collections.ArrayCollection;

	public function IncomingSubObjTasks(fullsync:Boolean):Array {
		
		var subSync:Array = new Array();
		var list:ArrayCollection = Database.transactionDao.listEnabledTransaction();
		for each(var o:Object in list){
			//sub
			var subList:Array = Database.subSyncDao.listSubEnabledTransaction(o.entity);
			for each(var subObj:Object in subList){
				switch (subObj.sodname){
					case  "Attachment":
						if(Database.serviceDao.entity==subObj.entity && !fullsync){
							break;
						}
						subSync.push(new IncomingAttachment(subObj.entity));
						break;
					case "Activity":
					case "Asset":	
						var obj:Object = Database.transactionDao.find(subObj.entity);
						if(!obj.enabled){
							subSync.push(new IncomingSubActivity(subObj.entity,subObj.sodname));
						}
						break;
					
//					case "Note": subSync.push(new IncomingNote(subObj.entity));	
					default:
						subSync.push(new IncomingSubobjects(subObj.entity,subObj.sodname));
				}
			}
		}		
		return subSync;
		
		
//		function attachmentFilter(t:SodUtilsTAO, index:int, arr:Array):Boolean {
//			var o:Object = Database.transactionDao.find(t.sod_name);
//			return o!=null && o.enabled && o.sync_attachments;
//		}
//		
//		function activityFilter(t:SodUtilsTAO, index:int, arr:Array):Boolean {
//			var o:Object = Database.transactionDao.find(t.sod_name);
//			return o!=null && o.enabled && o.sync_activities;
//		}
//		function transactionFilter(t:SodUtilsTAO,index:int,arr:Array):Boolean {
//			//teamp solution 
//			if(t.sod_name!="Contact"){
//				return false;}
//			var transaction:Object = Database.transactionDao.find(t.sod_name);
//			return transaction!=null && transaction.enabled == 1;
//		}
//		return [].concat(
//			
////			SodUtils.transactionsTAOif("ws20act")
////			.filter(transactionFilter)
////			.map(function (t:SodUtilsTAO, i:int,a:Array):WebServiceIncoming{
////				return new IncomingTeam(t.sod_name);
////			}),
//					
//			
//				SodUtils.transactionsTAOif("ws20att")
//					.filter(attachmentFilter)
//					.map(function (t:SodUtilsTAO, i:int,a:Array):WebServiceIncoming {
//						return new IncomingAttachment(t.sod_name);
//					}),
//					
//					
//				SodUtils.transactionsTAOif("ws20act")
//					.filter(activityFilter)
//					.map(function (t:SodUtilsTAO, i:int,a:Array):WebServiceIncoming {
//						return new IncomingSubActivity(t.sod_name);
//					})
//			);
	}
}
