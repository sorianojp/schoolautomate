<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
	.textbox_noborder2{
		font-family:Verdana, Arial, Helvetica, sans-serif;
		font-size:11px;
		border:none;
	}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function DelAll() {
	if(!confirm('Are you sure you want to remvoe this fee from all courses.'))
		return;
		
	document.form_.del_all.value='1';
	document.form_.submit();
}
function DelOne(strInfoIndex) {
	if(!confirm('Are you sure you want to remvoe this fee from one course.'))
		return;
		
	document.form_.del_all.value='';
	document.form_.info_index.value=strInfoIndex;
	document.form_.submit();
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.ReportFeeAssessment,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
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
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","FEE MAINTENANCE",request.getRemoteAddr(),
														"print_oth_charge_per_subj_fee_del.jsp");
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

Vector vRetResult  = new Vector();
String strSYIndex  = null;
String strSYFrom   = WI.fillTextValue("syf");
String strCatgIndex= WI.fillTextValue("catg");
String strFeeName  = WI.fillTextValue("fee");
String strSQLQuery = null;

if(strSYFrom.length() > 0) {
	strSQLQuery = "select sy_index from fa_schyr where sy_from = "+strSYFrom;
	strSYIndex  = dbOP.getResultOfAQuery(strSQLQuery, 0);
}


if(strSYIndex != null && strFeeName.length() > 0 && strCatgIndex.length() > 0) {
	strSQLQuery = null;
	if(WI.fillTextValue("del_all").length() > 0) {
		strSQLQuery = "update fa_misc_fee set is_valid = 0, is_del = 2, last_mod_date = '"+WI.getTodaysDate()+"', "+
		"last_mod_by = "+(String)request.getSession(false).getAttribute("userIndex")+" where is_valid = 1 and "+
		"sy_index = "+strSYIndex+" and catg_index = "+strCatgIndex+
		" and misc_other_charge = 1 and fee_name = '"+ConversionTable.replaceString(strFeeName, "'","''")+"'";
	}
	else if(WI.fillTextValue("info_index").length() > 0) {
		strSQLQuery = "update fa_misc_fee set is_valid = 0, is_del = 2, last_mod_date = '"+WI.getTodaysDate()+"', "+
		"last_mod_by = "+(String)request.getSession(false).getAttribute("userIndex")+" where misc_fee_index = "+WI.fillTextValue("info_index"); 
	}
	if(strSQLQuery != null) {
		if(dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false) == -1)
			strErrMsg = "Removing of fees failed.";
		else
			strErrMsg = "Fees Removed successfully.";
	}
	strSQLQuery = "select fa_misc_fee.misc_fee_index,course_offered.course_code, course_name, major.course_code,major_name, "+
					"semester, year_level, amount from fa_misc_fee "+
					"join course_offered on (course_offered.course_index = fa_misc_fee.course_index) "+
					"left join major on (major.major_index = fa_misc_fee.major_index) "+
					"where fa_misc_fee.is_valid = 1 and sy_index = "+strSYIndex+" and catg_index = "+strCatgIndex+
					" and fee_name = '"+ConversionTable.replaceString(strFeeName, "'","''")+"'";
	java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		vRetResult.addElement(rs.getString(1));//[0] misc_fee_index
		vRetResult.addElement(rs.getString(2)+" ::: "+rs.getString(3));//[1] course_code 
		if(rs.getString(4) == null)
			vRetResult.addElement("&nbsp;");
		else
			vRetResult.addElement(rs.getString(4)+" ::: "+rs.getString(5));//[2] major.course_code
		
		vRetResult.addElement(rs.getString(6));//[3] semester
		vRetResult.addElement(rs.getString(7));//[4] year_level
		vRetResult.addElement(CommonUtil.formatFloat(rs.getDouble(8), true));//[5] Amount
	}
	rs.close();
}

if(strSYIndex == null)
	strErrMsg = "SY Information not created.";

%>


<form name="form_" action="./print_oth_charge_per_subj_fee_del.jsp" method="post">
<input type="hidden" name="syf" value="<%=WI.fillTextValue("syf")%>">
<input type="hidden" name="catg" value="<%=WI.fillTextValue("catg")%>">
<input type="hidden" name="fee" value="<%=WI.fillTextValue("fee")%>">

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td height="24" colspan="3"><div align="center"><font color="#FFFFFF"><strong>:::: Courses having the Fee ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="22" colspan="3">&nbsp;&nbsp;<b><font size="3"><%=WI.getStrValue(strErrMsg)%></font></b></td>
    </tr>
    <tr>
      <td width="5%" height="22">&nbsp;</td>
      <td width="26%">Fee Name </td>
      <td width="69%"><strong><%=WI.fillTextValue("fee")%></strong></td>
    </tr>
	<tr>
      <td height="22">&nbsp;</td>
      <td>Subject Category </td>
      <td><strong><%=dbOP.getResultOfAQuery("select catg_name from subject_Catg where catg_index = "+strCatgIndex, 0)%></strong></td>
	</tr>

    <tr>
      <td height="22">&nbsp;</td>
      <td>&nbsp;</td>
      <td style="font-weight:bold; font-size:9px;">
	  <%if(vRetResult != null && vRetResult.size() > 0) {%>
	  	<a href="javascript:DelAll();"><img src="../../../images/delete.gif" border="0"></a> Delete All
	  <%}%>
	  </td>
    </tr>
  </table>

<%
if(vRetResult != null && vRetResult.size() > 0) {
	String[] convertYearLevel = {"ALL","1ST YEAR","2ND YEAR","3RD YEAR","4TH YEAR","5TH YEAR","6TH YEAR","7TH YEAR","8TH YEAR"};
	String[] strConvertSem    = {"SUMMER","1ST","2ND","3RD","4TH","ALL"};
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#DDDDDD">
      <td height="22" colspan="11" class="thinborder"><div align="center"><strong><font size="1">
	  LIST OF COURSES HAVING FEE</font></strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr align="center" style="font-weight:bold">
      <td width="50%" height="22" class="thinborder"><strong><font size="1">Course</font></strong></td>
      <td width="25%" class="thinborder"><font size="1">Major Code </font></td>
      <td width="5%" class="thinborder"><font size="1">Sem</font></td>
      <td width="5%" class="thinborder"><font size="1">Year Level </font></td>
      <td width="10%" class="thinborder"><font size="1">Amount</font></td>
      <td width="5%" class="thinborder">Delete</td>
    </tr>
<%
for(int i = 0; i< vRetResult.size() ; i+=6) {
%>
    <tr>
      <td height="22" class="thinborder" style="font-size:10px"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder" style="font-size:10px"><%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder" style="font-size:10px"><%=strConvertSem[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i + 3), "5"))]%></td>
      <td class="thinborder" style="font-size:10px"><%=convertYearLevel[Integer.parseInt((String)vRetResult.elementAt(i + 4))]%></td>
      <td align="right" class="thinborder" style="font-size:10px"><%=vRetResult.elementAt(i + 5)%></td>
      <td align="center" class="thinborder" style="font-size:10px"><a href='javascript:DelOne("<%=vRetResult.elementAt(i)%>");'>Delete</a></td>
    </tr>
<%
	}//end of displaying levels
%>
  </table>
<%}//if condition%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable2">
    <tr bgcolor="#FFFFFF">
      <td height="22" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="22" colspan="9">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="del_all" />
<input type="hidden" name="info_index" />

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
