<%@ page language="java" import="utility.*, citbookstore.BookOrders, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
	boolean bolIsCIT = strSchCode.startsWith("CIT");
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<title>Ordering</title></head>
<script language="javascript" src="../../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript" src="../../../../jscript/date-picker.js"></script>
<script language="javascript">
function UpdateBookExpiration(){
	document.form_.page_action.value='1';
	document.form_.submit();
}
function deleteOrders() {
	document.form_.page_action.value = '1';
	document.form_.submit();
}
function GoBack(){
	location = "../../book_magement_settings_main.jsp";
}
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"BOOKSTORE-EXPIRED","expiration_setting.jsp");
	}
	catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
	<%
		return;
	}
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("BOOKSTORE"),"0"));
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../../../../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		if(iAccessLevel == 0){
			response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
			return;
		}
	}
	//end of security
	
	Vector vRetResult = new Vector();
	BookOrders BO = new BookOrders();
	strErrMsg = "";
	String strSQLQuery = null;
	if(WI.fillTextValue("page_action").length() > 0){
		String strAuthID = (String)request.getSession(false).getAttribute("userIndex");
    	if(strAuthID == null)
      		strErrMsg = "You are logged out. Please login again.";      		
        else{
			String strLimit = WI.getStrValue(WI.fillTextValue("_limit"),"0");
			if(strLimit.equals("0"))
				strErrMsg = "Day(s) of duration must not be empty or equal to zero.";
			else{
				strSQLQuery = " update bs_book_expire_setting set duration="+WI.fillTextValue("_limit") +
					", LAST_MOD_BY="+strAuthID+", LAST_MOD_DATE='"+WI.getTodaysDate()+"' ";	
				
				if (dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false) == -1)
					strErrMsg = "Error in SQLQuery";
				else
					strErrMsg = "Update Successfully";
			}
		}
	}
	
	
	//if(!BO.delExpiredOrder(dbOP,request))
	//	strErrMsg = BO.getErrMsg();

	strSQLQuery = " select duration from bs_book_expire_setting where is_valid=1";
	strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery,0); 
	if(strSQLQuery == null)		
		strErrMsg = "Book Expiration not set.";
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./expiration_settings.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: BOOK EXPIRATION SETTING ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td colspan=""><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
			<td width="10%" align="right"><a href="javascript:GoBack();"><img src="../../../../images/go_back.gif" border="0" /></a></td>
		</tr>
	</table>
	
	<table width="100%" border="0" bgcolor="#FFFFFF">    
    <tr>
      <td>&nbsp;</td>
      <td>Current Book Expiration Duration</td>
      <td>Duration Setting</td>
    </tr>
    <tr>
      <td width="13%">&nbsp;</td>
      <td width="34%">&nbsp;<%=strSQLQuery%> Day(s)</td>
      <td><input type="text" name="_limit" value="<%=WI.fillTextValue("_limit")%>" 
	  				class="textbox"
	  				onfocus="style.backgroundColor='#D3EBFF'"
	  				onBlur="AllowOnlyInteger('form_','_limit');style.backgroundColor='white';" 
	  				onkeyup="AllowOnlyInteger('form_','_limit')"
	  				maxlength="2" size="3"/> Day(s)</td>
	  
	  
	</tr>
    
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td width="53%">&nbsp;</td>
    </tr>
<%
if(iAccessLevel == 2){%>    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><input type="image" onClick="UpdateBookExpiration();" src="../../../../images/update.gif">
        <font size="1">Click to update expiration</font></td>
    </tr>
<%}%>
    <tr>
      <td height="22">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td colspan="3">&nbsp;</td>
    </tr>
  </table>
	

	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="3" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="page_action"/>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
