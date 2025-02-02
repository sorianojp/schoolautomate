<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Trust Fund Collection Report</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript">
	function ReloadPage(){
		document.form_.reload_page.value = "1";
		document.form_.submit();
	}
	
	function SetShowOption(strOption){
		document.form_.show_option.value= strOption;
	}
	
	function PrintPg(){
			
		
		var pgLoc = "./trust_fund_collection_report_detailed_print.jsp?date_from="+document.form_.date_from.value+
		"&date_to="+document.form_.date_to.value+
		"&emp_id="+document.form_.emp_id.value+
		"&num_rec_page="+document.form_.num_rec_page.value+	
		"&c_index="+document.form_.c_index.value+	
		"&course_index="+document.form_.course_index.value+
		"&major_index="+document.form_.major_index.value+
		"&show_option="+document.form_.show_option.value+
		"&othsch_fee_index="+document.form_.othsch_fee_index.value;	
	
		var win=window.open(pgLoc,"AddOrderItems",'width=1024,height=600,top=20,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.ReportFeeAssessment,java.util.Vector, java.util.*" %>
<%

	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","trust_fund_collection_report_detailed.jsp");
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
														"Fee Assessment & Payments","Reports",request.getRemoteAddr(),
														"trust_fund_collection_report_detailed.jsp");
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","REPORTS-CASHIER REPORT",request.getRemoteAddr(),
														"trust_fund_collection_report_detailed.jsp");
}
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

//end of authenticaion code.
Vector vRetResult  = null;
Vector vGradeLevel = new Vector();

ReportFeeAssessment othschReport = new ReportFeeAssessment();
if(WI.fillTextValue("reload_page").length() > 0){
	vRetResult = othschReport.operateOnTrustFundReport(dbOP, request, 4);
	if(vRetResult == null)
		strErrMsg = othschReport.getErrMsg();	
	else {
		String strSQLQuery = "select g_level, level_name from bed_level_info";
		java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
		while(rs.next()) {
			vGradeLevel.addElement(rs.getString(1));//g_level
			vGradeLevel.addElement(rs.getString(2));//[1] edu_level
		} 
		rs.close();
	}
}
%>

<form name="form_" method="post" action="./trust_fund_collection_report_detailed.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          TRUST FUND COLLECTION REPORT::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" width="3%">&nbsp;</td>
	  <td><strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    <tr>
      <td height="25">&nbsp;</td>
      <td width="16%" height="25">Collection Date</td>
      <td height="25" colspan="2"><font size="1">

        <input name="date_from" type="text" size="12" maxlength="12" value="<%=WI.fillTextValue("date_from")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_from');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>
       to

        <input name="date_to" type="text" size="12" maxlength="12" value="<%=WI.fillTextValue("date_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" 
		onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>
        (for one day, leave to field empty.)

</font>		</td>
    </tr>
    <tr>
        <td height="25">&nbsp;</td>
        <td height="25">&nbsp;</td>
        <td height="25" colspan="2">
		<font style="font-weight:bold; color:blue; font-size:8px;">  
<%
strTemp = WI.fillTextValue("show_option_1");
if(strTemp.equals("0") || strTemp.length() == 0)
	strErrMsg = "checked";
else
	strErrMsg = "";
%>     
		<input type="radio" name="show_option_1" value="0" <%=strErrMsg%> onClick="SetShowOption('0')"> Show All 
<%
if(strTemp.equals("1"))
	strErrMsg = "checked";
else
	strErrMsg = "";
%>	   	<input type="radio" name="show_option_1" value="1" <%=strErrMsg%> onClick="SetShowOption('1')"> Show only College 
<%
if(strTemp.equals("2"))
	strErrMsg = "checked";
else
	strErrMsg = "";
%>		<input type="radio" name="show_option_1" value="2" <%=strErrMsg%> onClick="SetShowOption('2')"> Show only HS 
<%
if(strTemp.equals("3"))
	strErrMsg = "checked";
else
	strErrMsg = "";
%>		<input type="radio" name="show_option_1" value="3" <%=strErrMsg%> onClick="SetShowOption('3')"> Show only HS 
<%
if(strTemp.equals("4"))
	strErrMsg = "checked";
else
	strErrMsg = "";
%>		<input type="radio" name="show_option_1" value="4" <%=strErrMsg%> onClick="SetShowOption('4')"> Show only Elementary</font>
		</td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td height="25">Teller ID</td>
      <td width="81%">
	  <input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" 
	  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
    </tr>
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>Fee Name</td>
		<td colspan="5">
			<select name="othsch_fee_index">
				<option value="">ALL</option>
				<%
				strTemp = " from fa_oth_sch_fee where is_valid = 1 "+
					" and exists(select * from UB_TRUST_FUND_PAYMENT where othsch_fee_index = fa_oth_sch_fee.othsch_fee_index) "+
					" order by fee_name";
				%>
				<!--<%=dbOP.loadCombo("othsch_fee_index","fee_name", strTemp, WI.fillTextValue("othsch_fee_index"), false)%>-->
				<%=dbOP.loadCombo("distinct fee_name","fee_name", strTemp, WI.fillTextValue("othsch_fee_index"), false)%>
			</select>		</td>
	</tr>
	
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>College</td>
		<td colspan="4"><select name="c_index" onChange="document.form_.submit();">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("c_index","c_name"," from college where IS_DEL=0 order by c_name asc",
		  		request.getParameter("c_index"), false)%> </select></td>
	</tr>
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>Course</td>
		<td colspan="3">
		<%
		if(WI.fillTextValue("c_index").length() > 0)
		{
			strTemp = " from course_offered where IS_DEL=0 and is_valid=1 and is_offered = 1 and c_index="+WI.fillTextValue("c_index")+
					" order by course_name asc" ;
		}
		else
			strTemp = " from course_offered where IS_DEL=0 AND IS_VALID=1 and is_offered = 1 order by course_name asc";
		%>
			<select name="course_index" onChange="document.form_.submit();" style="width:500px;">
				<option value="">ALL</option>
				<%=dbOP.loadCombo("course_index","course_code, course_name", strTemp, WI.fillTextValue("course_index"),false)%>
			</select>		</td>
	</tr>
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>Major</td>
		<td colspan="3">
		<select name="major_index">
          <option value="">ALL</option>
          <%
			strTemp = WI.fillTextValue("course_index");
			if(strTemp.compareTo("0") != 0 && strTemp.length() > 0)
			{
			strTemp = " from major where is_del=0 and course_index="+strTemp ;
			%>
         	<%=dbOP.loadCombo("major_index","major_name",strTemp, request.getParameter("major_index"), false)%>
          <%}%>
        </select>		</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		
		<td><input type="image" src="../../../../images/form_proceed.gif" onClick="ReloadPage();"></td>
	</tr>
	
	
	<%if(vRetResult != null && vRetResult.size() > 0) {%>
	<tr>		
	  <td colspan="5" align="right">
		<font size="2">Number of Rows Per Page :</font>
		<select name="num_rec_page">
		<% 
		int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
		for(int i = 10; i <=40 ; i++) {
			if ( i == iDefault) {%>
				<option selected value="<%=i%>"><%=i%></option>
			<%}else{%>
				<option value="<%=i%>"><%=i%></option>
			<%}
		}%>
		</select>
		
		&nbsp; &nbsp; &nbsp;
	  <a href="javascript:PrintPg();"><img src="../../../../images/print.gif" border="0"></a>
    <font size="1">click to print report</font>	</td></tr>
	
	<tr><td height="20">&nbsp;</td></tr>
	<%}%>  
  </table>
  
<%

if(vRetResult != null && vRetResult.size() > 0){



String strTotalAmt = (String)vRetResult.remove(0);

String strTellerName = "";
strTemp = "select fname, mname, lname from user_table where id_number = "+WI.getInsertValueForDB(WI.fillTextValue("emp_id"), true, null);
java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
if(rs.next())
	strTellerName = WebInterface.formatName(rs.getString(1),rs.getString(2),rs.getString(3),4);
rs.close();

int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
int iNumRec = 0;
int iPageNo = 1;
int iTotalPages = vRetResult.size()/(17*iMaxRecPerPage);	
if(vRetResult.size()%(17*iMaxRecPerPage) > 0)
	iTotalPages++;
	
//if(iTotalPages == 0)
//	iTotalPages = 1;

%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td colspan="5" align="center"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
								<%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br><br>
								DAILY TRUST FUND COLLECTION REPORT<br>
								</strong>
								 <%=WI.getStrValue(WI.fillTextValue("date_from"), "From ","","")%><%=WI.getStrValue(WI.fillTextValue("date_to"), " to ","","")%><br><br>
								</td></tr>
	
	<tr><td colspan="5" height="16">&nbsp;</td></tr>
</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
		<td class="thinborder" width="14%" height="22"><strong>STUDENT ID NO</strong></td>
		<td class="thinborder" width="30%"><strong>NAME</strong></td>
		<td class="thinborder" width="17%"><strong>COURSE/YR LEVEL</strong></td>
		<td class="thinborder" width="28%"><strong>FEE NAME</strong></td>
		<td class="thinborder" width="11%" align="center"><strong>AMOUNT</strong></td>
	</tr>
	
	<%
	String strDate = "";
	String strPrevDate = "";
	for(int i = 0; i < vRetResult.size(); i+=17){
		strDate = (String)vRetResult.elementAt(i);
		if(!strPrevDate.equals(strDate)){
			strPrevDate = strDate;
	%>
	<tr>
		<td class="thinborder" height="20" colspan="10"><%=strDate%></td>
	</tr>		
	<%}%>
	<tr>
		<td height="20" class="thinborder"><%=vRetResult.elementAt(i+1)%></td>
		<%
		strTemp = WebInterface.formatName((String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),4);
		%>
		<td class="thinborder"><%=strTemp%></td>
		<%
		//may be grade school trust fund.. 
		if(vRetResult.elementAt(i + 5) == null) 
			strTemp = (String)vGradeLevel.elementAt(vGradeLevel.indexOf((String)vRetResult.elementAt(i+12)) + 1);
		else {
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+5), "") + WI.getStrValue((String)vRetResult.elementAt(i+6)," - ","","") ;
			if(strTemp.length() > 0)
				strTemp += WI.getStrValue((String)vRetResult.elementAt(i+12)," / ","","");
		}
		%>
		<td class="thinborder"><%=strTemp%></td>
		<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+7),"&nbsp;")%></td>
		<td align="right" class="thinborder"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+8), true)%></td>
	</tr>
	<%}%>
	<tr>
		<td colspan="4" height="20" align="right" class="thinborder"><strong>TOTAL</strong> &nbsp;</td>
		<td class="thinborder" align="right"><strong><%=CommonUtil.formatFloat(strTotalAmt, true)%></strong></td>
	</tr>
</table>

<%}%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable3">
<tr><td height="25" colspan="8">&nbsp;</td></tr>
<tr bgcolor="#B8CDD1"><td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td></tr>
</table>
<input type="hidden" name="reload_page">
<input type="hidden" name="show_option" value="<%=WI.fillTextValue("show_option")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
