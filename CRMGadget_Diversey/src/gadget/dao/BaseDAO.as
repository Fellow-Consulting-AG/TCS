package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	import gadget.control.CalculatedField;
	import gadget.service.PicklistService;
	import gadget.service.UserService;
	import gadget.util.FieldUtils;
	import gadget.util.StringUtils;
	import gadget.util.Utils;
	
	import mx.collections.ArrayCollection;
	
	import org.flexunit.runner.Result;
	
	public class BaseDAO extends BaseQuery implements DAO {
		private var stmtSum:SQLStatement;
		private var stmtUpdateByFieldRelation:SQLStatement;
		private var stmtUpdateByField:SQLStatement;
		private var stmtFindAll:SQLStatement;
		private var stmtFindByOID:SQLStatement;
		private var stmtInsert:SQLStatement;
		private var stmtUpdate:SQLStatement;
		private var stmtUpdateByOID:SQLStatement;
		private var stmtDelete:SQLStatement;
		private var stmtDeleteOracle:SQLStatement;
		private var stmtFindById:SQLStatement;
		private var stmtSelectLastRecord:SQLStatement;
		private var stmtFindCreated:SQLStatement;
		private var stmtFindUpdated:SQLStatement;
		private var stmtDeleteTemporary:SQLStatement;
		private var stmtUndeleteTemporary:SQLStatement;
		private var stmtFindDeleted:SQLStatement;
		private var stmtUpdateRef:SQLStatement;
		private var stmtSetError:SQLStatement;
		private var stmtSetErrorGid:SQLStatement;
		private var stmtFindDuplicateByColumn:SQLStatement;
		private var stmtUpdateRelationField:SQLStatement;
		private var sqlConnection:SQLConnection;
		private var stmtFindMSId:SQLStatement;
		private var stmtIncreaseImportant:SQLStatement;
		private var stmtUpdateFavorite:SQLStatement;
		private var stmtFindOutgoingMSId:SQLStatement;
		private var stmtRemoveRelationField:SQLStatement;
		private var stmtDeletedByParentId:SQLStatement;
		private var stmtGetByParentId:SQLStatement;
		public static function getUppernameCol(num:int):String {
			if (num == 0) {
				return "uppername";
			} else {
				return "uppername" + num;
			}
		}

		public function BaseDAO(work:Function, sqlConnection:SQLConnection, structure:Object) {
			var indexes:Array = ["deleted", "local_update" ];
			this.sqlConnection=sqlConnection;
			var columns:Object = {
				gadget_id: "INTEGER PRIMARY KEY AUTOINCREMENT",
				local_update: "string",
				deleted: "boolean",
				error: "boolean",
				ood_lastmodified:"string",
				sync_number: "integer",
				important: "integer",
				favorite: "boolean"
			};
			if (structure.search_columns) {
				for (var i:int = 0; i < structure.search_columns.length; i++) {
					indexes = indexes.concat(getUppernameCol(i));
					columns[getUppernameCol(i)] = { type:"TEXT", init:"upper(" + structure.search_columns[i] + ")"};
				}
			}
			super(work, sqlConnection, structure, {
				table: (structure && structure.table) ? structure.table : entity,	//VAHI XXX TODO actually this is a hack, let it vanish if everything has been refactored
				index: indexes,
				columns: columns
			});

			if (sqlConnection==null)
				return;

			DAOUtils.register(entity, structure);
			
			//Sum number,int,currency fields
			stmtSum = new SQLStatement();
			stmtSum.sqlConnection = sqlConnection;
			
			// Find all the items, used in lists
			stmtFindAll = new SQLStatement();
			stmtFindAll.sqlConnection = sqlConnection;
			
			// Find by Oracle CRM Id
			stmtFindByOID = new SQLStatement();
			stmtFindByOID.sqlConnection = sqlConnection;
			stmtFindByOID.text = "SELECT '" + entity + "' gadget_type, * FROM " + tableName + " WHERE " + fieldOracleId + " = :" + fieldOracleId;
			
			// Inserts a new item
			stmtInsert = new SQLStatement();
			stmtInsert.sqlConnection = sqlConnection;
			// Update an some fields based on Gadget's Id
			stmtUpdateByField = new SQLStatement();
			stmtUpdateByField.sqlConnection = sqlConnection;
			
			//
			stmtUpdateByFieldRelation = new SQLStatement();
			stmtUpdateByFieldRelation.sqlConnection = sqlConnection;
			
			
			// Update an item based on Gadget's Id
			stmtUpdate = new SQLStatement();
			stmtUpdate.sqlConnection = sqlConnection;
				
			// Update an item based on Oracle CRM Id
			stmtUpdateByOID = new SQLStatement();
			stmtUpdateByOID.sqlConnection = sqlConnection;
			
			// Deletes an item
			stmtDelete = new SQLStatement();
			stmtDelete.sqlConnection = sqlConnection;
			stmtDelete.text = "DELETE FROM " + tableName + " WHERE gadget_id = :gadget_id";
			
			stmtDeleteOracle = new SQLStatement();
			stmtDeleteOracle.sqlConnection = sqlConnection;
			stmtDeleteOracle.text = "DELETE FROM " + tableName + " WHERE " + fieldOracleId + " = :" + fieldOracleId;
			
			// Find an item by Gadget's Id
			stmtFindById = new SQLStatement();
			stmtFindById.sqlConnection = sqlConnection;
			stmtFindById.text = "SELECT '" + entity + "' gadget_type, * FROM " + tableName + " WHERE gadget_id = :gadget_id";
			
			// Find an item by MS Exchange Id
			stmtFindMSId = new SQLStatement();
			stmtFindMSId.sqlConnection = sqlConnection;
			stmtFindMSId.text = "SELECT '" + entity + "' gadget_type, * FROM " + tableName + " WHERE ms_id = :ms_id";
			
			stmtFindOutgoingMSId = new SQLStatement();
			stmtFindOutgoingMSId.sqlConnection = sqlConnection;
			stmtFindOutgoingMSId.text = "SELECT '" + entity + "' gadget_type, * FROM " + tableName + " WHERE (Type is null OR Type !='Email') AND (ms_id is not null AND ms_id !='') AND (ms_local_change is not null AND ms_local_change != '') AND Activity = :activity";
			
			var msId:String = "";
			if(entity == "Activity" || entity == "Contact"){
				msId =  "AND (ms_id is null OR ms_id ='')";
			}
			// Find all items updated locally
			stmtFindUpdated = new SQLStatement();
			stmtFindUpdated.sqlConnection = sqlConnection;
			stmtFindUpdated.text = "SELECT '" + entity + "' gadget_type, *, " + DAOUtils.getNameColumn(entity) + " name FROM " + tableName + " WHERE local_update is not null AND (deleted = 0 OR deleted IS null)" + msId + " ORDER BY local_update LIMIT :limit OFFSET :offset";	

			// Find all items created locally
			stmtFindCreated = new SQLStatement();
			stmtFindCreated.sqlConnection = sqlConnection;
			//VAHI the "OR ... IS NULL" is a workaround to make Expenses work
			stmtFindCreated.text = "SELECT '" + entity + "' gadget_type, *, " + DAOUtils.getNameColumn(entity) + " name FROM " + tableName + " WHERE ( (" + fieldOracleId + " >= '#' AND " + fieldOracleId + " <= '#zzzz') OR " + fieldOracleId + " IS NULL ) AND (deleted = 0 OR deleted IS null) " + msId + " ORDER BY  " + fieldOracleId + " LIMIT :limit OFFSET :offset";	
			
			// Get or Select Last Record
			stmtSelectLastRecord = new SQLStatement();
			stmtSelectLastRecord.sqlConnection = sqlConnection;
			stmtSelectLastRecord.text = "SELECT '" + entity + "' gadget_type, * FROM " + tableName + " WHERE " + fieldOracleId + " is null ORDER BY gadget_id desc limit 1";
			
			// Delete temporary just updates the field deleted to true
			stmtDeleteTemporary = new SQLStatement();
			stmtDeleteTemporary.sqlConnection = sqlConnection;
			stmtDeleteTemporary.text = "UPDATE " + tableName + " SET deleted = true WHERE gadget_id = :gadget_id"; 

			stmtUndeleteTemporary = new SQLStatement();
			stmtUndeleteTemporary.sqlConnection = sqlConnection;
			stmtUndeleteTemporary.text = "UPDATE " + tableName + " SET deleted = false WHERE gadget_id = :gadget_id"; 

			stmtFindDeleted = new SQLStatement();
			stmtFindDeleted.sqlConnection = sqlConnection;
			stmtFindDeleted.text = "SELECT * FROM " + tableName + " WHERE deleted = true ORDER BY uppername LIMIT :limit OFFSET :offset";
			
			stmtUpdateRef = new SQLStatement();
			stmtUpdateRef.sqlConnection = sqlConnection;
			
			stmtFindDuplicateByColumn = new SQLStatement();
			stmtFindDuplicateByColumn.sqlConnection = sqlConnection;
			
			stmtSetError = new SQLStatement();
			stmtSetError.sqlConnection = sqlConnection;
			stmtSetError.text = "UPDATE " + tableName + " SET error = :error WHERE " + fieldOracleId + " = :" + fieldOracleId;
			
			stmtSetErrorGid = new SQLStatement();
			stmtSetErrorGid.sqlConnection = sqlConnection;
			stmtSetErrorGid.text = "UPDATE " + tableName + " SET error = :error WHERE gadget_id = :gadget_id";
			
			stmtIncreaseImportant = new SQLStatement();
			stmtIncreaseImportant.sqlConnection = sqlConnection;
			stmtIncreaseImportant.text = "UPDATE " + tableName + " SET important = :important WHERE gadget_id = :gadget_id";
			
			stmtUpdateFavorite = new SQLStatement();
			stmtUpdateFavorite.sqlConnection = sqlConnection;
			stmtUpdateFavorite.text = "UPDATE " + tableName + " SET favorite = :favorite WHERE gadget_id = :gadget_id";
			
			
		}
		public function sumFields(sqlObject:Object):Object{
			stmtSum.clearParameters();
			stmtSum.parameters[":" +sqlObject.entityId] = sqlObject[sqlObject.entityId];
			stmtSum.text = sqlObject.sql;
			exec(stmtSum);
				
			var items:ArrayCollection = new ArrayCollection(stmtSum.getResult().data);
			if(items.length >0 ){
				return items[0];
			}
			
			return null;
			
		}
		public function increaseImportant(data:Object):void {
			stmtIncreaseImportant.parameters[":important"] = data.important==null?1:data.important+1;
			stmtIncreaseImportant.parameters[":gadget_id"] = data.gadget_id;
			exec(stmtIncreaseImportant);
		}
		
		public function updateFavorite(data:Object):void {
			stmtUpdateFavorite.parameters[":favorite"] = data.favorite;
			stmtUpdateFavorite.parameters[":gadget_id"] = data.gadget_id;
			exec(stmtUpdateFavorite);
		}
		
		public function updateRelationFields(objsVals:Object, criteria:Object):void{
			
			var where:String="";			
			var cols:String="", c:String="";			
			var col:String="";			
			var query:String = "UPDATE "+tableName + " SET ";
			stmtUpdateRelationField=new SQLStatement();
			stmtUpdateRelationField.sqlConnection=sqlConnection;
			for ( col in criteria) {
				where += " AND " +col+ "= :" + col;
				stmtUpdateRelationField.parameters[':'+col]=criteria[col];
			}
			
			for (col in objsVals) {				
				cols	+= c + " "  + col+"=:"+col;				
				c		=  ",";
				stmtUpdateRelationField.parameters[':'+col]=objsVals[col];
				
			}
			 			
			 where=where!="" ? " WHERE "+where.substr(5) : "";
			 query = query + cols + where;
			 stmtUpdateRelationField.text=query;
			exec(stmtUpdateRelationField);
			
			
		}
		
		public function removeRelationFields(fields:Array, criteria:Object):void{
			var where:String="";			
			var cols:String="", c:String="";			
			var col:String="";			
			var query:String = "UPDATE "+tableName + " SET ";
			stmtRemoveRelationField = new SQLStatement();
			stmtRemoveRelationField.sqlConnection=sqlConnection;
			
			for(col in criteria){
				where+=" AND " + col +"= :"+col;
				stmtRemoveRelationField.parameters[':'+col] = criteria[col];
			}
			
			for each(col in fields){
				cols	+= c + " "  + col+"=:"+col;				
				c		=  ",";
				stmtRemoveRelationField.parameters[':'+col]='';				
			}
			
			where=where!="" ? " WHERE "+where.substr(5) : "";
			query = query + cols + where;
			stmtRemoveRelationField.text=query;
			exec(stmtRemoveRelationField);
			
		}
		
		
		
		public function deleteByParentId(criteria:Object):void{
			var where:String="";			
					
			var col:String="";			
			var query:String = "DELETE FROM "+tableName ;
			stmtDeletedByParentId = new SQLStatement();
			stmtDeletedByParentId.sqlConnection = sqlConnection;
			
			for(col in criteria){
				where+=" AND " + col +"= :"+col;
				stmtDeletedByParentId.parameters[':'+col] = criteria[col];
			}
			
			
			where=where!="" ? " WHERE "+where.substr(5) : "";
			query = query + where;
			stmtDeletedByParentId.text=query;
			exec(stmtDeletedByParentId);
		}
		
		public function getByParentId(criteria:Object):Array{
			var where:String="";			
			
			var col:String="";			
			var query:String = "SELECT  '" + entity + "' gadget_type, * FROM " + tableName ;
			stmtGetByParentId = new SQLStatement();
			stmtGetByParentId.sqlConnection = sqlConnection;
			
			for(col in criteria){
				where+=" AND " + col +"= :"+col;
				stmtGetByParentId.parameters[':'+col] = criteria[col];
			}
			
			
			where=where!="" ? " WHERE "+where.substr(5) : "";
			query = query + where;
			stmtGetByParentId.text=query;
			exec(stmtGetByParentId);
			var result:SQLResult = stmtGetByParentId.getResult();
			if(result!=null)
				return result.data;
			return null;			
		}
		
		
		public function getOutgoingIgnoreFields():ArrayCollection{
			//need to implement in subclass
			return new ArrayCollection();
		}
		public function getIncomingIgnoreFields():ArrayCollection{
			//need to implement in subclass
			return new ArrayCollection();
		}
			
		
		
		
		public function findAll(columns:ArrayCollection, filter:String = null, selectedId:String = null, limit:int = 1001,order_by:String=null,addColOODLastModified:Boolean=true, group_by:String=null):ArrayCollection {
			var cols:String = '';
			var colOODLastModified:String="";
			for each (var column:Object in columns) {
				cols += ", " + column.element_name;
			}
			
			if(addColOODLastModified){
				colOODLastModified="ood_lastmodified,";
			}
			if(order_by==null){
				order_by = daoStructure.order_by? daoStructure.order_by + ' desc' : 'uppername';
			}			
//			stmtFindAll.text = "SELECT '" + entity + "' gadget_type, local_update, gadget_id, error,sync_number, "+colOODLastModified + fieldOracleId + cols + " FROM " + tableName + " WHERE " + (StringUtils.isEmpty(filter) ? "" : filter + " AND ") + "deleted != 1 ORDER BY " + order_by + ( limit==0? "":" LIMIT " + limit );
			stmtFindAll.text = "SELECT '" + entity + "' gadget_type, local_update, gadget_id, error,sync_number, "+colOODLastModified + fieldOracleId + cols + " FROM " + tableName + " WHERE " + (StringUtils.isEmpty(filter) ? "" : filter + " AND ") + "deleted != 1 " + (StringUtils.isEmpty(group_by) ? "" : "GROUP BY " + group_by) + " ORDER BY " + order_by + ( limit==0? "":" LIMIT " + limit );
			exec(stmtFindAll, false);
			var items:ArrayCollection = new ArrayCollection(stmtFindAll.getResult().data);
			// add a specific item when selectedId arg is provided
			// this is usefull when the user follows links to add the target item
			if (selectedId != null) {
				var found:Boolean = false;
				for each (var item:Object in items) {
					if (item.gadget_id == selectedId) {
						found = true;
						break;
					}
				}
				if (!found) {
					stmtFindAll.text = "SELECT '" + entity + "' gadget_type, local_update, gadget_id, error, "+colOODLastModified + fieldOracleId + cols + " FROM " + tableName + " WHERE " + (StringUtils.isEmpty(filter) ? "" : filter + " AND ") + "(deleted = 0 OR deleted is null) AND gadget_id =" + selectedId;
					exec(stmtFindAll);
					items.addAll(new ArrayCollection(stmtFindAll.getResult().data));
				}
			}
			computeCategory(items);
			Utils.suppressWarning(items);
			return items;
			
		}

		
		private function computeCategory(items:ArrayCollection):void {
			var synNum:Number = Database.syncNumberDao.getSyncNumber();
			var userIsJD:Boolean = UserService.DIVERSEY==UserService.getCustomerId();
			for each (var item:Object in items) {
				if (item.error) {
					item.modified = "ERR";
				} else if (!(item[fieldOracleId]) || StringUtils.startsWith(item[fieldOracleId], "#")) {
					item.modified = "NEW";
				} else if(item.local_update) {
					item.modified = "UPD";
				} else if((item[fieldOracleId]) && item.sync_number==synNum && item.gadget_type =='Service Request' && userIsJD) {
					item.modified = "NEW";
					item.fromsync = "sync";
				} else {
					item.modified = "";
				}	
				
						
			}
		}
		
		public function findByOracleId(oracleId:String):Object {
			stmtFindByOID.parameters[":" + fieldOracleId] = oracleId; 
			exec(stmtFindByOID);
			var result:SQLResult = stmtFindByOID.getResult();
			if (result.data == null || result.data.length == 0) {
				return null;
			}
			return result.data[0];
		}
		

		
		public function findByGadgetId(gadgetId:String):Object {
			stmtFindById.parameters[":gadget_id"] = gadgetId;
			exec(stmtFindById);
			var result:SQLResult = stmtFindById.getResult();
			if (result.data == null || result.data.length == 0) {
				return null;
			}
			return result.data[0];
		}
		public function findByMSId(msId:String):Object {
			stmtFindMSId.parameters[":ms_id"] = msId;
			exec(stmtFindMSId);
			var result:SQLResult = stmtFindMSId.getResult();
			if (result.data == null || result.data.length == 0) {
				return null;
			}
			return result.data[0];
		}
		
		public function getMSOutgoingObject(activity:String):ArrayCollection {
//			stmtFindMSId.parameters[":ms_id"] = msId;
			stmtFindOutgoingMSId.parameters[":activity"] = activity;
			exec(stmtFindOutgoingMSId);
			var result:SQLResult = stmtFindOutgoingMSId.getResult();
			if (result.data == null || result.data.length == 0) {
				return null;
			}
			return  new ArrayCollection(result.data);
		}
		
		public function findDeleted(offset:int, limit:int):ArrayCollection {
			stmtFindDeleted.parameters[":offset"] = offset; 
			stmtFindDeleted.parameters[":limit"] = limit; 
			exec(stmtFindDeleted, false);
			return new ArrayCollection(stmtFindDeleted.getResult().data);
		}

		public function findCreated(offset:int, limit:int):ArrayCollection {
			stmtFindCreated.parameters[":offset"] = offset; 
			stmtFindCreated.parameters[":limit"] = limit; 
			exec(stmtFindCreated, false);
			var list:ArrayCollection = new ArrayCollection(stmtFindCreated.getResult().data);
			//checkBindPicklist(stmtFindCreated.text,list);
			return list;
		}
		
		public function findUpdated(offset:int, limit:int):ArrayCollection {
			stmtFindUpdated.parameters[":offset"] = offset; 
			stmtFindUpdated.parameters[":limit"] = limit; 
			exec(stmtFindUpdated, false);
			var list:ArrayCollection = new ArrayCollection(stmtFindUpdated.getResult().data);
			//checkBindPicklist(stmtFindUpdated.text,list);
			return list;
		}
		
		public function checkBindPicklist(stmtFind:String,list:ArrayCollection):ArrayCollection {
			if(!StringUtils.isEmpty(entity)){
				var columns:ArrayCollection = Utils.getColumns(entity);
				var picklistFields:ArrayCollection = CalculatedField.getEntityPicklistFields(columns);
				for each(var obj:Object in list){
					for each(var objCol:Object in picklistFields){
						var str:String = obj[objCol.column];
						if(str!=null && str.indexOf("=")>-1){
							//TODO should be return picklist keyvalue
							// obj[objCol.column]=PicklistService.getId(entity,objCol.column,str.split("=")[1]);
							obj[objCol.column] = str.split("=")[1];
						} 
					}
				}
			}
			
			return list;
		}
		
		public function insert(object:Object, useCustomfield:Boolean=true):void {
			object.deleted = false;
			stmtInsert.text = insertQuery(useCustomfield);
			execStatement(stmtInsert, object,useCustomfield);
		}
		public function updateByFieldRelation(fields:Array,object:Object,relationId:String):void{
			stmtUpdateByFieldRelation.clearParameters();
			var sql:String  =  'UPDATE ' + tableName + " SET local_update = :local_update, deleted = :deleted, error = :error, sync_number = :sync_number,ood_lastmodified =:ood_lastmodified";
			
			for (var i:int=0 ;i<fields.length;i++) {
				stmtUpdateByFieldRelation.parameters[":" + fields[i] ] = object[fields[i]];
				sql = sql + "," + fields[i] +"= :"+ fields[i];
			}
			stmtUpdateByFieldRelation.text = sql + " WHERE "+ relationId + "= :" + relationId;
			stmtUpdateByFieldRelation.parameters[":"+relationId] = object[relationId];
			stmtUpdateByFieldRelation.parameters[':local_update'] = object.local_update;
			stmtUpdateByFieldRelation.parameters[':deleted'] = object.deleted;
			stmtUpdateByFieldRelation.parameters[':error'] = object.error;
			stmtUpdateByFieldRelation.parameters[':sync_number'] = object.sync_number;
			stmtUpdateByFieldRelation.parameters[':ood_lastmodified']=object.ood_lastmodified;
			exec(stmtUpdateByFieldRelation);
		}
		
		public function updateByField(fields:Array,object:Object):void{
			stmtUpdateByField.clearParameters();
			var sql:String  =  'UPDATE ' + tableName + " SET local_update = :local_update, deleted = :deleted, error = :error, sync_number = :sync_number,ood_lastmodified =:ood_lastmodified";
			
			for (var i:int=0 ;i<fields.length;i++) {
				stmtUpdateByField.parameters[":" + fields[i] ] = object[fields[i]];
				sql = sql + "," + fields[i] +"= :"+ fields[i];
			}
			stmtUpdateByField.text = sql + " WHERE gadget_id = :gadget_id";
			stmtUpdateByField.parameters[":gadget_id"] = object.gadget_id;
			stmtUpdateByField.parameters[':local_update'] = object.local_update;
			stmtUpdateByField.parameters[':deleted'] = object.deleted;
			stmtUpdateByField.parameters[':error'] = object.error;
			stmtUpdateByField.parameters[':sync_number'] = object.sync_number;
			stmtUpdateByField.parameters[':ood_lastmodified']=object.ood_lastmodified;
			exec(stmtUpdateByField);
		}
		
		public function update(object:Object):void {
			stmtUpdate.clearParameters();
			stmtUpdate.text = updateQuery() + " WHERE gadget_id = :gadget_id";
			stmtUpdate.parameters[":gadget_id"] = object.gadget_id;
			execStatement(stmtUpdate, object);
		}

		public function updateByOracleId(object:Object,updateCustomField:Boolean=false):void {
			stmtUpdateByOID.clearParameters();
			stmtUpdateByOID.text = updateQuery(updateCustomField)
				+ " WHERE " + fieldOracleId + " = :" + fieldOracleId;
			execStatement(stmtUpdateByOID, object,updateCustomField);
		}

		public function delete_(object:Object):void	{
			stmtDelete.parameters[":gadget_id"] = object.gadget_id;
			exec(stmtDelete);
		}

		public function deleteTemporary(object:Object):void	{
			stmtDeleteTemporary.parameters[":gadget_id"] = object.gadget_id;
			exec(stmtDeleteTemporary);
		}

		public function undeleteTemporary(object:Object):void	{
			stmtUndeleteTemporary.parameters[":gadget_id"] = object.gadget_id;
			exec(stmtUndeleteTemporary);
		}
		
		public function deleteByOracleId(oracleId:String):void	{
			stmtDeleteOracle.parameters[":" + fieldOracleId] = oracleId;
			exec(stmtDeleteOracle);
		}
		
		private function fieldList(updateFF:Boolean=true):ArrayCollection {
			var allFields:ArrayCollection = new ArrayCollection();
			allFields.addAll(FieldUtils.allFields(entity));
			// check if the Oracle ID is in the list
			var found:Boolean = false;
			for each (var field:Object in allFields) {
				if (field.element_name == fieldOracleId) {
					found = true;
					break;
				}
			}
			// add custom fields
			if(updateFF){
				// var customfields:ArrayCollection = Database.layoutDao.selectCustomFields(entity);
				var customfields:ArrayCollection = Database.customFieldDao.selectCustomFields(entity);
				allFields.addAll(customfields);
			}
			
			if (!found) {
				allFields.addItem({element_name:fieldOracleId});
			}
			return allFields;
		}
		
		
		
		public function selectLastRecord():ArrayCollection{
			exec(stmtSelectLastRecord);
			 var res:Array = stmtSelectLastRecord.getResult().data;
			 return new ArrayCollection(res);
		}
	
		private function  insertQuery(updateFF:Boolean=true):String {
			var sql:String = 'INSERT INTO ' + tableName + "(local_update, deleted, error, sync_number,ood_lastmodified";
			var i:int;
			var field:Object;
			if (daoStructure.search_columns) {
				for (i = 0; i < daoStructure.search_columns.length; i++) {
					sql += ", " + getUppernameCol(i);
				}
			}
			var listField:ArrayCollection = fieldList(updateFF);
			for each (field in listField) {
				sql += ", " + field.element_name;
			}
			sql += ") VALUES (:local_update, :deleted, :error, :sync_number,:ood_lastmodified";
			if (daoStructure.search_columns) {
				for (i = 0; i < daoStructure.search_columns.length; i++) {
					sql += ", :" + getUppernameCol(i);
				}
			}
			for each (field in listField) {
				sql += ", :" + field.element_name;
			}
			sql += ")";
			return sql;
		}
		
		private function updateQuery(updateFF:Boolean=true):String {
			var sql:String = 'UPDATE ' + tableName + " SET local_update = :local_update, deleted = :deleted, error = :error, sync_number = :sync_number,ood_lastmodified =:ood_lastmodified";
			if (daoStructure.search_columns) {
				for (var i:int = 0; i < daoStructure.search_columns.length; i++) {
					sql += ", " + getUppernameCol(i) + " = :" + getUppernameCol(i);
				}
			}
			var field:Object;
			for each (field in fieldList(updateFF)) {
				sql += ", " + field.element_name + " = :" + field.element_name;
			}
			return sql;
		}
		
		private function get fieldOracleId():String {
			return DAOUtils.getOracleId(entity);
		}
		
		
		protected function get tableName():String {
			return DAOUtils.getTable(entity);
		}
		
		
		private function execStatement(stmt:SQLStatement, object:Object,updateFF:Boolean=true):void {
			
			for each (var field:Object in fieldList(updateFF)) {
				if (object[field.element_name] != null)
					stmt.parameters[":" + field.element_name] = object[field.element_name];
				else{
					if(!updateFF){
						var fieldName:String = field.element_name;
						var oracleId:String = DAOUtils.getOracleId(entity);
						//					if(this is ActivityDAO){
						if(Database.getDao(entity).getIncomingIgnoreFields().contains(fieldName)){
							
							var obj:Object = findByOracleId(object[oracleId]);
							if(obj!=null){
								stmt.parameters[":" + field.element_name]=obj[fieldName];
								continue;
							}
							
						}
					}					
						
//					}
					
					stmt.parameters[":" + field.element_name] = null;
				}					
					
			}
			if (daoStructure.search_columns) {
				for (var i:int = 0; i < daoStructure.search_columns.length; i++) {
					stmt.parameters[':' + getUppernameCol(i)] = StringUtils.toUpperCase(stmt.parameters[":" + daoStructure.search_columns[i]]);
				}
			}
			stmt.parameters[':local_update'] = object.local_update;
			stmt.parameters[':deleted'] = object.deleted;
			stmt.parameters[':error'] = object.error;
			stmt.parameters[':sync_number'] = object.sync_number;
			stmt.parameters[':ood_lastmodified']=object.ood_lastmodified;
			exec(stmt);
		}

		
		public function findDuplicateByColumn(columnName:String, columnValue:String, gadget_id:String):Object{
			stmtFindDuplicateByColumn.text = 'SELECT * FROM ' + tableName + ' WHERE ' + columnName + ' = :columnValue AND gadget_id != :gadget_id';
			stmtFindDuplicateByColumn.parameters[":columnValue"] = columnValue;
			stmtFindDuplicateByColumn.parameters[":gadget_id"] = gadget_id;
			exec(stmtFindDuplicateByColumn);
			var r:SQLResult = stmtFindDuplicateByColumn.getResult();
			if(r.data==null || r.data.length==0){
				return null;
			}
			return r.data[0];
		}		
		
		public function updateReference(columnName:String, previousValue:String, nextValue:String):void {
			stmtUpdateRef.text = "UPDATE " + tableName + " SET " + columnName + " = '" + nextValue + "' WHERE " + columnName + " = '" + previousValue + "'";
			exec(stmtUpdateRef);
		}
		
		public function updateByGadgetId(columnName:String, gadgetId:String, value:String):void {
			stmtUpdateRef.text = "UPDATE " + tableName + " SET " + columnName + " = '" + value + "' WHERE gadget_id = " + gadgetId;
			exec(stmtUpdateRef);
		}
		
		public function setError(oracleId:String, error:Boolean):void {
			stmtSetError.parameters[":" + fieldOracleId ] = oracleId;
			stmtSetError.parameters[":error"] = error;
			exec(stmtSetError);
		}

		//VAHI added for more marking errors on outgoing where RowID not yet known
		public function setErrorGid(gadget_id:String, error:Boolean):void {
			stmtSetErrorGid.parameters[":gadget_id"] = gadget_id;
			stmtSetErrorGid.parameters[":error"] = error;
			exec(stmtSetErrorGid);
		}
		
		//VAHI added for scoop functions
		public function listAll():Array {
			var Id:String = fieldOracleId;

			stmtFindAll.text = "SELECT " + Id + " FROM " + tableName;
			exec(stmtFindAll);

			function reduceToOne(ob:Object, i:int, a:Array):String {
				return ob[Id];
			}
			
			var data:Array = stmtFindAll.getResult().data;
			if (data==null)	return [];
			return data.map(reduceToOne);
		}
		
		public function queryAll():ArrayCollection {
			stmtFindAll.text = "SELECT * FROM " + tableName;
			exec(stmtFindAll);
			return new ArrayCollection(stmtFindAll.getResult().data);
		}
		
		/** This is a fix hook to fix issues with a dao at Sync time.
		 *
		 * INCOMING sync calls this callback to detect a siebel RowId to update the record
		 * 
		 * @params rec:Object the record
		 * @params parent:Object parental record (if any)
		 * @returns Boolean true if checks for NULL shall be skipped, false for the normal case
		 */
		public function fix_sync_incoming(rec:Object,parent:Object=null):Boolean { return false; }
		
		/** This is a fix hook to fix issues with a dao at Sync time.
		 *
		 * INCOMING sync calls this after add when the RowID was null.
		 * 
		 * @params rec:Object the record
		 * @params parent:Object parental record (if any)
		 */
		public function fix_sync_add(rec:Object,parent:Object=null):void {}
		
		
		
		
		/** This is a fix hook to fix issues with a dao at Sync time.
		 *
		 * OUTGOING after data was uploaded with the return values right before it is updated
		 * 
		 * @params ob:Object the record, shall be modified accordingly
		 * @returns Boolean true if record must be written, false else
		 */
		public function fix_sync_outgoing(rec:Object):Boolean { return false; }
	}
}
