package gadget.sync.incoming
{
	import flash.utils.Dictionary;
	
	import flexunit.utils.ArrayList;
	
	import gadget.dao.DAOUtils;
	import gadget.dao.Database;
	import gadget.dao.SupportDAO;
	import gadget.dao.SupportRegistry;
	import gadget.i18n.i18n;
	import gadget.sync.WSProps;
	import gadget.util.FieldUtils;
	import gadget.util.ObjectUtils;
	import gadget.util.SodUtils;
	import gadget.util.SodUtilsTAO;
	import gadget.util.StringUtils;
	
	import mx.collections.ArrayCollection;

	public class IncomingSubobjects extends IncomingSubBase
	{
		protected var deletedAlready:Dictionary = new Dictionary();
		protected var subDao:SupportDAO = null;		
		public function IncomingSubobjects(ID:String, _subID:String) {
			var daoName:String = null;
			var sodDao:SodUtilsTAO = SodUtils.transactionProperty(_subID);
			if(sodDao!=null && this is IncomingSubActivity){
				daoName = sodDao.dao;
			}else{
					
				subDao = SupportRegistry.getSupportDao(ID, _subID);	
				
				if(subDao==null){
					subDao = Database[sodDao.dao] as SupportDAO;
				}
			}
			super(ID, _subID, daoName);
			if(subDao!=null){
				isUsedLastModified = !subDao.isSelectAll;
			}
			
			
		}
		
		
		
		
		
//		override protected function importRecords(entitySod:String, list:XMLList, googleListUpdate:ArrayCollection=null):int{
//			var subList:ArrayCollection = null;
//			if(! isUsedLastModified && subDao!=null){	
//				var criteria:Object = {};
//				criteria[entityIDour+"Id"] = this.pid;
//				var subs:Array = subDao.getByParentId(criteria);
//				if(subs!=null){
//					subList = new ArrayCollection(subs);
//				}
//			}
//			
//			var n:int =  super.importRecords(entitySod,list,subList);
//			if(subDao!=null){
//				var oraId:String = DAOUtils.getOracleId(subDao.entity);
//				if(subList!=null && subList.length>0){
//					for each(var obj:Object in subList){
//						var id:String = obj[oraId];
//						if(id.indexOf("#")==-1){
//							subDao.deleteByOracleId(id);
//						}
//					}
//				}
//			}
//			return n;
//			
//		}
		
		private function removeFromList(oracleId:String,list:ArrayCollection,fieldId:String ):Object{
			var i:int=0;
			for each(var obj:Object in list){
				if(obj[fieldId] == oracleId){
					return list.removeItemAt(i);					
				}
				i++;
			}
			return null;
		}
		
		protected function deleteOracleRecordByParentId(parentId:String):void{
			var criteria:Object = {};
			criteria[entityIDour+"Id"] = parentId;
			subDao.deleteOnlyRecordeNotErrorByParent(criteria);
		}
		
		override protected function handleResponse(request:XML, response:XML):int {
			var listObject:XML = response.child(new QName(ns2.uri,listID))[0];
			var lastPage:Boolean = listObject.attribute("lastpage")[0].toString() == 'true';
			var lastSubPage:Boolean = true;
			var qsublist:QName = new QName(ns2.uri,subList);
			var cnt:int=0;
			var parentIds:ArrayCollection = new ArrayCollection();
			var subXmls:ArrayCollection = new ArrayCollection();
			for each (var parentRec:XML in listObject.child(new QName(ns2.uri,entityIDns))) {
				var subObject:XML = parentRec.child(qsublist)[0];					
				//this.pid =  parentRec.child(new QName(ns2.uri,"Id"))[0].toString();	
				parentIds.addItem(parentRec.child(new QName(ns2.uri,"Id"))[0].toString());
				lastSubPage = lastSubPage && ( subObject.attribute("lastpage")[0].toString() == 'true' );					
				subXmls.addItem(subObject);				
			}
			if(! isUsedLastModified && subDao!=null){	
				Database.begin();
				try{
					for each(var parentId:String in parentIds){
						if(!deletedAlready.hasOwnProperty(parentId)){
							deleteOracleRecordByParentId(parentId);
							deletedAlready[parentId]=parentId;
						}
					}
				}finally{
					Database.commit();
				}
			}
			Database.begin();
			try{
				for(var i:int;i<subXmls.length;i++){
					var subXml:XML = subXmls.getItemAt(i) as XML;
					this.pid = parentIds.getItemAt(i) as String;
					var nr:int = importRecords(subIDsod, subXml.child(new QName(ns2.uri,subIDns)));
					if (nr<0) {
						nr=0;
					}
					cnt += nr;
				}
				
			}finally{
				Database.commit();
			}		
			
			nextSubPage(lastPage,lastSubPage);
			return cnt;
			
		}
		

		override protected function importRecord(sub:String, data:XML, subList:ArrayCollection=null):int {
			if(this is IncomingSubActivity){
				return super.importRecord(sub,data);
			}
			
			
//			var subDao:SupportDAO = SupportRegistry.getSupportDao(entityIDour, sub);
			var subId:String = DAOUtils.getOracleId(subDao.entity);	
			
			var parentFieldId:String = entityIDour+"Id";
			
			
			
			var rec:Object = {};
			
			
			for each (var col:String in subDao.getCols()) {
				//var col:String=colObj.element_name;
				var xmldata:XMLList = data.child(new QName(ns2.uri,WSProps.ws10to20(subDao.entity,col)));
				if (xmldata.length()>1)
					trace(col,xmldata.length());
				rec[col] = xmldata.length()>0 ? xmldata[0].toString() : null;				
			}
//			//read id
//			var idXml:XMLList = data.child(new QName(ns2.uri,WSProps.ws10to20(subDao.entity,subId));
//			if(idXml!=null){
//				rec[subId]= idXml.length()>0 ? xmldata[0].toString()
//			}
			
			if(subDao.entity == Database.relatedContactDao.entity){
				rec['RelatedContactFullName'] = rec['RelatedContactFirstName'] +' '+rec['RelatedContactLastName']
			}
			rec[parentFieldId] = this.pid;
			
			rec.deleted = false;
			rec.local_update = null;
			if (StringUtils.isEmpty(rec[subId])) {
				
				return 0;
				
			} else{
				
				var obj:Object = subDao.findByOracleId(rec[subId]);
//				if(isUsedLastModified){
//					obj = subDao.findByOracleId(rec[subId]);
//				}else{
//					if(subList!=null){
//						obj = removeFromList(rec[subId],subList,subId);
//					}
//				}
					
				
				if(obj==null){
//					trace('ADD', subDao.entity, rec[subId]);
					try{
					subDao.insert(rec);
					}catch(e:Error){
						//maybe dupldate recode 
					}
				}else {
					
//					trace('UPD', subDao.entity, rec[subId]);
					if(isChange(obj,rec)){
						subDao.updateByOracleId(rec);
					}
					
					
				}
				
				
				
			} 
			
			_nbItems ++;
			
			
			return 1;
			
		}
		
		private function isChange(locRec:Object,serverRec:Object):Boolean{
			
			for( var f:String in serverRec){
				if(locRec[f] != serverRec[f]){
					return true;
				}
			}
			
			return false;
		}
		
		override protected function tweak_vars():void {
			super.tweak_vars();
			
			//var dateXML:XML = linearTask ? <{MODIFIED_DATE}/> : <{MODIFIED_DATE}>{SEARCHSPEC_PLACEHOLDER}</{MODIFIED_DATE}>;

			if (stdXML == null) {
				stdXML =
					<{wsID} xmlns={ns1.uri}>
						<ViewMode>{viewMode}</ViewMode>
						<{listID} pagesize={pageSize} startrownum={ROW_PLACEHOLDER}>
							<{entityIDns} searchspec={PARENT_SEARCH_SPEC}>
								<Id/>
								<{subList} pagesize={SUB_PAGE_SIZE} startrownum={SUBROW_PLACEHOLDER}>
									<{subIDns} searchspec={SEARCHSPEC_PLACEHOLDER}>										
									</{subIDns}>
								</{subList}>
							</{entityIDns}>
						</{listID}>
					</{wsID}>
				;
			}
		}

		// Fiddle the subobject into the XML
		override protected function initXMLsub(baseXML:XML, qapp:XML):void {
			var qsublist:QName=new QName(ns1.uri,subList), qsub:QName=new QName(ns1.uri,subIDns);
			qapp = qapp.child(qsublist)[0].child(qsub)[0];			
			for each (var field:String in subDao.getCols()) {
				
				if(subDao.getIncomingIgnoreFields().contains(field)) continue;
				
				if (ignoreQueryFields.indexOf(field)<0) {
					qapp.appendChild(new XML("<" + field + "/>"));
				}
			}
		}
	}
}