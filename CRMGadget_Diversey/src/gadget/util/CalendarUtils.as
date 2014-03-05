package gadget.util
{
	import flexlib.scheduling.util.DateUtil;
	
	import gadget.dao.Database;
	
	import mx.collections.ArrayCollection;
	import mx.controls.DateChooser;
	import mx.formatters.DateFormatter;

	public class CalendarUtils
	{
		
		public static const ACTIVITY_CALL_COLOR:Object = 0x009999;
		public static const ACTIVITY_APPOINTMENT_COLOR:Object = 0xDFD22C;
		public static const ACTIVITY_TASK_COLOR:Object = 0xFF8080;
		public static const ACTIVITY_GOOGLE_COLOR:Object = 0x668CD9;
		
		public static const SELECTED_DAY:int = 0;
		public static const SELECTED_WEEK:int = 1;
		public static const SELECTED_5DAYS:int = 2;
		public static const SELECTED_MONTH:int = 3;
		
		public function CalendarUtils(){}
		
		public static function generateFilter(paramStartDate:String, paramEndDate:String):String{
			var filter:String = "(substr(StartTime, 1, 4) || substr(StartTime, 6, 2) || substr(StartTime, 9, 2) >= '" + paramStartDate + "'" +
				" AND substr(StartTime, 1, 4) || substr(StartTime, 6, 2) || substr(StartTime, 9, 2) <= '" + paramEndDate + "'" + 
				" AND Activity = 'Appointment'" +
				")";
			
			filter += " OR ";
			
			filter += "(substr(DueDate, 1, 4) || substr(DueDate, 6, 2) || substr(DueDate, 9, 2) >= '" + paramStartDate + "'" +
				" AND substr(DueDate, 1, 4) || substr(DueDate, 6, 2) || substr(DueDate, 9, 2) <= '" + paramEndDate + "'" + 
				" AND Activity = 'Task'" +
				")";
			return filter;
		} 
		
		public static function getActivities(dateChooser:DateChooser, selectBy:int = SELECTED_WEEK):ArrayCollection {
			
			var resultList:ArrayCollection;
			var columns:ArrayCollection = new ArrayCollection([
				//				{element_name:"Activity"},
				//				{element_name:"StartTime"}, {element_name:"EndTime"},
				//				{element_name:"DueDate"}, {element_name:"Subject"}
				{element_name:"*"},
				{element_name:"substr(Priority,1,1) PriorityIndex"}
			]);
			
			var startDate:Date;
			var endDate:Date;
			
			var dateFormatter:DateFormatter = new DateFormatter();
			dateFormatter.formatString = "YYYYMMDD";
			
			switch(selectBy){
				case SELECTED_DAY:
					startDate =  getSelectedDate(dateChooser);
					endDate = new Date(startDate.getTime() + DateUtil.DAY_IN_MILLISECONDS * 1);
					break;
				case SELECTED_5DAYS:
					startDate =  getMondayOfWeek(getSelectedDate(dateChooser));
					endDate = new Date(startDate.getTime() + DateUtil.DAY_IN_MILLISECONDS * 5);
					break;
				case SELECTED_WEEK:
					startDate =  getMondayOfWeek(getSelectedDate(dateChooser));
					endDate = new Date(startDate.getTime() + DateUtil.DAY_IN_MILLISECONDS * 7);
					break;
				case SELECTED_MONTH:
					startDate =  getFirstDateOfMonth(dateChooser);
					endDate = new Date(startDate.getTime() + DateUtil.DAY_IN_MILLISECONDS * 31);
					break;
			}
			var filter:String = CalendarUtils.generateFilter(dateFormatter.format( startDate ), dateFormatter.format( endDate ));
			
			return Database.activityDao.findAll(columns, "(" + filter + ")", null, 1001, "PriorityIndex");			   
		}	
		
		public static function getSelectedDate(dateChooser:DateChooser):Date {
			return dateChooser.selectedDate == null ? new Date(new Date().getFullYear(), new Date().getMonth(), new Date().getDate(), 0, 0, 0, 0) : dateChooser.selectedDate;
		}	
		
		public static function getFirstDateOfMonth(dateChooser:DateChooser):Date {
			var currentDate:Date = dateChooser.selectedDate == null ? new Date() : dateChooser.selectedDate;
			return new Date(currentDate.getFullYear(), currentDate.getMonth(), 1, 0, 0, 0, 0);
		}

		public static function getMondayOfWeek(selectedDate:Date):Date {
			return new Date(selectedDate.getTime() - DateUtil.DAY_IN_MILLISECONDS * (selectedDate.getDay() == 0 ? 6 : selectedDate.getDay()-1));
		}	
		

		public static function getSpecialDays(year:int, month:int):ArrayCollection {
			var resultList:ArrayCollection;
			var columns:ArrayCollection = new ArrayCollection([
				{element_name:"*"}
			]);
			var tmp:String = "" + year + (month < 9 ? "0" : "") + (month+1);
			
			return Database.activityDao.findAll(columns, "(" + generateFilter(tmp+"01", tmp + "31") + ")");
		}
		
		public static function setSpecialDays(dateChooser:DateChooser): void {
			var specialDayData:Array = [];
			for each(var activity:Object in getSpecialDays(dateChooser.displayedYear, dateChooser.displayedMonth)){		
				var startDate:Date = null;
				var endDate:Date = null;
				var cDateObject:Object = null;
				if (activity.Activity == 'Task') { 
					startDate = DateUtils.guessAndParse(activity.DueDate);
					cDateObject = {rangeStart:startDate, rangeEnd:startDate};
				} else {
					startDate = DateUtils.guessAndParse(activity.StartTime);
					endDate = DateUtils.guessAndParse(activity.EndTime);
					if(startDate && endDate && startDate.getHours() < endDate.getHours()){
						cDateObject = {rangeStart:startDate, rangeEnd:endDate};
					}
				}
				if (cDateObject != null && !itemExist(specialDayData, cDateObject)) {
					specialDayData.push(cDateObject);
				}
			}
			dateChooser.selectedRanges = specialDayData;
		}	
		
		private static function itemExist(specialDayData:Array, item:Object):Boolean {
			for each(var object:Object in specialDayData){
				var startDate:Date = object.rangeStart;
				var endDate:Date = object.rangeEnd;
				
				if(startDate.getTime() == item.rangeStart.getTime() && endDate.getTime() == item.rangeEnd.getTime()) return true;
			}
			return false;
		}
		
	}
}