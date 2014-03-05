package gadget.sync.tasklists {
	import gadget.dao.Database;
	import gadget.sync.WSProps;
	import gadget.sync.incoming.IncomingObjectPerId;
	import gadget.sync.incoming.ModificationTracking;
	import gadget.sync.incoming.WebServiceIncoming;
	import gadget.util.SodUtils;
	import gadget.util.SodUtilsTAO;

	public function IncomingPerIdTasks():Array {

		function transactionFilter(t:SodUtilsTAO, index:int, arr:Array):Boolean {
			var transaction:Object = Database.transactionDao.find(t.sod_name);
			return transaction!=null && transaction.enabled == 1;
		}
		
		return [].concat(
			SodUtils.transactionsTAOif("top_level")
			.filter(transactionFilter)
			.map(function (t:SodUtilsTAO, i:int,a:Array):WebServiceIncoming {
				return new IncomingObjectPerId(t.our_name);
			})
		);
	}
}
