<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/td.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.submit();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function FocusID() {
	document.form_.stud_id_fr.focus();
}
</script>

<body bgcolor="#D2AE72" onLoad="FocusID();">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-Program fix-Move Wrong ID",
								"move_payment_swu.jsp");

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
														"System Administration","Application Fix",request.getRemoteAddr(),
														"move_payment_swu.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
String strSQLQuery    = null;
java.sql.ResultSet rs = null;

String strIDFrom = WI.fillTextValue("stud_id_fr");
String strIDTo   = WI.fillTextValue("stud_id_to");

String strSYFrom   = WI.fillTextValue("sy_from");
String strSemester = WI.fillTextValue("semester");

String strIsTempFr = null;
String strIsTempTo = null;

String strIDFromUIndex = null;
String strIDToUIndex   = null;

if(strIDFrom.length() > 0 && strIDTo.length() > 0 && strSYFrom.length() > 0) {
	strIDFromUIndex = dbOP.mapUIDToUIndex(strIDFrom);
	strIDToUIndex   = dbOP.mapUIDToUIndex(strIDTo);
	if(strIDFromUIndex == null) {
		strSQLQuery = "select application_index from new_application where temp_id = '"+strIDFrom+"' and is_valid =1";
		strIDFromUIndex = dbOP.getResultOfAQuery(strSQLQuery, 0);
		if(strIDFromUIndex != null) 
			strIsTempFr = "1";
	}
	else
		strIsTempFr = "0";
	if(strIDToUIndex == null) {
		strSQLQuery = "select application_index from new_application where temp_id = '"+strIDFrom+"' and is_valid =1";
		strIDToUIndex = dbOP.getResultOfAQuery(strSQLQuery, 0);
		if(strIDToUIndex != null) 
			strIsTempTo = "1";
	}
	else
		strIsTempTo = "0";
	
	if(strIDFromUIndex == null)
		strErrMsg = "ID From is not found.";
	else if(strIDToUIndex == null)
		strErrMsg = "ID To is not found.";
	
	if(strErrMsg == null) {
		Vector vPaymentIndex   = new Vector();
		Vector vPmtMethodIndex = new Vector();
		
		strSQLQuery = "select payment_index from fa_stud_payment where sy_from = "+strSYFrom+" and semester = "+strSemester+" and is_valid = 1 and "+
			" amount > 0 and user_index = "+strIDFromUIndex+" and is_stud_temp = "+strIsTempFr;
		rs = dbOP.executeQuery(strSQLQuery);
		while(rs.next())
			vPaymentIndex.addElement(rs.getString(1));
		rs.close();
		
		strSQLQuery = "select pmtmethod_index from fa_stud_pmtmethod where sy_from = "+strSYFrom+" and semester = "+strSemester+" and is_valid = 1 and "+
			" amount > 0 and user_index = "+strIDToUIndex+" and is_stud_temp = "+strIsTempTo;
		if(dbOP.getResultOfAQuery(strSQLQuery, 0) == null) {//get from wrong ID..
			strSQLQuery = "select pmtmethod_index from fa_stud_pmtmethod where sy_from = "+strSYFrom+" and semester = "+strSemester+" and is_valid = 1 and "+
				" user_index = "+strIDFromUIndex+" and is_stud_temp = "+strIsTempFr;
			rs = dbOP.executeQuery(strSQLQuery);
			while(rs.next())
				vPmtMethodIndex.addElement(rs.getString(1));
			rs.close();
		}
		if(vPaymentIndex.size() > 0) {
			strSQLQuery = "update fa_stud_payment set user_index = "+strIDToUIndex+", is_stud_temp = "+strIsTempTo+" where payment_index in ("+
							CommonUtil.convertVectorToCSV(vPaymentIndex)+")";
			dbOP.executeUpdateWithTrans(strSQLQuery, "fa_stud_payment", (String)request.getSession(false).getAttribute("login_log_index"), true);
			
			strErrMsg = "Payment Moved successfully.";
			if(vPmtMethodIndex.size() > 0) {
				strSQLQuery = "update fa_stud_pmtmethod set user_index = "+strIDToUIndex+", is_stud_temp = "+strIsTempTo+" where pmtmethod_index = "+
								vPmtMethodIndex.elementAt(0);
				dbOP.executeUpdateWithTrans(strSQLQuery, "fa_stud_pmtmethod", (String)request.getSession(false).getAttribute("login_log_index"), true);
			}
		}
		else {
			strErrMsg = "NO PAYMENT FOUND.";
		}		
				
	}
}	

%>


<form name="form_" action="./move_payment_swu.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: 
          MOVE STUDENT PAYMENT FROM WRONG ID ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" width="3%">&nbsp;</td>
      <td colspan="2"><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font> </td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="49%"><font color="#FF6600"><strong>WRONG ID (ACCEPTS TEMP/PERM ID) </strong></font></td>
      <td width="48%">CORRECT ID</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><input name="stud_id_fr" type="text" size="16" value="<%=WI.fillTextValue("stud_id_fr")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td><input name="stud_id_to" type="text" size="16" value="<%=WI.fillTextValue("stud_id_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>SY/term 
  <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
if(strTemp == null)
	strTemp = "";
%>	  
        <input name="sy_from" type="text" class="textbox" id="sy_from" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  value="<%=strTemp%>" size="4" maxlength="4"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"  onKeyUp="DisplaySYTo('form_','sy_from','sy_to');">
        
        <select name="semester" id="semester">
          <option value="1">1st</option>
  <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp == null)
	strTemp = "";

if(strTemp.compareTo("2") ==0)
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="2" <%=strErrMsg%>>2nd</option>
  <%if(strTemp.compareTo("3") ==0)
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="3"<%=strErrMsg%>>3rd</option>
  <%if(strTemp.compareTo("0") ==0)
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="0"<%=strErrMsg%>>Summer</option>
        </select>
      </td><td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td colspan="2" align="center"><a href="javascript:ReloadPage()"><img src="../../../images/form_proceed.gif" border="0"></a>
	  <font size="1"> Click to view information to be moved.</font></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
  </table>

<table width="100%" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
</table>
<input type="hidden" name="page_action">
<input type="hidden" name="prev_id_1" value="<%=WI.fillTextValue("stud_id_fr")%>">
<input type="hidden" name="prev_id_2" value="<%=WI.fillTextValue("stud_id_to")%>">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
