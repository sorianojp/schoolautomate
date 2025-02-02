<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script>
function PrintPg() {
	if(document.form_.stud_id.value != document.form_.old_stud_id.value) {
		document.form_.print_pg.value = "2";
		document.form_.submit();
		return;
	}
	document.form_.print_pg.value = "1";
	document.form_.submit();
	//location = "./clearance_print.jsp?stud_id="+document.form_.stud_id.value+"&clr_index="+document.form_.type_index.value;
}
function forcePrint() {
	document.form_.print_pg.value = "1";
	document.form_.submit();
	//location = "./clearance_print.jsp?stud_id="+document.form_.stud_id.value+"&clr_index="+document.form_.type_index.value;
}

</script>
</head>
<%@ page language="java" import="utility.*,clearance.ClearanceMain, java.util.Vector " buffer="16kb"%>
<%
	WebInterface WI = new WebInterface(request);
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));

	//I have to do this to avoid get requrest using URL 
	if(WI.fillTextValue("print_pg").equals("1")) {//System.out.println(WI.fillTextValue("print_pg"));
		HttpSession curSession = request.getSession(false);
		curSession.setAttribute("stud_id",WI.fillTextValue("stud_id"));
		curSession.setAttribute("sy_from",WI.fillTextValue("sy_from"));
		curSession.setAttribute("sy_to",WI.fillTextValue("sy_to"));
		curSession.setAttribute("semester",WI.fillTextValue("semester"));
		curSession.setAttribute("type_index",WI.fillTextValue("type_index"));
		

		if(strSchCode == null)
			strSchCode = "";//strSchCode = "AUF";
		if(strSchCode.startsWith("CLDH")){%>
			<jsp:forward page="./clearance_print_CLDH.jsp" />
		<%}else if(strSchCode.startsWith("AUF")){%>
			<jsp:forward page="./clearance_print_AUF.jsp" />
		<%}else{%>
			<jsp:forward page="./clearance_print_GENERIC.jsp" />
		<%}
		return;
	}
	


	DBOperation dbOP = null;
	
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Clearance-Clearance Status-Print Clearance","clearance_main.jsp");
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
														"Clearances","Clearance Status",request.getRemoteAddr(),
														"clearance_main.jsp");
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
boolean bolLmsPending        = false; Vector vClearanceInfo = null;
boolean bolShowClearanceInfo = false;

boolean bolClearancePending = false;

double dOSBal = 0d;//outstanding balance.

//other clearance.
Vector vOthClearance = null;

String strStudID = WI.fillTextValue("stud_id");
String strUserIndex = null;
Vector vStudInfo = null;

if(strStudID.length() > 0 && WI.fillTextValue("sy_from").length() > 0) {
	vStudInfo = new enrollment.EnrlAddDropSubject().getEnrolledStudInfo(dbOP, null, strStudID, WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"), WI.fillTextValue("semester"));

	if(vStudInfo == null)
		strErrMsg = "Error in locating student information for this Sy/Term.";
	else {
		bolShowClearanceInfo = true;
		strUserIndex = (String)vStudInfo.elementAt(0);
		
		//get receivable.. 
		enrollment.FAFeeOperation fOperation = new enrollment.FAFeeOperation();
		dOSBal = fOperation.calOutStandingOfPrevYearSem(dbOP, strUserIndex,true, true);
		//dOSBal = 0d;
		///get other clearance posted.. 
		clearance.ClearanceMain cM = new clearance.ClearanceMain();
		vOthClearance = cM.getStudPendingClearance(dbOP,strUserIndex, WI.fillTextValue("type_index"));
		if(vOthClearance == null) 
			strErrMsg = cM.getErrMsg();
		
		//for LMS.
		lms.PatronInformation pInfo = new lms.PatronInformation();
		vClearanceInfo = pInfo.queryForClearance(dbOP, strUserIndex);
		if(vClearanceInfo == null)
			strErrMsg = pInfo.getErrMsg();
		else if(vClearanceInfo.size() > 0) {
			bolLmsPending = true;
			bolClearancePending = true;
		}
	}
}
%>

<body bgcolor="#D2AE72">
<form name="form_" method="post" action = "clearance_main.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
        CLEARANCES- PRINT CLEARANCE ::::</strong></font></div></td>
    </tr>
</table>  
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td height="25" colspan="3" style="font-size:14px; color:#FF0000; font-weight:bold">&nbsp;&nbsp;&nbsp;
	<%=WI.getStrValue(strErrMsg)%></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td>SY/Term: </td>
    <td>
<% strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from"); %> 
			<input name="sy_from" type="text" size="4" maxlength="4"  value="<%=strTemp%>" class="textbox"
	onFocus= "style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	onKeyPress= " if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
			to 
			<%  strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to"); %> 
			<input name="sy_to" type="text" size="4" maxlength="4" 
		  value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">
			- 
			<select name="semester">
				<%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0 )
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("0") ==0){%>
				<option value="0" selected>Summer</option>
<%}else{%>
				<option value="0">Summer</option>
<%}if(strTemp.compareTo("1") ==0){%>
				<option value="1" selected>1st Sem</option>
<%}else{%>
				<option value="1">1st Sem</option>
<%}if(strTemp.compareTo("2") == 0){%>
				<option value="2" selected>2nd Sem</option>
<%}else{%>
				<option value="2">2nd Sem</option>
<%}if(strTemp.compareTo("3") == 0){%>
				<option value="3" selected>3rd Sem</option>
<%}else{%>
				<option value="3">3rd Sem</option>
<%}%>
			</select>
			<a href = 'javascript:document.form_.print_pg.value="";document.form_.submit();'><img src="../../../images/refresh.gif" border="0"></a><font size="1">Click to refresh the page</font>
	  </td>
  </tr>
  <tr> 
    <td width="6%" height="25">&nbsp;</td>
    <td width="18%">Clearance Type</td>
    <td> <%strTemp = WI.fillTextValue("type_index");%> <select name="type_index">
        <%=dbOP.loadCombo("CLE_CTYPE_INDEX","CLEARANCE_TYPE"," FROM CLE_TYPE WHERE IS_VALID = 1 AND IS_DEL = 0", strTemp, false)%> </select> </td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td>Specific Student ID</td>
    <td width="76%"><input name="stud_id" type="text"  value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	<%if (!bolLmsPending && !bolClearancePending && 
			vOthClearance != null && vOthClearance.size() == 0 &&
			dOSBal <= 1d &&  strSchCode.startsWith("CLDH")){%>	
		<input type="checkbox" value="1" name="print_credentials"> 
		<font size="1">check to print clearance for releasing credentials </font>
		
	<%}%>
	  </td>
    </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td>&nbsp;</td>
    <td><a href="javascript:document.form_.submit();"></a></td>
    </tr>
</table>
<%if(bolShowClearanceInfo){//show only if all informations are entered.. %>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
  </table>
<table width="100%" bgcolor="#FFFFFF">
	<tr><td width="40%">
	<%if(bolLmsPending) {%>
		<table width="95%" border="0" cellpadding="0" cellspacing="0">
		  <tr>
			<td colspan="2" align="center" bgcolor="#9FcFFF" class="thinborderALL" height="18"><strong>Circulation Detail</strong></td>
		  </tr>
		  <tr>
			<td width="24%" height="18" bgcolor="#EEEEEE" class="thinborderBOTTOMLEFT"> Books Issued(Due now) </td>
			<td bgcolor="#EEEEEE" width="8%" class="thinborderBOTTOMLEFTRIGHT"><%=(String)vClearanceInfo.elementAt(0)%></td>
		  </tr>
		  <tr>
			<td height="18" bgcolor="#EEEEEE" class="thinborderBOTTOMLEFT"> Overdue </td>
			<td bgcolor="#EEEEEE" class="thinborderBOTTOMLEFTRIGHT"><%=(String)vClearanceInfo.elementAt(1)%></td>
		  </tr>
		  <tr>
			<td height="18" bgcolor="#EEEEEE" class="thinborderBOTTOMLEFT">Unpaid Fine Outstanding </td>
			<td bgcolor="#EEEEEE" class="thinborderBOTTOMLEFTRIGHT"><%=(String)vClearanceInfo.elementAt(2)%></td>
		  </tr>
		</table>
	<%}else{%>
		<font style="color:#0000FF; font-weight:bold; font-size:14">Library Clearance :: OK </font>
		<font size="1" color="#0000FF"><br> &radic; All books are returned <br> 
		&radic; No outstanding balance/Fine  </font>
	    <%}%>
	</td>
	<td width="10%"></td>
	<td width="50%" valign="top">
	<%if(dOSBal > 1.0d){bolClearancePending = true; %>
		<font size="4" color="red"><strong>Outstanding Balance : 
			<%=CommonUtil.formatFloat(dOSBal,true)%></strong></font>	
	<%}else{%>
		<font style="color:#0000FF; font-weight:bold; font-size:14">Accounts Receivable :: OK </font>
		<font size="1" color="#0000FF"><br> &radic; No outstanding balance</font>
	<% }%>
	</td>
	</tr>
</table>
<%if(vOthClearance != null && vOthClearance.size() > 0) {bolClearancePending = true;%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	  <tr>
		<td colspan="6" align="center" bgcolor="#9FcFFF" class="thinborderALL" height="18"><strong>:: Other Pending Clearance :: </strong></td>
	  </tr>
	  <tr bgcolor="#DDDDDD">
		<td width="20%" height="18" class="thinborderBOTTOMLEFT"><strong> Posted By </strong></td>
		<td width="10%" class="thinborderBOTTOMLEFT"><strong>Due</strong></td>
		<td width="25%" class="thinborderBOTTOMLEFT"><strong>Requirement</strong></td>
		<td width="25%" class="thinborderBOTTOMLEFT"><strong>Remark</strong></td>
		<td width="10%" class="thinborderBOTTOMLEFTRIGHT"><strong>Date Posted </strong></td>
	    <td width="10%" class="thinborderBOTTOMLEFTRIGHT"><strong>Last Date to Clear </strong></td>
	  </tr>
<%for(int i = 0; i < vOthClearance.size(); i += 8){%>
	  <tr bgcolor="#EEEEEE">
	    <td height="18" class="thinborderBOTTOMLEFT"><%=vOthClearance.elementAt(i) +" - "+vOthClearance.elementAt(i + 1)%></td>
	    <td class="thinborderBOTTOMLEFT">
			Amt : <%=WI.getStrValue((String)vOthClearance.elementAt(i+2),"","","0")%><br>
			Qty : <%=WI.getStrValue((String)vOthClearance.elementAt(i+3),"","","n/a")%></td>
	    <td class="thinborderBOTTOMLEFT"><%=WI.getStrValue(vOthClearance.elementAt(i + 4),"&nbsp;")%></td>
	    <td class="thinborderBOTTOMLEFT"><%=WI.getStrValue(vOthClearance.elementAt(i + 5),"&nbsp;")%></td>
	    <td class="thinborderBOTTOMLEFTRIGHT"><%=WI.getStrValue(vOthClearance.elementAt(i + 6),"&nbsp;")%></td>
	    <td class="thinborderBOTTOMLEFTRIGHT"><%=WI.getStrValue(vOthClearance.elementAt(i + 7),"&nbsp;")%></td>
      </tr>
<%}//end of for loop %>
    </table>
<%}//end of vOthClearance..

}//if(bolShowClearanceInfo){//show only if all informations are entered.
%>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%if(bolClearancePending){bolShowClearanceInfo = false;%>
    <tr> 
      <td height="25" colspan="5" style="font-size:14px; color:#FF0000; font-weight:bold" align="center">System suggests not to print Clearance for this student</td>
    </tr>
<%}if(bolShowClearanceInfo || strSchCode.startsWith("AUF")){%>
    <tr> 
      <td height="25" colspan="5" align="center"><a href="javascript:PrintPg();">
	  	<img src="../../../images/print.gif" border="0"></a><font size="1"> Print Clearance</font></td>
    </tr>
<%}%>
    <tr> 
      <td height="25" colspan="5">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5">&nbsp;</td>
    </tr>
</table>  

<input type="hidden" name="print_pg">
<input type="hidden" name="old_stud_id" value="<%=WI.fillTextValue("stud_id")%>">
</form>
<%
if(bolShowClearanceInfo && WI.fillTextValue("print_pg").equals("2")) {%>
	<script language="javascript">
		this.forcePrint();
	</script>
<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>