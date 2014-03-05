package gadget.sync.incoming
{
	import gadget.dao.Database;
	import gadget.util.DateUtils;
	import gadget.util.ServerTime;

	public class IncomingCurrentUserData extends IncomingObject
	{
		public function IncomingCurrentUserData()
		{
			super(Database.allUsersDao.entity);
		}
		
		override protected function doRequest():void {
			
//			if (getLastSync() != NO_LAST_SYNC_DATE){
//				successHandler(null);
//				return;
//			} 
			
			var searchSpec:String =  "[UserSignInId]= '"+Database.userDao.read().user_sign_in_id+"' ";			
			
			
			var pagenow:int = _page;
			
			_lastItems = _nbItems;
			

			sendRequest("\""+getURN()+"\"", new XML(getRequestXML().toXMLString()
				.replace(ROW_PLACEHOLDER, pagenow*pageSize)
				.replace(SEARCHSPEC_PLACEHOLDER, searchSpec)
			));
		}
		
		
		override protected function nextPage(lastPage:Boolean):void {
			//update servertimezone
			var sec:int = DateUtils.getCurrentTimeZone()*3600;
			ServerTime.setSodTZ(sec,null,null,true);
			showCount();
			successHandler(null);
		}
	}
}