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

function PrintPg(){
	
	if(!confirm("Click OK to print Page."))
		return;

	document.bgColor = "#FFFFFF";

	document.getElementById("myADTable1").deleteRow(0);
	document.getElementById("myADTable1").deleteRow(0);
	
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
								"Admin/staff-Enrollment-REPORTS","enrolment_data_per_course_and_year_and_gender.jsp");
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
														"enrolment_data_per_course_and_year_and_gender.jsp");
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
enrollment.ReportEnrollmentAUF rprtEnrl = new enrollment.ReportEnrollmentAUF();
if(WI.fillTextValue("show_report").length() > 0){
	vRetResult = rprtEnrl.generateEnrollDataWithYearGender(dbOP, request);
	if(vRetResult == null)
		strErrMsg = rprtEnrl.getErrMsg();
	else{
		iElemCount = rprtEnrl.getElemCount();		
	}
}


String[] astrYearLevel = {"","FIRST YEAR","SECOND YEAR","THIRD YEAR","FOURTH YEAR","FIFTH YEAR","SIXTH YEAR"};
%>
<form name="form_" action="enrolment_data_per_course_and_year_and_gender.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable1">
<tr bgcolor="#A49A6A">
	<td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
		ENROLLMENT DATA PER YEAR LEVEL REPORT PAGE ::::</strong></font></div></td>
</tr>   
<tr><td height="25">&nbsp; &nbsp; &nbsp; &nbsp; <font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td></tr>    
</table>



<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable5">
<tr> 
      <td height="25" width="3%">&nbsp;</td>
      <td height="25" width="18%">Previous SY-Term</td>
      <td colspan="2"> 
<%
	strTemp = WI.getStrValue(WI.fillTextValue("prev_sy_from"));
%> <input name="prev_sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="DisplaySYTo('form_','prev_sy_from','prev_sy_to');">
        to 
<%
	strTemp = WI.getStrValue(WI.fillTextValue("prev_sy_to"));
%> <input name="prev_sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly>        
	&nbsp;
	<select name="prev_semester">
<%
	strTemp = WI.getStrValue(WI.fillTextValue("prev_semester"));
%>	<%=CommonUtil.constructTermList(dbOP, request, strTemp)%>
        </select> 
		&nbsp; &nbsp;
		
		
	 <!--<input name="prev_as_of_date" type="text" size="10" maxlength="10" readonly="yes" value="<%=WI.fillTextValue("prev_as_of_date")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.prev_as_of_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../../images/calendar_new.gif" border="0"></a>-->		</td>      
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
		&nbsp; &nbsp;
		
	 <input name="as_of_date" type="text" size="10" maxlength="10" readonly="yes" value="<%=WI.fillTextValue("as_of_date")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.as_of_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../../images/calendar_new.gif" border="0"></a>		</td>      
    </tr>
<tr>
    <td height="25">&nbsp;</td>
    <td height="25">Year Level</td>
    <td colspan="2">
	<select name="year_level">
		<%
		strTemp = WI.fillTextValue("year_level");
		for(int i = 1; i < astrYearLevel.length; ++i){
		if(strTemp.equals(Integer.toString(i)))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		%>
		<option value="<%=i%>" <%=strErrMsg%>><%=astrYearLevel[i]%></option>
		<%}%>
	</select>
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

String strGTCurr = (String)vRetResult.remove(0);
String strGTCurrF = (String)vRetResult.remove(0);
String strGTCurrM = (String)vRetResult.remove(0);
String strGTPrev = (String)vRetResult.remove(0);
Vector vCurrSubTotal = (Vector)vRetResult.remove(0);
Vector vPrevSubTotal = (Vector)vRetResult.remove(0);

String[] astrConvertSem ={"Summer","1st Sem.","2nd Sem."," 3rd Sem.","4th Sem."};
%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
	 <tr>
        <td height="25">
  		  <div align="right"><a href="javascript:PrintPg();">
			  <img src="../../../../../images/print.gif" width="58" height="26" border="0"></a>
			  <font size="1">click to print report</font>
  		  </div>
  	    </td>
      </tr>
	<tr>
		<td height="25" colspan="9" align="center">
		  <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
		  <%=SchoolInformation.getAddressLine1(dbOP,false,false)%>
		  <br><strong>OFFICE OF THE UNIVERSITY REGISTRAR</strong><br><BR>
		  
		  <strong>TOTAL ENROLLMENT <%=astrYearLevel[Integer.parseInt(WI.fillTextValue("year_level"))]%> DATA, A.Y. <%=WI.fillTextValue("prev_sy_from")%>-<%=WI.fillTextValue("prev_sy_to")%> : <%=WI.fillTextValue("sy_from")%>-<%=WI.fillTextValue("sy_to")%></strong>
		</td>
	</tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
		<td class="thinborder"><strong>COLLEGES</strong></td>		
		<td width="7%" align="center" class="thinborder"><strong><%=astrConvertSem[Integer.parseInt(WI.fillTextValue("prev_semester"))]%></strong></td>
		<td align="center" class="thinborder" colspan="3"><strong><%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%></strong></td>
		<td width="20%" align="center" class="thinborder"><strong>Decrease/Increase</strong></td>
	</tr>
	<tr style="font-weight:bold;">
	    <td align="center" class="thinborder">&nbsp;</td>
	    <td width="15%" align="center" class="thinborder">AY <%=WI.fillTextValue("prev_sy_from")+"-"+WI.fillTextValue("prev_sy_to")%></td>
	    <td width="7%" align="center" class="thinborder">M</td>
	    <td width="7%" align="center" class="thinborder">F</td>
	    <td width="15%" align="center" class="thinborder">AY <%=WI.fillTextValue("sy_from")+"-"+WI.fillTextValue("sy_to")%></td>
	    <td align="center" class="thinborder">&nbsp;</td>
	    </tr>
	<tr style="font-weight:bold;">
	    <td align="center" class="thinborder">&nbsp;</td>
	    <td align="center" class="thinborder">(Total Enrollment)<!--As of <%=WI.fillTextValue("prev_as_of_date")%>--></td>
	    <td align="center" class="thinborder">&nbsp;</td>
	    <td align="center" class="thinborder">&nbsp;</td>
	    <td align="center" class="thinborder">As of <%=WI.fillTextValue("as_of_date")%></td>
	    <td align="center" class="thinborder">&nbsp;</td>
	    </tr>
	
<%
int iCourseCount =0;
int iCount = 0;
int iPrevVal = 0;
int iCurrVal = 0;
int iIndexOf = 0;
String strPrevCCode = "";
String strCurrCCode = null;
for(int i = 0 ; i < vRetResult.size() ; i += iElemCount){
	strCurrCCode = (String)vRetResult.elementAt(i+1);
	
if(!strPrevCCode.equals(strCurrCCode)){
	strPrevCCode = strCurrCCode;
	if(i > 0 && iCourseCount > 1){
	strCurrCCode = (String)vRetResult.elementAt(i-iElemCount+1);
%>
	<tr style="font-weight:bold;">
	    <td  class="thinborder">&nbsp;</td>
		<%
		strTemp = "0";
		iPrevVal = 0;
		iIndexOf = vPrevSubTotal.indexOf(strCurrCCode);
		if(iIndexOf > -1){
			strTemp = (String)vPrevSubTotal.elementAt(iIndexOf + 1);
			iPrevVal = rprtEnrl.getIntValue(strTemp);
		}
		%>
	    <td align="center" class="thinborder"><%=strTemp%></td>
		
		<%		
		strTemp = "0";
		iIndexOf = vCurrSubTotal.indexOf(strCurrCCode);
		if(iIndexOf > -1)
			strTemp = (String)vCurrSubTotal.elementAt(iIndexOf + 1);					
		%>
		 <td align="center" class="thinborder"><%=strTemp%></td>
		<%		
		strTemp = "0";
		iIndexOf = vCurrSubTotal.indexOf(strCurrCCode);
		if(iIndexOf > -1)
			strTemp = (String)vCurrSubTotal.elementAt(iIndexOf + 2);					
		%>
	    <td align="center" class="thinborder"><%=strTemp%></td>
		<%
		iCurrVal = 0;
		strTemp = "0";
		iIndexOf = vCurrSubTotal.indexOf(strCurrCCode);
		if(iIndexOf > -1){
			strTemp = (String)vCurrSubTotal.elementAt(iIndexOf + 3);
			iCurrVal = rprtEnrl.getIntValue(strTemp); 
		}
		%>
	    <td align="center" class="thinborder"><%=strTemp%></td>
	    <td align="center" class="thinborder"><%=iCurrVal - iPrevVal%></td>
    </tr>
	<%}
	strCurrCCode = (String)vRetResult.elementAt(i+1);
	%>
	<tr>
	    <td align="" class="thinborder"><strong><%=strCurrCCode%></strong></td>
	    <td align="center" class="thinborder">&nbsp;</td>
	    <td align="center" class="thinborder">&nbsp;</td>
	    <td align="center" class="thinborder">&nbsp;</td>
	    <td align="center" class="thinborder">&nbsp;</td>
	    <td align="center" class="thinborder">&nbsp;</td>
	</tr>
<%iCourseCount =0;}
++iCourseCount;
%>
	<tr>
	    <td align="" class="thinborder" style="padding-left:40px;">&nbsp;
			<%=(String)vRetResult.elementAt(i+2)%><%=WI.getStrValue((String)vRetResult.elementAt(i+3),"-","","")%></td>
	    <td align="center" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+4),"&nbsp;")%></td>
	    <td align="center" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+5),"&nbsp;")%></td>
	    <td align="center" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+6),"&nbsp;")%></td>
	    <td align="center" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+7),"&nbsp;")%></td>
	    <td align="center" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+8),"&nbsp;")%></td>
	</tr>
<%}
if(iCourseCount > 1){
%>
	<tr style="font-weight:bold;">
	    <td  class="thinborder">&nbsp;</td>
		<%
		strTemp = "0";
		iPrevVal = 0;
		iIndexOf = vPrevSubTotal.indexOf(strCurrCCode);
		if(iIndexOf > -1){
			strTemp = (String)vPrevSubTotal.elementAt(iIndexOf + 1);
			iPrevVal = rprtEnrl.getIntValue(strTemp);
		}
		%>
	    <td align="center" class="thinborder"><%=strTemp%></td>
		
		<%		
		strTemp = "0";
		iIndexOf = vCurrSubTotal.indexOf(strCurrCCode);
		if(iIndexOf > -1)
			strTemp = (String)vCurrSubTotal.elementAt(iIndexOf + 1);					
		%>
		 <td align="center" class="thinborder"><%=strTemp%></td>
		<%		
		strTemp = "0";
		iIndexOf = vCurrSubTotal.indexOf(strCurrCCode);
		if(iIndexOf > -1)
			strTemp = (String)vCurrSubTotal.elementAt(iIndexOf + 2);					
		%>
	    <td align="center" class="thinborder"><%=strTemp%></td>
		<%
		iCurrVal = 0;
		strTemp = "0";
		iIndexOf = vCurrSubTotal.indexOf(strCurrCCode);
		if(iIndexOf > -1){
			strTemp = (String)vCurrSubTotal.elementAt(iIndexOf + 3);
			iCurrVal = rprtEnrl.getIntValue(strTemp); 
		}
		%>
	    <td align="center" class="thinborder"><%=strTemp%></td>
	    <td align="center" class="thinborder"><%=iCurrVal - iPrevVal%></td>
    </tr>
	
<%}%>
<tr style="font-weight:bold;">
	<td  class="thinborder">GRAND TOTAL</td>
	<td align="center" class="thinborder"><%=strGTPrev%></td>
	<td align="center" class="thinborder"><%=strGTCurrM%></td>
	<td align="center" class="thinborder"><%=strGTCurrF%></td>
	<td align="center" class="thinborder"><%=strGTCurr%></td>
	<td align="center" class="thinborder"><%=rprtEnrl.getIntValue(strGTCurr) - rprtEnrl.getIntValue(strGTPrev)%></td>
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