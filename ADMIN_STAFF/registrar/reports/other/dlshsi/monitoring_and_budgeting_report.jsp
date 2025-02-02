<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }


</style>
</head>

<script language="JavaScript" src="../../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../../jscript/date-picker.js"></script>
<script language="javascript">
function ShowReport(){
	document.form_.show_report.value = "1";
	document.form_.submit();
}

function PrintPage(){
	
	if(!confirm("Click OK to print Page."))
		return;

	document.bgColor = "#FFFFFF";

	document.getElementById("myADTable1").deleteRow(0);
	document.getElementById("myADTable1").deleteRow(0);
	
	document.getElementById("myADTable5").deleteRow(0);
	document.getElementById("myADTable5").deleteRow(0);
	document.getElementById("myADTable5").deleteRow(0);
	
	document.getElementById("myADTable2").deleteRow(0);
	
	document.getElementById("myADTable4").deleteRow(0);
	document.getElementById("myADTable4").deleteRow(0);

	window.print();

}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
		
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORTS","expected_enrollee_per_course_and_year.jsp");
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
/**
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","REPORTS",request.getRemoteAddr(),
														"expected_enrollee_per_course_and_year.jsp");
**/
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","REPORTS",request.getRemoteAddr(), null);	

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.


int iElemCount =0 ;
Vector vRetResult = null;
enrollment.ReportRegistrar rprtReg = new enrollment.ReportRegistrar();
if(WI.fillTextValue("show_report").length() > 0){	
	vRetResult = rprtReg.getEnrlRegularityStat(dbOP, request);	
	if(vRetResult == null)
		strErrMsg = rprtReg.getErrMsg();
}
%>
<form name="form_" action="monitoring_and_budgeting_report.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable1">
<tr bgcolor="#A49A6A">
	<td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
		MONITORING AND BUDGETING REPORT PAGE ::::</strong></font></div></td>
</tr>   
<tr><td height="25">&nbsp; &nbsp; &nbsp; &nbsp; <font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td></tr>    
</table>



<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable5">
<tr> 
      <td height="25" width="3%">&nbsp;</td>
      <td height="25" width="18%">SY-Term</td>
      <td colspan="2"> 
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");	  
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="DisplaySYTo('form_','sy_from','sy_to');">
        to 
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");	  
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly>        
	&nbsp;
	<select name="semester">
	<%=CommonUtil.constructTermList(dbOP, request, WI.fillTextValue("semester"))%>        
	</select> </td>      
    </tr>
	
	

<tr> 
      <td height="25" width="3%">&nbsp;</td>
      <td height="25" width="18%">As of Date</td>
      <td colspan="2">
	  <input name="as_of_date" type="text" size="10" maxlength="10" readonly="yes" value="<%=WI.fillTextValue("as_of_date")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
          <a href="javascript:show_calendar('form_.as_of_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../../images/calendar_new.gif" border="0"></a>
		  to
		  <input name="as_of_date_to" type="text" size="10" maxlength="10" readonly="yes" value="<%=WI.fillTextValue("as_of_date_to")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
          <a href="javascript:show_calendar('form_.as_of_date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../../images/calendar_new.gif" border="0"></a>		
	  </td>      
    </tr>

</tr>
<tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td colspan="2"><a href="javascript:ShowReport();"><img src="../../../../../images/refresh.gif" border="0" align="absmiddle"></a></td>
</tr>
</table>

<%

if(vRetResult != null && vRetResult.size() > 0){

String[] astrConvertTerm = {"Summer","First Semester","Second Semester","Third Semester","Fourth Semester","",""};
String[] astrYearLevel   = {"","FIRST","SECOND", "THIRD", "FOURTH","FIFTH","SIXTH", "SEVENTH"};
String[] astrYearLevel2   = {"","1st Year","2nd Year", "3rd Year", "4th Year","5th Year","6th Year", "7th Year"};




Vector vYearLevelGTotal = (Vector)vRetResult.remove(0);
Vector vRegularityTotal = (Vector)vRetResult.remove(0);  
Vector vYearLevelTotal  = (Vector)vRetResult.remove(0);
Vector vCourseList  = (Vector)vRetResult.remove(0);
int iGrandTotal = Integer.parseInt((String)vRetResult.remove(0));
int iMaxYearLevel = Integer.parseInt((String)vRetResult.remove(0));
int iYear = 0;
int iIndexOf = 0;

%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
	<tr>
	    <td align="right" colspan="2">
		<a href="javascript:PrintPage();"><img src="../../../../../images/print.gif" border="0"></a>
		<font size="1">Click to print report</font>		</td>
	 </tr>
	 <tr>	
      <td width="9%"><img src="../../../../../images/logo/<%=strSchCode%>.gif" border="0" height="70" width="70" align="absmiddle"></td>
      <td width="91%"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%></td>
    </tr>
	 <tr>
	     <td colspan="2">ACTUAL ENROLLES<br>
			<%=astrConvertTerm[Integer.parseInt(request.getParameter("semester"))]%>, School Year <%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%><br>
			<%
			strTemp = WI.fillTextValue("as_of_date");
			strErrMsg = WI.fillTextValue("as_of_date_to");
			if(strTemp.length() > 0)
				strTemp = "AS OF "+strTemp;
			if(strTemp.length() > 0 && strErrMsg.length() > 0)
				strTemp += " to "+strErrMsg;
			%> <%=strTemp%>
		 </td>
     </tr>
	 <tr><td colspan="2">&nbsp;</td></tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr style="font-weight:bold">
		<td height="22" align="center" class="thinborder">YEAR LEVEL</td>
		<%for(int i =0 ; i < vCourseList.size(); i += 2){%>
		<td align="center" width="5%" class="thinborder"><%=vCourseList.elementAt(i)%></td>
		<%}%>
		<td align="center" width="7%" class="thinborder">GRAND TOTAL</td>
	</tr>
	
<%for(iYear = 1; iYear <= iMaxYearLevel; ++iYear){
	if(iYear > 1){
%>	
	<tr style="font-weight:bold">
	    <td height="22" class="thinborder">TOTAL (<%=astrYearLevel2[iYear - 1]%>)</td>
	    <%for(int i =0 ; i < vCourseList.size(); i += 2){
		
		strTemp = "0";
		iIndexOf = vYearLevelTotal.indexOf((String)vCourseList.elementAt(i)+"_"+(iYear - 1));
		if(iIndexOf > -1)
			strTemp = (String)vYearLevelTotal.elementAt(iIndexOf + 1);
		%>
		<td align="center" width="5%" class="thinborder"><%=WI.getStrValue(strTemp,"0")%></td>
		<%}
		
		strTemp = "0";
		iIndexOf = vYearLevelGTotal.indexOf("YEAR_GT_"+(iYear - 1));
		if(iIndexOf > -1)
			strTemp = (String)vYearLevelGTotal.elementAt(iIndexOf + 1);
		%>
	    <td align="center" class="thinborder"><%=WI.getStrValue(strTemp,"0")%></td>
	</tr>
<%}%>
	<tr>
	    <td height="22" class="thinborder"><%=astrYearLevel[iYear]%></td>
	    <%for(int i =0 ; i < vCourseList.size(); i += 2){%>
		<td align="center" width="5%" class="thinborder">&nbsp;</td>
		<%}%>
	    <td align="center" class="thinborder">&nbsp;</td>
	</tr>
	
	
	
	<tr>
	    <td style="padding-left:30px;" height="22" class="thinborder">REGULAR</td>
	    <%for(int i =0 ; i < vCourseList.size(); i += 2){
		strTemp = "&nbsp;";
		iIndexOf = vRetResult.indexOf((String)vCourseList.elementAt(i)+"_0_"+iYear);
		if(iIndexOf > -1)
			strTemp = (String)vRetResult.elementAt(iIndexOf + 4);
		%>
		<td align="center" width="5%" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<%}
		strTemp = "0";
		iIndexOf = vRegularityTotal.indexOf("REG_TOTAL_0_"+iYear);
		if(iIndexOf > -1)
			strTemp = (String)vRegularityTotal.elementAt(iIndexOf + 1);
		%>
	    <td align="center" class="thinborder"><%=WI.getStrValue(strTemp,"0")%></td>
	</tr>
	<tr>
	    <td style="padding-left:30px;" height="22" class="thinborder">IRREGULAR</td>
	    <%for(int i =0 ; i < vCourseList.size(); i += 2){
		strTemp = "&nbsp;";
		iIndexOf = vRetResult.indexOf((String)vCourseList.elementAt(i)+"_1_"+iYear);
		if(iIndexOf > -1)
			strTemp = (String)vRetResult.elementAt(iIndexOf + 4);
		%>
		<td align="center" width="5%" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<%}
		strTemp = "0";
		iIndexOf = vRegularityTotal.indexOf("REG_TOTAL_1_"+iYear);
		if(iIndexOf > -1)
			strTemp = (String)vRegularityTotal.elementAt(iIndexOf + 1);
		%>
	    <td align="center" class="thinborder"><%=WI.getStrValue(strTemp,"0")%></td>
	</tr>
	<tr>
	    <td style="padding-left:30px;" height="22" class="thinborder">FOREIGN</td>
	    <%for(int i =0 ; i < vCourseList.size(); i += 2){
		strTemp = "&nbsp;";
		iIndexOf = vRetResult.indexOf((String)vCourseList.elementAt(i)+"_2_"+iYear);
		if(iIndexOf > -1)
			strTemp = (String)vRetResult.elementAt(iIndexOf + 4);
		%>
		<td align="center" width="5%" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<%}
		strTemp = "0";
		iIndexOf = vRegularityTotal.indexOf("REG_TOTAL_2_"+iYear);
		if(iIndexOf > -1)
			strTemp = (String)vRegularityTotal.elementAt(iIndexOf + 1);
		%>
	    <td align="center" class="thinborder"><%=WI.getStrValue(strTemp,"0")%></td>
	</tr>
<%}%>
	
	
	<tr style="font-weight:bold">
	    <td height="22" class="thinborder">TOTAL (<%=astrYearLevel2[iYear-1]%>)</td>
	    <%for(int i =0 ; i < vCourseList.size(); i += 2){
		
		strTemp = "0";
		iIndexOf = vYearLevelTotal.indexOf((String)vCourseList.elementAt(i)+"_"+(iYear-1));
		if(iIndexOf > -1)
			strTemp = (String)vYearLevelTotal.elementAt(iIndexOf + 1);
		%>
		<td align="center" width="5%" class="thinborder"><%=WI.getStrValue(strTemp,"0")%></td>
		<%}strTemp = "0";
		iIndexOf = vYearLevelGTotal.indexOf("YEAR_GT_"+(iYear - 1));
		if(iIndexOf > -1)
			strTemp = (String)vYearLevelGTotal.elementAt(iIndexOf + 1);
		%>
	    <td align="center" class="thinborder"><%=WI.getStrValue(strTemp,"0")%></td>
	</tr>
	<tr style="font-weight:bold">
	    <td height="22" class="thinborder">GRAND TOTAL STUDENTS</td>
	    <%for(int i =0 ; i < vCourseList.size(); i += 2){%>
		<td align="center" width="5%" class="thinborder"><%=WI.getStrValue(vCourseList.elementAt(i+1),"0")%></td>
		<%}%>
	    <td align="center" class="thinborder"><%=iGrandTotal%></td>
	    </tr>
</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
	    <td width="71%" height="25">&nbsp;</td>
	    <td width="29%">&nbsp;</td>
	    </tr>
	<tr>
		<td height="22">Prepared by:</td>
		<td>Noted by:</td>
	</tr>
	<tr>
	    <td valign="bottom" height="50"><%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP, "Accounting Clerk",7)).toUpperCase()%></td>
	    <td valign="bottom"><%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP, "Head-Cash Services",7)).toUpperCase()%></td>
	    </tr>
	<tr>
	    <td height="22">Accgt. Clerk - Student Account</td>
	    <td>Head - Cash Services</td>
	    </tr>
</table>


<%}%>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable4">
<tr><td height="25" colspan="8">&nbsp;</td></tr>
<tr bgcolor="#B8CDD1"><td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td></tr>
</table>

<input type="hidden" name="exclude_degree_list" value="1">
<input type="hidden" name="show_report">
</form>




</body>
</html>
<%dbOP.cleanUP();%>