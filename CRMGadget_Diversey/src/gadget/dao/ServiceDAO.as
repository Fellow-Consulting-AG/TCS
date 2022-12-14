package gadget.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	import gadget.util.FieldUtils;
	
	import mx.collections.ArrayCollection;
	
	
	public class ServiceDAO extends BaseDAO {
	
		
		private var stmtUserStatusUpdate:SQLStatement;
		private var stmtUpdateStatusModified:SQLStatement;
		private var stmtCheckPdfAtt:SQLStatement;
		private var stmtSelectServiceNotComplete:SQLStatement;
		private var stmtFindCreated:SQLStatement;
		private var stmtFindUpdated:SQLStatement;
		
		public function ServiceDAO(sqlConnection:SQLConnection, work:Function) {
			super(work, sqlConnection, {
				table: 'service',
				oracle_id: 'ServiceRequestId',
				name_column: [ 'SRNumber' ],
				search_columns: [ 'SRNumber' ],
				display_name : "services",				
				index: [ "AccountId", "ServiceRequestId", "OwnerId" ],
				columns: { 'TEXT' : textColumns }
			});
			stmtUserStatusUpdate = new SQLStatement;
			stmtUserStatusUpdate.sqlConnection=sqlConnection;
			stmtUserStatusUpdate.text="SELECT 'Service Request' gadget_type, * FROM service  WHERE StatusModified=1";
			
			
			stmtUpdateStatusModified = new SQLStatement();
			stmtUpdateStatusModified.sqlConnection=sqlConnection;
			stmtUpdateStatusModified.text="UPDATE service SET StatusModified=:status, local_update=:local_update WHERE gadget_id = :gadget_id ";
			
			stmtCheckPdfAtt = new SQLStatement();
			stmtCheckPdfAtt.sqlConnection = sqlConnection;
			stmtCheckPdfAtt.text = "SELECT * FROM attachment WHERE entity = 'Service Request' AND gadget_id = :gadget_id AND filename like '%.pdf'";
			
			stmtSelectServiceNotComplete = new SQLStatement();
			stmtSelectServiceNotComplete.sqlConnection = sqlConnection;
			stmtSelectServiceNotComplete.text = "SELECT 'Service Request' gadget_type,* FROM "+tableName +" WHERE status <> 'Closed' OR local_update is not null";
			
			
			// Find all items updated locally
			stmtFindUpdated = new SQLStatement();
			stmtFindUpdated.sqlConnection = sqlConnection;
			stmtFindUpdated.text = "SELECT '" + entity + "' gadget_type, *, " + DAOUtils.getNameColumn(entity) + " name FROM " + tableName + " WHERE local_update is not null AND (deleted = 0 OR deleted IS null) AND gadget_id NOT IN(select gadget_id from service where (CustomPickList10='SUSP' OR CustomPickList10='AWPT' OR CustomPickList11='TECO') And gadget_id Not In (Select gadget_id from attachment where entity='Service Request' And gadget_id is not null and (filename like '%.pdf' or filename like '%.doc' or filename like '%.docx'))) ORDER BY local_update LIMIT :limit OFFSET :offset";	
			
			// Find all items created locally
			stmtFindCreated = new SQLStatement();
			stmtFindCreated.sqlConnection = sqlConnection;
			//VAHI the "OR ... IS NULL" is a workaround to make Expenses work
			stmtFindCreated.text = "SELECT '" + entity + "' gadget_type, *, " + DAOUtils.getNameColumn(entity) + " name FROM " + tableName + " WHERE ( (" + fieldOracleId + " >= '#' AND " + fieldOracleId + " <= '#zzzz') OR " + fieldOracleId + " IS NULL ) AND (deleted = 0 OR deleted IS null) AND gadget_id NOT IN(select gadget_id from service where (CustomPickList10='SUSP' OR CustomPickList10='AWPT' OR CustomPickList11='TECO') And gadget_id Not In (Select gadget_id from attachment where entity='Service Request' And gadget_id is not null and (filename like '%.pdf' or filename like '%.doc' or filename like '%.docx'))) ORDER BY  " + fieldOracleId + " LIMIT :limit OFFSET :offset";	
			
			
			
		}
/*		
		override protected function get sortColumn():String {
			return "SRNumber";
		}
*/
		
		public function selectOpenService():ArrayCollection{
			exec(stmtSelectServiceNotComplete);
			var data:Array = stmtSelectServiceNotComplete.getResult().data;
			return new ArrayCollection(data);
		}
		
		
		//for JD user only
		public function selectUserStatusUpdate():Array{			
			exec(stmtUserStatusUpdate);
			var data:Array=stmtUserStatusUpdate.getResult().data;			
			return data;
		}
		
		public function updateStatusModified(service:Object):void{
			stmtUpdateStatusModified.parameters[":local_update"] = new Date().getTime();
			stmtUpdateStatusModified.parameters[':status'] = service.StatusModified?1:0;
			stmtUpdateStatusModified.parameters[':gadget_id'] = service.gadget_id;
			exec(stmtUpdateStatusModified);
			
		}
		
		public function isHasPdfAtt(srObj:Object):Boolean{			
			stmtCheckPdfAtt.parameters[":gadget_id"]=srObj.gadget_id;
			exec(stmtCheckPdfAtt);
			var result:SQLResult = stmtCheckPdfAtt.getResult();
			if(result==null){
				return false;
			}
			var data:Array = result.data;
			if(data ==null || data.length==0){
				return false;
			}
			
			return true;
			
		}
		
		
		
		override public function get entity():String {
			return "Service Request";
		}
		
		override public function findCreated(offset:int, limit:int):ArrayCollection {
			stmtFindCreated.parameters[":offset"] = offset; 
			stmtFindCreated.parameters[":limit"] = limit; 
			exec(stmtFindCreated, false);
			var list:ArrayCollection = new ArrayCollection(stmtFindCreated.getResult().data);
			//checkBindPicklist(stmtFindCreated.text,list);
			return list;
		}
		
		override public function findUpdated(offset:int, limit:int):ArrayCollection {
			stmtFindUpdated.parameters[":offset"] = offset; 
			stmtFindUpdated.parameters[":limit"] = limit; 
			exec(stmtFindUpdated, false);
			var list:ArrayCollection = new ArrayCollection(stmtFindUpdated.getResult().data);
			//checkBindPicklist(stmtFindUpdated.text,list);
			return list;
		}
		
		
		override public function getOutgoingIgnoreFields():ArrayCollection{
			return INGNORE_FIELDS;
		}
		
		override public function getIncomingIgnoreFields():ArrayCollection{
			
			return new ArrayCollection(["GroupReport"]);
		}
		
		private static const INGNORE_FIELDS:ArrayCollection=new ArrayCollection(
			[
				"AccountName",
				"AccountExternalSystemId",
				"AccountLocation",
				"AssetExternalSystemId",
				"AssetIntegrationId",
				"AssetName",
				"ContactEmail",
				"ContactExternalSystemId",
				"ContactFirstName",
				"ContactFullName",
				"ContactLastName",
				"CustomObject1ExternalSystemId",
				"CustomObject1Name",
				"CustomObject2ExternalSystemId",
				"CustomObject2Name",
				"CustomObject3ExternalSystemId",
				"CustomObject3Name",
				"GroupReport",
				'Owner',
				'OwnerExternalSystemId'
				]);
		
		private var textColumns:Array = [
			'CustomNote0',
			'AccountExternalSystemId',
			'AccountId',
			'AccountLocation',
			'AccountName',
			'Area',
			'AssessmentFilter1',
			'AssessmentFilter2',
			'AssessmentFilter3',
			'AssessmentFilter4',
			'AssetExternalSystemId',
			'AssetId',
			'AssetIntegrationId',
			'AssetName',
			'AssignmentStatus',
			'Cause',
			'ClosedTime',
			'ContactEmail',
			'ContactExternalSystemId',
			'ContactFirstName',
			'ContactFullName',
			'ContactId',
			'ContactLastName',
			'CreatedBy',
			'CreatedById',
			'CreatedByName',
			'CreatedDate',
			'CreatedbyEmailAddress',
			'CurrencyCode',
			'Dealer',
			'DealerExternalSystemId',
			'DealerId',
			'DealerIntegrationId',
			'Description',
			'ExternalSystemId',
			'IntegrationId',
			'LastAssessmentDate',
			'LastAssignmentCompletionDate',
			'LastAssignmentSubmissionDate',
			'LastUpdated',
			'Make',
			'ModId',
			'Model',
			'ModifiedBy',
			'ModifiedByFullName',
			'ModifiedById',
			'ModifiedDate',
			'ModifiedbyEmailAddress',
			'OpenedTime',			
			'OwnerId',
			'Owner',
			'OwnerExternalSystemId',
			'Priority',
			'Product',
			'ProductExternalSystemId',
			'ProductId',
			'ProductIntegrationId',
			'ReassignOwnerFlag',
			'SRNumber',
			'ServiceRequestConcatField',
			'ServiceRequestId',
			'ServicingDealer',
			'Source',
			'Status',
			'Subject',
			'Type',
			'WorkPhone',
			'Year',
			'CustomBoolean0',
			'CustomBoolean1',
			'CustomBoolean2',
			'CustomBoolean3',
			'CustomBoolean4',
			'CustomBoolean5',
			'CustomBoolean6',
			'CustomBoolean7',
			'CustomBoolean8',
			'CustomBoolean9',
			'CustomBoolean10',
			'CustomBoolean11',
			'CustomBoolean12',
			'CustomBoolean13',
			'CustomBoolean14',
			'CustomBoolean15',
			'CustomBoolean16',
			'CustomBoolean17',
			'CustomBoolean18',
			'CustomBoolean19',
			'CustomBoolean20',
			'CustomBoolean21',
			'CustomBoolean22',
			'CustomBoolean23',
			'CustomBoolean24',
			'CustomBoolean25',
			'CustomBoolean26',
			'CustomBoolean27',
			'CustomBoolean28',
			'CustomBoolean29',
			'CustomBoolean30',
			'CustomBoolean31',
			'CustomBoolean32',
			'CustomBoolean33',
			'CustomBoolean34',
			'CustomCurrency0',
			'CustomCurrency1',
			'CustomCurrency2',
			'CustomCurrency3',
			'CustomCurrency4',
			'CustomCurrency5',
			'CustomCurrency6',
			'CustomCurrency7',
			'CustomCurrency8',
			'CustomCurrency9',
			'CustomCurrency10',
			'CustomCurrency11',
			'CustomCurrency12',
			'CustomCurrency13',
			'CustomCurrency14',
			'CustomCurrency15',
			'CustomCurrency16',
			'CustomCurrency17',
			'CustomCurrency18',
			'CustomCurrency19',
			'CustomCurrency20',
			'CustomCurrency21',
			'CustomCurrency22',
			'CustomCurrency23',
			'CustomCurrency24',
			'CustomDate0',
			'CustomDate1',
			'CustomDate2',
			'CustomDate3',
			'CustomDate4',
			'CustomDate5',
			'CustomDate6',
			'CustomDate7',
			'CustomDate8',
			'CustomDate9',
			'CustomDate10',
			'CustomDate11',
			'CustomDate12',
			'CustomDate13',
			'CustomDate14',
			'CustomDate15',
			'CustomDate16',
			'CustomDate17',
			'CustomDate18',
			'CustomDate19',
			'CustomDate20',
			'CustomDate21',
			'CustomDate22',
			'CustomDate23',
			'CustomDate24',
			'CustomDate25',
			'CustomDate26',
			'CustomDate27',
			'CustomDate28',
			'CustomDate29',
			'CustomDate30',
			'CustomDate31',
			'CustomDate32',
			'CustomDate33',
			'CustomDate34',
			'CustomDate35',
			'CustomDate36',
			'CustomDate37',
			'CustomDate38',
			'CustomDate39',
			'CustomDate40',
			'CustomDate41',
			'CustomDate42',
			'CustomDate43',
			'CustomDate44',
			'CustomDate45',
			'CustomDate46',
			'CustomDate47',
			'CustomDate48',
			'CustomDate49',
			'CustomDate50',
			'CustomDate51',
			'CustomDate52',
			'CustomDate53',
			'CustomDate54',
			'CustomDate55',
			'CustomDate56',
			'CustomDate57',
			'CustomDate58',
			'CustomDate59',
			'CustomInteger0',
			'CustomInteger1',
			'CustomInteger2',
			'CustomInteger3',
			'CustomInteger4',
			'CustomInteger5',
			'CustomInteger6',
			'CustomInteger7',
			'CustomInteger8',
			'CustomInteger9',
			'CustomInteger10',
			'CustomInteger11',
			'CustomInteger12',
			'CustomInteger13',
			'CustomInteger14',
			'CustomInteger15',
			'CustomInteger16',
			'CustomInteger17',
			'CustomInteger18',
			'CustomInteger19',
			'CustomInteger20',
			'CustomInteger21',
			'CustomInteger22',
			'CustomInteger23',
			'CustomInteger24',
			'CustomInteger25',
			'CustomInteger26',
			'CustomInteger27',
			'CustomInteger28',
			'CustomInteger29',
			'CustomInteger30',
			'CustomInteger31',
			'CustomInteger32',
			'CustomInteger33',
			'CustomInteger34',
			'CustomMultiSelectPickList0',
			'CustomMultiSelectPickList1',
			'CustomMultiSelectPickList2',
			'CustomMultiSelectPickList3',
			'CustomMultiSelectPickList4',
			'CustomMultiSelectPickList5',
			'CustomMultiSelectPickList6',
			'CustomMultiSelectPickList7',
			'CustomMultiSelectPickList8',
			'CustomMultiSelectPickList9',
			'CustomNumber0',
			'CustomNumber1',
			'CustomNumber2',
			'CustomNumber3',
			'CustomNumber4',
			'CustomNumber5',
			'CustomNumber6',
			'CustomNumber7',
			'CustomNumber8',
			'CustomNumber9',
			'CustomNumber10',
			'CustomNumber11',
			'CustomNumber12',
			'CustomNumber13',
			'CustomNumber14',
			'CustomNumber15',
			'CustomNumber16',
			'CustomNumber17',
			'CustomNumber18',
			'CustomNumber19',
			'CustomNumber20',
			'CustomNumber21',
			'CustomNumber22',
			'CustomNumber23',
			'CustomNumber24',
			'CustomNumber25',
			'CustomNumber26',
			'CustomNumber27',
			'CustomNumber28',
			'CustomNumber29',
			'CustomNumber30',
			'CustomNumber31',
			'CustomNumber32',
			'CustomNumber33',
			'CustomNumber34',
			'CustomNumber35',
			'CustomNumber36',
			'CustomNumber37',
			'CustomNumber38',
			'CustomNumber39',
			'CustomNumber40',
			'CustomNumber41',
			'CustomNumber42',
			'CustomNumber43',
			'CustomNumber44',
			'CustomNumber45',
			'CustomNumber46',
			'CustomNumber47',
			'CustomNumber48',
			'CustomNumber49',
			'CustomNumber50',
			'CustomNumber51',
			'CustomNumber52',
			'CustomNumber53',
			'CustomNumber54',
			'CustomNumber55',
			'CustomNumber56',
			'CustomNumber57',
			'CustomNumber58',
			'CustomNumber59',
			'CustomNumber60',
			'CustomNumber61',
			'CustomNumber62',
			'CustomObject1ExternalSystemId',
			'CustomObject1Id',
			'CustomObject1Name',
			'CustomObject2ExternalSystemId',
			'CustomObject2Id',
			'CustomObject2Name',
			'CustomObject3ExternalSystemId',
			'CustomObject3Id',
			'CustomObject3Name',
			'CustomPhone0',
			'CustomPhone1',
			'CustomPhone2',
			'CustomPhone3',
			'CustomPhone4',
			'CustomPhone5',
			'CustomPhone6',
			'CustomPhone7',
			'CustomPhone8',
			'CustomPhone9',
			'CustomPhone10',
			'CustomPhone11',
			'CustomPhone12',
			'CustomPhone13',
			'CustomPhone14',
			'CustomPhone15',
			'CustomPhone16',
			'CustomPhone17',
			'CustomPhone18',
			'CustomPhone19',
			'CustomPickList0',
			'CustomPickList1',
			'CustomPickList2',
			'CustomPickList3',
			'CustomPickList4',
			'CustomPickList5',
			'CustomPickList6',
			'CustomPickList7',
			'CustomPickList8',
			'CustomPickList9',
			'CustomPickList10',
			'CustomPickList11',
			'CustomPickList12',
			'CustomPickList13',
			'CustomPickList14',
			'CustomPickList15',
			'CustomPickList16',
			'CustomPickList17',
			'CustomPickList18',
			'CustomPickList19',
			'CustomPickList20',
			'CustomPickList21',
			'CustomPickList22',
			'CustomPickList23',
			'CustomPickList24',
			'CustomPickList25',
			'CustomPickList26',
			'CustomPickList27',
			'CustomPickList28',
			'CustomPickList29',
			'CustomPickList30',
			'CustomPickList31',
			'CustomPickList32',
			'CustomPickList33',
			'CustomPickList34',
			'CustomPickList35',
			'CustomPickList36',
			'CustomPickList37',
			'CustomPickList38',
			'CustomPickList39',
			'CustomPickList40',
			'CustomPickList41',
			'CustomPickList42',
			'CustomPickList43',
			'CustomPickList44',
			'CustomPickList45',
			'CustomPickList46',
			'CustomPickList47',
			'CustomPickList48',
			'CustomPickList49',
			'CustomPickList50',
			'CustomPickList51',
			'CustomPickList52',
			'CustomPickList53',
			'CustomPickList54',
			'CustomPickList55',
			'CustomPickList56',
			'CustomPickList57',
			'CustomPickList58',
			'CustomPickList59',
			'CustomPickList60',
			'CustomPickList61',
			'CustomPickList62',
			'CustomPickList63',
			'CustomPickList64',
			'CustomPickList65',
			'CustomPickList66',
			'CustomPickList67',
			'CustomPickList68',
			'CustomPickList69',
			'CustomPickList70',
			'CustomPickList71',
			'CustomPickList72',
			'CustomPickList73',
			'CustomPickList74',
			'CustomPickList75',
			'CustomPickList76',
			'CustomPickList77',
			'CustomPickList78',
			'CustomPickList79',
			'CustomPickList80',
			'CustomPickList81',
			'CustomPickList82',
			'CustomPickList83',
			'CustomPickList84',
			'CustomPickList85',
			'CustomPickList86',
			'CustomPickList87',
			'CustomPickList88',
			'CustomPickList89',
			'CustomPickList90',
			'CustomPickList91',
			'CustomPickList92',
			'CustomPickList93',
			'CustomPickList94',
			'CustomPickList95',
			'CustomPickList96',
			'CustomPickList97',
			'CustomPickList98',
			'CustomPickList99',
			'CustomText0',
			'CustomText1',
			'CustomText2',
			'CustomText3',
			'CustomText4',
			'CustomText5',
			'CustomText6',
			'CustomText7',
			'CustomText8',
			'CustomText9',
			'CustomText10',
			'CustomText11',
			'CustomText12',
			'CustomText13',
			'CustomText14',
			'CustomText15',
			'CustomText16',
			'CustomText17',
			'CustomText18',
			'CustomText19',
			'CustomText20',
			'CustomText21',
			'CustomText22',
			'CustomText23',
			'CustomText24',
			'CustomText25',
			'CustomText26',
			'CustomText27',
			'CustomText28',
			'CustomText29',
			'CustomText30',
			'CustomText31',
			'CustomText32',
			'CustomText33',
			'CustomText34',
			'CustomText35',
			'CustomText36',
			'CustomText37',
			'CustomText38',
			'CustomText39',
			'CustomText40',
			'CustomText41',
			'CustomText42',
			'CustomText43',
			'CustomText44',
			'CustomText45',
			'CustomText46',
			'CustomText47',
			'CustomText48',
			'CustomText49',
			'CustomText50',
			'CustomText51',
			'CustomText52',
			'CustomText53',
			'CustomText54',
			'CustomText55',
			'CustomText56',
			'CustomText57',
			'CustomText58',
			'CustomText59',
			'CustomText60',
			'CustomText61',
			'CustomText62',
			'CustomText63',
			'CustomText64',
			'CustomText65',
			'CustomText66',
			'CustomText67',
			'CustomText68',
			'CustomText69',
			'CustomText70',
			'CustomText71',
			'CustomText72',
			'CustomText73',
			'CustomText74',
			'CustomText75',
			'CustomText76',
			'CustomText77',
			'CustomText78',
			'CustomText79',
			'CustomText80',
			'CustomText81',
			'CustomText82',
			'CustomText83',
			'CustomText84',
			'CustomText85',
			'CustomText86',
			'CustomText87',
			'CustomText88',
			'CustomText89',
			'CustomText90',
			'CustomText91',
			'CustomText92',
			'CustomText93',
			'CustomText94',
			'CustomText95',
			'CustomText96',
			'CustomText97',
			'CustomText98',
			'CustomText99',
			'IndexedBoolean0',
			'IndexedCurrency0',
			'IndexedDate0',
			'IndexedLongText0',
			'IndexedNumber0',
			'IndexedPick0',
			'IndexedPick1',
			'IndexedPick2',
			'IndexedPick3',
			'IndexedPick4',
			'IndexedPick5',
			'IndexedShortText0',
			'IndexedShortText1'
		];
		
	}
}