<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.submit();
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
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
boolean bolIsCGH = strSchCode.startsWith("CGH");

java.sql.ResultSet rs = null;
int iPageAction = Integer.parseInt(WI.getStrValue(WI.fillTextValue("page_action"), "-1"));
if(iPageAction == 0) {
	if(dbOP.executeUpdateWithTrans("delete from gwa_extn where gwa_index="+WI.fillTextValue("info_index"),
		null,null,false) == -1)
		strErrMsg = "Delete operation failed.";
	else	
		strErrMsg = "Delete operation is successful.";
}
else if(iPageAction == 1) {
	String strGrade        = WI.fillTextValue("grade");
	String strGradePercent = WI.fillTextValue("grade_percent");
	String strRemarkIndex  = WI.fillTextValue("remark_index");
	if(strGrade.length() == 0) {
		strErrMsg = "Please enter grade.";
	}
	if(strGradePercent.length() == 0) {
		if(bolIsCGH) 
			strErrMsg = "Grade percentage value can't be empty.";
		else
			strGradePercent = null;
	}
	
	if(strErrMsg == null) {
		rs = dbOP.executeQuery("select count(*) from gwa_extn where remark_index = "+strRemarkIndex);
		if(rs.next() && rs.getInt(1) > 0)
			strErrMsg = "Grade for this remark exists.";
		rs.close();
		if(strErrMsg == null) {
			iPageAction = 
				dbOP.executeUpdateWithTrans("insert into gwa_extn (GRADE,GRADE_PERCENT,REMARK_INDEX) values ("+
				strGrade+","+strGradePercent+","+strRemarkIndex+")" ,null,null,false);
			if(iPageAction == -1)
				strErrMsg = "Error in adding grade.";
			else	
				strErrMsg = "Information added successfully.";
		} 
	}
}
%>

<form name="form_" action="./gwa_fail_grade.jsp" method="post">
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="4" align="center"><font color="#FFFFFF"><strong>:::: 
        GWA GRADE EQUIVALENT PAGE ::::</strong></font></td>
    </tr>
    <tr> 
      <td width="1%" height="25" >&nbsp;</td>
      <td height="25" colspan="3" >&nbsp;&nbsp;&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr> 
      <td width="1%" height="25" >&nbsp;</td>
      <td width="4%" height="25" >&nbsp;</td>
      <td width="15%" >Remark</td>
      <td width="80%" >
	  <select name="remark_index">
		<%=dbOP.loadCombo("REMARK_INDEX","REMARK +' ::: '+remark_abbr",
			" from REMARK_STATUS where IS_DEL=0 and is_internal = 1 "+
			"and remark not like 'pass%'",null,false,false)%>	
	  </select>
	  </td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td >&nbsp;</td>
      <td >Grade</td>
      <td >
	  <input name="grade" type="text" size="3" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';"
  	  onKeyPress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;">
	  </td>
    </tr>
<%if(bolIsCGH){%>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td >&nbsp;</td>
      <td >Grade %ge </td>
      <td >
	  <input name="grade_percent" type="text" size="3" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';"
  	  onKeyPress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;">
	  </td>
    </tr>
<%}%>
    <tr>
      <td height="25" >&nbsp;</td>
      <td >&nbsp;</td>
      <td >&nbsp;</td>
      <td >&nbsp;<input type="image" src="../../../images/save.gif" border="0" onClick="document.form_.page_action.value=1">
	  <font size="1">Click to save information.</font></td>
    </tr>
    
    <tr> 
      <td colspan="4" height="10" >&nbsp;</td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr bgcolor="#FFFFCC">
      <td width="25%" height="25" class="thinborder">&nbsp;Grade</td>
      <td width="25%" class="thinborder">&nbsp;Grade %ge </td>
      <td width="25%" class="thinborder">&nbsp;Remark </td>
      <td width="25%" class="thinborder">&nbsp;Remove </td>
    </tr>
<%rs = dbOP.executeQuery("select GWA_INDEX,GRADE,GRADE_PERCENT,remark,REMARK_abbr from gwa_extn "+
	  "join remark_status on (remark_status.remark_index = gwa_extn.remark_index) order by remark_abbr");
  while(rs.next()){%>
    <tr >
      <td height="25" class="thinborder">&nbsp;<%=rs.getString(2)%></td>
      <td class="thinborder">&nbsp;<%=rs.getString(3)%></td>
      <td class="thinborder">&nbsp;<%=rs.getString(4)%> ::: <%=rs.getString(5)%></td>
      <td class="thinborder">&nbsp;
	  	<input type="image" src="../../../images/delete.gif" 
		onClick="document.form_.page_action.value=0;document.form_.info_index.value=<%=rs.getString(1)%>"></td>
    </tr>
<%}
rs.close();%>
  </table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable4">
    <tr>
      <td colspan="8" height="25">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="8" height="25" bgcolor="#A49A6A">&nbsp;</td>
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
