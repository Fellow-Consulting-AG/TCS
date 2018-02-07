package gadget.sync.tasklists {
	import gadget.dao.Database;
	import gadget.dao.PreferencesDAO;
	import gadget.service.UserService;
	import gadget.sync.incoming.AccessProfileService;
	import gadget.sync.incoming.CurrencyService;
	import gadget.sync.incoming.CustomRecordTypeService;
	import gadget.sync.incoming.FieldManagementService;
	import gadget.sync.incoming.GetFields;
	import gadget.sync.incoming.IncomingCurrentUserData;
	import gadget.sync.incoming.IncomingObject;
	import gadget.sync.incoming.IncomingSalesProcess;
	import gadget.sync.incoming.IncomingUser;
	import gadget.sync.incoming.PicklistService;
	import gadget.sync.incoming.ReadCascadingPicklists;
	import gadget.sync.incoming.ReadPicklist;
	import gadget.sync.incoming.RoleService;
	import gadget.sync.task.MetadataChangeService;
	import gadget.sync.tests.TestCreateRight;
	import gadget.sync.tests.TestPharma;
	import gadget.sync.tests.TestUpdateRight;
	
	public function InitializationTasks(metaSyn:Boolean=false,fullSync:Boolean=false):Array {
		
		function testUpdateRights():Array {
			var a:Array = new Array();
			for each (var transaction:Object in Database.transactionDao.listTransaction()){
				if (transaction.enabled) {
					a.push(new TestUpdateRight(transaction.entity));
				}
			}
			return a;
		}
		
		function testCreateRights():Array {
			var a:Array = new Array();
			for each (var transaction:Object in Database.transactionDao.listTransaction()){
				if (transaction.enabled) {
					a.push(new TestCreateRight(transaction.entity));
				}
			}
			return a;
		}
		
		
		
		var all:Array = [
			new IncomingUser(),		
			new MetadataChangeService(),
						
			new CustomRecordTypeService(),
//			//new IncomingSalesProcess(),			
			new GetFields(),
			new FieldManagementService(),
			new IncomingCurrentUserData(),
//
//			// Picklists in this sequence, not different.
			new ReadPicklist(),
			new PicklistService(),
			new CurrencyService,
			new ReadCascadingPicklists(),			
			// capabilities testing
			new TestPharma()
		];
		
		if(!(Database.preferencesDao.getBooleanValue("use_sso",0) && UserService.DIVERSEY ==UserService.getCustomerId())){
			all.push(new AccessProfileService());
			all.push(new RoleService());
		}
		if(metaSyn || fullSync || Database.lastsyncDao.getCount() == 0){
			all = all.concat(testUpdateRights());
			all = all.concat(testCreateRights());	
		}
		if (Database.transactionDao.find("Opportunity").enabled || Database.transactionDao.find("Lead").enabled) {
			all = all.concat(new IncomingSalesProcess());
		}
		
		return all;
	}
	
}
