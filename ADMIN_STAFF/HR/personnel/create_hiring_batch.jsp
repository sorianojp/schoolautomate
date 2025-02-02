<%@ page language="java" import="utility.*,java.util.Vector,hr.HRGeneric" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
	.fontsize10{
		font-size:11px;
	}
</style>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function PageAction(strPageAction, strInfoIndex){
	if(strPageAction == '0') {
		if(!confirm("Are you sure you want to remove this entry."))
			return;
	}
	
	document.form_.page_action.value=strPageAction;
	document.form_.preparedToEdit.value="";
	document.form_.info_index.value=strInfoIndex;
	document.form_.submit();
}
function prepareToEdit(strInfoIndex){
	document.form_.page_action.value="";
	document.form_.preparedToEdit.value="1";
	document.form_.info_index.value=strInfoIndex;
	document.form_.submit();
}
function ReloadPage(){
	document.form_.page_action.value="";
	document.form_.preparedToEdit.value="";
	document.form_.info_index.value="";
	document.form_.submit();
}
</script>

<body bgcolor="#663300" class="bgDynamic">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

	int iSearchResult = 0;
	
	if (WI.fillTextValue("print_page").equals("1")){ %>
	<jsp:forward page="./hr_stat_logout_print.jsp" />
<% return;	}
	
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-HR Management-Personnel-Manage Hiring Batch","create_hiring_batch.jsp");

	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","PERSONNEL",request.getRemoteAddr(),
														"create_hiring_batch.jsp");
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

HRGeneric hrGen   = new HRGeneric();
Vector vRetResult = null; Vector vEditInfo = null;
String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"), "0");
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(hrGen.operateOnHRHiringBatchPreload(dbOP, request, Integer.parseInt(strTemp)) != null) {
		strErrMsg = "Operation successful.";
		strPreparedToEdit = "0";
	}
	else	
		strErrMsg = hrGen.getErrMsg();
}
if(strPreparedToEdit.equals("1")) {
	vEditInfo = hrGen.operateOnHRHiringBatchPreload(dbOP, request, 3);
	if(vEditInfo == null) 
		strErrMsg = hrGen.getErrMsg();
}
vRetResult = hrGen.operateOnHRHiringBatchPreload(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = hrGen.getErrMsg();
%>
<form action="./create_hiring_batch.jsp" method="post" name="form_" >
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A" class="footerDynamic">
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF"><strong>::::MANAGE HIRING BATCH ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25">&nbsp;<%=WI.getStrValue(strErrMsg,"<strong><font size=\"3\" color=\"#FF0000\">","</font></strong>","")%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    
    <tr>
      <td height="25" class="fontsize10">&nbsp;Hiring Batch Name </td>
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("batch");
%>	  
      <td><input name="batch" value="<%=strTemp%>" type="text"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16" ></td>
    </tr>
    <tr> 
      <td width="14%" height="25" class="fontsize10"> &nbsp;Hiring Date </td>
      <td width="86%">
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("dur_fr");
%>	  
	  <input name="dur_fr" value="<%=strTemp%>" type="text"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16" > 
	  <a href="javascript:show_calendar('form_.dur_fr',<%=CommonUtil.getMMYYYYForCal()%>);" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
      to        
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(3);
else	
	strTemp = WI.fillTextValue("dur_to");
%>	  
      <input name="dur_to" value="<%=strTemp%>" type="text"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16" >
	  <a href="javascript:show_calendar('form_.dur_to',<%=CommonUtil.getMMYYYYForCal()%>);" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
      </td>
	</tr>
    <tr> 
      <td height="25" class="fontsize10"> &nbsp;Salary Range </td>
      <td>
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(4);
else	
	strTemp = WI.fillTextValue("sal_fr");
%>	  
	  <input name="sal_fr" value="<%=strTemp%>" type="text"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16" > 
      to 
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(5);
else	
	strTemp = WI.fillTextValue("sal_to");
%>	  
      <input name="sal_to" value="<%=strTemp%>" type="text"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16" ></td>
    </tr>
    <tr>
      <td height="25" class="fontsize10" valign="top"><br>&nbsp;Comments</td>
      <td>
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(6);
else	
	strTemp = WI.fillTextValue("note_");
%>	  
	  <textarea name="note_" class="textbox" cols="95" rows="5" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ><%=WI.getStrValue(strTemp)%></textarea>
	  
	  </td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="18">&nbsp;</td>
    </tr>
    
    <tr> 
      <td width="8%" height="25" align="center">
      <% if (iAccessLevel > 1){
		if (strPreparedToEdit.equals("0")){%>
            <a href="javascript:PageAction('1','');"><img src="../../../images/save.gif" border="0" name="hide_save"></a>
    	        <font size="1">click to save entries</font>
        <%}else{ %><font size="1">
             <a href="javascript:PageAction('2', '<%=vEditInfo.elementAt(0)%>');"><img src="../../../images/edit.gif" border="0"></a> click to save changes
			 <a href='./create_hiring_batch.jsp'><img src="../../../images/cancel.gif" border="0"></a> click to cancel and clear entries
			 </font>
        <%}
		}%>
	  </td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr align="center" style="font-weight:bold">
      <td height="25" colspan="7" class="thinborder" bgcolor="#FFFFCC">::: LIST OF AVAILABLE BATCH :::</td>
    </tr>
    <tr align="center" style="font-weight:bold"> 
      <td height="25" width="5%" class="thinborder">Count</td>
      <td width="20%" class="thinborder">Hiring Batch Name </td>
      <td width="15%" class="thinborder">Hiring Duration </td>
      <td width="15%" class="thinborder">Salary Range</td>
      <td width="30%" class="thinborder">Comments</td>
      <td width="7%" class="thinborder">Edit</td>
      <td width="8%" class="thinborder">Delete</td>
    </tr>
<%
int iCount = 0;
for(int i = 0; i < vRetResult.size(); i += 7){%>
    <tr>
      <td height="25" class="thinborder">&nbsp;<%=++iCount%></td>
      <td class="thinborder">&nbsp;<%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder">&nbsp;<%=vRetResult.elementAt(i + 2)%> - <%=vRetResult.elementAt(i + 3)%></td>
      <td class="thinborder">&nbsp;<%=vRetResult.elementAt(i + 4)%> - <%=vRetResult.elementAt(i + 5)%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i + 6), "&nbsp;")%></td>
      <td class="thinborder">&nbsp;
      <% if (iAccessLevel > 1){%>
            <a href="javascript:prepareToEdit('<%=vRetResult.elementAt(i)%>');"><img src="../../../images/edit.gif" border="0"></a>
	  <%}%>	  </td>
      <td class="thinborder">&nbsp;
      <% if (iAccessLevel == 2){%>
            <a href="javascript:PageAction('0','<%=vRetResult.elementAt(i)%>');"><img src="../../../images/delete.gif" border="0"></a>
	  <%}%>	  </td>
    </tr>
<%}%>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="footer">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="preparedToEdit" value="<%=strPreparedToEdit%>">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>