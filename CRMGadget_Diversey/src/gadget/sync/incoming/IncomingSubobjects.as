package gadget.sync.incoming
{
	import flexunit.utils.ArrayList;
	
	import gadget.dao.DAOUtils;
	import gadget.dao.Database;
	import gadget.dao.SupportDAO;
	import gadget.dao.SupportRegistry;
	import gadget.i18n.i18n;
	import gadget.sync.WSProps;
	import gadget.util.ObjectUtils;
	import gadget.util.SodUtils;
	import gadget.util.SodUtilsTAO;
	import gadget.util.StringUtils;
	
	import mx.collections.ArrayCollection;

	public class IncomingSubobjects extends IncomingSubBase
	{
		protected var subDao:SupportDAO = null;		
		public function IncomingSubobjects(ID:String, _subID:String) {
			var daoName:String = null;
			var sodDao:SodUtilsTAO = SodUtils.transactionProperty(_subID);
			if(sodDao!=null && this is IncomingSubActivity){
				daoName = sodDao.dao;
			}else{
				subDao = SupportRegistry.getSupportDao(ID, _subID);				
			}
			super(ID, _subID, daoName);
			if(subDao!=null){
				isUsedLastModified = !subDao.isSelectAll;
			}
			
			
		}
		
		override protected function importRecords(entitySod:String, list:XMLList, googleListUpdate:ArrayCollection=null):int{
			var subList:ArrayCollection = null;
			if(! isUsedLastModified){	
				var criteria:Object = {};
				criteria[entityIDour+"Id"] = this.pid;
				var subs:Array = subDao.getByParentId(criteria);
				if(subs!=null){
					subList = new ArrayCollection(subs);
				}
			}
			
			var n:int =  super.importRecords(entitySod,list,subList);
			var oraId:String = DAOUtils.getOracleId(subDao.entity);
			if(subList!=null && subList.length>0){
				for each(var obj:Object in subList){
					var id:String = obj[oraId];
					if(id.indexOf("#")==-1){
						subDao.deleteByOracleId(id);
					}
				}
			}
			
			return n;
			
		}
		
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

		override protected function importRecord(sub:String, data:XML, subList:ArrayCollection=null):int {
			if(this is IncomingSubActivity){
				return super.importRecord(sub,data);
			}
			
			
//			var subDao:SupportDAO = SupportRegistry.getSupportDao(entityIDour, sub);
			var subId:String = DAOUtils.getOracleId(subDao.entity);	
			
			var parentFieldId:String = entityIDour+"Id";
			
			
			
			var rec:Object = {};
			
			
			for each (var col:String in subDao.getCols()) {
				var xmldata:XMLList = data.child(new QName(ns2.uri,col));
				if (xmldata.length()>1)
					trace(col,xmldata.length());
				rec[col] = xmldata.length()>0 ? xmldata[0].toString() : null;				
			}
			
			if(subDao.entity == Database.relatedContactDao.entity){
				rec['RelatedContactFullName'] = rec['RelatedContactFirstName'] +' '+rec['RelatedContactLastName']
			}
			rec[parentFieldId] = this.pid;
			
			rec.deleted = false;
			rec.local_update = null;
			
			if (StringUtils.isEmpty(rec[subId])) {
				
				return 0;
				
			} else{
				
				var obj:Object = null;
				if(isUsedLastModified){
					obj = subDao.findByOracleId(rec[subId]);
				}else{
					if(subList!=null){
						obj = removeFromList(rec[subId],subList,subId);
					}
				}
					
				
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
							<{entityIDns}>
								<Id/>
								<{subList} pagesize={SUB_PAGE_SIZE} startrownum={SUBROW_PLACEHOLDER}>
									<{subIDsod} searchspec={SEARCHSPEC_PLACEHOLDER}>										
									</{subIDsod}>
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