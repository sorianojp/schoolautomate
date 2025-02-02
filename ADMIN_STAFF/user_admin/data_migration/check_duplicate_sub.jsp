<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function CheckSubject() {
	document.form_.check_.value = "1";
	this.SubmitOnce('form_');
}
</script>

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
								"Admin/staff-System Administration->Data Migrate->Chk Subject","check_duplicate_sub.jsp");
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

CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"System Administration","Data Migrate",request.getRemoteAddr(),
														"check_duplicate_sub.jsp");
	//iAccessLevel = 2;
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
	
Vector vRetResult = null;
DataMigrate dm = new DataMigrate();
boolean bolRemoveDuplicate = false;
boolean bolKeepDupSubCode = true;
boolean bolChangeSearchOrder = false;

if(request.getParameter("check_") != null) {
	if(WI.fillTextValue("remove_dup").compareTo("1") == 0) 
		bolRemoveDuplicate = true;
	if(WI.fillTextValue("dup_sub_code").length() == 0) 
		bolKeepDupSubCode = false;
	if(WI.fillTextValue("chng_search_or").length()> 0) 
		bolChangeSearchOrder = true;
	if(WI.fillTextValue("check_").length() > 0) {
		vRetResult = dm.verifySubject(dbOP, bolRemoveDuplicate, bolKeepDupSubCode,bolChangeSearchOrder);
		strErrMsg = dm.getErrMsg();
	}
}


	

%>
<body >
<form action="./check_duplicate_sub.jsp" method="post" name="form_">
<%=WI.getStrValue(strErrMsg,"<font size=\"3\" color=\"#FF0000\"><strong>","</strong></font>","")%><br>
  <font size="3"><br>
  </font> 
<%
strTemp = WI.fillTextValue("dup_sub_code");
if(strTemp.compareTo("1") == 0 || request.getParameter("dup_sub_code") == null) 
	strTemp = "checked";
else	
	strTemp = "";
%>

  <input type="checkbox" value="1" name="dup_sub_code" <%=strTemp%>>
  <font color="#0000FF">Allow duplicate subject code.</font>
<%
strTemp = WI.fillTextValue("remove_dup");
if(strTemp.compareTo("1") == 0 ) 
	strTemp = "checked";
else	
	strTemp = "";
%>  <input type="checkbox" value="1" name="remove_dup" <%=strTemp%>>
  <font color="#0000FF">Auto Delete Duplicate entries (deletes if not used in 
  curriculum or class program)</font><br>
  
  <br><br>
  <%
strTemp = WI.fillTextValue("chng_search_or");
if(strTemp.compareTo("1") == 0 ) 
	strTemp = "checked";
else	
	strTemp = "";
%>  <input type="checkbox" value="1" name="chng_search_or" <%=strTemp%>>
  <font color="#0000FF">Change search order and try again (applicable only if 
  Auto Delete is selected)</font><br>
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  <div align="center"> <a href="javascript:CheckSubject()"><img src="../../../images/verify.gif" border="1" name="hide_move" width="70"></a><font size="1">Click 
    to Apply setting.</font> </div>
<br><br>  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr bgcolor="#FFFFAF"> 
      <td height="25" class="thinborder"><div align="center"><strong>LIST OF DUPLICATE 
          SUBJECT</strong></div></td>
      <td class="thinborder"><div align="center"><strong>LIST OF DUPLICATE SUBJECT</strong></div></td>
    </tr>
 <%for(int i = 0; vRetResult != null && i < vRetResult.size(); i += 3){%>
    <tr> 
      <td width="50%" height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 1)+" ::: "+(String)vRetResult.elementAt(i + 2)%></td>
      <td width="50%" class="thinborder">&nbsp;
	  <%
	  if(i < vRetResult.size() ){ i += 3;%>
	  <%=(String)vRetResult.elementAt(i + 1)+" ::: "+(String)vRetResult.elementAt(i + 2)%>
	  <%}%></td>
    </tr>
 <%}%>
  </table>
  <input type="hidden" name="check_">
</form>
</body>
</html>
<% 
dbOP.cleanUP();
%>
