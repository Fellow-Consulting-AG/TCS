
package gadget.sync.incoming {
	import com.google.analytics.utils.UserAgent;
	
	import flash.events.IOErrorEvent;
	import flash.utils.Dictionary;
	
	import gadget.dao.BaseDAO;
	import gadget.dao.DAOUtils;
	import gadget.dao.Database;
	import gadget.dao.IncomingSyncDAO;
	import gadget.dao.SupportDAO;
	import gadget.dao.SupportRegistry;
	import gadget.dao.TransactionDAO;
	import gadget.i18n.i18n;
	import gadget.service.LocaleService;
	import gadget.service.PicklistService;
	import gadget.service.UserService;
	import gadget.sync.WSProps;
	import gadget.sync.task.WebServiceBase;
	import gadget.util.FieldUtils;
	import gadget.util.OOPS;
	import gadget.util.ObjectUtils;
	import gadget.util.ServerTime;
	import gadget.util.SodUtils;
	import gadget.util.StringUtils;
	import gadget.util.Utils;
	
	import mx.collections.ArrayCollection;

	
	public class WebServiceIncoming extends WebServiceBase {

		protected var isFormulaError:Boolean = false;
		protected const SEARCHSPEC_PLACEHOLDER:String = "___HERE__THE__SEARCH__SPEC___";
		protected const ROW_PLACEHOLDER:String = "___HERE__THE__ROW__NUMBER___";
		protected const SUCCESSFULLY_FAIL_UNFORCED_PAGES:int = 3;
		protected const MODIFIED_DATE:String = "ModifiedDate"; // ModifiedDate or ModifiedByDate
		
		protected var syncRecords:Dictionary = new Dictionary();

		
		protected var _page:int;
		protected var haveLastPage:Boolean, isLastPage:Boolean;
		protected var _nbItems:int=0;
		protected var _lastItems:int;
		
		// Following are precalculated from initialization
		protected var entityIDour:String;	// Account, Contact, AllUsers, ...
		protected var entityIDsod:String;	// Account, Contact, User, ...
		protected var entityIDns:String;	// CustomObject1, ...
		private var sodID:String;		// account, contact, ...
		protected var listID:String;	// ListOfAccount, ...
		protected var wsID:String;		// AccountWS_AccountQueryPage_Input,  ...
		protected var entityIDId:String;	//AccountId
		protected var urn:String;		// document/urn:crmondemand/ws/account/:AccountQueryPage, ...
		
		protected var ns1:Namespace;	// new Namespace("urn:crmondemand/ws/account/")
		protected var ns2:Namespace;	// new Namespace("urn:/crmondemand/xml/account")
		
		protected var withFilters:Boolean;
		protected var viewType:Number;
		// Some defaults
		protected var viewMode:String;
		protected var stdXML:XML;
		protected var pageSize:int = 50;
		protected var isUnboundedTask:Boolean = false;

		protected var startTime:Number=-1;
		// Likely to be changed after initialization
		protected var ignoreFields:Array = [ "ModifiedBy" ];
		//SEEALSO[1] Keep this in sync (field ModifiedDate)
		protected var ignoreQueryFields:Array = [ ];
		// METHODS not to change
		
		
		protected var dao:BaseDAO;

		public function WebServiceIncoming(ID:String, daoName:String=null) {
			isUnboundedTask = false;

			entityIDour	= ID;
			entityIDsod	= SodUtils.transactionProperty(ID).sod_name;
			entityIDns	= entityIDsod.replace(/ /g,"");
			sodID		= entityIDns.toLowerCase();
			listID		= "ListOf"+entityIDns;
			entityIDId	= entityIDns+"Id";
			
			withFilters	= true;
			
			wsID		= entityIDns+"QueryPage_Input";
			urn			= "document/urn:crmondemand/ws/ecbs/"+sodID+"/:"+entityIDns+"QueryPage";
			ns1			= new Namespace("urn:crmondemand/ws/ecbs/"+sodID+"/");
			ns2			= new Namespace("urn:/crmondemand/xml/"+entityIDns+"/Data");
			
			if (daoName==null)
				daoName	= SodUtils.transactionProperty(ID).dao;
			dao = Database[daoName] as BaseDAO;
			if (!dao)
				notImpl(i18n._("DAO {1} for {2}", daoName, ID));


			//In WSDL2.0 this is ModifiedDate, even for Products
			stdXML			= null;
			startTime		= Utils.calculateStartTime(Database.transactionDao.getAdvancedFilterType(entityIDour)); 
			viewMode		= getViewmode();
			viewType  		= Database.transactionDao.getTransactionViewType(entityIDour);
			tweak_vars();

			//SEEALSO[1] Keep this in sync (field ModifiedDate)
			//<{ModifiedDate}>{DatePlaceholder}</{ModifiedDate}>
			trace(wsID);
			if (stdXML==null) {
				stdXML =
					<{wsID} xmlns={ns1.uri}>						
						<ViewMode>{viewMode}</ViewMode>						
						<{listID} pagesize={pageSize} startrownum={ROW_PLACEHOLDER}>
							<{entityIDns} searchspec={SEARCHSPEC_PLACEHOLDER}>
							</{entityIDns}>
						</{listID}>
					</{wsID}>
				;
				
			}
			

		}

		protected function getViewmode():String{
			
			return Database.transactionDao.getTransactionViewMode(entityIDour);
		}
		protected function initXML(baseXML:XML):void {
			
			// append childs
			var qlist:QName=new QName(ns1.uri,listID), qent:QName=new QName(ns1.uri,entityIDns);
			
			
//			if(UserService.getCustomerId()==UserService.JD && entityIDour==Database.customObject3Dao.entity){
//				for each(var f:String in Database.customObject3Dao.queryFields){
//					var ws20name:String = WSProps.ws10to20(getEntityName(), f);
//					var xml:XML = baseXML.child(qlist)[0].child(qent)[0];					
//					xml.appendChild(new XML("<" + ws20name + "/>"));
//				}
//				return;
//			}
			
			if(viewType == TransactionDAO.DEFAULT_BOOK_TYPE){
				var bookid:String = Database.bookDao.getDefaultBookId();
				if(!StringUtils.isEmpty(bookid)){
					stdXML.appendChild(<BookId>{bookid}</BookId>);
				}
			}
			// Hack in all the ListOf... subobject thingies.
			for each (var sub:String in SupportRegistry.getSubObjects(entityIDour)) {
				if (entityIDour=="Activity" && sub=="Product") {
					//continue;
					if (Database.preferencesDao.getIntValue("pharma.disabled") == 1) {
						continue;
					}
				} 
				
				
				
				var subDao:SupportDAO = SupportRegistry.getSupportDao(entityIDour,sub);
				
				if(!subDao.isSyncWithParent){
					continue;
				}
				
				
				var subName:String = subDao.getSodSubName();
				
				var tmp:XML = <{subName} xmlns={ns1}/>;
				for each (var col:String in subDao.getCols()) {
					if (col!="DummySiebelRowId")
						tmp.appendChild(<{col}/>);
				}
				
				subName = "ListOf"+subName;
				stdXML.child(qlist)[0].child(qent)[0].appendChild(<{subName} xmlns={ns1}>{tmp}</{subName}>);
			}			
			
			var criterials:ArrayCollection = getFilterCriterials(entityIDour);
			
			// FieldUtils.allFields(entityIDsod, true), we pass true to force select from DB
			// indeed for some virtual field like owner it is pushed into the DB during app starting
			// this create caching issue
			var xml:XML = baseXML.child(qlist)[0].child(qent)[0];
			for each (var field:Object in FieldUtils.allFields(entityIDsod, true)) {
				// Filter out the column given in the standard XML above
				//SEEALSO[1] Keep this in sync 
//				if (field.element_name == "IsPrivateEvent" || field.element_name == "GUID" || field.element_name == "GDATA"){
//					continue;
//				} 
//				if(entityIDour==Database.serviceDao.entity && "GroupReport" ==field.element_name){
//					continue;
//				}
				if(dao.getIncomingIgnoreFields().contains(field.element_name)){
					continue;
				}
				if (ignoreQueryFields.indexOf(field.element_name)<0) {
					var ws20name:String = WSProps.ws10to20(entityIDsod, field.element_name);					
					
					xml.appendChild(new XML("<" + ws20name + "/>"));
					//VAHI XXX TODO HACK87
					// Do we need to add this to the SearchSpec instead?
					//applyFilters(xml, field.element_name, ws20name, criterials);
				}
			}
			
			
		}
		
		//VAHI We need late initalization (just before the run) to be able to access all the fields etc.
		override protected function initOnce():void {
			
			initXML(stdXML);
		}


		// We have two types of inits:
		// those only needed once and those needed every time on each request start.
		// This here is on each request:
		override protected function initEach():void {
			_page	= 0;
			haveLastPage = false;
			isLastPage = false;
		}
		
		protected function doSplit():void {
			//_nbItems	= _lastItems;	//reset the counts.
			setFailed();				// failed success, do a split
			successHandler(null);
		}

		override protected function handleZeroFault(soapAction:String, request:XML, event:IOErrorEvent):Boolean {
			//VAHI isLastPage includes that param.force==false
			if (!isLastPage || linearTask)
				return false;

			// Request overwhelmed SoD, try a split
			doSplit();
			return true;
		}

		protected function nextPage(lastPage:Boolean):void {
			// As we finished a page, restore all hacks
			if (isLastPage) {
				isLastPage		= false;
				if (lastPage==false) {
					doSplit();
					return;
				}
				showCount();
				haveLastPage	= true;
				doRequest();	// Now fetch _page=0
				return;
			}
			showCount();
			if (lastPage == false) {
				_page ++;
				if (_page<SUCCESSFULLY_FAIL_UNFORCED_PAGES || param.force || isUnboundedTask) {
					doRequest();
					return;
				}
				if (!haveLastPage) {
					//VAHI This code should no more be reached, but be sure
					setFailed();		// failed success
				}
			}			
			successHandler(null);
		}

		

		protected function generateSearchSpec():String{
			var searchSpec:String ="";
			if (param.range) {
				searchSpec = "["+MODIFIED_DATE+"] &gt;= '"+ServerTime.toSodIsoDate(param.range.start)+"'"
					+ " AND ["+MODIFIED_DATE+"] &lt;= '"+ServerTime.toSodIsoDate(param.range.end)+"'";
			}
			
			
			if(entityIDour==Database.customObject3Dao.entity && UserService.getCustomerId()==UserService.DIVERSEY){
				if(searchSpec==''){
					searchSpec = "[Name]= \'"+Utils.getGPlantLocation() + "\'";
				}else{
					searchSpec = "[Name]= \'"+Utils.getGPlantLocation() + "\' AND "+searchSpec;
				}
				
			}
			//CR #7137 CRO
			if(entityIDour==Database.serviceDao.entity){
				if(! StringUtils.isEmpty(searchSpec)){
					searchSpec += " AND ";
				}
				
				searchSpec += "[Status]&lt;&gt; \'Closed\' AND [Status]&lt;&gt; \'Cancelled\'";
			}
			//#7195
			if(entityIDour=="User"){
				if(! StringUtils.isEmpty(searchSpec)){
					searchSpec += " AND ";
				}
				
				searchSpec += "[Status]= \'Active\'";
			}
			
			var searchFilter:String = getSearchFilterCriteria();
			if(!StringUtils.isEmpty(searchFilter)){
				
				if(searchSpec!=''){
					searchSpec+=' AND '
				}
				
				searchSpec +=searchFilter;
			}			
			
			
			return searchSpec;
			
		}
		
		
		protected function getSearchFilterCriteria():String{
			var criterials:ArrayCollection = getFilterCriterials(entityIDour);
			var searchSpec:String ="";
			for each (var objCriterial:Object in criterials) {
				//order by cannot send
				if(objCriterial.num=="5"){
					continue;
				}
				if (objCriterial.column_name!=null) {
					var oodField:String = WSProps.ws10to20(entityIDour,objCriterial.column_name);
					var operator:String =Utils.getOODOperation(objCriterial.operator);			
					if(objCriterial.operator=='is null'||objCriterial.operator=='is not null'){
						if(searchSpec !=''){
							searchSpec+=' AND ';
						}
						searchSpec+="["+oodField+"] "+ operator;
					}else{
						var val:String= Utils.doEvaluateForFilter(objCriterial,entityIDour);
						if(val != "<ERROR>"){
							if(val=='') continue;
							var childValue:String = "";
							
							if(operator.toLocaleUpperCase() == 'LIKE'){
								childValue = "LIKE " + StringUtils.xmlEscape(StringUtils.sqlStrArg("*"+val+"*"));
							}else if(operator.toLocaleUpperCase() == 'LIKE%'){
								childValue = "LIKE " + StringUtils.xmlEscape(StringUtils.sqlStrArg(val+"*"));
							}else{
								childValue = operator + " " + StringUtils.xmlEscape(StringUtils.sqlStrArg(val))
							}					
							if(searchSpec !=''){
								searchSpec+=' AND ';
							}
							searchSpec+="["+oodField+"] "+ childValue;
						}else{
							isFormulaError=true;						
						}
					}
				}
			}
			return searchSpec;
		}
		
		
		override protected function doRequest():void {
			//Bug fixing 588 CRO
			if(isFormulaError){
				setFailed();
				param.errorHandler(i18n._("CANNOT_EVALUATE_YOUR_FILER",entityIDour), null);
				successHandler(null);
				return;
			}
			if(startTime!=-1){
				if(param.range){
					var start:Date = param.range.start;
					var end:Date = param.range.end;	
					if(start.getTime()<startTime && end.getTime()<startTime){
						successHandler(null);
						return;
					}else{
						if(start.getTime()<startTime){
							param.range.start = new Date(startTime);
						}
						
					}					
				}
			}
			
			var searchSpec:String = generateSearchSpec();
//			if (param.range) {
//				searchSpec = "["+MODIFIED_DATE+"] &gt;= '"+ServerTime.toSodIsoDate(param.range.start)+"'"
//					+ " AND ["+MODIFIED_DATE+"] &lt;= '"+ServerTime.toSodIsoDate(param.range.end)+"'";
//			}
//			
//			
//			if(entityIDour==Database.customObject3Dao.entity && UserService.getCustomerId()==UserService.JD){
//				if(searchSpec==''){
//					searchSpec = "[Name]= \'"+Utils.getGPlantLocation() + "\'";
//				}else{
//					searchSpec = "[Name]= \'"+Utils.getGPlantLocation() + "\' AND "+searchSpec;
//				}
//				
//			}
			
			var pagenow:int = _page;

			_lastItems = _nbItems;
			isLastPage=false;			
			if (pagenow==0 && haveLastPage==false && param.force==false && isUnboundedTask==false) {
				isLastPage = true;
				pagenow	= SUCCESSFULLY_FAIL_UNFORCED_PAGES;
			}
			
			trace("::::::: REQUEST20 ::::::::", getEntityName(), _page, pagenow, isLastPage, haveLastPage, searchSpec);
			//CRO 15-06-2011 release table size
			//Database.errorLoggingDao.add(null, {trace:[getEntityName(), _page, pagenow, isLastPage, haveLastPage, searchSpec]});
			
			//VAHI another poor man's workaround for missing late binding in XML templates
			sendRequest("\""+getURN()+"\"", new XML(getRequestXML().toXMLString()
					.replace(ROW_PLACEHOLDER, pagenow*pageSize)
					.replace(SEARCHSPEC_PLACEHOLDER, searchSpec)
				));
		}
		
		override protected function handleResponse(request:XML, response:XML):int {
			
			var listObject:XML = response.child(new QName(ns2.uri,listID))[0];
			var lastPage:Boolean = listObject.attribute("lastpage")[0].toString() == 'true';
			
			var googleListUpdate:ArrayCollection;
			if(getEntityName() == "Activity")
				googleListUpdate = new ArrayCollection();
			
			Database.begin();
			var cnt:int = importRecords(entityIDsod, listObject.child(new QName(ns2.uri,entityIDns)),googleListUpdate);
			Database.commit();
			
			//do update to google calendar
			if(googleListUpdate != null){
				if(getEntityName() == "Activity" && googleListUpdate.length>0){
					var calUpdateService:GoogleCalendarUpdateService = new GoogleCalendarUpdateService(googleListUpdate);
					calUpdateService.start();
				}
			}
			
			nextPage(lastPage);
			return cnt;
		}
		
		protected function importRecords(entitySod:String, list:XMLList, googleListUpdate:ArrayCollection=null):int {
			var cnt:int = 0;
			for each (var data:XML in list) {
				cnt += importRecord(entitySod, data, googleListUpdate);
			}
			return cnt;
		}

		protected function isChangeOwner(localeRec:Object,serverRec:Object):Boolean{
			return false;
		}
		
		protected function isCanSave(obj:Object):Boolean{
			return true;
		}
		
		protected function importRecord(entitySod:String, data:XML, googleListUpdate:ArrayCollection=null):int {
			var tmpOb:Object={};
			
			for each (var field:Object in FieldUtils.allFields(entitySod)) {
				
				var xmllist:XMLList = data.child(new QName(ns2.uri,WSProps.ws10to20(entitySod,field.element_name)));
				if (xmllist.length()>1)
					trace(field.element_name,xmllist.length());
				if (xmllist.length() > 0) {
					tmpOb[field.element_name] = xmllist[0].toString();
				} else {
					tmpOb[field.element_name] = null;
				}
			}
			
			
			
			var info:Object = getInfo(data,tmpOb);
			var localRecord:Object = dao.findByOracleId(info.rowid);
			
			if(isChangeOwner(localRecord,tmpOb) && UserService.DIVERSEY==UserService.getCustomerId()){				
				dao.deleteByOracleId(info.rowid);
				_nbItems ++;
				return 1;
			}
			if(!isCanSave(tmpOb)){
				return 0;
			}
			
			//only jd user		
			if(entityIDour== Database.serviceDao.entity 
				&& UserService.DIVERSEY==UserService.getCustomerId()){
				
				if(tmpOb["Status"] == 'Cancelled'){
					if(localRecord!=null){
						dao.deleteByOracleId(info.rowid);
					}
					return 0;//
				}
				
				var pickId:String='';
				if(tmpOb['CustomPickList9']==null||tmpOb['CustomPickList9']==''){
					pickId = gadget.service.PicklistService.getId(entityIDour,"CustomPickList9",tmpOb["CustomText39"],LocaleService.getLanguageInfo().LanguageCode);
					tmpOb['CustomPickList9']= pickId;
				}
				
				if(tmpOb['CustomPickList8']==null||tmpOb['CustomPickList8']==''){
					pickId = gadget.service.PicklistService.getId(entityIDour,"CustomPickList8",tmpOb["CustomText39"],LocaleService.getLanguageInfo().LanguageCode);
					tmpOb['CustomPickList8']= pickId;
				}
				
				
			}
			
			
			tmpOb.deleted = false;
			tmpOb.local_update = null;
			if(entityIDour == Database.activityDao.entity){
				tmpOb.ms_local_change = new Date().getTime();
			}
			

			var modName:String = WSProps.ws20to10(entitySod, MODIFIED_DATE);
			var modDate:Date = ServerTime.parseSodDate(tmpOb[modName]);
			if (modDate==null) {
				optWarn(i18n._("{1} record with Id {2} has NULL modification date", entitySod, info.rowid));   
			} else {
				if (param.minRec>modDate)		// this works for > but not for ==
					param.minRec	= modDate;
				if (param.maxRec<modDate)
					param.maxRec	= modDate;
			}

			

			
			
			
			initBeforeSave(tmpOb);
			
			if(entityIDour==Database.productDao.entity){
				tmpOb.ood_lastmodified=tmpOb.ModifiedByDate;
			}else{
				tmpOb.ood_lastmodified=tmpOb.ModifiedDate;
			}
			if (info.rowid == null || info.rowid == "") {
				//VAHI actually this is an internal programming error if it occurs
				//Database.errorLoggingDao.add(null,{entitySod:entitySod,task:getEntityName(),ob:ObjectUtils.DUMPOBJECT(tmpOb),data:data.toXMLString()});
				trace("missing rowid in",getEntityName(),ObjectUtils.DUMPOBJECT(tmpOb));
				optWarn(i18n._("empty rowid in {1}, ignoring record", getEntityName()));
			} else if (localRecord == null) {
				//-- VM -- bug 331
				tmpOb.sync_number = Database.syncNumberDao.getSyncNumber();
				
				trace('ADD',getTransactionName(), info.rowid,tmpOb[modName],info.name);
				updateTracking(entitySod, info.rowid);
				dao.insert(tmpOb,false);
				notifyCreation(false, info.name);
				
			} else {
				var doGoogleSynce:Boolean = false;
				var changed:Boolean = false;
				if (this is IncomingObjectPerId) {
					changed = true;
				} else {
					for each (var field2:Object in FieldUtils.allFields(entitySod)) {
						
						if(field2.element_name == "GDATA" || field2.element_name == "IsPrivateEvent" || field2.element_name == "GUID") continue;
						
						if (tmpOb[field2.element_name] != localRecord[field2.element_name]) {
							
							if (StringUtils.isEmpty(tmpOb[field2.element_name]) && StringUtils.isEmpty(localRecord[field2.element_name])) {
								continue;
							}
							
							// VAHI: XXX
							// The ignoreFields are probably not used.
							// These fields may be present on the SoD side, but they are not on the fieldDao side.
							// As the iteration goes over fieldDao, these fields cannot be present.
							// So perhaps following is redundant code?
							if (field2.element_name.indexOf("CI_") == 0 || ignoreFields.indexOf(field2.element_name)>=0) {
								continue;
							}
							
							if(getEntityName() == "Activity"){
								if( field2.element_name == "Subject" || field2.element_name == "Description" || field2.element_name == "Location" ||
									field2.element_name == "StartTime" || field2.element_name == "EndTime" || field2.element_name == "DueDate")
								{ 
									doGoogleSynce = true; 
								}
							}
							
							changed = true;
							break;
						}
					}
				}
				if (changed) {
					
					if(Database.preferencesDao.getValue("enable_google_calendar", 0) != 0){
						if(doGoogleSynce && getEntityName()=="Activity" && !StringUtils.isEmpty(localRecord.GUID) && googleListUpdate!=null){
							tmpOb.IsPrivateEvent = localRecord.IsPrivateEvent;
							tmpOb.GDATA 		 = localRecord.GDATA;
							tmpOb.GUID 			 = localRecord.GUID;
							googleListUpdate.addItem(tmpOb);
						}
					}
					
					trace('UPD',getTransactionName(), info.rowid,tmpOb[modName],info.name);
					updateTracking(entitySod, info.rowid);
					dao.updateByOracleId(tmpOb);
					notifyUpdate(false, info.name);
					
				} else {
					trace('HAV',getTransactionName(), info.rowid,tmpOb[modName],info.name);
				}
			}
			postImportRecord(tmpOb);
			//update language info
			if(this is IncomingCurrentUserData){
				LocaleService.updateLanguageInfo(tmpOb);
				Database.allUsersDao.setOwnerUser(tmpOb);
			}
			if(!syncRecords.hasOwnProperty(info.rowid)){
				_nbItems ++;
				syncRecords[info.rowid]=info.rowid;
			}
			handleInlineData(data, tmpOb, info);
			
			return 1;
		}
		
		protected function postImportRecord(tmpOb:Object):void{
			//implement at sub class
		}
		
		protected function initBeforeSave(obj:Object):void{
			//implement at sub class
		}
		
		/**
		 * Cleanup modification tracking handled rows so they are not processed twice.
		 * @param entity Current entity.
		 * @param id Identifier.
		 */
		protected function updateTracking(entity:String, id:String):void {
			if (!(this is ModificationTracking)) {
				Database.modificationTrackingDao.process(IncomingObjectPerId.translateEntity(entity), id);
			}			
		}

		protected function getRequestXML():XML { return stdXML; }

		// Most likely methods to override
		
		/**
		 * Override to tweak variables in constructor
		 */
		protected function tweak_vars():void {}

		protected function handleInlineData(data:XML, tmpOb:Object, info:Object):void {

			for each (var sub:String in SupportRegistry.getSubObjects(entityIDour)) {

				var subDao:SupportDAO = SupportRegistry.getSupportDao(entityIDour, sub);
				var subId:String = DAOUtils.getOracleId(subDao.entity);	
				var subName:String = subDao.getSodSubName();
				var listName:String = "ListOf"+subName;
				
				var xmllist:XMLList = data.child(new QName(ns2.uri,listName));
				if (xmllist.length()==0)
					continue;
				if (xmllist[0].attribute("lastpage")[0].toString() != 'true')
					OOPS("=missing","Cannot handle additional sub-object-pages yet", entityIDour, sub);
				
				for each (var subrec:XML in xmllist[0].child(new QName(ns2.uri,subName))) {
					// XXX TODO MISSING: Delete records which are missing now?
					// Or can this be handled by deleted-Objects? (Hopefully, later)

					//VAHI the following is highly redundant to the above,
					// but no time yet to do proper common code, sorry.

					var rec:Object = {};
					var objTemp:Object = new Object();
					for each (var col:String in subDao.getCols()) {
						var xmldata:XMLList = subrec.child(new QName(ns2.uri,col));
						if (xmldata.length()>1)
							trace(col,xmldata.length());
						rec[col] = xmldata.length()>0 ? xmldata[0].toString() : null;
						objTemp[col] = rec[col];
					}

					var allOk:Boolean = subDao.fix_sync_incoming(rec, tmpOb);
					
					if("ListOfAddress"==listName){
						try{
							objTemp['ParentId'] = tmpOb[entityIDour + "Id"];
							objTemp['Full_Address'] = rec.Address + ", "+ rec.City + ", "+ rec.ZipCode + ", "+ rec.Country;
							objTemp['Entity'] = entityIDour;
							Database.addressDao._insert(objTemp); 					
						}catch(e:Error){
							trace(e.message);
						}
						continue;
					}
					rec.deleted = false;
					rec.local_update = null;

					if (!allOk && StringUtils.isEmpty(rec[subId])) {

						//Database.errorLoggingDao.add(null,{entitySod:subDao.entity, task:getEntityName(), ob:ObjectUtils.DUMPOBJECT(rec), data:subrec.toXMLString()});
						trace("missing rowid in", getEntityName(), ObjectUtils.DUMPOBJECT(rec));
						optWarn(i18n._("empty rowid in {1}, ignoring record", subDao.entity));

					} else if (rec[subId]==null || subDao.findByOracleId(rec[subId])==null) {
							
						trace('ADD', subDao.entity, rec[subId]);
						subDao.insert(rec);
						
						if (rec[subId]==null)
							subDao.fix_sync_add(rec, tmpOb);
						
					} else {
						trace('UPD', subDao.entity, rec[subId]);
						subDao.updateByOracleId(rec);
						
					}
				}
			}
		}
		
		private var once:Boolean = true;
		override protected function handleErrorGeneric(soapAction:String, request:XML, response:XML, mess:String, errors:XMLList):Boolean {
			if (mess==null || errors==null) {
				return false;
			}
			if (errors.length()>0 && errors[0].faultstring.length()>0) {
				mess = errors[0].faultstring[0].toString();
			}
			mess = mess.replace(/[[:space:]][[:space:]]*/g," ");
			//if (mess==i18n._("Method 'Execute' of business component '{1}' (integration component '{1}') returned the following error: \"Access denied.(SBL-DAT-00553)\"(SBL-EAI-04376)", entityIDsod)) {
			if(mess.indexOf("SBL-DAT-00553")!=-1){//|| mess.indexOf("SBL-EAI-04376")!=-1---timeout should be retry
				//not display
				//				if (once)
				//					warn(i18n._("Object {1} not supported in this environment", entityIDour));
				once = false;
				nextPage(true);
				return true;
			}
			OOPS("=unhandled(in)", soapAction, mess);
			return false;
		}


		//
		// Abstract Methods
		//

		// Return Object: { rowid:"Siebel ROWID", name:"User readable object name" }
		// Probably must be extended for future dynamic things (which are not like Account/Contact).
		protected function getInfo(response:XML, ob:Object):Object { notImpl("doResponse"); return null }
		
		

		
		override public function getRecordCount():String {
			return _nbItems.toString();
		}


		
		override public function getTransactionName():String { return entityIDour; }
		override public function getEntityName():String { return entityIDsod; }
		protected function getURN():String { return urn; }
		
		//VAHI this is bullshit bingo if we sync horizontally ..
		override  public function getName() : String {
			return i18n._('Reading "{1}" data from server', getEntityName());
		}
		
		protected function showCount():void {
			if (_lastItems!=_nbItems)
				countHandler(_nbItems);
			//_lastItems = _nbItems;
		}
		
		// Copied from SyncTask
		
		protected function notifyCreation(remote:Boolean, name:String):void {
			if (eventHandler != null) 
				eventHandler(remote, getTransactionName(), name, "Created");
		}
		
		protected function notifyUpdate(remote:Boolean, name:String):void {
			if (eventHandler != null)
				eventHandler(remote, getTransactionName(), name, "Updated");	
		}
		
		/*
		protected function notifyDelete(remote:Boolean, name:String, entity:String = null):void {
		if (eventHandler != null)
		eventHandler(remote, entity == null ? getEntityName() : entity, name, "Deleted");
		}
		*/
		
		// Change following into a class,
		// such that member functions can be called!
		
		//VAHI as seen in the original Sync
		protected function getFilterCriterials(entityOur:String):ArrayCollection {
			
			var criterials:ArrayCollection = new ArrayCollection();
			
			if (!withFilters)
				return criterials;
			
			// XXX TODO
			// This should not go here, it should go into filterDao or transactionDao
			
			var transaction:Object = Database.transactionDao.find(entityOur);
			if (transaction==null)
				return criterials;
			
			var filters:Object = Database.filterDao.getObjectFilter(entityOur,transaction.filter_id);
			if (transaction.filter_id>0)
				return Database.criteriaDao.findCriterialWithConjunctionAnd(filters.id);
			
			return criterials;
		}
		
	
		// change it into a function returning the complete field, such that it can be added directly.
		// Also looking up the field in the criterials this way is clumsy.
		// Even that criterials only have very few fields.
//		protected function applyFilters(xml:XML, fieldInternal:String, fieldSod:String, criterials:ArrayCollection):void {
//			//VAHI generic variant of what was found in original Sync:
//			// apply some criterials (filter specs)
//			if (!withFilters)
//				return;
//			
//			// XXX TODO
//			// This should not go here, it should go into filterDao or transactionDao
//			for each (var objCriterial:Object in criterials) {
//			    //order by cannot send
//				if(objCriterial.num=="5"){
//					continue;
//				}
//				//Bug fixing 588 CRO
//				if (fieldInternal == objCriterial.column_name) {
//					var val:String= Utils.doEvaluateForFilter(objCriterial,entityIDour);
//					if(val != "<ERROR>"){
//						if(val=='') continue;
//						var childValue:String = objCriterial.operator + " " + StringUtils.xmlEscape(StringUtils.sqlStrArg(val));
//						var operator:String =objCriterial.operator;
//						if(operator.toLocaleUpperCase() == 'LIKE'){
//							childValue = "LIKE " + StringUtils.xmlEscape(StringUtils.sqlStrArg("*"+val+"*"));
//						}else if(operator.toLocaleUpperCase() == 'LIKE%'){
//							childValue = "LIKE " + StringUtils.xmlEscape(StringUtils.sqlStrArg(val+"*"));
//						}
//						trace("filter",getEntityName(),"column",fieldSod,"with",childValue);
//						xml.elements(fieldSod).appendChild(childValue);
//					}else{
//						isFormulaError=true;						
//					}
//				}
//			}
//		}
		
		protected function addFilters(entityOur:String, entitySod:String, xml:XML):XML {
			if (!withFilters)
				return xml;
			

			for each (var objCriterial:Object in getFilterCriterials(entityOur)) {
				var col:String = objCriterial.column_name;
				col = WSProps.ws10to20(entitySod, col);
				
				var chi:XML = new XML("<" + col + "/>");
				var childValue:String = objCriterial.operator + " " + StringUtils.xmlEscape(StringUtils.sqlStrArg(objCriterial.param));
				
				trace("filter",getEntityName(),"column",col,"with",childValue);
				chi.appendChild(childValue);
				xml.appendChild(chi);
			}
			return xml;
		}
	}
}
