package gadget.dao {
	
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	
	import gadget.util.Relation;
	import gadget.util.Utils;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	
	public class LinkDAO extends BaseSQL {
		
		private var stmtAllItems:SQLStatement;
		private var stmtLinkedItems:SQLStatement;
		
		public function LinkDAO(sqlConnection:SQLConnection) {

			
			stmtAllItems = new SQLStatement();
			stmtAllItems.sqlConnection = sqlConnection;

			stmtLinkedItems = new SQLStatement();
			stmtLinkedItems.sqlConnection = sqlConnection;

		}

		
		private static const ALL_ENTITIES:ArrayCollection = new ArrayCollection(
			["Account", "Contact", "Opportunity", "Activity", "Product", "Service Request", "Custom Object 1", "Campaign"]
		);
		
		public function allItems(entities:ArrayCollection, name:String, filter:String = null,selectCols:Array = null):ArrayCollection {
			if (entities == null) {
				entities = ALL_ENTITIES;
			}
			var query:String = "";
			for each (var entity:String in entities) {
				if (query != "") {
					query += " UNION ALL ";
				}
					
				var nameCondition :String = "";
				if(entity == "User"){
					nameCondition = "( upper(FirstName) >='" + name + "' AND upper(FirstName) <= '" + name + "zzzz'" +
						" OR upper(LastName) >='" + name + "' AND upper(LastName) <= '" + name + "zzzz')";
				}else{
					var i:int=0;
					for each(var col:String in DAOUtils.getSearchColumns(entity)){
						if(i > 0 ){	
							// if it has several columns
							nameCondition +=" OR ";
						}
						nameCondition += "("+ col + ">='" + name + "' AND "+ col + " <= '" + name + "zzzz')";
						i++;
					}
				}
				
				nameCondition = Utils.replaceGermanCharacter( nameCondition,Utils.charUpperGermanAccents,Utils.charGerman);
				var userFields:String = entity == "User" ? ",FirstName,LastName ":"" ;
				if(selectCols!=null && selectCols.length>0){
					userFields = userFields+"," + selectCols.join(',');
				}
				
				query += "SELECT '" + entity + "' gadget_type, " + DAOUtils.getNameForSearch(entity) + " name, gadget_id, " +
					DAOUtils.getOracleId(entity) + " oracle_id, deleted" + userFields +
					" FROM " + DAOUtils.getTable(entity) +
					// deleted items will be shown (which is bad) but this improves greatly performance
					// see if we could hide deleted items and sort postwards the query
					" WHERE (" + nameCondition + ")" + (filter ? " AND " + filter : "");

				}
			
			
			if (query == "") {
				return new ArrayCollection();
			}
			//query += " ORDER BY name LIMIT 1000";
			query += " LIMIT 1000";
			stmtAllItems.text = query;
			trace(query);
			exec(stmtAllItems);
			
			var data:ArrayCollection = new ArrayCollection(stmtAllItems.getResult().data);
			
			filterByDeleted(data);
			sortByName(data);
			
			return data;
		}
		
		private function sortByName(data:ArrayCollection):void {
			var dataSortField:SortField = new SortField();
			
			//name of the field of the object on which you wish to sort the Collection
			dataSortField.name = "name";
			dataSortField.caseInsensitive = true;
			
			//create the sort object
			var dataSort:Sort = new Sort();
			dataSort.fields = [dataSortField];
			
			data.sort = dataSort;
			//refresh the collection to sort
			data.refresh();			
		}		
		
		private function filterByDeleted(data:ArrayCollection):void {
			data.filterFunction = function(item:Object):Boolean {
				return item['deleted'] == false;
			};
			data.refresh();
		}
		
		public function linkedItems(entities:ArrayCollection, source:Object):ArrayCollection {
			if (entities == null) {
				entities = ALL_ENTITIES;
			}
			var referenced:ArrayCollection = Relation.getReferenced(source.gadget_type);
			var query:String = "";
			var relation:Object;
			for each (relation in referenced) {
				if (entities.contains(relation.entityDest)) {
					if (query != "") {
						query += " UNION ";
					}
					if (relation.supportTable == null) {  
						query += "SELECT '" + relation.entityDest + "' gadget_type, " + DAOUtils.getNameColumn(relation.entityDest, "dest.") + " name, dest.gadget_id gadget_id" + 
							" FROM " + DAOUtils.getTable(relation.entityDest) + " dest, " + DAOUtils.getTable(relation.entitySrc)+ " src " +
							" WHERE src." + relation.keySrc + " = dest." + relation.keyDest + " AND src.gadget_id = " + source.gadget_id + ' AND (dest.deleted = false OR dest.deleted IS null)';
					} else {
						query += "SELECT '" + relation.entityDest + "' gadget_type, " + DAOUtils.getNameColumn(relation.entityDest, "dest.") + " name, dest.gadget_id gadget_id" + 
							" FROM " + DAOUtils.getTable(relation.entityDest) + " dest, " + relation.supportTable.replace(/\./, '_') + " supp, " + DAOUtils.getTable(relation.entitySrc)+ " src " +
							" WHERE (src." + relation.keySrc + " = supp." + relation.keySrc + " AND dest." + relation.keyDest + " = supp." + relation.keySupport + ") AND src.gadget_id = " + source.gadget_id + 
							" AND (supp.deleted = false OR supp.deleted IS null) AND (dest.deleted = false OR dest.deleted IS null)";
						
					}
				}
			}
			var referencers:ArrayCollection = Relation.getReferencers(source.gadget_type);
			for each (relation in referencers) {
				if (entities.contains(relation.entitySrc)) {
					if (query != "") {
						query += " UNION ";
					}
					if (relation.supportTable == null) {  
						query += "SELECT '" + relation.entitySrc + "' gadget_type, " + DAOUtils.getNameColumn(relation.entitySrc, "src.") + " name, src.gadget_id gadget_id" + 
							" FROM " + DAOUtils.getTable(relation.entitySrc) + " src, " + DAOUtils.getTable(relation.entityDest)+ " dest " +
							" WHERE dest." + relation.keyDest + " = src." + relation.keySrc + " AND dest.gadget_id = " + source.gadget_id + ' AND (src.deleted = false OR src.deleted IS null)';
					} else {
						query += "SELECT '" + relation.entitySrc + "' gadget_type, " + DAOUtils.getNameColumn(relation.entitySrc, "src.") + " name, src.gadget_id gadget_id" + 
							" FROM " + DAOUtils.getTable(relation.entitySrc) + " src, " + relation.supportTable.replace(/\./, '_') + " supp, " + DAOUtils.getTable(relation.entityDest)+ " dest " +
							" WHERE dest." + relation.keyDest + " = supp." + relation.keySupport + " AND src." + relation.keySrc + " = supp." + relation.keySrc + " AND dest.gadget_id = " + source.gadget_id + 
							" AND (supp.deleted = false OR supp.deleted IS null) AND (src.deleted = false OR src.deleted IS null)";
					}
				}
			}
			if (query == "") {
				return new ArrayCollection();
			}
			query += " ORDER BY name";
			stmtLinkedItems.text = query;
			exec(stmtLinkedItems);
			var records:ArrayCollection = new ArrayCollection(stmtLinkedItems.getResult().data);
			Utils.suppressWarning(records);
			return records;
		}

	}
}