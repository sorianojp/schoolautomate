<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script src="../../../jscript/common.js"></script>
<script src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function setValue(strIsFromVal,strValue, strIndexVal) {
	var frIndex;
	var toIndex;
	if(strIsFromVal == "1") {
		document.form_.from_index.value = strIndexVal;
		window.opener.document.form_.id_fr.value = strValue;
	}
	else {	
		document.form_.to_index.value = strIndexVal;
		window.opener.document.form_.id_to.value = strValue;
	}
	frIndex = document.form_.from_index.value;
	toIndex = document.form_.to_index.value;
	if(frIndex.length > 0 && toIndex.length > 0) {
		if(eval(frIndex) > eval(toIndex)){
			alert("To selection must be greater than From selection");
			return;
		}
	}
}
</script>
<%@ page language="java" import="utility.*,lms.LmsUtil,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;

//add security here.
	try
	{
		dbOP = new DBOperation();
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


//end of authenticaion code.


java.sql.ResultSet rs = null;
%>
<body bgcolor="#D0E19D">
<form action="./search_patron.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td height="20" colspan="5" bgcolor="#9FC081" class="thinborder"><div align="center"><font size="1"><strong>::: STUDENT WITH BOOK ISSUED ::: </strong></font></div></td>
    </tr>
    <tr> 
      <td width="15%" height="25" class="thinborder"><div align="center"><strong><font size="1">ID #</font></strong></div></td>
      <td width="55%" class="thinborder"><div align="center"><strong><font size="1">NAME (LNAME, FNAME, MI) </font></strong></div></td>
      <td width="10%" class="thinborder" align="center"><strong><font size="1">FROM</font></strong></td>
      <td width="10%" class="thinborder" align="center"><strong><font size="1">TO</font></strong></td>
    </tr>
	<%
	//I have to get here patron type infomration.
	strTemp = WI.fillTextValue("pat_index");
	String strSQLQuery = "";
	if(strTemp.length() > 0) {//i have to filter patron only.. 
		boolean bolIsStud = false;
		rs = dbOP.executeQuery("select PATRON_TYPE from LMS_PATRON_TYPE where PATRON_TYPE_INDEX in ("+strTemp+")");
		while(rs.next()) {
			if(rs.getString(1).toLowerCase().equals("student")) {
				bolIsStud = true;
				break;
			}
		}
		rs.close();
		if(!bolIsStud)
			strSQLQuery = " and exists (select * from LMS_USER_PATRON_TYPE where "+
				"LMS_USER_PATRON_TYPE.user_index = user_table.user_index and PATRON_TYPE_INDEX in ("+
				strTemp+") )";
		else 
			strSQLQuery = " and (exists (select * from LMS_USER_PATRON_TYPE where "+
				"LMS_USER_PATRON_TYPE.user_index = user_table.user_index and PATRON_TYPE_INDEX in ("+
				strTemp+")) or user_table.AUTH_TYPE_INDEX = 4)";
			
	}
	if(WI.fillTextValue("frm_accountability").length() > 0) 
		strSQLQuery = "select distinct id_number, fname,mname,lname from user_table "+
						"where (exists (select * from lms_book_issue where DATE_RETURNED is null and "+
						"lms_book_issue.user_index = user_table.user_index) or exists ("+
						"select * from LMS_BOOK_FINE where LMS_BOOK_FINE.user_index = user_table.user_index "+
						" and FINE_BALANCE > 0)) order by lname,fname";
	else	
		strSQLQuery = "select distinct id_number, fname,mname,lname from lms_book_issue "+
						"join user_table on (user_table.user_index = lms_book_issue.user_index) "+
						"where DATE_RETURNED is null"+strSQLQuery+
						"order by lname,fname";
	rs = dbOP.executeQuery(strSQLQuery);
	int i = 0; 
	while(rs.next()) {++i;%>	
		<tr>
		  <td height="25" class="thinborder"><%=rs.getString(1)%></td>
		  <td class="thinborder">
		  <%=WebInterface.formatName(rs.getString(2),rs.getString(3), rs.getString(4), 4)%></td>
		  <td class="thinborder" align="center"><input type="radio" name="from_val" onClick="javascript:setValue('1','<%=rs.getString(1)%>','<%=i%>');"></td>
		  <td class="thinborder" align="center"><input type="radio" name="to_val" onClick="javascript:setValue('0','<%=rs.getString(1)%>','<%=i%>');"></td>
		</tr>
	<%}rs.close();%>
  </table>

<input type="hidden" name="from_index" value="<%=WI.fillTextValue("from_index")%>">
<input type="hidden" name="to_index" value="<%=WI.fillTextValue("to_index")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>