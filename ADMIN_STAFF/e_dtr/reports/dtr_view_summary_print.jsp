<%@page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTR, eDTR.eDTRUtil, 
																java.util.Calendar, java.util.Date" buffer="16kb"%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
    table.thinborder {
    border-top: solid 1px #000000;
		border-right: solid 1px #000000;
    }
    TD.thinborder {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: 9px;  
    }
		
		TD.BottomLeftRight {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		border-right: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: 9px;  
    }

    TD.NoBorder {
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: 9px;  
		}
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script> 

<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
  Vector vRetEDTR = new Vector();
	Calendar calTemp = Calendar.getInstance();
	String strTemp2 = null;
	String strTemp3 = null;
	int iSearchResult =0;
	int iIndex = 0;
	int iCtr = 0;
	String strMonths = WI.fillTextValue("strMonth");
 	String strYear = WI.fillTextValue("sy_");
	if(strMonths.length() == 0)
		strMonths = Integer.toString(calTemp.get(Calendar.MONTH) + 1);
	if(strYear.length() == 0)
		strYear = Integer.toString(calTemp.get(Calendar.YEAR));
	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-View/Print DTR","dtr_view_summary.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","STATISTICS & REPORTS",request.getRemoteAddr(),
														"dtr_view_summary.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
if(strErrMsg == null) strErrMsg = "";
String[] strConvertAlphabet = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","0","5"};

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if (strSchCode == null)
	strSchCode = "";

ReportEDTR RE = new ReportEDTR(request);
Vector vSummaryWrkHours = null;
Vector vHoursWork = null;
Vector vDayInterval = null;
Vector vHoursOT = null;

Vector vRetHolidays = null;
Vector vTempHoliday = null;
Vector vEmpLeave = null;
Vector vRetOBOT = null;
Vector vAWOLRecords = null;
Vector vLateUnderTime = null;
Vector vEmpLogout = null;
Vector vEmpOvertime = null;
Vector vMultipleLogin = null;

String strEmpDayRec = null;
String strDateFr = null;
String strDateTo = null;
String strHoliday  = null;
int iIndexOf  = 0;
String strLate = null;
String strUt = null;
double dAwol = 0d;

String[] astrMonth={"&nbsp;", "January", "February", "March", "April", "May", "June",
					 "July","August", "September","October", "November", "December"};

	vRetResult = RE.searchEDTR(dbOP);
	double dOTTotal = 0d; // Total OT Hours for the specified date
	double dHoursWork = 0d;
	long lTotalLateUt = 0l;
	long lLateUt = 0l;
	double dTotalHoursWork = 0d;
	boolean bolPageBreak = false;
	int i = 0;

	if (vRetResult == null)
		strErrMsg = RE.getErrMsg();

//added by biswa to get from and to date.
	if( WI.fillTextValue("DateDefaultSpecify").equals("0")) {
		String[] astrTemp = eDTRUtil.getCurrentCutoffDateRange(dbOP, true);
		if(astrTemp != null) {
			strDateFr = astrTemp[0];
			strDateTo = astrTemp[1];
		}
	} else if( WI.fillTextValue("DateDefaultSpecify").equals("2")) {
		try{			
				if (strYear.length()> 0){
					if (Integer.parseInt(strYear) >= 2005)
						calTemp.set(Calendar.YEAR, Integer.parseInt(strYear));
				else
					strErrMsg = " Invalid year entry";
	
				}else{
					strYear = Integer.toString(calTemp.get(Calendar.YEAR));
				}
			}
			catch (NumberFormatException nfe){
			strErrMsg = " Invalid year entry";
			}
	
			calTemp.set(Calendar.DAY_OF_MONTH,1);
	
			 if(!strMonths.equals("0") && strMonths.length() > 0){
					calTemp.set(Calendar.MONTH,Integer.parseInt(strMonths)-1);
			 }else{
					strMonths = Integer.toString(calTemp.get(Calendar.MONTH) + 1);
			 }

				strDateFr = strMonths + "/01/" + calTemp.get(Calendar.YEAR);
				strDateTo = strMonths + "/" + Integer.toString(calTemp.getActualMaximum(Calendar.DAY_OF_MONTH))
						+ "/" + calTemp.get(Calendar.YEAR); 
	} else {
		strDateFr = WI.fillTextValue("from_date");
		strDateTo = WI.fillTextValue("to_date");

	}

 		vDayInterval = RE.getDayNDateDetail(strDateFr,strDateTo, true);		
		//System.out.println("PRINT -  vDayInterval -- " + vDayInterval.size());
		if (vDayInterval == null)
			strErrMsg = RE.getErrMsg();
		vRetHolidays = RE.getHolidaysOfMonth(dbOP,request);
		
	if (vRetResult != null && vDayInterval != null) {
	int iPage = 1; int iCount = 0;
	int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));

	int iNumRec = 0;//System.out.println(vRetResult);
	int iIncr    = 1;
	int iTotalPages = (vRetResult.size())/(7*iMaxRecPerPage);	
	if((vRetResult.size() % (7*iMaxRecPerPage)) > 0) ++iTotalPages;
	 for (;iNumRec < vRetResult.size();iPage++){				
%>
<body onLoad="javascript:window.print();">
<form name="dtr_op">  	
  <table width="100%" border="0" cellpadding="2" cellspacing="0"  bgcolor="#FFFFFF">
    <tr >
      <td height="22" colspan="2"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></td>
    </tr>
    <tr >
      <td height="22" colspan="2"  class="NoBorder"><strong>For the period covering <%=strDateFr%> to <%=strDateTo%></strong></td>
    </tr>
    <tr >
      <td height="25" colspan="2" align="center">&nbsp;</td>
    </tr>
	</table>	
	<table width="100%" border="0" cellpadding="2" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">		
    <tr >
      <td width="13%" height="25" align="center" class="thinborder"><strong>Name</strong></td>
			<%for(int iDay = 0; iDay < vDayInterval.size(); iDay+=2){%>
      <td align="center" class="thinborder"><%=WI.formatDate((String)vDayInterval.elementAt(iDay),9)%><br>
<%=(String)vDayInterval.elementAt(iDay+1)%></td>			
			<%}%>
			<td width="3%" align="center" class="thinborder">Total W.Hours </td>
      <td width="3%" align="center" class="thinborder">Total Late/UT/<br>
      Absences</td>
      <td width="3%" align="center" class="thinborder">Overtime</td>
    </tr>
    <tr>
      <td height="25" class="thinborder">&nbsp;</td>
			<%for(int iDay = 0; iDay < vDayInterval.size(); iDay+=2){
			strHoliday = "";
			if (vRetHolidays != null && vRetHolidays.size() > 0 &&
				((String)vRetHolidays.elementAt(1)).equals((String)vDayInterval.elementAt(iDay))){
				strHoliday = (String)vRetHolidays.remove(0);
				vRetHolidays.removeElementAt(0);
			} 
			%>
      <td height="25" class="thinborder"><%=WI.getStrValue(strHoliday,"&nbsp;")%></td>			
			<%}%>
			<td align="right" class="thinborder">&nbsp; </td>
      <td align="right" class="thinborder">&nbsp;</td>
	    <td align="right" class="thinborder">&nbsp;</td>
    </tr>
    <% 
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=7,++iIncr, ++iCount){
			dTotalHoursWork = 0d;
			dOTTotal = 0d;
			lLateUt = 0l;
			lTotalLateUt = 0l;
			dAwol = 0d;
		i = iNumRec;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	
	  strTemp = (String)vRetResult.elementAt(i+3);

	if(strTemp == null)
		strTemp = (String)vRetResult.elementAt(i+4);
	else if(vRetResult.elementAt(i+4) != null)
		strTemp += "/"+(String)vRetResult.elementAt(i+4);

	vRetEDTR = RE.getDTRDetails(dbOP, (String)vRetResult.elementAt(i), true);
	//vTempHoliday.addAll(vRetHolidays); uncomment this if per employee i display ang holiday
 	
	// leave.. vRetResult.elementAt(i+4)
	vEmpLeave = RE.getEmployeeLeave(dbOP, (String)vRetResult.elementAt(i+6),
										strDateFr, strDateTo);
		//System.out.println("vEmpLeave : "  + vEmpLeave);
		
	// trainings / ob / otin
	vRetOBOT = RE.getEmpOBOT(dbOP, (String)vRetResult.elementAt(i+6),
										strDateFr, strDateTo);
	//System.out.println("vRetOBOT : "  + vRetOBOT);
	
	// awol records..
	 vAWOLRecords = RE.getAWOLEmployee(dbOP, (String)vRetResult.elementAt(i+6),
										strDateFr, strDateTo);
	
	//Employee Logout..
	vEmpLogout = RE.getEmpLogout(dbOP, (String)vRetResult.elementAt(i+6),
										strDateFr, strDateTo);
	//System.out.println("vEmpLogout : "  + vEmpLogout);
	
	vEmpOvertime = RE.getEmpOverTime(dbOP, (String)vRetResult.elementAt(i+6),
										strDateFr, strDateTo);
												
	vHoursWork = RE.computeWorkingHour(dbOP, (String)vRetResult.elementAt(i),
												strDateFr, strDateTo, null, null);
	vHoursOT  =  RE.getOTHours(dbOP, (String)vRetResult.elementAt(i +6),
												strDateFr, strDateTo, null, null);

	vMultipleLogin = RE.getMultipleLogRange(dbOP, (String)vRetResult.elementAt(i),
												strDateFr, strDateTo);	
%>
    <tr>
      <td height="25" class="thinborder">
				<%=WI.formatName((String)vRetResult.elementAt(i+1), "", 
												 (String)vRetResult.elementAt(i+2),4).toUpperCase()%></td>
		<%
		 for(int iDay = 0; iDay < vDayInterval.size(); iDay+=2){
		  //System.out.println("---------- " + vDayInterval.elementAt(iDay));
			strEmpDayRec = "";
			strTemp = "";
			strTemp2 = "";
			if (vRetEDTR == null || vRetEDTR.size() ==  0) {
				// this part here is for the multiple login employees				
				if(vMultipleLogin == null || vMultipleLogin.size() == 0)
					strErrMsg=RE.getErrMsg();
				else{
					iIndexOf = 0;
					while(iIndexOf != -1){
						iIndexOf = vMultipleLogin.indexOf((String)vDayInterval.elementAt(iDay));
 
  						if(iIndexOf != -1){
							//"select tin_tout_fac_index, user_index, login_date, sch_login_time_hr, " + // 0 - 3
							//" sch_login_time_min, sch_login_time_ampm, sch_logout_time_hr, " + // 4 - 6
							//" sch_logout_time_min, sch_logout_time_ampm, actual_login_time_bi, " + // 7 - 9
							//" actual_logout_time_bi, null, null, sch_login_time_bi, sch_logout_time_bi, " + // 14
							//" ut_min, late_min, mins_worked from tin_tout_faculty where is_valid = 1 " + // 17						
							vMultipleLogin.remove(iIndexOf); // remove login_date 2
							vMultipleLogin.remove(iIndexOf); // remove sch_login_time_hr 3
							vMultipleLogin.remove(iIndexOf); // remove sch_login_time_min 4
							vMultipleLogin.remove(iIndexOf); // remove sch_login_time_ampm 5
							vMultipleLogin.remove(iIndexOf); // remove sch_logout_time_hr 6
							vMultipleLogin.remove(iIndexOf); // remove sch_logout_time_min 7
							vMultipleLogin.remove(iIndexOf); // remove sch_logout_time_ampm 8
							vMultipleLogin.remove(iIndexOf); // remove actual_login_time_bi 9
							vMultipleLogin.remove(iIndexOf); // remove actual_logout_time_bi 10
							
							if(strTemp.length() == 0)
								strTemp = (String)vMultipleLogin.remove(iIndexOf); // remove actual time in // null 11
							else
								vMultipleLogin.remove(iIndexOf);

							if((String)vMultipleLogin.elementAt(iIndexOf) != null)
								strTemp2 = (String)vMultipleLogin.remove(iIndexOf);
							else
								vMultipleLogin.remove(iIndexOf);  // remove timeout 12
 							  							
							vMultipleLogin.remove(iIndexOf); // sch_login_time_bi 13
							vMultipleLogin.remove(iIndexOf); // sch_logout_time_bi 14
							
							strUt = (String)vMultipleLogin.remove(iIndexOf); // ut_min 15

							lLateUt = Long.parseLong(WI.getStrValue(strUt,"0"));
							strLate = (String)vMultipleLogin.remove(iIndexOf); // late_min 16

							lLateUt += Long.parseLong(WI.getStrValue(strLate,"0"));
							lTotalLateUt += lLateUt;
							
							dTotalHoursWork += Double.parseDouble((String)vMultipleLogin.remove(iIndexOf)); // hours worked 17
							
							vMultipleLogin.remove(iIndexOf - 1); // user_index 1
							vMultipleLogin.remove(iIndexOf - 2); // tin_tout_fac_indexs			0				
						} // end if(iIndexOf != -1)
					} // end while(iIndexOf != -1)
				}// end else
			}else{
				if (vRetEDTR.size() == 1){//non DTR employees
					strTemp = (String) vRetEDTR.elementAt(0);
 				}else{
					/*
					iIndexOf = 0;
					while(iIndexOf != -1){
						iIndexOf = vRetEDTR.indexOf((String)vDayInterval.elementAt(iDay));
 						if(iIndexOf != -1){
							vRetEDTR.remove(iIndexOf); // remove timein_date
							vRetEDTR.remove(iIndexOf); // remove timeout_date
							strTemp2 = WI.formatDateTime(((Long)vRetEDTR.remove(iIndexOf - 1)).longValue(),2);  // remove timeout
							strTemp  = WI.formatDateTime(((Long)vRetEDTR.remove(iIndexOf - 2)).longValue(),2);  // remove timein
							vRetEDTR.remove(iIndexOf - 3); // remove user_index
							vRetEDTR.remove(iIndexOf - 4); // remove wh_index
							if(strEmpDayRec.length() == 0)
								strEmpDayRec = WI.getStrValue(strTemp,""," - "+strTemp2,"");
							else
								strEmpDayRec += "<br>" + WI.getStrValue(strTemp,""," - "+strTemp2,"");
						}
						//iIndexOf = vRetEDTR.indexOf((String)vDayInterval.elementAt(iDay));
					}			
					*/
					
					iIndexOf = 0;
					while(iIndexOf != -1){
						iIndexOf = vRetEDTR.indexOf((String)vDayInterval.elementAt(iDay));
 						if(iIndexOf != -1){
							vRetEDTR.remove(iIndexOf); // remove timein_date
							vRetEDTR.remove(iIndexOf); // remove timeout_date
							
							strLate = (String)vRetEDTR.remove(iIndexOf); // remove late_time_in
							lLateUt = Long.parseLong(WI.getStrValue(strLate,"0"));
							strUt = (String)vRetEDTR.remove(iIndexOf); // remove under_time
							lLateUt += Long.parseLong(WI.getStrValue(strUt,"0"));							
							lTotalLateUt += lLateUt;
							
							if(((Long)vRetEDTR.elementAt(iIndexOf - 1)).longValue() > 0)
								strTemp2 = WI.formatDateTime(((Long)vRetEDTR.remove(iIndexOf - 1)).longValue(),2);  // remove timeout
							else
								vRetEDTR.remove(iIndexOf - 1);  // remove timeout	
								
							if(strTemp.length() == 0)
								strTemp  = WI.formatDateTime(((Long)vRetEDTR.remove(iIndexOf - 2)).longValue(),2);  // remove timein
							else
								vRetEDTR.remove(iIndexOf - 2);
							
							vRetEDTR.remove(iIndexOf - 3); // remove user_index
							vRetEDTR.remove(iIndexOf - 4); // remove wh_index
								
						}						
						//iIndexOf = vRetEDTR.indexOf((String)vDayInterval.elementAt(iDay));
					}		
				}
			}
			strEmpDayRec = WI.getStrValue(strTemp,"","-"+strTemp2,"");					
			strEmpDayRec = ConversionTable.replaceString(strEmpDayRec,"AMPM","");
			
			//System.out.println("strEmpDayRec " + strEmpDayRec);
 			if (vEmpLeave != null && vEmpLeave.size() > 0 &&
				((String)vEmpLeave.elementAt(0)).equals((String)vDayInterval.elementAt(iDay))){
 				vEmpLeave.removeElementAt(0);
				strHoliday = " leave (" + (String)vEmpLeave.remove(0) +")";
                                vEmpLeave.remove(0);																
			}else
				strHoliday = "";
			//System.out.println("after leave ");
			if (vRetOBOT != null && vRetOBOT.size() > 0 &&
				((String)vRetOBOT.elementAt(0)).equals((String)vDayInterval.elementAt(iDay))){
				vRetOBOT.removeElementAt(0);
				if(strHoliday.length() > 0)
					strHoliday += "<br>";				
				strHoliday += " OB/OT";
			}
			//System.out.println("after OT");
			//System.out.println("vAWOLRecords.elementAt(0)    " + (Date)vAWOLRecords.elementAt(0));
			//System.out.println("vDayInterval.elementAt(iDay) " + (String)vDayInterval.elementAt(iDay));
			if (vAWOLRecords != null && vAWOLRecords.size() > 0 &&
			(ConversionTable.convertMMDDYYYY((Date)vAWOLRecords.elementAt(0)).equals((String)vDayInterval.elementAt(iDay)))){
				//System.out.println("here--?");
				vAWOLRecords.removeElementAt(0);
				if(strHoliday.length() > 0)
					strHoliday += "<br>";				
								 
				
				strTemp = (String)vAWOLRecords.remove(0);
				strHoliday += "Absent (" + CommonUtil.formatFloat(strTemp, true) +")";				
				dAwol += Double.parseDouble(strTemp);
			}

			if (vEmpLogout != null && vEmpLogout.size() > 0 &&
			((String)vEmpLogout.elementAt(0)).equals((String)vDayInterval.elementAt(iDay))){
				vEmpLogout.removeElementAt(0);
				if(strHoliday.length() > 0)
					strHoliday += "<br>";				
				strHoliday += "OL (" + (String)vEmpLogout.remove(0) +")";
			}

			if (vEmpOvertime != null && vEmpOvertime.size() > 0 &&
			((String)vEmpOvertime.elementAt(0)).equals((String)vDayInterval.elementAt(iDay))){
				vEmpOvertime.removeElementAt(0); // date
				if(strHoliday.length() > 0)
					strHoliday += "<br>";				
				strHoliday += "OT (" + (String)vEmpOvertime.remove(0) +")";
			}
			//System.out.println("strHoliday " + strHoliday);
				if(strHoliday.length() > 0)
					strEmpDayRec += "<br>" + strHoliday;
			//System.out.println("strEmpDayRec " + strEmpDayRec);				
		%>			
      <td height="25" align="center" class="thinborder"><%=WI.getStrValue(strEmpDayRec,"&nbsp;")%></td>			
			<%}// end for loop%>
			<% //System.out.println("vHoursWork print " + vHoursWork);
				if (vHoursWork != null && vHoursWork.size() > 0){		
					for(iCtr = 0; iCtr < vHoursWork.size(); iCtr +=3){
						dHoursWork =((Double)vHoursWork.elementAt(iCtr+2)).doubleValue();						
						dTotalHoursWork += dHoursWork;
					}
				}
			%>			
			<td align="right" class="thinborder"><%=CommonUtil.formatFloat(dTotalHoursWork, true)%></td>
			<% strTemp = "";
			if(strSchCode.startsWith("CGH")){			
				if(lTotalLateUt > 0 || dAwol > 0d){
					dTotalHoursWork = ((double)lTotalLateUt/60) + dAwol;
					strTemp = CommonUtil.formatFloat(dTotalHoursWork, 2);
					strTemp = "<br>(" + strTemp + ")";
				}
			}
			%>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat((lTotalLateUt + (dAwol*60)), true)%><%=strTemp%></td>
		<%
		if (vHoursOT != null && vHoursOT.size() > 0){
			for(iCtr = 0; iCtr < vHoursOT.size(); iCtr +=3){
				dHoursWork =((Double)vHoursOT.elementAt(iCtr+2)).doubleValue();
				dOTTotal += dHoursWork;
			}
		} 
 		%>					
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dOTTotal,true)%></td>
    </tr>
		<%} // end for loop inner%>
  </table>
	
   
  <%if (bolPageBreak){%>
<DIV style="page-break-before:always">&nbsp;</Div>
<%}//page break ony if it is not last page.

	} //end for (iNumRec < vRetResult.size()
} //end end upper most if (vRetResult !=null)%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
