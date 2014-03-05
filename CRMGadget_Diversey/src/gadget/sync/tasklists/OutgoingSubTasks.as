package gadget.sync.tasklists {
	import gadget.dao.Database;
	import gadget.dao.SupportDAO;
	import gadget.dao.SupportRegistry;
	import gadget.sync.outgoing.OutgoingAttachment;
	import gadget.sync.outgoing.OutgoingSubObject;
	import gadget.util.SodUtils;
	import gadget.util.SodUtilsTAO;
	import gadget.util.StringUtils;
	
	import mx.collections.ArrayCollection;

	public function OutgoingSubTasks():Array {

		

		
		var enablesTrans:ArrayCollection=Database.transactionDao.listEnabledTransaction();
		var outs:Array =new Array();
		for each(var obj:Object in enablesTrans){
			
			var subList:Array = Database.subSyncDao.listSubEnabledTransaction(obj.entity);
			for each(var subObj:Object in subList){
				var sodname:String = subObj.sodname;
				if(StringUtils.isEmpty(sodname)){
					sodname = subObj.sub;
				}
				
				switch (sodname){
					case  "Attachment":
						if(subObj.entity!=Database.serviceDao.entity){
							outs.push(new OutgoingAttachment(subObj.entity));
						}
						break;
					case "Activity":
					case "Asset":
						break;					
						
					default:
						var supportDao:SupportDAO = SupportRegistry.getSupportDao(subObj.entity,sodname);
						if(supportDao!=null && !supportDao.isSyncWithParent){
							outs.push(new OutgoingSubObject(subObj.entity,sodname));
						}
						
				}
			}
			
			
		}
		
		return outs;
		
		
	}
}
