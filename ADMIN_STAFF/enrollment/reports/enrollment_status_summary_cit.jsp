<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector,java.util.Calendar,java.text.*,java.util.Date " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>



<script language="JavaScript">
function submitForm() {
	document.form_.reloadPage.value='1';	
	document.all.processing.style.visibility = "visible";
	document.bgColor = "#FFFFFF";	
	document.forms[0].style.visibility = "hidden";
	document.forms[0].submit();
}

function PrintPg()
{
 	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(!vProceed)
		return;
	
	
	document.bgColor = "#FFFFFF";
	
	var obj = document.getElementById('myID1');
	obj.deleteRow(0);
	obj.deleteRow(0);	
		
	var obj1 = document.getElementById('myID2');
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	
	document.getElementById('myID3').deleteRow(0);
	document.getElementById('myID3').deleteRow(0);
	
	document.getElementById('myID4').deleteRow(0);
	document.getElementById('myID4').deleteRow(0);
	
	//alert("Click OK to print this page");
	window.print();//called to remove rows, make bg white and call print.	
}


</script>




<style type="text/css">
    TD.thinborderTOPLEFTBOTTOM {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
</style>

<body bgcolor="#D2AE72">
<%
	String strTemp = null;
	int iSubTotal   = 0; // sub total of a course - major.
	int iElemSubTotal = 0;
	int iHSSubTotal = 0;
	int iPreElemSubTotal = 0;	
	String strErrMsg = null;
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORT-enrollment summary","enrollment_status_summary_cit.jsp");
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
														"Enrollment","REPORTS",request.getRemoteAddr(),
														"enrollment_status_summary_cit.jsp");
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
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";


Vector vCollege = null;
Vector vCourse = null;
Vector vDateRange = null;
Vector vTodaysResult = null;
Vector vLastYear = null;
Vector vLast2Year = null;
Vector vEndOfDate = null;
String strTodayWD = null;
String strRangeWD = null;
Vector vETEEAP = null;


Vector vRetResult = null;
ReportEnrollment reportEnrl = new ReportEnrollment();
if(WI.fillTextValue("reloadPage").length()>0){
	vRetResult = reportEnrl.enrollmentSummaryCIT(dbOP, request);
	if(vRetResult == null)
		strErrMsg = reportEnrl.getErrMsg();	
}	


String[] strConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester","4th Semester"};
	
%>
<form action="./enrollment_status_summary_cit.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myID1">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          SUMMARY REPORT ON ENROLMENT PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myID2">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="11%" height="25">School year </td>
      <td width="22%" height="25"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> </td>
      <td width="5%">Term</td>
      <td width="22%" height="25"><select name="offering_sem">
          <option value="1">1st Sem</option>
          <%
strTemp =WI.fillTextValue("offering_sem");
if(strTemp.length() ==0) strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>4th Sem</option>
          <%}else{%>
          <option value="4">4th Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select></td>
      <td width="38%">
	  <input type="button" name="Login" value="Generate Report" onClick="submitForm();">	  </td>
    </tr>

    <tr> 
      <td>&nbsp;</td>
      <td width="11%" height="25">
		Date as of
      </td>
	
	<%
	strTemp = WI.fillTextValue("specific_date");
	if(strTemp.length() ==0)
		strTemp = WI.getTodaysDate(1);
	%>
	  <td colspan="3"><input name="specific_date" type="text" size="10" value="<%=strTemp%>" class="textbox"
	  		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly>
        <a href="javascript:show_calendar('form_.specific_date');" 
			title="Click to select date" onMouseOver="window.status='Select date';return true;" 
			onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        </font> </td>
	
    </tr>
    
    <tr>
      <td>&nbsp;</td>
      <td height="25" colspan="5">&nbsp;</td>
    </tr>

    <tr> 
      <td height="25" colspan="6">&nbsp;</td>
    </tr>
  </table>
  
<%

if(vRetResult != null && vRetResult.size() > 0){
	vCollege = (Vector)vRetResult.remove(0);
	vCourse = (Vector)vRetResult.remove(0);
	vDateRange = (Vector)vRetResult.remove(0);
	vTodaysResult = (Vector)vRetResult.remove(0);
	vLastYear = (Vector)vRetResult.remove(0);
	vLast2Year = (Vector)vRetResult.remove(0);
	vEndOfDate = (Vector)vRetResult.remove(0);
	strTodayWD = (String)vRetResult.remove(0);
	strRangeWD = (String)vRetResult.remove(0);
	vETEEAP = (Vector)vRetResult.remove(0);

	String strDateFrom = WI.fillTextValue("specific_date");	
	if(strDateFrom.length() == 0)	
		strDateFrom = WI.getTodaysDate(1);

%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myID3">
		<tr><td align="right"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a> 
			<font size="1">Click to print summary</font>		
		</td></tr>
		<td height="15">&nbsp;</td>
	</table>

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
			<tr><td align="center"><font size="2"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font><br>
				<font size="1">Enrollment Status Summary 
				<br> <strong><%=strConvertSem[Integer.parseInt(WI.fillTextValue("offering_sem"))]%> SY <%=WI.fillTextValue("sy_from")%>-<%=WI.fillTextValue("sy_to")%></strong> <br>
				As of <%=WI.formatDate(strDateFrom,6)%></font>
			</td></tr>	
			<tr><td height="15">&nbsp;</td></tr>			
  	</table>
	
<%

double dPercentage = 0d;
int iSubTotalCount = 0;
int iSubTotalLast2Year = 0;
int iSubTotalLastYear = 0;
int iSubTotalEndAll = 0;
int iSubTotalWithdraw = 0;
int iSubTotalEndNew = 0;
int iSubTotalEndOld = 0;
int iSubTotalTodayNew = 0;
int iSubTotalTodayOld = 0;
int iSubTotalRangeNew = 0;
int iSubTotalRangeOld = 0;
int iLast2Year = 0;
int iLastYear = 0;
int iEndTotal = 0;
int iEndOld = 0;
int iEndNew = 0;
int iSumWithdraw = 0;
String strTodayOld = null;
String strTodayNew = null;
String strRangeOld = null;
String strRangeNew = null;


int iTotalRangeNew = 0;
int iTotalRangeOld = 0;
int iTotalTodayNew = 0;
int iTotalTodayOld = 0;
String strWithdraw = null;
String strEndOld = null;
String strEndNew = null;
String strEndTotal  = null;

String strLastYear = null;
String strLast2Year = null;
int iCount = 0;
int iTotalCount = 0;



Calendar cal = Calendar.getInstance();				
DateFormat dateFormat = new SimpleDateFormat("MM/dd/yyyy");	
Date date = (Date)dateFormat.parse(strDateFrom);				
cal.setTime(date);
cal.add(cal.DATE,-1);		


int iTempSem1 = 0;
int iTempSem2 = 0;
int iTempYear1 = 0;
int iTempYear2 = 0;

int iYear = Integer.parseInt(WI.getStrValue(WI.fillTextValue("sy_from"),(String)request.getSession(false).getAttribute("cur_sch_yr_from")));
int iSemester = Integer.parseInt(WI.getStrValue(WI.fillTextValue("offering_sem"),(String)request.getSession(false).getAttribute("cur_sem")));

iTempYear1 = iYear - 1;
iTempSem1 = iSemester;	

if(iSemester == 1){		
	iTempYear2 = iTempYear1;		
	iTempSem2 = 2;
}
else if(iSemester == 2) {//2nd sem		
	iTempYear2 = iTempYear1;		
	iTempSem2 = 1;
}
else if(iSemester == 0) {//summer		
	iTempYear2 = iYear - 2;
	iTempSem2 = 0;
}

int iLineCount = 0;
int iCourseSize = 4;
int i =0;
boolean bolIsPageBreak = false;
int iIndexOf = 0;
String strCourse  = null;
String strAdvCourse = "";
boolean bolIsLastCount = false;

int iTemp = 0;

String strPrevCollege = "";
String strCurrCollege = null;
String strCourseIndex = null;
String strAdvCourseIndex = "";
while(iCourseSize <= vCourse.size()){
iLineCount = 0;

%>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
		<tr>
			<td width="" rowspan="2" align="center" class="thinborder"><font size="1">Course Code</font></td>
			<td colspan="2" align="center" class="thinborder">As of <%=dateFormat.format(cal.getTime())%></td>
			<td colspan="2" align="center" class="thinborder"><font size="1"><%=WI.formatDate(strDateFrom,2)%></font></td>
			<td colspan="4" align="center" class="thinborder"><font size="1">End of <%=WI.formatDate(strDateFrom,6)%></font></td>
			<td align="center" class="thinborder"><font size="1"><%=strConvertSem[iTempSem1]%></font></td>
			<td align="center" class="thinborder"><font size="1"><%=strConvertSem[iTempSem2]%></font></td>
			<td colspan="2" align="center" class="thinborder"><font size="1">
				<%=strConvertSem[Integer.parseInt(WI.fillTextValue("offering_sem"))]%> 
				<%=iYear%> O/(U)<%=strConvertSem[Integer.parseInt(WI.fillTextValue("offering_sem"))]%> 
				<%=iYear - 1%></font></td>
		</tr>
		
		<tr>			
			<td width="6%" height="23" align="center" class="thinborder"><font size="1">Old</font></td>
			<td width="6%"  align="center" class="thinborder"><font size="1">New</font></td>
			<td width="6%"  align="center" class="thinborder"><font size="1">Old</font></td>
			<td width="6%"  align="center" class="thinborder"><font size="1">New</font></td>
			
			<td width="6%"  align="center" class="thinborder"><font size="1">Old</font></td>
			<td width="6%"  align="center" class="thinborder"><font size="1">New</font></td>
			<td width="6%"  align="center" class="thinborder"><font size="1">W/D All</font></td>
			<td width="6%"  align="center" class="thinborder"><font size="1">Total</font></td>
			
			<td width="7%"  align="center" class="thinborder"><font size="1"><%=iTempYear1%></font></td>
			<td width="7%"  align="center" class="thinborder"><font size="1"><%=iTempYear2%></font></td>
			<td width="7%"  align="center" class="thinborder"><font size="1">Count</font></td>
			<td width="7%"  align="center" class="thinborder"><font size="1">Percentage</font></td>
		</tr>
		
		
		<%
			iLineCount+=2;
			
			for(; i < vCourse.size();){	
				strCourse = (String)vCourse.elementAt(i+2);
				strCourseIndex = (String)vCourse.elementAt(i+1);
				
				iCourseSize += 4;
				iIndexOf = strCourse.indexOf("ETEEAP");				
				if(iIndexOf > -1){
					iCourseSize += 4;
					i+=4;
					continue;
				}
				
				
				iIndexOf = i + 5;
				if(iIndexOf > vCourse.size()){}
				else
					strAdvCourseIndex = (String)vCourse.elementAt(iIndexOf);
					
				if(i + 4 >= vCourse.size())
					 bolIsLastCount = true;
				 else
					 bolIsLastCount = false;
			
				iIndexOf = vCollege.indexOf(vCourse.elementAt(i+1));
				strCurrCollege = ((String)vCollege.elementAt(iIndexOf+1)).toUpperCase();
				
			if(!strPrevCollege.equals(strCurrCollege)){
				strPrevCollege = strCurrCollege;
			%>
			
			<tr>
				
				<td align="center"><font size="1"><strong><%=strCurrCollege.substring(11)%></strong></font></td>
				<td align="left" colspan="2" class="thinborderLEFT">&nbsp;</td>
				<td align="left" colspan="2" class="thinborderLEFT">&nbsp;</td>
				<td align="left" colspan="4" class="thinborderLEFT">&nbsp;</td>
				<td align="left" colspan="0" class="thinborderLEFT">&nbsp;</td>
				<td align="left" colspan="0" class="thinborderLEFT">&nbsp;</td>
				<td align="left" colspan="2" class="thinborderLEFT">&nbsp;</td>					
			</tr>	
			<%}%>
			
			
			<tr>
			
				<td align="left"> <font size="1"><%=WI.getStrValue(strCourse)%><%=WI.getStrValue((String)vCourse.elementAt(i+3),"_","","")%></font></td>		
				
				<%
					/*iIndexOf = vDateRange.indexOf(vCourse.elementAt(i));					
					if(iIndexOf == -1) 
						strRangeNew = null;
					else{
						if(  ((String)vDateRange.elementAt(iIndexOf + 2)).equalsIgnoreCase("New")  ){
							strRangeNew = (String)vDateRange.elementAt(iIndexOf + 1);
							if(!bolIsLastCount){												
								vDateRange.remove(iIndexOf);vDateRange.remove(iIndexOf);vDateRange.remove(iIndexOf);
							}else{
								iIndexOf = iIndexOf + 3;
								if(iIndexOf > vDateRange.size()){}
								else{
									if((vCourse.elementAt(i)).equals(vDateRange.elementAt(iIndexOf))){								
										vDateRange.remove(iIndexOf);vDateRange.remove(iIndexOf);vDateRange.remove(iIndexOf);							
									}
								}
							}
							iTotalRangeNew += Integer.parseInt(WI.getStrValue(strRangeNew,"0"));
						}
					}
					
					iIndexOf = vDateRange.indexOf(vCourse.elementAt(i));					
					if(iIndexOf == -1)
						strRangeOld = null;				
					else{
						if(((String)vDateRange.elementAt(iIndexOf + 2)).equalsIgnoreCase("Old"))
							strRangeOld = (String)vDateRange.elementAt(iIndexOf + 1);	
							iTotalRangeOld += Integer.parseInt(WI.getStrValue(strRangeOld,"0"));	
						//	vDateRange.remove(iIndexOf);vDateRange.remove(iIndexOf);vDateRange.remove(iIndexOf);				
					}
					*/
					
					strRangeOld = null;
					strRangeNew = null;
					for(int x = 0; x < vDateRange.size(); x+=3){
						if(  ((String)vDateRange.elementAt(x)).equals((String)vCourse.elementAt(i))  ){
							if(((String)vDateRange.elementAt(x + 2)).equalsIgnoreCase("Old"))
								strRangeOld = (String)vDateRange.elementAt(x + 1);	
							else
								strRangeNew = (String)vDateRange.elementAt(x + 1);
							
							vDateRange.remove(x);vDateRange.remove(x);vDateRange.remove(x);
							x-=3;
						}						
					}
					
					iTotalRangeOld += Integer.parseInt(WI.getStrValue(strRangeOld,"0"));
					iTotalRangeNew += Integer.parseInt(WI.getStrValue(strRangeNew,"0"));
					
				%>	
				
				<td align="Right" class="thinborderLEFT"><font size="1"><%=WI.getStrValue(strRangeOld,"-")%></font></td>				
				<td align="Right"><font size="1"><%=WI.getStrValue(strRangeNew,"-")%></font></td>
					
				<%
					/*iIndexOf = vTodaysResult.indexOf(vCourse.elementAt(i));
					if(iIndexOf == -1) 
						strTodayNew = null;
					else{
						if(((String)vTodaysResult.elementAt(iIndexOf + 2)).equalsIgnoreCase("New")){
							strTodayNew = (String)vTodaysResult.elementAt(iIndexOf + 1);
							if(!bolIsLastCount){												
								vTodaysResult.remove(iIndexOf);vTodaysResult.remove(iIndexOf);vTodaysResult.remove(iIndexOf);
							}else{				
								iIndexOf = iIndexOf + 3;
								if(iIndexOf > vTodaysResult.size()){}
								else{
									if((vCourse.elementAt(i)).equals(vTodaysResult.elementAt(iIndexOf))){								
										vTodaysResult.remove(iIndexOf);vTodaysResult.remove(iIndexOf);vTodaysResult.remove(iIndexOf);							
									}
								}
							}
							iTotalTodayNew += Integer.parseInt(WI.getStrValue(strTodayNew,"0"));
						}
					}
					
					iIndexOf = vTodaysResult.indexOf(vCourse.elementAt(i));
					if(iIndexOf == -1)
						strTodayOld = null;				
					else{
						if(((String)vTodaysResult.elementAt(iIndexOf + 2)).equalsIgnoreCase("Old"))
							strTodayOld = (String)vTodaysResult.elementAt(iIndexOf + 1);		
							iTotalTodayOld += Integer.parseInt(WI.getStrValue(strTodayOld,"0"));
						//	vTodaysResult.remove(iIndexOf);vTodaysResult.remove(iIndexOf);vTodaysResult.remove(iIndexOf);
					}*/
					
					strTodayOld = null;
					strTodayNew = null;
					for(int x = 0; x < vTodaysResult.size(); x+=3){
						if(  ((String)vTodaysResult.elementAt(x)).equals((String)vCourse.elementAt(i))  ){
							if(((String)vTodaysResult.elementAt(x + 2)).equalsIgnoreCase("Old"))
								strTodayOld = (String)vTodaysResult.elementAt(x + 1);	
							else
								strTodayNew = (String)vTodaysResult.elementAt(x + 1);
							
							vTodaysResult.remove(x);vTodaysResult.remove(x);vTodaysResult.remove(x);
							x-=3;
						}						
					}
					
					iTotalTodayOld += Integer.parseInt(WI.getStrValue(strTodayOld,"0"));
					iTotalTodayNew += Integer.parseInt(WI.getStrValue(strTodayNew,"0"));
					
				%>
																	
				<td align="Right" class="thinborderLEFT"><font size="1"><font size="1"></font><%=WI.getStrValue(strTodayOld,"-")%></font></td>	
				<td align="Right"><font size="1"><%=WI.getStrValue(strTodayNew,"-")%></font></td>
				
				<%
				iIndexOf = vEndOfDate.indexOf(vCourse.elementAt(i));
				if(iIndexOf == -1)
					strWithdraw = null;
				else
					strWithdraw = (String)vEndOfDate.elementAt(iIndexOf+1);
				
				
				iSumWithdraw += Integer.parseInt(WI.getStrValue(strWithdraw,"0"));
				
				iEndOld = Integer.parseInt(WI.getStrValue(strTodayOld,"0")) + Integer.parseInt(WI.getStrValue(strRangeOld,"0"));
				iEndNew = Integer.parseInt(WI.getStrValue(strTodayNew,"0")) + Integer.parseInt(WI.getStrValue(strRangeNew,"0"));
				
				strEndOld = Integer.toString(iEndOld);
				if(iEndOld == 0)
					strEndOld = null;
					
				strEndNew = Integer.toString(iEndNew);
				if(iEndNew == 0)
					strEndNew = null;
					
				iEndTotal = ( iEndOld + iEndNew ) - Integer.parseInt(WI.getStrValue(strWithdraw,"0"));
				if(iEndTotal == 0)
					strEndTotal = null;
				else
					strEndTotal = Integer.toString(iEndTotal);
				
				%>
							
				<td align="Right" class="thinborderLEFT"><font size="1"><%=WI.getStrValue(strEndOld,"-")%></font></td>
				<td align="Right"><font size="1"><%=WI.getStrValue(strEndNew,"-")%></font></td>
				<td align="Right"><font size="1"><%=WI.getStrValue(strWithdraw,"-")%></font></td>
				<td align="Right"><font size="1"><%=WI.getStrValue(strEndTotal,"-")%></font></td>	
				
				<%
				iIndexOf = vLastYear.indexOf(vCourse.elementAt(i));
				if(iIndexOf == -1)
					strLastYear = null;
				else
					strLastYear = (String)vLastYear.elementAt(iIndexOf + 1);		
					
				iLastYear += Integer.parseInt(WI.getStrValue(strLastYear,"0"));
				%>
				
				<td align="Right" class="thinborderLEFT"><font size="1"><%=WI.getStrValue(strLastYear,"-")%></font></td>	
				<%
				iIndexOf = vLast2Year.indexOf(vCourse.elementAt(i));
				if(iIndexOf == -1)
					strLast2Year = null;
				else
					strLast2Year = (String)vLast2Year.elementAt(iIndexOf + 1);		
					
				iLast2Year += Integer.parseInt(WI.getStrValue(strLast2Year,"0"));		
				%>			
				<td align="Right" class="thinborderLEFT"><font size="1"><%=WI.getStrValue(strLast2Year,"-")%></font></td>		
				
				<%
					iCount = iEndTotal - Integer.parseInt(WI.getStrValue(strLastYear,"0"));
					if(iCount < 0)
						strTemp = WI.getStrValue((Integer.toString(iCount)).substring(1),"(",")","-");
					else if (iCount == 0)
						strTemp = "-";
					else
						strTemp = WI.getStrValue(Integer.toString(iCount),"-");
						
					iTotalCount += iCount;
				%>		
				<td align="Right" class="thinborderLEFT"><font size="1"><%=strTemp%></font></td>
				<%				
				dPercentage = 0d;
				if(iCount != 0 && Integer.parseInt(WI.getStrValue(strLastYear,"0")) != 0)					
					dPercentage = (Double.parseDouble(Integer.toString(iCount))/Double.parseDouble(strLastYear)) * 100;
				else
					dPercentage = 100d;
					
					strTemp = CommonUtil.formatFloat(Math.ceil((dPercentage)),1);
					strTemp = strTemp.substring(0,strTemp.length()-2);
					strTemp = WI.getStrValue(strTemp,"","%","");
				%>
				<td align="Right"><font size="1"><%=strTemp%></font></td>	
			</tr>	
			
			<%
			if(!strAdvCourseIndex.equals(strCourseIndex) || i + 4 >= vCourse.size() ){			
			%>
		
			<tr>
				<%
				iIndexOf = vCollege.indexOf((String)vCourse.elementAt(i+1));
				%>
			
				<td align="right"><font size="1"><strong>Total <%=(String)vCollege.elementAt(iIndexOf+2)%></strong></font></td>	
				<%
				strTemp = Integer.toString(iTotalRangeOld);
				if(iTotalRangeOld == 0)
					strTemp = null;
				iSubTotalRangeOld += iTotalRangeOld;		
				%>
				<td align="Right" class="thinborderTOPLEFTBOTTOM"><font size="1"><strong><%=WI.getStrValue(strTemp,"-")%></strong></font></td>
				<%
				strTemp = Integer.toString(iTotalRangeNew);
				if(iTotalRangeNew == 0)
					strTemp = null;
				iSubTotalRangeNew += iTotalRangeNew;		
				%>							
				<td align="Right" class="thinborderTOPBOTTOM"><font size="1"><strong><%=WI.getStrValue(strTemp,"-")%></strong></font></td>		
				<%
				strTemp = Integer.toString(iTotalTodayOld);
				if(iTotalTodayOld == 0)
					strTemp = null;
				iSubTotalTodayOld += iTotalTodayOld;		
				%>		
				<td align="Right" class="thinborderTOPLEFTBOTTOM"><font size="1"><strong><%=WI.getStrValue(strTemp,"-")%></strong></font></td>	
				<%
				strTemp = Integer.toString(iTotalTodayNew);
				if(iTotalTodayNew == 0)
					strTemp = null;
				iSubTotalTodayNew += iTotalTodayNew;		
				%>					
				<td align="Right" class="thinborderTOPBOTTOM"><font size="1"><strong><%=WI.getStrValue(strTemp,"-")%></strong></font></td>					
				<%
				int iSumEndOld = iTotalRangeOld + iTotalTodayOld;
				if(iSumEndOld == 0)
					strTemp = null;
				else
					strTemp = Integer.toString(iSumEndOld);			
				iSubTotalEndOld += iSumEndOld;
				%>						
				<td align="Right" class="thinborderTOPLEFTBOTTOM"><font size="1"><strong><%=WI.getStrValue(strTemp,"-")%></strong></font></td>
				<%
				int iSumEndNew = iTotalRangeNew+iTotalTodayNew;
				if(iSumEndNew == 0)
					strTemp = null;
				else
					strTemp = Integer.toString(iSumEndNew);
				iSubTotalEndNew += iSumEndNew;
				%>				
				<td align="Right" class="thinborderTOPBOTTOM"><font size="1"><strong><%=WI.getStrValue(strTemp,"-")%></strong></font></td>
				<%				
				strTemp = Integer.toString(iSumWithdraw);
				if(strTemp.equals("0"))	
					strTemp = null;
				iSubTotalWithdraw += iSumWithdraw;
				%>
				<td align="Right" class="thinborderTOPBOTTOM"><font size="1"><strong><%=WI.getStrValue(strTemp,"-")%></strong></font></td>	
				<%				
				iSumEndOld =  ( iSumEndOld + iSumEndNew ) - iSumWithdraw;
				if(iSumEndOld == 0)
					strTemp = null;
				else
					strTemp = Integer.toString(iSumEndOld);
				iSubTotalEndAll += iSumEndOld;
				%>			
				<td align="Right" class="thinborderTOPBOTTOM"><font size="1"><strong><%=WI.getStrValue(strTemp,"-")%></strong></font></td>
				
				<%
				if(iLastYear == 0)
					strTemp = null;
				else
					strTemp = Integer.toString(iLastYear);
				iSubTotalLastYear += iLastYear;
				%>
				
				<td align="Right" class="thinborderTOPLEFTBOTTOM"><font size="1"><strong><%=WI.getStrValue(strTemp,"-")%></strong></font></td>		
				<%
				if(iLast2Year == 0)
					strTemp = null;
				else
					strTemp = Integer.toString(iLast2Year);
				iSubTotalLast2Year += iLast2Year;
				%>		
				<td align="Right" class="thinborderTOPLEFTBOTTOM"><font size="1"><strong><%=WI.getStrValue(strTemp,"-")%></strong></font></td>
				<%
				strTemp = Integer.toString(iTotalCount);
				if(iTotalCount == 0)
					strTemp = null;
				if(iTotalCount < 0){
					if(strTemp.indexOf("-")==0)
						strTemp = strTemp.substring(1);
					strTemp = WI.getStrValue(strTemp, "(", ")", "");
				}
					
				iSubTotalCount += iTotalCount;
				%>
				<td align="Right" class="thinborderTOPLEFTBOTTOM"><font size="1"><strong><%=WI.getStrValue(strTemp,"")%></strong></font></td>
				<%
				dPercentage = 0d;
				if(iTotalCount != 0 && iLastYear != 0)					
					dPercentage = (Double.parseDouble(Integer.toString(iTotalCount))/Double.parseDouble(Integer.toString(iLastYear))) * 100;
				else
					dPercentage = 100d;
					
					strTemp = CommonUtil.formatFloat(Math.ceil((dPercentage)),1);
					strTemp = strTemp.substring(0,strTemp.length()-2);
					strTemp = WI.getStrValue(strTemp,"","%","");
				%>
				<td align="Right" class="thinborderTOPBOTTOM"><font size="1"><strong><%=strTemp%></strong></font></td>
			</tr>
			<%			
				iTotalRangeOld = 0;
				iTotalRangeNew = 0;
				iTotalTodayOld = 0;
				iTotalTodayNew = 0;
				iSumEndOld = 0;
				iSumEndNew = 0;
				iSumWithdraw = 0;
				iLastYear = 0;
				iLast2Year = 0;
				iTotalCount = 0;
			}%>
			
			
		<%
		 i+=4;
		
		}//end vCourse Loop%>
		
		
		<tr>
			<td align="right"><font size="1"><strong>Total ETEEAP</strong></font></td>			
			<%
			iTemp = Integer.parseInt(WI.getStrValue((String)vETEEAP.elementAt(0),"0"));
			iSubTotalRangeOld += iTemp;
			
			strTemp = Integer.toString(iTemp);
			if(iTemp == 0)
				strTemp = "-";
			%>
			<td align="right" class="thinborder"><font size="1"><strong><%=strTemp%></strong></font></td>			
			<%
			iTemp = Integer.parseInt(WI.getStrValue((String)vETEEAP.elementAt(1),"0"));
			iSubTotalRangeNew += iTemp;
			
			strTemp = Integer.toString(iTemp);
			if(iTemp == 0)
				strTemp = "-";
			%>
			<td align="right" class="thinborderBOTTOM"><font size="1"><strong><%=strTemp%></strong></font></td>			
			<%
			iTemp = Integer.parseInt(WI.getStrValue((String)vETEEAP.elementAt(2),"0"));
			iSubTotalTodayOld += iTemp;
			
			strTemp = Integer.toString(iTemp);
			if(iTemp == 0)
				strTemp = "-";
			%>					
			<td align="right" class="thinborder"><font size="1"><strong><%=strTemp%></strong></font></td>			
			<%
			iTemp = Integer.parseInt(WI.getStrValue((String)vETEEAP.elementAt(3),"0"));
			iSubTotalTodayNew += iTemp;
			
			strTemp = Integer.toString(iTemp);
			if(iTemp == 0)
				strTemp = "-";
			%>
			<td align="right" class="thinborderBOTTOM"><font size="1"><strong><%=strTemp%></strong></font></td>	
			
			<%
			iTemp = Integer.parseInt(WI.getStrValue((String)vETEEAP.elementAt(4),"0"));
			iSubTotalEndOld += iTemp;
			
			strTemp = Integer.toString(iTemp);
			if(iTemp == 0)
				strTemp = "-";
			%>		
			<td align="right" class="thinborder"><font size="1"><strong><%=strTemp%></strong></font></td>	
			
			<%
			iTemp = Integer.parseInt(WI.getStrValue((String)vETEEAP.elementAt(5),"0"));
			iSubTotalEndNew += iTemp;
			
			strTemp = Integer.toString(iTemp);
			if(iTemp == 0)
				strTemp = "-";
			%>
			<td align="right" class="thinborderBOTTOM"><font size="1"><strong><%=strTemp%></strong></font></td>
			
			<%
			iTemp = Integer.parseInt(WI.getStrValue((String)vETEEAP.elementAt(6),"0"));
			iSubTotalWithdraw += iTemp;
			
			strTemp = Integer.toString(iTemp);
			if(iTemp == 0)
				strTemp = "-";
			%>
						
			<td align="right" class="thinborderBOTTOM"><font size="1"><strong><%=strTemp%></strong></font></td>
			<%
			iTemp = Integer.parseInt(WI.getStrValue((String)vETEEAP.elementAt(7),"0"));
			iSubTotalEndAll += iTemp;
			
			strTemp = Integer.toString(iTemp);
			if(iTemp == 0)
				strTemp = "-";			
			%>			
			<td align="right" class="thinborderBOTTOM"><font size="1"><strong><%=strTemp%></strong></font></td>
			<%
			iTemp = Integer.parseInt(WI.getStrValue((String)vETEEAP.elementAt(8),"0"));
			iSubTotalLastYear += iTemp;
			
			strTemp = Integer.toString(iTemp);
			if(iTemp == 0)
				strTemp = "-";			
			%>
			<td align="right" class="thinborder"><font size="1"><strong><%=strTemp%></strong></font></td>
			<%
			iTemp = Integer.parseInt(WI.getStrValue((String)vETEEAP.elementAt(9),"0"));
			iSubTotalLast2Year += iTemp;
			
			strTemp = Integer.toString(iTemp);
			if(iTemp == 0)
				strTemp = "-";			
			%>
			<td align="right" class="thinborder"><font size="1"><strong><%=strTemp%></strong></font></td>		
			<%
			iTemp = Integer.parseInt(WI.getStrValue((String)vETEEAP.elementAt(10),"0"));
			iSubTotalCount += iTemp;
			strTemp = Integer.toString(iTemp);
			if(iTemp < 0){
				if(strTemp.indexOf("-")==0)
					strTemp = strTemp.substring(1);
				strTemp = WI.getStrValue(strTemp, "(", ")", "");
				//strTemp = WI.getStrValue(strTemp,"(",")","");			
			}
			%>
			<td align="right" class="thinborder"><font size="1"><strong><%=WI.getStrValue(strTemp,"")%></strong></font></td>						
			<td align="right" class="thinborderBOTTOM"><font size="1"><strong><%=WI.getStrValue((String)vETEEAP.elementAt(11),"-")%></strong></font></td>
		</tr>
		
		
		<tr>
			<td width="">&nbsp;</td>
			<%
				strTemp = Integer.toString(iSubTotalRangeOld);
				if(iSubTotalRangeOld == 0)
					strTemp = null;
			%>
			<td align="Right" width="5%" class="thinborder"><strong><font size="1"><%=WI.getStrValue(strTemp,"-")%></font></strong></td>	
			<%
				strTemp = Integer.toString(iSubTotalRangeNew);
				if(iSubTotalRangeNew == 0)
					strTemp = null;
			%>
			<td align="Right" width="5%" class="thinborderBOTTOM"><strong><font size="1"><%=WI.getStrValue(strTemp,"-")%></font></strong></td>			
			<%
				strTemp = Integer.toString(iSubTotalTodayOld);
				if(iSubTotalTodayOld == 0)
					strTemp = null;
			%>
			<td align="Right" width="5%" class="thinborder"><strong><font size="1"><%=WI.getStrValue(strTemp,"-")%></font></strong></td>		
			<%
				strTemp = Integer.toString(iSubTotalTodayNew);
				if(iSubTotalTodayNew == 0)
					strTemp = null;
			%>
			<td align="Right" width="5%" class="thinborderBOTTOM"><strong><font size="1"><%=WI.getStrValue(strTemp,"-")%></font></strong></td>
			<%
				strTemp = Integer.toString(iSubTotalEndOld);
				if(iSubTotalEndOld == 0)
					strTemp = null;
			%>
			<td align="Right" width="5%" class="thinborder"><strong><font size="1"><%=WI.getStrValue(strTemp,"-")%></font></strong></td>
			<%
				strTemp = Integer.toString(iSubTotalEndNew);
				if(iSubTotalEndNew == 0)
					strTemp = null;
			%>
			<td align="Right" width="5%" class="thinborderBOTTOM"><strong><font size="1"><%=WI.getStrValue(strTemp,"-")%></font></strong></td>
			<%
				strTemp = Integer.toString(iSubTotalWithdraw);
				if(iSubTotalWithdraw == 0)
					strTemp = null;
			%>
			<td align="Right" width="5%" class="thinborderBOTTOM"><strong><font size="1"><%=WI.getStrValue(strTemp,"-")%></font></strong></td>
			<%
				strTemp = Integer.toString(iSubTotalEndAll);
				if(iSubTotalEndAll == 0)
					strTemp = null;
			%>
			<td align="Right" width="5%" class="thinborderBOTTOM"><strong><font size="1"><%=WI.getStrValue(strTemp,"-")%></font></strong></td>
			<%
				strTemp = Integer.toString(iSubTotalLastYear);
				if(iSubTotalLastYear == 0)
					strTemp = null;
			%>
			<td align="Right" width="5%" class="thinborder"><strong><font size="1"><%=WI.getStrValue(strTemp,"-")%></font></strong></td>
			<%
				strTemp = Integer.toString(iSubTotalLast2Year);
				if(iSubTotalLast2Year == 0)
					strTemp = null;
			%>
			<td align="Right" width="5%" class="thinborder"><strong><font size="1"><%=WI.getStrValue(strTemp,"-")%></font></strong></td>
			<%
				strTemp = Integer.toString(iSubTotalCount);
				if(iSubTotalCount == 0)					
					strTemp = null;
				
				if(iSubTotalCount < 0 ){
					if(strTemp.indexOf("-") == 0)
						strTemp = strTemp.substring(1);
					strTemp = WI.getStrValue(strTemp, "(", ")", "-");
				}				
			%>
			<td align="Right" width="5%" class="thinborder"><strong><font size="1"><%=WI.getStrValue(strTemp,"-")%></font></strong></td>
			<%
			dPercentage = 0d;
			if(iSubTotalCount != 0 && iSubTotalLastYear != 0)					
				dPercentage = (Double.parseDouble(Integer.toString(iSubTotalCount))/Double.parseDouble(Integer.toString(iSubTotalLastYear))) * 100;
			else
				dPercentage = 100d;
				
				strTemp = CommonUtil.formatFloat(Math.ceil((dPercentage)),1);
				strTemp = strTemp.substring(0,strTemp.length()-2);
				strTemp = WI.getStrValue(strTemp,"","%","");
			%>
			<td align="Right" width="5%" class="thinborderBOTTOM"><strong><font size="1"><%=WI.getStrValue(strTemp,"-")%></font></strong></td>
		</tr>
		
		<%
		int iGrandRangeTotal = (iSubTotalRangeOld + iSubTotalRangeNew) - Integer.parseInt(WI.getStrValue(strRangeWD,"0"));
		int iGrandTodayTotal = (iSubTotalTodayOld + iSubTotalTodayNew) - Integer.parseInt(WI.getStrValue(strTodayWD,"0"));
		int iTotal = iGrandRangeTotal +  iGrandTodayTotal;
		%>
		<tr>
			<td>&nbsp;</td>			
			<td class="thinborder"><font size="1"><strong>Withdraw</strong></font></td>
			<td class="thinborder" align="right"><font size="1"><strong><%=WI.getStrValue(strRangeWD,"-")%></strong></font></td>			
			<td class="thinborder"><font size="1"><strong>Withdraw</strong></font></td>
			<td class="thinborder" align="right"><font size="1"><strong><%=WI.getStrValue(strTodayWD,"-")%></strong></font></td>			
			<td class="thinborder" rowspan="2" colspan="4" align="center" valign="bottom"><strong><%=iTotal%></strong></td>	
			<td colspan="4" align="center" valign="bottom" class="thinborder">&nbsp;</td>	
		</tr>
		<tr>
			<td align="right"><font size="1"><strong>GRAND TOTAL</strong></font> &nbsp; &nbsp; &nbsp;</td>
			<td class="thinborder" align="center" colspan="2"><strong><%=iGrandRangeTotal%></strong></td>
			<td class="thinborder" align="center" colspan="2"><strong><%=iGrandTodayTotal%></strong></td>		
			<td class="thinborder" align="center">SY</td>
			<td class="thinborder" align="center">Freshmen</td>
			<td class="thinborder" align="center">Transferee</td>
			<td class="thinborder" align="center">Total</td>
		</tr>
		
		
		<%
		
		
		
		//this is for the current year transferee
		strTemp = " select count(*) from stud_curriculum_hist "+
			" join user_status on (user_status.status_index = stud_curriculum_hist.status_index) "+
			" where stud_curriculum_hist.is_valid = 1 "+
			" and sy_from = "+iYear+
			" and exists (select * from enrl_final_cur_list "+
			" 	where is_valid = 1 and is_temp_stud=0 and sy_from = stud_curriculum_hist.sy_from and "+
			" 	current_semester = stud_curriculum_hist.semester and user_index = stud_curriculum_hist.user_index) "+
			//" and course_index > 0 and status = 'Transferee' and new_stat = 'New' "+
			" and course_index > 0 and stud_curriculum_hist.status_index = 4 "+
			" and date_enrolled is not null ";
		String strTransCurrYear = dbOP.getResultOfAQuery(strTemp,0);
			
		//this is for the current year freshmen
		strTemp = " select count(*) from stud_curriculum_hist "+
			" join user_status on (user_status.status_index = stud_curriculum_hist.status_index) "+
			" where stud_curriculum_hist.is_valid = 1 "+
			" and sy_from = "+iYear+
			" and exists (select * from enrl_final_cur_list "+
			" 	where is_valid = 1 and is_temp_stud=0 and sy_from = stud_curriculum_hist.sy_from and "+
			" 	current_semester = stud_curriculum_hist.semester and user_index = stud_curriculum_hist.user_index) "+
			//" and course_index > 0 and status <> 'Transferee' and new_stat = 'New' "+
			" and course_index > 0 and stud_curriculum_hist.status_index = 2 "+
			" and date_enrolled is not null ";	
		String strFreshCurrYear = dbOP.getResultOfAQuery(strTemp,0);
		
		int iPrevYear = iYear - 1;
		
		//this is for the current year transferee
		strTemp = " select count(*) from stud_curriculum_hist "+
			" join user_status on (user_status.status_index = stud_curriculum_hist.status_index) "+
			" where stud_curriculum_hist.is_valid = 1 "+
			" and sy_from = "+iPrevYear+
			" and exists (select * from enrl_final_cur_list "+
			" 	where is_valid = 1 and is_temp_stud=0 and sy_from = stud_curriculum_hist.sy_from and "+
			" 	current_semester = stud_curriculum_hist.semester and user_index = stud_curriculum_hist.user_index) "+
			//" and course_index > 0 and status = 'Transferee' and new_stat = 'New' "+
			" and course_index > 0 and stud_curriculum_hist.status_index = 4 "+
			" and date_enrolled is not null ";
		String strTransPrevYear = dbOP.getResultOfAQuery(strTemp,0);
			
		//this is for the current year freshmen
		strTemp = " select count(*) from stud_curriculum_hist "+
			" join user_status on (user_status.status_index = stud_curriculum_hist.status_index) "+
			" where stud_curriculum_hist.is_valid = 1 "+
			" and sy_from = "+iPrevYear+
			" and exists (select * from enrl_final_cur_list "+
			" 	where is_valid = 1 and is_temp_stud=0 and sy_from = stud_curriculum_hist.sy_from and "+
			" 	current_semester = stud_curriculum_hist.semester and user_index = stud_curriculum_hist.user_index) "+
			//" and course_index > 0 and status <> 'Transferee' and new_stat = 'New' "+
			" and course_index > 0 and stud_curriculum_hist.status_index = 2 "+
			" and date_enrolled is not null ";	
		String strFreshPrevYear = dbOP.getResultOfAQuery(strTemp,0);
		
		%>
		
		<tr>
			<td colspan="9" align="right">&nbsp;</td>
			<td class="thinborder" align="center"><%=iPrevYear%>-<%=iPrevYear+1%></td>
			<td class="thinborder" align="center"><%=strFreshPrevYear%></td>
			<td class="thinborder" align="center"><%=strTransPrevYear%></td>
			<td class="thinborder" align="center"><%=Integer.parseInt(strTransPrevYear)+Integer.parseInt(strFreshPrevYear)%></td>			
		</tr>
		<tr>
			<td colspan="9" align="right">&nbsp;</td>
			<td class="thinborder" align="center"><%=iYear%>-<%=iYear+1%></td>
			<td class="thinborder" align="center"><%=strFreshCurrYear%></td>
			<td class="thinborder" align="center"><%=strTransCurrYear%></td>
			<td class="thinborder" align="center"><%=Integer.parseInt(strFreshCurrYear)+Integer.parseInt(strTransCurrYear)%></td>
			
		</tr>
		</table>


		
		
<%}//end while



}//end vRetResult%>
	
	
	
  
  
  

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myID4">
<tr><td height="25">&nbsp;</td></tr>
<tr bgcolor="#B8CDD1"><td height="25" bgcolor="#A49A6A">&nbsp;</td></tr>
  </table>

<input type="hidden" name="reloadPage">
</form>


<!--- Processing Div --->

<div id="processing" style="position:absolute; top:100px; left:250px; width:400px; height:125px;  visibility:hidden">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center>
      <tr>
            <td align="center" class="v10blancong">
			<p style="font-size:16px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif"> Processing Request. Please wait ...... </p>
			
			<img src="../../../Ajax/ajax-loader_big_black.gif"></td>
      </tr>
</table>
</div>

</body>
</html>
<%
dbOP.cleanUP();
%>