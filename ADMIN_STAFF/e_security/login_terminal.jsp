<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
body {
	background-color: #D2AE72;
}
-->
</style></head>
<script language="JavaScript">
function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
function ReloadPage() {
	document.form_.page_action.value = "";
	document.form_.info_index.value = "";
	document.form_.submit();
}

function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function focusID() {
	document.form_.login_ip.focus();
}
</script>
<body onLoad="focusID();">
<%@ page language="java" import="utility.*,eSC.CampusQuery,java.util.Vector " buffer="16kb" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp   = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eSecurity Check-Login Terminal","login_terminal.jsp");
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
														"eSecurity Check","Login Terminals",request.getRemoteAddr(), 
														"login_terminal.jsp");	
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

//end of authenticaion code.
	CampusQuery libAtt = new CampusQuery(request);
	Vector vRetResult = null;

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(libAtt.operateOnESecLoginTerminal(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = libAtt.getErrMsg();
		else {
			if(strTemp.equals("0"))
				strErrMsg = "E-Security Login Terminal successfully removed.";
			if(strTemp.compareTo("1") == 0)
				strErrMsg = "E-Security Login Terminal successfully added.";
		}
	}

	vRetResult = libAtt.operateOnESecLoginTerminal(dbOP, request,4);
	
%>
<form action="./login_terminal.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A8A8D5">
      <td height="25" colspan="3" align="center" bgcolor="#A49A6A"><font color="#FFFFFF" ><strong>:::: 
      E-SECURITY ATTENDANCE - ASSIGN PC FOR USERS LOGIN ::::</strong></font></td>
    </tr>
    <tr>
      <td width="4%" height="25">&nbsp; </td>
      <td colspan="2"><font size="3" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>

    <tr> 
      <td width="4%">&nbsp;</td>
      <td width="22%"><strong><font size="1" >IP ADDRESS : </font></strong></td>
      <td width="74%">
      <input name="login_ip" type="text" maxlength="15" value="<%=WI.fillTextValue("login_ip")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;">      </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td><font size="1" ><strong>LOCATION :</strong></font></td>
      <td> 
<select name="loc_index" 
			style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 13;">
<%=dbOP.loadCombo("LOCATION_INDEX","LOC_NAME"," from ESC_LOGIN_LOC order by LOC_NAME", WI.fillTextValue("loc_index"),false)%> </select>
        <font size="1" ><a href='javascript:viewList("ESC_LOGIN_LOC","LOCATION_INDEX","LOC_NAME","LOCATION",
		"ESC_TIN_TOUT,ESC_TIN_TOUT,ESC_LOGIN_IP",
		"ESC_TIN_TOUT.LOC_INDEX_TIN,ESC_TIN_TOUT.LOC_INDEX_TOUT,ESC_LOGIN_IP.LOCATION_INDEX",
		" and ESC_TIN_TOUT.is_del = 0 and ESC_TIN_TOUT.is_valid = 1, " + 
		" and ESC_TIN_TOUT.is_del = 0 and ESC_TIN_TOUT.is_valid = 1, " + 
		" and ESC_LOGIN_IP.is_del = 0 ","","loc_index");'>
		<img src="../../images/update.gif" width="60" height="26" border="0"></a></font>      </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td><font size="1" ><strong>LOCATION USED FOR :</strong></font></td>
      <td>
	  <select name="io_stat">
	  <option value="0">In Only</option>
<%
strTemp = WI.fillTextValue("io_stat");
if(strTemp.length() == 0 || strTemp.equals("1")) 
	strTemp = " selected";
else	
	strTemp = "";
%>
		<option value="1" <%=strTemp%>>In and Out</option>
	  
	  </select>
	  </td>
    </tr>
    <%
if(iAccessLevel > 1){%>
    <tr> 
      <td height="40" colspan="3" align="center"> <a href='javascript:PageAction(1,"");'><img src="../../images/save.gif" width="48" height="28" border="0"></a><font size="1" >click 
        to save entries/changes <a href="./login_terminal.jsp"><img src="../../images/cancel.gif" width="51" height="26" border="0"></a>click 
        to clear entries</font></td>
    </tr>
    <tr>
      <td height="28" colspan="3">&nbsp;</td>
    </tr>
    <%}%>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#A8A8D5" > 
      <td height="25" colspan="4" align="center" bgcolor="#A49A6A" class="thinborder"><font color="#ffffff"><strong>LIST 
      OF ASSIGNED PC FOR USERS LOGIN</strong></font></td>
    </tr>
    <tr > 
      <td width="28%" height="25" align="center" class="thinborder"><strong>IP Address</strong></td>
      <td width="44%" align="center" class="thinborder"><strong>Location</strong></td>
      <td width="18%" align="center" class="thinborder"><b>In/Out Status </b></td>
      <td width="10%" class="thinborder">&nbsp;</td>
    </tr>
    <%
for(int i = 0; i < vRetResult.size(); i += 5){%>
    <tr > 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 3)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 4)%></td>
      <td class="thinborder"> <%if(iAccessLevel == 2){%> <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'> 
        <img src="../../images/delete.gif" width="55" height="28" border="0"></a> <%}%> </td>
    </tr>
    <%}%>
  </table>
<%}//if vRetResult not null
%>

<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>