<%@ page language="java" import="utility.*,search.SearchStudent,enrollment.Authentication, java.util.Vector" %>
<%
boolean bolIsSchool = false;
if((new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript">
function PageAction(strAction, strInfoIndex) {
	if(strAction == '0') {
		if(!confirm('Are you sure you want to remove rfid as maser card.'))
			return;
	}
	document.form_.page_action.value = strAction;
	document.form_.info_index.value  = strInfoIndex;
	document.form_.submit();
}
</script>

<body bgcolor="#D2AE72" onLoad="document.id_number.focus();">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-user admin->Assign Turnstile Master Card.","assign_turnstile_mastercard.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
				"System Administration","User Management",request.getRemoteAddr(),
				null);

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../commfile/unauthorized_page.jsp");
	return;
}

Vector vRetResult = new Vector();
String strSQLQuery = null;
java.sql.ResultSet rs = null;

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(strTemp.equals("0")) {
		if(WI.fillTextValue("info_index").length() == 0)
			strErrMsg = "Reference index is missing";
		else
			strSQLQuery = "update user_Table set is_master_card = 0 where user_index = "+WI.fillTextValue("info_index");
	}
	else {	
		if(WI.fillTextValue("id_number").length() == 0)
			strErrMsg = "Enter Employee ID/RF ID to set as master card";
		else {
			//check if not employee
			strSQLQuery = "select user_index from user_Table where (id_number = '"+
				WI.fillTextValue("id_number")+"' or barcode_id = '"+WI.fillTextValue("id_number")+"') and (expire_Date is null or expire_date >='"+WI.getTodaysDate()+"')";
			String strUserIndex = dbOP.getResultOfAQuery(strSQLQuery, 0);
			if(strUserIndex == null) {
				strErrMsg = "ID/RFID not found.";
				strSQLQuery = null;
			}
			else {
				//check now if student
				strSQLQuery = "select auth_type_index from user_Table where user_index = "+strUserIndex;
				strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
				if(strSQLQuery != null && strSQLQuery.equals("4")) {
					strErrMsg = "ID/RFID belongs to student. Can't set student card as Master card.";
					strSQLQuery = null;
				}
				else
					strSQLQuery = "update user_Table set is_master_card = 1 where user_index = "+strUserIndex;
			}
		}
	}
	if(strSQLQuery != null) {
		if(dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false) < 1)
			strErrMsg = "Error in updating information.";
		else	
			strErrMsg = "Master card setting information updated successfully.";
	}
}

//view all
strSQLQuery = "select user_index, id_number, fname, mname, lname, barcode_id from user_Table where "+
" is_valid =1 and (expire_Date is null or expire_date >='"+WI.getTodaysDate()+"') and is_master_Card = 1 order by lname";
rs = dbOP.executeQuery(strSQLQuery);
while(rs.next()) {
	vRetResult.addElement(rs.getString(1));//[0] user_index
	vRetResult.addElement(rs.getString(2));//[1] id_number
	vRetResult.addElement(WebInterface.formatName(rs.getString(3),rs.getString(4),rs.getString(5),4));//[2] Name
	vRetResult.addElement(rs.getString(6));//[3] barcode_id
}
rs.close();


%>
<form action="./assign_turnstile_mastercard.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          RF ID MANAGEMENT PAGE ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="10%" class="thinborderNONE">ID/RFID Number</td>
      <td width="20%"><input type="text" name="id_number" value="<%=WI.fillTextValue("id_number")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="67%">
	  <a href="javascript:PageAction('1','');"><img src="../../images/update.gif" border="0"></a><font size="1">click to set rfid as Master Card</font>		</td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="3%" height="18">&nbsp;</td>
      <td width="10%">&nbsp;</td>
      <td width="25%">&nbsp;</td>
      <td width="28%">&nbsp;</td>
      <td width="34%">&nbsp;</td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="66%" height="25">&nbsp;</td>
      <td width="16%" height="25">&nbsp;</td>
      <td width="18%" align="right">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="3" bgcolor="#B9B292"><div align="center"><strong><font color="#FFFFFF">::: LIST OF MASTER CARD AREADY SET ::: </font></strong></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr align="center" style="font-weight:bold"> 
      <td  width="5%" height="25" class="thinborder"><font size="1">Count</font></td>
      <td width="21%" class="thinborder"><font size="1">ID Number </font></td>
      <td width="36%" class="thinborder"><font size="1">Name</font></td>
	  <td width="22%" class="thinborder"><font size="1">RFID Number </font></td>
      <td width="16%" class="thinborder"><font size="1">REMOVE</font></td>
    </tr>
	<%for(int i =0; i < vRetResult.size(); i += 4) {%>
		<tr>
		  <td height="25" class="thinborder"><%=i/4 + 1%></td>
		  <td class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
		  <td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
		  <td class="thinborder"><%=vRetResult.elementAt(i + 3)%></td>
		  <td class="thinborder" align="center"><a href="javascript:PageAction('0','<%=vRetResult.elementAt(i)%>');"><img src="../../images/delete.gif" border="0"></a></td>
		</tr>
	<%}%>
  </table>
<%}//vRetResult is not null
%>
  <table  bgcolor="#ffffff" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25">&nbsp;</td>
  </tr>
  <tr>
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="info_index">
<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>