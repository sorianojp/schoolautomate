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
	font-size: 12px;	
    }
    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
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

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORTS","report_enrollment_projection.jsp");
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
														"report_enrollment_projection.jsp");
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

String strCorrectionDate = null;
int iElemCount =0 ;
Vector vRetResult = null;
enrollment.ReportEnrollmentAUF rprtEnrl = new enrollment.ReportEnrollmentAUF();
if(WI.fillTextValue("show_report").length() > 0){
	vRetResult = rprtEnrl.generateEnrollmentProjection(dbOP, request);
	if(vRetResult == null)
		strErrMsg = rprtEnrl.getErrMsg();
	else{
		iElemCount = rprtEnrl.getElemCount();
		strTemp = "select MAX(create_date) from AUF_ENRL_PROJECTION where IS_VALID =1 and SY_FROM = "+WI.fillTextValue("sy_from")+
			" and SEMESTER = "+WI.fillTextValue("semester");
		java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
		if(rs.next())
			strCorrectionDate = WI.formatDate(ConversionTable.convertMMDDYYYY(rs.getDate(1)),6);
		rs.close();
	}
}
%>
<form name="form_" action="report_enrollment_projection.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable1">
<tr bgcolor="#A49A6A">
	<td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
		ENROLLMENT PROJECTION REPORT PAGE ::::</strong></font></div></td>
</tr>   
<tr><td height="25">&nbsp; &nbsp; &nbsp; &nbsp; <font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td></tr>    
</table>



<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable5">
<tr> 
      <td height="25" width="3%">&nbsp;</td>
      <td height="25" width="18%">Previous SY-Term(D-3)</td>
      <td colspan="2"> 
<%
	strTemp = WI.getStrValue(WI.fillTextValue("sy_from_d3"));
%> <input name="sy_from_d3" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="DisplaySYTo('form_','sy_from_d3','sy_to_d3');">
        to 
<%
	strTemp = WI.getStrValue(WI.fillTextValue("sy_to_d3"));
%> <input name="sy_to_d3" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly>        
	&nbsp;
	<select name="semester_d3">
<%
	strTemp = WI.getStrValue(WI.fillTextValue("semester_d3"));
%>	<%=CommonUtil.constructTermList(dbOP, request, strTemp)%>
        </select> 
		&nbsp; &nbsp;
		<a href="javascript:document.form_.submit();"></a>	</td>      
    </tr>
	
	<tr> 
      <td height="25" width="3%">&nbsp;</td>
      <td height="25" width="18%">Previous SY-Term(D-4)</td>
      <td colspan="2"> 
<%
	strTemp = WI.getStrValue(WI.fillTextValue("sy_from_d4"));
%> <input name="sy_from_d4" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="DisplaySYTo('form_','sy_from_d4','sy_to_d4');">
        to 
<%
	strTemp = WI.getStrValue(WI.fillTextValue("sy_to_d4"));
%> <input name="sy_to_d4" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly>        
	&nbsp;
	<select name="semester_d4">
<%
	strTemp = WI.getStrValue(WI.fillTextValue("semester_d4"));
%>	<%=CommonUtil.constructTermList(dbOP, request, strTemp)%>
        </select> 
		&nbsp; &nbsp;
		<a href="javascript:document.form_.submit();"></a>	</td>      
    </tr>

<tr> 
      <td height="25" width="3%">&nbsp;</td>
      <td height="25" width="18%">Current SY-Term</td>
      <td colspan="2"> 
<%
	strTemp = WI.getStrValue(WI.fillTextValue("sy_from"), (String)request.getSession(false).getAttribute("cur_sch_yr_from"));
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="DisplaySYTo('form_','sy_from','sy_to');">
        to 
<%
	strTemp = WI.getStrValue(WI.fillTextValue("sy_to"), (String)request.getSession(false).getAttribute("cur_sch_yr_to"));
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly>        
	&nbsp;
	<select name="semester">
<%
	strTemp = WI.getStrValue(WI.fillTextValue("semester"), (String)request.getSession(false).getAttribute("cur_sem"));
%>	<%=CommonUtil.constructTermList(dbOP, request, strTemp)%>
        </select> 
		&nbsp; &nbsp;</td>      
    </tr>
<tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td colspan="2">
	 <input name="as_of_date" type="text" size="10" maxlength="10" readonly="yes" value="<%=WI.fillTextValue("as_of_date")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.as_of_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../../images/calendar_new.gif" border="0"></a> 
	</td>
</tr>
<tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td colspan="2"><a href="javascript:ShowReport();"><img src="../../../../../images/refresh.gif" border="0" align="absmiddle"></a></td>
</tr>
</table>

<%
String[] astrConvertSem1 = {"","Summer","1st Sem","2nd Sem","3rd Sem", "4th Sem"};
if(vRetResult != null && vRetResult.size() > 0){
Vector vGrandTotal = (Vector)vRetResult.remove(0);
String[] astrConvertSem = {"Summer", "First Semester", "Second Semester", "Third Semester", "Fourth Semester"};
%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
	<tr>
	    <td align="right">
		<a href="javascript:PrintPage();"><img src="../../../../../images/print.gif" border="0"></a>
		<font size="1">Click to print report</font>
		</td>
	    </tr>
	<tr><td align="center">
	<strong style="font-size:13px;"><%=SchoolInformation.getSchoolName(dbOP, true, false)%></strong><br>
	<%=SchoolInformation.getAddressLine1(dbOP, false, false)%><br><br><br><font style="font-size:14px;">COMPARATIVE ENROLMENT DATA</font><br>
	<%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%>, A.Y.<%=WI.fillTextValue("sy_from")+"-"+WI.fillTextValue("sy_to")%>
	<br>&nbsp;
	</td></tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
	    <td valign="bottom" height="25" class="thinborder">&nbsp;</td>
	    <td colspan="2" rowspan="2" valign="bottom" class="thinborder" align="center">Enrolment<br>Projection</td>
	    <td rowspan="3" class="thinborder" align="center"><%=astrConvertSem1[Integer.parseInt(WI.getStrValue(WI.fillTextValue("semester_d3"),"0"))+1]%><br>
			<%=WI.fillTextValue("sy_from_d3")+"-"+WI.fillTextValue("sy_to_d3")%></td>
	    <td rowspan="3" class="thinborder" align="center"><%=astrConvertSem1[Integer.parseInt(WI.getStrValue(WI.fillTextValue("semester_d4"),"0"))+1]%><br>
			<%=WI.fillTextValue("sy_from_d4")+"-"+WI.fillTextValue("sy_to_d4")%></td>
	    <td rowspan="4" class="thinborder" align="center">Actual<br>
	        Enrollment<%=WI.getStrValue(WI.fillTextValue("as_of_date"),"<br>","","")%></td>
	    <td valign="bottom" class="thinborder">&nbsp;</td>
	    <td valign="bottom" class="thinborder">&nbsp;</td>
	    <td valign="bottom" class="thinborder">&nbsp;</td>
	    <td valign="bottom" class="thinborder">&nbsp;</td>
	    <td valign="bottom" class="thinborder">&nbsp;</td>
	    <td valign="bottom" class="thinborder">&nbsp;</td>
	    <td valign="bottom" class="thinborder">&nbsp;</td>
	    <td valign="bottom" class="thinborder">&nbsp;</td>
	    </tr>
	<tr>
		<td valign="bottom" height="25" class="thinborder">&nbsp;</td>
		<td valign="bottom" class="thinborder">&nbsp;</td>
		<td valign="bottom" class="thinborder">&nbsp;</td>
		<td valign="bottom" class="thinborder">&nbsp;</td>
		<td valign="bottom" class="thinborder">&nbsp;</td>
		<td valign="bottom" class="thinborder">&nbsp;</td>
		<td valign="bottom" class="thinborder">&nbsp;</td>
		<td valign="bottom" class="thinborder">&nbsp;</td>
		<td valign="bottom" class="thinborder">&nbsp;</td>
	</tr>
	<tr>
	    <td valign="bottom" height="25" class="thinborder">&nbsp;</td>
	    <td valign="bottom" class="thinborder" align="center">Minimum</td>
	    <td valign="bottom" class="thinborder" align="center">Maximum</td>
	    <td valign="bottom" class="thinborder">&nbsp;</td>
	    <td valign="bottom" class="thinborder">&nbsp;</td>
	    <td valign="bottom" class="thinborder">&nbsp;</td>
	    <td valign="bottom" class="thinborder">&nbsp;</td>
	    <td valign="bottom" class="thinborder">&nbsp;</td>
	    <td valign="bottom" class="thinborder">&nbsp;</td>
	    <td valign="bottom" class="thinborder">&nbsp;</td>
	    <td valign="bottom" class="thinborder">&nbsp;</td>
	    </tr>
	<tr>
	    <td valign="bottom" height="25" class="thinborder">&nbsp;</td>
	    <td valign="bottom" class="thinborder" align="center">D-1</td>
	    <td valign="bottom" class="thinborder" align="center">D-2</td>
	    <td valign="bottom" class="thinborder" align="center">D-3</td>
	    <td valign="bottom" class="thinborder" align="center">D-4</td>
	    <td valign="bottom" class="thinborder" align="center">D-1</td>
	    <td valign="bottom" class="thinborder" align="center">%</td>
	    <td valign="bottom" class="thinborder" align="center">D-2</td>
	    <td valign="bottom" class="thinborder" align="center">%</td>
	    <td valign="bottom" class="thinborder" align="center">D-3</td>
	    <td valign="bottom" class="thinborder" align="center">%</td>
	    <td valign="bottom" class="thinborder" align="center">D-4</td>
	    <td valign="bottom" class="thinborder" align="center">%</td>
	    </tr>
<%
for(int i = 0 ; i < vRetResult.size(); i+=iElemCount){
%>
	<tr>
	    <td valign="bottom" height="25" class="thinborder">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i+2)).toUpperCase()%></td>
	    <td align="right" width="6%" valign="bottom" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+4),"&nbsp;")%></td>
	    <td align="right" width="6%" valign="bottom" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+5),"&nbsp;")%></td>
	    <td align="right" width="6%" valign="bottom" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+6),"&nbsp;")%></td>
	    <td align="right" width="6%" valign="bottom" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+7),"&nbsp;")%></td>
	    <td align="right" width="6%" valign="bottom" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+8),"&nbsp;")%></td>
	    <td align="right" width="6%" valign="bottom" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+9),"&nbsp;")%></td>
		<%
		strTemp = WI.getStrValue(vRetResult.elementAt(i+10),"&nbsp;");
		if(!strTemp.startsWith("&nbsp"))
			strTemp += "%";
		%>
	    <td align="right" width="6%" valign="bottom" class="thinborder"><%=strTemp%></td>
	    <td align="right" width="6%" valign="bottom" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+11),"&nbsp;")%></td>
		<%
		strTemp = WI.getStrValue(vRetResult.elementAt(i+12),"&nbsp;");
		if(!strTemp.startsWith("&nbsp"))
			strTemp += "%";
		%>
	    <td align="right" width="6%" valign="bottom" class="thinborder"><%=strTemp%></td>
	    <td align="right" width="6%" valign="bottom" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+13),"&nbsp;")%></td>
		<%
		strTemp = WI.getStrValue(vRetResult.elementAt(i+14),"&nbsp;");
		if(!strTemp.startsWith("&nbsp"))
			strTemp += "%";
		%>
	    <td align="right" width="6%" valign="bottom" class="thinborder"><%=strTemp%></td>
	    <td align="right" width="6%" valign="bottom" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+15),"&nbsp;")%></td>
		<%
		strTemp = WI.getStrValue(vRetResult.elementAt(i+16),"&nbsp;");
		if(!strTemp.startsWith("&nbsp"))
			strTemp += "%";
		%>
	    <td align="right" width="6%" valign="bottom" class="thinborder"><%=strTemp%></td>
	    </tr>
	
	<%}%>
	
	<tr>
	    <td valign="bottom" height="25" class="thinborder">&nbsp;</td>
	    <td align="right" valign="bottom" class="thinborder">&nbsp;</td>
	    <td align="right" valign="bottom" class="thinborder">&nbsp;</td>
	    <td align="right" valign="bottom" class="thinborder">&nbsp;</td>
	    <td align="right" valign="bottom" class="thinborder">&nbsp;</td>
	    <td align="right" valign="bottom" class="thinborder">&nbsp;</td>
	    <td align="right" valign="bottom" class="thinborder">&nbsp;</td>
	    <td align="right" valign="bottom" class="thinborder">&nbsp;</td>
	    <td align="right" valign="bottom" class="thinborder">&nbsp;</td>
	    <td align="right" valign="bottom" class="thinborder">&nbsp;</td>
	    <td align="right" valign="bottom" class="thinborder">&nbsp;</td>
	    <td align="right" valign="bottom" class="thinborder">&nbsp;</td>
	    <td align="right" valign="bottom" class="thinborder">&nbsp;</td>
	    <td align="right" valign="bottom" class="thinborder">&nbsp;</td>
	    </tr>
	<tr>
	    <td valign="bottom" height="25" class="thinborder"><strong>GRAND TOTAL</strong></td>
		<%
		strTemp = "&nbsp;";
		if(vGrandTotal != null && vGrandTotal.size() > 0)
			strTemp = WI.getStrValue(vGrandTotal.remove(0));
		%>
	    <td style="font-weight:bold;" align="right" valign="bottom" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<%
		strTemp = "&nbsp;";
		if(vGrandTotal != null && vGrandTotal.size() > 0)
			strTemp = WI.getStrValue(vGrandTotal.remove(0));
		%>
	    <td style="font-weight:bold;" align="right" valign="bottom" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<%
		strTemp = "&nbsp;";
		if(vGrandTotal != null && vGrandTotal.size() > 0)
			strTemp = WI.getStrValue(vGrandTotal.remove(0));
		
		%>
	    <td style="font-weight:bold;" align="right" valign="bottom" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<%
		strTemp = "&nbsp;";
		if(vGrandTotal != null && vGrandTotal.size() > 0)
			strTemp = WI.getStrValue(vGrandTotal.remove(0));
		%>
	    <td style="font-weight:bold;" align="right" valign="bottom" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<%
		strTemp = "&nbsp;";
		if(vGrandTotal != null && vGrandTotal.size() > 0)
			strTemp = WI.getStrValue(vGrandTotal.remove(0));
		%>
	    <td style="font-weight:bold;" align="right" valign="bottom" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<%
		strTemp = "&nbsp;";
		if(vGrandTotal != null && vGrandTotal.size() > 0)
			strTemp = WI.getStrValue(vGrandTotal.remove(0));
		%>
	    <td align="right" valign="bottom" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<%
		strTemp = "&nbsp;";
		if(vGrandTotal != null && vGrandTotal.size() > 0)
			strTemp = WI.getStrValue(vGrandTotal.remove(0),"&nbsp;");
		if(!strTemp.startsWith("&nbsp"))
			strTemp += "%";
		%>
	    <td align="right" valign="bottom" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<%
		strTemp = "&nbsp;";
		if(vGrandTotal != null && vGrandTotal.size() > 0)
			strTemp = WI.getStrValue(vGrandTotal.remove(0),"&nbsp;");
		%>
	    <td align="right" valign="bottom" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<%
		strTemp = "&nbsp;";
		if(vGrandTotal != null && vGrandTotal.size() > 0)
			strTemp = WI.getStrValue(vGrandTotal.remove(0),"&nbsp;");
		if(!strTemp.startsWith("&nbsp"))
			strTemp += "%";
		%>
	    <td align="right" valign="bottom" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<%
		strTemp = "&nbsp;";
		if(vGrandTotal != null && vGrandTotal.size() > 0)
			strTemp = WI.getStrValue(vGrandTotal.remove(0),"&nbsp;");
		%>
	    <td align="right" valign="bottom" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<%
		strTemp = "&nbsp;";
		if(vGrandTotal != null && vGrandTotal.size() > 0)
			strTemp = WI.getStrValue(vGrandTotal.remove(0),"&nbsp;");
		if(!strTemp.startsWith("&nbsp"))
			strTemp += "%";
		%>
	    <td align="right" valign="bottom" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<%
		strTemp = "&nbsp;";
		if(vGrandTotal != null && vGrandTotal.size() > 0)
			strTemp = WI.getStrValue(vGrandTotal.remove(0),"&nbsp;");
		%>
	    <td align="right" valign="bottom" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<%
		strTemp = "&nbsp;";
		if(vGrandTotal != null && vGrandTotal.size() > 0)
			strTemp = WI.getStrValue(vGrandTotal.remove(0),"&nbsp;");
		if(!strTemp.startsWith("&nbsp"))
			strTemp += "%";
		%>
	    <td align="right" valign="bottom" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	    </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td>Note: Correction on the Minimum and Maximum projection by AUF-IS<%=WI.getStrValue(strCorrectionDate," on ","","")%>.</td></tr>
</table>
<%}%>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable4">
<tr><td height="25" colspan="8">&nbsp;</td></tr>
<tr bgcolor="#B8CDD1"><td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td></tr>
</table>


<input type="hidden" name="show_report">
</form>




</body>
</html>
<%dbOP.cleanUP();%>