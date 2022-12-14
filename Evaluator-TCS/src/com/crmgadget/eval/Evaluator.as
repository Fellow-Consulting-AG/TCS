package com.crmgadget.eval
{
	import flash.sampler.NewObjectSample;
	import flash.utils.getTimer;
	
	import mx.charts.DateTimeAxis;
	import mx.collections.ArrayCollection;
	import mx.formatters.CurrencyFormatter;
	import mx.formatters.DateFormatter;
	import mx.formatters.NumberBaseRoundType;
	import mx.formatters.NumberFormatter;
	import mx.utils.StringUtil;

	public class Evaluator{

		private static  const PATTERN:RegExp=/'|>|</gi;
		private static  const BRACE_PATTERN:RegExp=/'|\[|\]/gi;
		
		private static const COMP_AND_CAL_FUNCTION:Object={
			"EQ":"EQ",
			"OPOSIT":"OPOSIT",
			"GTE":"GTE",
			"LTE":"LTE",
			"LT":"LT",
			"GT":"GT",
			"GTE":"GTE",
			"MULT":"MULT",
			"ADD":"ADD",
			"SUB":"SUB",
			"DIV":"DIV",
			"MIN":"MIN", // MIN(number,number,...)
			"MAX":"MAX",  // MAX(number,number,...)
			"MOD":"MOD"  // MOD(number,divisor)
		};
		
		private static const STRING_FUNCTION:Object={
			//"FieldValue":"FieldValue",
			//"FindNoneOf":"FindNoneOf",
			//"FindOneOf":"FindOneOf",
			"INSTR":"INSTR",
			"LEFT":"LEFT", // LEFT(text, num_chars)
			"LEN":"LEN", // LEN(text)
			"MID":"MID",  // MID(text, start_num, num_chars)
			"RIGHT":"RIGHT", // RIGHT(text, num_chars)
			"TOCHAR":"TOCHAR", // ToChar([field_name], 'format')  Ex: ToChar (10.2345, '##.##') returns 10.23
						
			"TRIM":"TRIM", // TRIM(text)
			"LOWER":"LOWER", // LOWER(text)
			"UPPER":"UPPER", // UPPER(text)
			"NOTHING":"NOTHING", // NOTHING()
			"BEGINS":"BEGINS",  //  BEGINS(text,compare_text)
			"SUBSTR":"SUBSTR",  // SUBSTR(text,startIndex,endIndex)  substring from a string text from an index to an index
			"REPLACE":"REPLACE", // REPLACE(text, old_text, new_text) = SUBSTITUTE
			"INDEXOF":"INDEXOF", // data: "Indexof(text, text_find_index)", 		desc: "Returns a character at the specified index of a text"},
			"LPAD":"LPAD", // data: "Lpad(text, padded_length , pad_string)", desc: "Pad the left side of the value with spaces or the optional pad string so that the length is padded_length"},
			"RPAD":"RPAD" // data: "Rpad(text, padded_length, pad_string)", 	desc: "Pad the right side of the value with spaces or the optional pad string so that the length is padded_length"},
		}
			
		public static var dtFormat:String = "yyyy-MM-dd";	
		private static const dayNames:Array=["Mon", "Tue", "Wen", "Thu", "Fri", "Sat", "Sun"];
		private static const monthNames:Array=["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];		
		private static const dayFullNames:Array=["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Satursday", "Sunday"];
		private static const monthFullNames:Array=["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
		
		private static const DATE_FUNCTION:Object={
			"NOW":"NOW", // Now()
			"DAY":"DAY", // Day(dateText, format)
			"MONTH":"MONTH", // Month(dateText, format)
			"YEAR":"YEAR", // Year(dateText, format)
			"DAYNAME":"DAYNAME", // DayName(dateText, format)
			"MONTHNAME":"MONTHNAME", // MonthName(dateText, format)
			"DAYFULLNAME":"DAYFULLNAME", // DayFullName(dateText, format)
			"MONTHFULLNAME":"MONTHFULLNAME", // MonthFullName(dateText, format)
			"CHANGEDATEFORMAT":"CHANGEDATEFORMAT" // ChangeDateFormat(dateText, oldFormat, newFormat)
		}
			
		public static function setDateFormat(df:String):void{
			Evaluator.dtFormat = df;
		}	
		
		public static function resetDateFormat():void{
			Evaluator.dtFormat = "YYYY-MM-DD";
		}
		
		private static const FILTER_FUNCTION:Array=["PREFERENCE","TODAY","LOCALE","USERVALUE","COUNTRY","LOCALELANG","LOCALEAREA",
					"THISYEAR","LASTYEAR","NEXTYEAR","THISMONTH","LASTMONTH","NEXTMONTH","THISWEEK","LASTWEEK","NEXTWEEK", "SPACE",
					"CASE", "CONTAINS", "FIND", "IF"
				];
		private static const FIL:Object={Left:"Left",Right:"Right",Preference:"Preference",Today:"Today",Locale:"Locale",UserValue:"UserValue"}
		private static const CURRENCY_SYMBOL:Object = {$:"$",'???':"???",'??':"??",CHF:"CHF",'???':"???",'HK$':"HK$",'???':"???",'??':"??",'??????':"??????",'z??':"z??"}
		
		
		public static function evaluate(strExp:String,owner:Object,entity:String, elment_name:String, objEntity:Object=null,doGetPickList:Function=null,doGetPickListId:Function=null,doGetXMLValueField:Function=null,isFiltered:Boolean=false,doGetJoinField:Function=null,getFieldNameFromIntegrationTag:Function=null,sqlLists:ArrayCollection=null):String{
			if(strExp.charAt(0) == '"' && strExp.charAt(strExp.length-1) == '"'){
				return strExp.replace(/\"/gi, '');
			}
			if(strExp.charAt(0) == "'" && strExp.charAt(strExp.length-1) == "'"){
				return strExp.replace(/\'/gi, '');
			}
			try{
				var formula:String=Functionalizer.functionalize(strExp);
				var node:Node=Parser.parse(formula);
			
				return doEvaluate(node,owner,entity,elment_name,objEntity,doGetPickList,doGetPickListId,doGetXMLValueField,isFiltered,doGetJoinField,getFieldNameFromIntegrationTag,sqlLists);
			} catch(e:Error){
				if(isFiltered){ 
					for(var i:int=0 ;i<FILTER_FUNCTION.length;i++){
						if(strExp.toUpperCase().indexOf(FILTER_FUNCTION[i]) != -1){
							return "<ERROR>"; //when function doGetXMLValueField is not null, this evaluator using in filter List.
							//Throwing error for checking function in filter list
						}
					}
					return strExp; 
				}
				return "";
			}
			return "";
		}
		
		private static function doEvaluate(node:Node,owner:Object,entity:String,elment_name:String,objEntity:Object,doGetPickList:Function,doGetPickListId:Function,doGetXMLValueField:Function,isFiltered:Boolean,doGetJoinField:Function,getFieldNameFromIntegrationTag:Function,sqlLists:ArrayCollection=null):String {
 			var params:ArrayCollection = new ArrayCollection();
			// non evaluated params are params, but not evaluated
			var nonEvaluatedParams:ArrayCollection = new ArrayCollection();
			var name:String=node.getName();
			var upperName:String = name.toUpperCase();
			for each (var child:Node in node.getChildren()) {	
				nonEvaluatedParams.addItem(child.getName());
				params.addItem(doEvaluate(child, owner, entity, elment_name, objEntity, doGetPickList, doGetPickListId, doGetXMLValueField, isFiltered, doGetJoinField, getFieldNameFromIntegrationTag,sqlLists));
				
			}
			
			if(upperName=="CURRENT_USER"){
				if(owner!=null){
					return owner.Id;
				}
				return null;
			}
			
			if(upperName=="" && params.length>0){
				return String(params.getItemAt(0));
			}
			
			if(name=="SPACE"){
				return " ";
			}
			
			if(upperName=="FIELDVALUE"){
				return getFieldValue(entity,String(params.getItemAt(0)),objEntity,getFieldNameFromIntegrationTag);
			}
			//Bug fixing 214 CRO 07.02.2011
			if(isProperty(upperName)){
				return String(getFieldValue(entity,name,objEntity,getFieldNameFromIntegrationTag));
			}
			if(upperName=="USERVALUE") {
				var p:String =String(params.getItemAt(0));
				p=replaceSpecialCh(p);
				var val:String=owner[p];
				return (isFiltered == true && val == null) ? "<ERROR>" : val;
			}
			
			if(upperName=="CONCAT") {
				return params.getItemAt(0) + params.getItemAt(1);
			}
			
			if (STRING_FUNCTION[upperName]) {
				return doStringFunction(entity, upperName, params, objEntity, getFieldNameFromIntegrationTag);
			}
			
			if (DATE_FUNCTION[upperName]) {
				return doDateFunction(entity, upperName, params, objEntity, getFieldNameFromIntegrationTag);
			}
			
			if(upperName=="LIKE"){
				var strSearch:String=String(params.getItemAt(0));
				var strPrefix:String=String(params.getItemAt(1));
				var chf:String=strPrefix.charAt(0);
				var chl:String=strPrefix.charAt(strPrefix.length-1);
				if(chf=="?"|| chf=="*" || chf=="%"){
					strSearch=strSearch.substring(1,strSearch.length);
				} 
				if(chl=="*"|| chl=="%"||chl=="?"){
					strPrefix=strPrefix.substr(0,strPrefix.length-1);
				}
				return doLikeFunction(strSearch.toLocaleLowerCase(),strPrefix.toLocaleLowerCase(),chf,chl);
				
			}
			
			if(COMP_AND_CAL_FUNCTION[upperName]){
				// return doCompareAndCalculate(name,String(params.getItemAt(0)),String(params.getItemAt(1)));
				return doCompareAndCalculate(upperName, params);
			}			
			
			if(upperName=="IIF"){
				if(params.getItemAt(0)=="true"){
					return String(params.getItemAt(1));
				}
				return String(params.getItemAt(2));
			}
			
			//Bug fixing 214 CRO 07.02.2011
			if(upperName=="IFNULL"){
				if(params.getItemAt(0)==null || params.getItemAt(0) == ""){
					return params.getItemAt(1)+"";
				}
				return params.getItemAt(0)+"";
			}
			
			if(upperName=="ISNULL"){
				return params.getItemAt(0).toString()=='null'?"true":"false";
			}
			
			var p1:Object, p2:Object;
			if(upperName=="OR"){
				p1=params.getItemAt(0);
				p2=params.getItemAt(1);
				if("true"==p1 ||p2=="true" || p1== "1"|| p2=="1"){
					return "true"
				}
				return "false"
			}
			
			if(upperName=="AND"){
				p1=params.getItemAt(0);
				p2=params.getItemAt(1);
				if(("true"==p1 && p2=="true") || (p1== "1"&& p2=="1")){
					return "true"
				}
				return "false"
			}
			
			
			if(upperName=="LOOKUPVALUE"){
				var type:String=replaceSpecialCh(String(nonEvaluatedParams.getItemAt(0)));
				var lang_ind_code:String=String(params.getItemAt(1));
				var picklist:String=type;
				// step 1 : get the Id
				var id:String = doGetPickListId(entity,type,lang_ind_code);
				
				if(elment_name != null && (id == null || id == "")){
					picklist=elment_name;
					id =  doGetPickListId(entity,elment_name,lang_ind_code);					
				}
				if(id==null || id==""){
					var value:String= doGetPickList(entity, type, lang_ind_code,objEntity);
					if(value!=null && value.length>0){
						return value;
					}
					return doGetPickList(entity, elment_name, lang_ind_code,objEntity); 
					
				}
				// step 2 : get the translated value
				return doGetPickList(entity, picklist, id,objEntity);
				
			}
			
			if(upperName=="TIMESTAMP"){
				return DateUtils.format(new Date(),DateUtils.DATABASE_DATETIME_FORMAT);
			}
			
			if(upperName == "TODAY"){
				return DateUtils.format(new Date(),DateUtils.DATABASE_DATETIME_FORMAT);
			}
			if(upperName=="ORGANISATIONNAME"){
				return owner["Company"] == null ? "" : owner["Company"];
				
			}
			if(upperName=="LOCALE"){
				return owner["Locale"] == null ? "" : owner["Locale"];
			}
			if(upperName=="JOINFIELDVALUE"){
				var entity:String =replaceSpecialCh(String(nonEvaluatedParams.getItemAt(0)));
				if( entity == "ServiceRequest"){
					entity="Service Request";
				}
				var foriegnKey :String = entity == "User" ? "Id" : replaceSpecialCh(replaceBRACE(String(nonEvaluatedParams.getItemAt(1))));
				var valueForeignKey:String = entity == "User" ?  owner[foriegnKey] : objEntity[foriegnKey];
				var criteria:String = foriegnKey + "='"+ valueForeignKey +"'";
				var fieldName:String = replaceSpecialCh(String(nonEvaluatedParams.getItemAt(2)));
				if (StringUtils.endsWith(fieldName, "_ITAG")) {
					fieldName = getFieldNameFromIntegrationTag(entity, fieldName);
				} 
				return doGetJoinField(entity,criteria,fieldName);
			}
			if(upperName == "FINDONEOF"){
				return doFindOneOf(String(params.getItemAt(0)),String(params.getItemAt(1)));
				
			}
			if(upperName == "FINDNONEOF"){
				
				return doFindNoneOf(String(params.getItemAt(0)),String(params.getItemAt(1)));
				
			}
			if(upperName == "PREFERENCE"){
				
				var pre:String =String(params.getItemAt(0));
				pre=replaceSpecialCh(pre);
				var v:String=doGetXMLValueField(pre,"");
				
				return (isFiltered == true && v == null) ? "<ERROR>" : v; //Return <ERROR> when do filter criteria
			}
			if(upperName=="USERLANGUAGE"){
				return owner["LanguageCode"] == null ? "" : owner["LanguageCode"];
			}
			//Only use in filter
			if(upperName == "COUNTRY"){
				return owner["LanguageCode"] == null ? "<ERROR>" : owner["LanguageCode"];
			}
			//Only use in filter
			if(upperName == "LOCALELANG"){
				if (owner["Locale"]== null) return "<ERROR>";
				var vl:Array = owner["Locale"].toString().split("-");
				return StringUtil.trim(vl[0].toString());
			}
			//Only use in filter
			if(upperName == "LOCALEAREA"){
				if (owner["Locale"]== null) return "<ERROR>";
				var va:Array = owner["Locale"].toString().split("-");
				return StringUtil.trim(va[1].toString());
			}
			
			if(upperName == "SQLLISTCOUNT"){
				if(sqlLists==null) return "0";
				var sqlName:String = params[0];
				for each(var obj:Object in sqlLists){
					if(obj.key==sqlName){
						return obj.count;
					}
				}
				return "0";
			}
			
			
			var date:Date = new Date();
			var v1:String = "", v2:String = "";
			if(upperName == "THISYEAR") {
				v1 = DateUtils.dateAdd(0, new Date(date.getFullYear(), 0, 1), "fullYear");
				v2 = DateUtils.dateAdd(1, DateUtils.parse(v1, DateUtils.DATABASE_DATETIME_FORMAT), "fullYear");
				return v1+"{#}"+v2;
			}
			
			if(upperName == "LASTYEAR") {
				v1 = DateUtils.dateAdd(-1, new Date(date.getFullYear(), 0, 1), "fullYear");
				v2 = DateUtils.dateAdd(1, DateUtils.parse(v1, DateUtils.DATABASE_DATE_FORMAT), "fullYear");
				return v1+"{#}"+v2;
			}
			
			if(upperName == "NEXTYEAR") {
				v1 = DateUtils.dateAdd(+1, new Date(date.getFullYear(), 0, 1), "fullYear");
				v2 = DateUtils.dateAdd(1, DateUtils.parse(v1, DateUtils.DATABASE_DATE_FORMAT), "fullYear");
				return v1+"{#}"+v2;
			}
			
			if(upperName == "THISMONTH") {
				v1 = DateUtils.dateAdd(0, new Date(date.getFullYear(), date.getMonth(), 1), "month");
				v2 = DateUtils.dateAdd(1, DateUtils.parse(v1, DateUtils.DATABASE_DATETIME_FORMAT), "month");
				return v1+"{#}"+v2; 
			}
			
			if(upperName == "LASTMONTH") {
				v1 = DateUtils.dateAdd(-1, new Date(date.getFullYear(), date.getMonth(), 1), "month");
				v2 = DateUtils.dateAdd(1, DateUtils.parse(v1, DateUtils.DATABASE_DATETIME_FORMAT), "month");
				return v1+"{#}"+v2;  
			}
			
			if(upperName == "NEXTMONTH") {
				v1 = DateUtils.dateAdd(+1, new Date(date.getFullYear(), date.getMonth(), 1), "month");
				v2 = DateUtils.dateAdd(1, DateUtils.parse(v1, DateUtils.DATABASE_DATETIME_FORMAT), "month");
				return v1+"{#}"+v2; 
			}
			
			if(upperName == "THISWEEK") {
				v1 = DateUtils.dateAdd(0, null, "startDayOfWeek");
				v2 = DateUtils.dateAdd(0, null, "endDayOfWeek");
				return v1+"{#}"+v2;
			}
			
			if(upperName == "LASTWEEK") {
				v1 = DateUtils.dateAdd(-7, DateUtils.parse(DateUtils.dateAdd(0, null, "startDayOfWeek"), DateUtils.DATABASE_DATETIME_FORMAT), "date");
				v2 = DateUtils.dateAdd(7, DateUtils.parse(v1, DateUtils.DATABASE_DATETIME_FORMAT), "date");
				return v1+"{#}"+v2;
			}
			
			if(upperName == "NEXTWEEK") {
				v1 = DateUtils.dateAdd(0, null, "endDayOfWeek");
				v2 = DateUtils.dateAdd(7, DateUtils.parse(v1, DateUtils.DATABASE_DATETIME_FORMAT), "date");
				return v1+"{#}"+v2;
			}
			if(upperName == "IMAGE"){
				return params[0];
			}
			return name;
		}
		
		private static function isProperty(property:String):Boolean{
			if(property==null){
				return false;
			}
			return property.indexOf("[")!=-1 ;//|| property.indexOf("<")!=-1;
		}

		private static function isNumber(strNum:String):Boolean {
			try {
				
				if (strNum == null) { return false; }
				var regx:RegExp = /^[-+]?\d*\.?\d+(?:[eE][-+]?\d+)?$/;
				return regx.test(strNum);
			} catch (error:Error) {
				return false;
			}
			return true;
		}
		
		private static function toNumber(strNum:String):Number {
			try {
				var n:Number = parseFloat(strNum);
				
				return n;
			} catch (error:Error) {
				
					trace("Either one of the operand is not a number, can not perform [" + strNum + "]");
				return 0;
			}
			return -1;
		}
		
		private static function doDateFunction(entity:String,oper:String,params:ArrayCollection,objEntity:Object,getFieldNameFromIntegrationTag:Function):String{
			// trace("Date Format : " + dtFormat);		
			try{
				
				var strDate:String=(oper == "NOW")?"":String(params.getItemAt(0));
				if(isPropertyField(strDate, objEntity)){
					strDate = getFieldValue(entity, strDate, objEntity, getFieldNameFromIntegrationTag);
				}
				// if(StringUtils.isEmpty(strDate)) return "";
				// if(!DateUtils.isDate(strDate)) return strDate;
				var dateFormate1:String = dtFormat;
				if(params.length>1){
					dateFormate1 = String(params.getItemAt(1));
				}
				var dateParam:Date = DateUtils.parse(strDate, dateFormate1);
				if(oper == "NOW"){
					dateParam = new Date();
					return DateFormatter.parseDateString(dateParam.toString()).toDateString();
				}
				if(oper == "DAY"){
					return dateParam.getDate().toString();
				}
				if(oper == "MONTH"){
					return (dateParam.getMonth()+1).toString();
				}
				if(oper == "YEAR"){
					return dateParam.getFullYear().toString();
				}
				if(oper == "DAYNAME"){
					return dayNames[dateParam.getDay()-1];
				}
				if(oper == "MONTHNAME"){
					return monthNames[dateParam.getMonth()];
				}
				if(oper == "DAYFULLNAME"){
					return dayFullNames[dateParam.getDay()-1];
				}
				if(oper == "MONTHFULLNAME"){
					return monthFullNames[dateParam.getMonth()];
				}
				if(oper == "CHANGEDATEFORMAT"){ // swich date format ex. changeFormat('4/5/2012','DD/MM/YY',''MM/DD/YY);
					var dateFormate2:String= String(params.getItemAt(2));
				 	var dateSeperator:String = getDateSeperator(dateFormate2);
					if(!StringUtils.isEmpty(dateSeperator)){
						var df:Array = dateFormate2.split(dateSeperator);
						// var tf:Array = dateFormate2.split(" ").split(":");
						var newDate:String = "",tmp:String;
						for each(tmp in df){
							if(newDate!="") newDate+= dateSeperator;
							if(tmp=="DD" || tmp=="D"){
								newDate+= dateParam.getDate().toString();
							}else if(tmp=="MM" || tmp=="M"){
								newDate+= (dateParam.getMonth()+1).toString();
							}else if(tmp=="YY"){
								var fullYear:String = dateParam.getFullYear().toString();
								newDate+= fullYear.substr(fullYear.length-2, fullYear.length);
							}else if(tmp=="YYYY"){
								newDate+= dateParam.getFullYear().toString();
							} 
						}
						/*for each(tmp in tf){
							// JJ:NN:SS - // KK:NN:SS
							if(tmp=="JJ" || tmp=="KK"){
								newDate+= " " + dateParam.hours;
							}else if(tmp=="NN"){
								newDate+= ":" + dateParam.minutes;
							}else if(tmp=="SS"){
								newDate+= ":" + dateParam.seconds;
							}
						}*/
						return newDate;
					}
					return "";
				}
			}catch(e:Error){
				trace("Either one of the operand is not a date, can not perform [" + strDate + "]\n" + e.getStackTrace());
			}
			
			return "";
		}
		
		private static function getDateSeperator(dformat:String):String{
			if(dformat.indexOf("-")!=-1) return "-";
			if(dformat.indexOf(".")!=-1) return ".";
			if(dformat.indexOf("/")!=-1) return "/";
			return "";
		}
		
		private static function doStringFunction(entity:String,oper:String,params:ArrayCollection,objEntity:Object,getFieldNameFromIntegrationTag:Function):String{
			var error:String = "";
			try{
				var param1:String = String(params.getItemAt(0));
				var param2:String, param3:String;
				if(param1==null){
					return oper=="INSTR"?"0":"";
				}
				if(oper=="LEFT"){				
					var lenght:Number = toNumber(String(params.getItemAt(1)));
					if(lenght==0) return "";
					if(lenght>param1.length) return param1;
					return param1.substring(0,lenght);
				}
				
				if(oper=="RIGHT"){
					var len:Number=toNumber(String(params.getItemAt(1)));
					if(len==0) return "";
					if(len>param1.length) return param1;
					return param1.substring(param1.length-len);
				}
				
				if(oper=="MID"){
					var indStart:int= toNumber(String(params.getItemAt(1)))-1;
					if(indStart>param1.length) return "";
					var indEnd:int = toNumber(String(params.getItemAt(2))) + indStart ;
					if (indEnd > param1.length) {
						indEnd = param1.length;
					}
					return  param1.substr(indStart,indEnd);
				}
				
				if(oper=="LEN"){
					var v :String = isPropertyValueLength(entity, param1, objEntity, getFieldNameFromIntegrationTag);
					if( v != ""){
						return String(v.length);
					}
					return String(param1.length);
				}
				
				if(oper=="INSTR"){
					param2 = String(params.getItemAt(1));
					return "" + (param1.indexOf(param2) + 1);
				}
				
				if(oper == "TOCHAR"){
					return toChar(params.getItemAt(0)+"", params.getItemAt(1)+"");
				}
				
				if(oper == "TRIM"){
					return StringUtil.trim(param1);
				}if(oper == "LOWER"){
					param1.toLowerCase();
				}if(oper == "UPPER"){
					param1.toUpperCase();
				}if(oper == "NOTHING"){
					return 'null';
				}if(oper == "BEGINS"){
					param2 = String(params.getItemAt(1));
					return StringUtils.beginsWith(param1, param2).toString();
				}if(oper == "SUBSTR"){
					param2 = String(params.getItemAt(1));
					var endIndex:int = parseInt(param2);
					if(param1.length>endIndex){
						return param1.substring(0, endIndex);
					}
					return param1;
				}if(oper == "REPLACE"){
					param2 = String(params.getItemAt(1));
					param3 = String(params.getItemAt(2));
					if(param1.indexOf(param2)!=-1){
						return param1.replace(param2, param3);
					}
					return param1;
				}if(oper == "INDEXOF"){
					param2 = String(params.getItemAt(1));
					if(!StringUtils.isEmpty(param2)){
						return String(param1.indexOf(param2));
					}
					return String(-1);	
				}if(oper == "LPAD"){
					
				}if(oper == "RPAD"){
					
				}
			}catch(e:Error){
				trace(e.getStackTrace());
				error = "<Error> " + oper + " " + e.getStackTrace();
			}
			
			trace("Funcion : '"+oper+"' coming soon...");
			return error;
		}
		
		
		private static function toChar(str:String,format:String):String{
			var value:String ="";
			if(isNumber(str)){
				
				var numberFormatter:NumberFormatter = new NumberFormatter();
				var symbol:String = CURRENCY_SYMBOL[format.substring(0,1)] == null ? "" : CURRENCY_SYMBOL[format.substring(0,1)];
				var minus:String = str.indexOf("-") != -1 ? "-" : "" ; 
				numberFormatter.precision= format.indexOf(".") != -1 && str.indexOf(".") != -1 ? format.length - format.indexOf(".")-1 : "0";
				numberFormatter.rounding="up";
				numberFormatter.decimalSeparatorTo=".";
				numberFormatter.thousandsSeparatorTo=format.indexOf(",") != -1 ? ",":"";
				numberFormatter.useThousandsSeparator=format.indexOf(",") != -1 ? "true":"false";
				
				return  symbol + minus + numberFormatter.format(Math.abs(toNumber(str)));
			}else if(DateUtils.isDate(str)){
				var date:Date = DateUtils.parse(str,DateUtils.DATABASE_DATETIME_FORMAT);
				if(format == "YYYY/MM/DD hh:mm:ss PM"){
					value = DateUtils.toDateTimeYMDHMS_PM(date);
				}else if(format == "YYYY/MM/DD hh:mm:ss" || format == "YYYY/MM/DD hh24:mm:ss PM"){
					value = DateUtils.toDateTimeYMDHMS(date);
				}else{
					value = DateUtils.format(date,format);
				}
				
			}else{
				return str;
			}
			return value;
		}
		private static function doCompareAndCalculate(operator:String, params:ArrayCollection):String{
			try{
				var str1:String = params.getItemAt(0).toString();
				var str2:String = params.getItemAt(1).toString();
				var bool:Boolean=false;
				var num:Number=0,i:int=0;
				if(operator=="MIN"){
					var minNum:Number = StringUtils.getNumber(params.getItemAt(0).toString());
					for(i=1; i<params.length; i++){
						num = StringUtils.getNumber(params.getItemAt(i).toString());
						if(num<minNum) minNum = num;
					}
					return minNum.toString();
					
				}else if(operator=="MAX"){
					var maxNum:Number = StringUtils.getNumber(params.getItemAt(0).toString());
					for(i=0; i<params.length; i++){
						num = StringUtils.getNumber(params.getItemAt(i).toString());
						if(num>maxNum) maxNum = num;
					}
					return maxNum.toString();
					
				}else if(isNumber(str1) && isNumber(str2)){ // compare number
					var num1:Number = toNumber(str1);
					var num2:Number = toNumber(str2);
					bool = false;
					if(operator=="GT"){					
						bool=num1>num2;
					}else if(operator=="GTE"){
						bool=num1>=num2;
					}else if(operator=="LT"){
						bool=num1<num2;
					}else if(operator=="LTE"){
						bool=num1<=num2;
					}else if(operator=="EQ"){
						bool=num1==num2;					
					}else if(operator=="ADD"){
						return String(num1+num2);
					}else if(operator=="MULT"){
						return String(num1*num2);
					}else if(operator=="DIV"){
						return String(num1/num2);
					}else if(operator=="SUB"){
						return String(num1-num2);
					}else if(operator=="MOD"){
						return String(num1%num2);
					}
					return bool?"true":"false";
					
				}else if(DateUtils.isDate(str1) && DateUtils.isDate(str2)){ // compare date
					var date1:Date = DateUtils.parse(str1,DateUtils.DATABASE_DATETIME_FORMAT);
					var date2:Date = DateUtils.parse(str2,DateUtils.DATABASE_DATETIME_FORMAT);
					bool = false;
					if(operator=="GT"){					
						bool=date1>date2;
					}else if(operator=="GTE"){
						bool=date1>=date2;
					}else if(operator=="LT"){
						bool=date1<date2;
					}else if(operator=="LTE"){
						bool=date1<=date2;
					}else if(operator=="EQ"){
						bool=date1.toString()==date2.toString();					
					}
					return bool?"true":"false";
				}else if(DateUtils.isDate(str1) && isNumber(str2)){  // compare String
					var date:Date = DateUtils.parse(str1,DateUtils.DATABASE_DATETIME_FORMAT)
					var day:int =toNumber(str2);
					var millisecondsPerDay:int = 1000*60*60*24;
					if(operator=="ADD"){
						return DateUtils.format(new Date(date.getTime()+(day*millisecondsPerDay)),DateUtils.DATABASE_DATETIME_FORMAT);
					}else if(operator=="SUB"){
						return DateUtils.format(new Date(date.getTime()-(day*millisecondsPerDay)),DateUtils.DATABASE_DATETIME_FORMAT);
					}
				}else if(operator=="OPOSIT"){
					return  str1 != str2 ? "true" : "false";
				}else if(operator=="ADD"){
					return (str1 == null ? "" : str1) + (str2 == null ? "" :str2);
				}else if(operator=="EQ"){
					return str1 == str2?"true":"false";
				}
			}catch(e:Error){
				trace( "doCompareAndCalculate \n" + e.getStackTrace());
			}
			return "";
		}
		
		private static function doFindOneOf(str1:String,str2:String):String{
			for(var i:int =0;i<str2.length;i++){
				var c:String = str2.charAt(i);
				var index:int = str1.indexOf(c);
				if(index != -1){
					return index +"";
				}
			}
			return "-1";
		}
		
		private static function doFindNoneOf(str1:String,str2:String):String{
			var curPos:int =0 ;
			for(var i:int =0;i<str2.length;i++){
				var c:String = str2.charAt(i);
				for(var j:int =curPos ;j<str1.length;j++){
					var s:String = str1.charAt(j);
					if(c != s){
						return j +"";
					}else{
						curPos = j+1;
						break;
					}
				}
			}
			return "-1";
		}
		
		private static function doLikeFunction(strSearch:String,prefix:String,chf:String,chl:String):String{
//			var chf:String=strSearch.charAt(0);
			var ind:int=strSearch.indexOf(prefix);
			
			if(chl=="*" || chl=="%"){			
				if(chf=="*"){
					return ind!=-1?"true":"false";
				}else{
					return ind==0?"true":"false";
				}
				
			}else if (chl=="?"){
				
				if(chf=="*"){					
					if(ind+prefix.length==strSearch.length-1){
					  return "true";	
					}
										
					
				}else{
					if(ind==0 && prefix.length==strSearch.length-1){
						return "true";
					}
				}
			}else{
				if(chf=="*" && ind!=-1){
					return "true"
				}else{
					if(ind==0 && prefix.length==strSearch.length){
						return "true"
					}
				}
			}
			return "false"
		}
		private static function replaceSpecialCh(strReplace:String):String{
			return strReplace.replace(PATTERN,"");	
		}
		private static function replaceBRACE(strReplace:String):String{
			return strReplace.replace(BRACE_PATTERN,"");	
		}
		private static function isPropertyField(pro:String,objEntity:Object):Boolean{
			if(pro.indexOf('<')!= -1 && pro.indexOf('>')!= -1){
				return true;
			}
			return false;
		}	
		private static function isPropertyValueLength(entity:String,pro:String,objEntity:Object,getFieldNameFromIntegrationTag:Function):String{
			if(pro.indexOf('<')!= -1 && pro.indexOf('>')!= -1){
				return getFieldValue(entity,pro,objEntity,getFieldNameFromIntegrationTag);
			}
			return "";
		}
		
		private static function getFieldValue(entity:String,name:String,objEntity:Object,getFieldNameFromIntegrationTag:Function):String{
			var str:String =replaceSpecialCh(name);
			str = str.replace(BRACE_PATTERN,"");
			if (StringUtils.endsWith(str, "_ITAG")) {
				str = getFieldNameFromIntegrationTag(entity, str);
			} 
			
			if (objEntity == null) return "";
			
			return objEntity[str] == null ? "" :objEntity[str];

		}
		
	}
}