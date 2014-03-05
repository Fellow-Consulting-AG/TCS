package gadget.sync.incoming
{
	import avmplus.getQualifiedClassName;
	
	import flash.events.IOErrorEvent;
	import flash.utils.Dictionary;
	
	import gadget.dao.Database;
	import gadget.dao.IncomingSyncDAO;
	import gadget.dao.SubobjectTable;
	import gadget.dao.SupportDAO;
	import gadget.dao.SupportRegistry;
	import gadget.sync.WSProps;
	import gadget.sync.task.TaskParameterObject;
	import gadget.util.DateUtils;
	import gadget.util.ServerTime;
	import gadget.util.SodUtils;
	import gadget.util.StringUtils;
	
	import mx.collections.ArrayCollection;

	public class IncomingSubBase extends WebServiceIncoming
	{
		protected var _subpage:int;

		protected var subIDour:String;
		protected var subIDsod:String;
		protected var subIDns:String;
		protected var subList:String;
		protected var subIDId:String;
		protected var parentLastSynch:String = null;
		protected var pid:String = null;
		protected var isUsedLastModified:Boolean = true;
		protected const SUBROW_PLACEHOLDER:String = "___HERE__THE__SUBROW__NUMBER___";
		protected var SUB_PAGE_SIZE:int;	
		public function IncomingSubBase(ID:String, subId:String, _dao:String=null) {
			subIDour	= subId;
			subIDsod	= SodUtils.transactionProperty(subId).sod_name;
			if(ID == Database.opportunityDao.entity && subId == Database.productDao.entity){
				subIDsod = subIDsod + "Revenue";
				
			}else if(ID == Database.contactDao.entity  && subId == "Related"){
				subIDsod = subIDsod + ID;
			}
			
			
			subIDns		= subIDsod.replace(/ /g,"");
			
			subList		= "ListOf"+subIDns;
			
			subIDId		= "Id";
			super(ID, _dao);
			//subobject ignore field
			ignoreQueryFields.push("IsPrivateEvent");
			ignoreQueryFields.push("GUID");
			ignoreQueryFields.push("GDATA");
			ignoreQueryFields.push("ms_id");
			ignoreQueryFields.push("ms_change_key");	
			ignoreQueryFields.push("ms_local_change");	
			noPreSplit = true;
			linearTask = true;
			var lastSyncObject:Object = Database.lastsyncDao.find(getQualifiedClassName(IncomingObject)+entityIDour);
			var lastSubSync:Object = Database.lastsyncDao.find(getQualifiedClassName(this)+entityIDour+subId);
			
			if(lastSyncObject!=null && lastSubSync!=null){
				ServerTime.setSodTZ(DateUtils.getCurrentTimeZone(new Date())*3600,lastSyncObject.sync_date,Database.allUsersDao.ownerUser().TimeZoneName);
				parentLastSynch = ServerTime.toSodIsoDate(ServerTime.parseSodDate(lastSyncObject.sync_date));
			}
			
		}

		override public function getMyClassName():String{
			return getQualifiedClassName(this)+entityIDour+subIDour;
		}
		
		override protected function tweak_vars():void {
			
			if(this is IncomingAttachment){
				pageSize = Math.max(1, Math.min(100, Database.preferencesDao.getIntValue(getEntityName()+"_page",10)));
				SUB_PAGE_SIZE = Math.max(1, Math.min(100, Database.preferencesDao.getIntValue(getEntityName()+"_subpage",10)));
			}else{
				pageSize = Math.max(1, Math.min(100, Database.preferencesDao.getIntValue(getEntityName()+"_page",50)));
				SUB_PAGE_SIZE = Math.max(1, Math.min(100, Database.preferencesDao.getIntValue(getEntityName()+"_subpage",50)));
			}
			
//			SUCCESSFULLY_FAIL_UNFORCED_PAGES	= Math.max(3, Math.min(100, Database.preferencesDao.getIntValue(getEntityName()+"_pages",3)));
			isUnboundedTask = true;
			
			//VAHI yes, call it here, even that it seems redundant.
			// but this way you cannot forget to hook it using super.tweak_vars() 
			tweak_vars2();
		}
		
		protected function tweak_vars2():void {}

		override protected function initXML(baseXML:XML):void {
			// VAHI Don't ask.  It took me (more than) 4hrs to find QName .. Bullshit documentation
			var qlist:QName=new QName(ns1.uri,listID), qent:QName=new QName(ns1.uri,entityIDns);

			initXMLsub(baseXML, addFilters(entityIDour, entityIDsod, baseXML.child(qlist)[0].child(qent)[0]));
		}

		protected function initXMLsub(baseXML:XML, subXML:XML):void {}

		override protected function initEach():void {
			_subpage = 0;
			_lastItems = _nbItems;
			super.initEach();
		}

		protected function nextSubPage(lastPage:Boolean, lastSubPage:Boolean):void {

			if (!lastSubPage) {
				showCount();
				_subpage++;		//VAHI yes, this might overcount
				doRequest();
				return;
			}
			_subpage=0;
			nextPage(lastPage);
		}

		override protected function handleZeroFault(soapAction:String, request:XML, event:IOErrorEvent):Boolean {
			if (param.force || linearTask)
				return false;
			doSplit();
			return true;
		}

		override protected function doRequest():void {
			var dateSpec:String = "";
			var pagenow:int = _page;
			var subpagenow:int = _subpage;
			
			isLastPage = false;
			
			if( !param.full){				
				if(parentLastSynch!=null && isUsedLastModified ){
					dateSpec = "["+MODIFIED_DATE+"] &gt;= '"+parentLastSynch+"'";
				}
				
			}
			
//			if (param.range) {
//				dateSpec	= "( &gt;= '"+DateUtils.toSodDate(param.range.start)+"' ) AND ( &lt;= '"+DateUtils.toSodDate(param.range.end)+"' )";
//			}
			trace("::::::: SUBREQUEST20 ::::::::",getEntityName(),param.force,_page,_subpage,pagenow,subpagenow,isLastPage,haveLastPage,dateSpec);
//			Database.errorLoggingDao.add(null,{trace:[getEntityName(),param.force,_page,_subpage,pagenow,subpagenow,isLastPage,haveLastPage,dateSpec]});

			sendRequest("\""+getURN()+"\"", new XML(
				getRequestXML().toXMLString()
				.replace(ROW_PLACEHOLDER, pagenow*pageSize)
				.replace(SUBROW_PLACEHOLDER, subpagenow*SUB_PAGE_SIZE)
				.replace(SEARCHSPEC_PLACEHOLDER,dateSpec)
				.replace(SEARCHSPEC_PLACEHOLDER,dateSpec)
			));
		}
		protected function checkResponse(listObject:XML):void{
			//implement in the sub class
		}
		override protected function handleResponse(request:XML, response:XML):int {
			var listObject:XML = response.child(new QName(ns2.uri,listID))[0];
			var lastPage:Boolean = listObject.attribute("lastpage")[0].toString() == 'true';
			var lastSubPage:Boolean = true;
			var qsublist:QName = new QName(ns2.uri,subList);
			var cnt:int=0;
			checkResponse(listObject); //Bug #7167 CRO
			Database.begin();
			try{
			for each (var parentRec:XML in listObject.child(new QName(ns2.uri,entityIDns))) {
				var subObject:XML = parentRec.child(qsublist)[0];
				if(!(this is IncomingAttachment)){
					this.pid =  parentRec.child(new QName(ns2.uri,"Id"))[0].toString();					
				}
				
				lastSubPage = lastSubPage && ( subObject.attribute("lastpage")[0].toString() == 'true' );
				var nr:int = importRecords(subIDsod, subObject.child(new QName(ns2.uri,subIDns)));
				if (nr<0) {
					//Database.commit();
					return cnt;
				}
				cnt += nr;
			}
				
			}finally{
				Database.commit();
			}
			nextSubPage(lastPage,lastSubPage);
			return cnt;
			
		}

		override public function getEntityName():String { return entityIDsod+subIDsod; }
		override public function getTransactionName():String { return subIDour; }
		override public function getParentTransactionName():String { return entityIDour; }

	}
}