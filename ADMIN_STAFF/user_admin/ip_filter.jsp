<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>IP FILTER</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript">
function AddAuthentication()
{
	document.page_auth.page_action.value = "1";
}
function DeleteAuthentication(strInfoIndex)
{
	document.page_auth.info_index.value = strInfoIndex;
	document.page_auth.page_action.value = "0";
}
function ReloadPage()
{
	document.page_auth.reloadPage.value="1";
	document.page_auth.page_action.value = "";
	document.page_auth.submit();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String[] strAccessStatus = {"Allowed","Allowed","<font color='red'>Blocked</font>","<font color='red'>Blocked</font>"};
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-IP FILTER","ip_filter.jsp");

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
														"System Administration","IP FILTER",request.getRemoteAddr(),
														"ip_filter.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)
{
	dbOP.cleanUP();
	response.sendRedirect("../../commfile/unauthorized_page.jsp");
	return;
}

//IP filter authentication added here.
//ADMINISTROTRS,ADMIN STAFF, FACULTY/ACAD. ADMIN, PARENTS/STUDENTS, eDTR(daily time recording)
IPFilter ipFilter  = new IPFilter();
int iIPAccessLevel = ipFilter.isAuthorizedIP(dbOP,(String)request.getSession(false).getAttribute("userId"), 
                            "IP FILTER","System Administration","IP FILTER",
							"ip_filter.jsp",request.getRemoteAddr());

if(iIPAccessLevel != 1)//for error while checking.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",ipFilter.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
//end of authenticaion code.

Vector vAuthList = new Vector();
String strPageAction = WI.fillTextValue("page_action");
if(strPageAction.length() > 0)
{
	if(ipFilter.operateOnIPFilter(dbOP,request,Integer.parseInt(strPageAction)) != null)
		strErrMsg = "Operation successful";
	else
		strErrMsg = ipFilter.getErrMsg();
}
vAuthList = ipFilter.operateOnIPFilter(dbOP,request,2);


if(strErrMsg == null) strErrMsg = "";

%>


<form name="page_auth" action="./ip_filter.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          IP FILTER PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="100%" height="25">&nbsp;&nbsp;&nbsp;&nbsp;<strong><%=strErrMsg%></strong></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" width="1%">&nbsp;</td>
      <td width="44%">IP Filter Target : 
        <select name="filter_target" onChange="ReloadPage();">
          <option value="0">Module/Sub-module IP Filter</option>
          <%
strTemp = WI.fillTextValue("filter_target");
if(strTemp.compareTo("1") ==0){
%>
          <option value="1" selected>Page level IP Filter</option>
          <%}else{%>
          <option value="1">Page level IP Filter</option>
          <%}%>
        </select> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
        <a href='javascript:Help("../../onlinehelp/ipfilter_help.htm");'><img src="../../images/online_help.gif" border="0"></a></td>
      <td width="55%">&nbsp;</td>
    </tr>
<tr>
<td colspan="3"><hr size="1"></td>
</tr>

    <% 
if(WI.fillTextValue("filter_target").compareTo("1") ==0){%>
    
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">Page URL (page name only) :&nbsp; 
        <input type="text" name="page_url" value="<%=WI.fillTextValue("page_url")%>" class="textbox" size="65" maxlength="64"
	  onfocus="style.backgroundColor='#D3EBFF';style.color='red';" onblur="style.backgroundColor='white';style.color='black'" style="font-weight:bold;"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">Description on this page URL : 
        <input type="text" name="url_desc" value="<%=WI.fillTextValue("url_desc")%>" class="textbox" size="65" maxlength="128"
	  onfocus="style.backgroundColor='#D3EBFF';style.color='red';" onblur="style.backgroundColor='white';style.color='black'" style="font-weight:bold;"></td>
    </tr>
    <%}else{%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Modules to access : 
        <select name="main_module" onChange="ReloadPage();">
          <option value="0">All</option>
          <%=dbOP.loadCombo("MODULE_INDEX","MODULE_NAME"," from IPFILTER_MODULE where IS_DEL=0 order by MODULE_INDEX asc", request.getParameter("main_module"), false)%> 
        </select></td>
      <td>Sub-modules : 
        <select name="sub_module">
          <option value="0">All</option>
          <%
strTemp = WI.fillTextValue("main_module");
if(strTemp.length() ==0) strTemp = "0";
strTemp = " from IPFILTER_SUB_MODULE where is_del=0 and module_index="+strTemp+" order by sub_mod_name";
%>
          <%=dbOP.loadCombo("SUB_MOD_INDEX","SUB_MOD_NAME",strTemp, request.getParameter("sub_module"), false)%> 
        </select></td>
    </tr>
    <%}//only if filter target is selected for module-submodule
%>
<tr>
<td colspan="3"><hr size="1"></td>
</tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">IP Address : 
        <select name="search_con">
          <option value="0">Allow one IP</option>
          <%
strTemp = WI.fillTextValue("search_con");
if(strTemp.compareTo("1") ==0){
%>
          <option value="1" selected>Allow all IP starts With</option>
          <%}else{%>
          <option value="1">Allow all IP starts with</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>Block one IP</option>
          <%}else{%>
          <option value="2">Block one IP</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>Block all IPs start with</option>
          <%}else{%>
          <option value="3">Block all IPs start with</option>
          <%}%>
        </select> &nbsp;&nbsp;&nbsp; <input type="text" name="ip_address" value="<%=WI.fillTextValue("ip_address")%>" class="textbox" size="16" maxlength="15"
	  onfocus="style.backgroundColor='#D3EBFF';style.color='red';" onblur="style.backgroundColor='white';style.color='black'" style="font-weight:bold;"> 
      </td>
    </tr>
    <%
if( iAccessLevel >1){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><div align="right"> 
          <input type="image" src="../../images/save.gif" onClick="AddAuthentication();">
          <font size="1">click to save entries</font></div></td>
      <td>&nbsp;</td>
    </tr>
    <%}%>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="5" bgcolor="#B9B292"><div align="center">LIST OF 
          AUTHORIZED IP ADDRESS</div></td>
    </tr>
</table>
<% 
if(WI.fillTextValue("filter_target").compareTo("1") !=0)
{%>
	  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
		<tr> 
		  <td height="25" width="20%"><div align="center"><font size="1"><strong>MODULES</strong></font></div></td>
		  <td width="39%"><div align="center"><strong><font size="1">SUB-MODULES</font></strong></div></td>
		  <td width="15%"> <div align="center"><font size="1"><strong>IP ADDRESS</strong></font></div></td>
		  <td width="13%" align="center"><strong><font size="1">STATUS</font></strong></td>
		  <td width="13%" align="center">&nbsp;</td>
		</tr>
	<%
	if(vAuthList != null && vAuthList.size() > 0){
	//System.out.println(vAuthList);
		for(int i = 0; i< vAuthList.size(); ++i)
		{
			strTemp = (String)vAuthList.elementAt(i+1);
			if(strTemp == null || strTemp.compareTo("0") ==0) strTemp = "ALL";
			else	strTemp = WI.getStrValue(vAuthList.elementAt(i+1));
		
			strTemp2 = (String)vAuthList.elementAt(i+2);
			if(strTemp2 == null || strTemp2.compareTo("0") ==0) strTemp2 = "ALL";
			else	strTemp2 = WI.getStrValue(vAuthList.elementAt(i+2),"&nbsp;");
		%>
			<tr> 
			  <td height="25" align="center"><%=strTemp%></td>
			  <td align="center"><%=strTemp2%></td>
			  <td align="center"><%=(String)vAuthList.elementAt(i+3)%></td>
			  <td align="center"><%=strAccessStatus[Integer.parseInt((String)vAuthList.elementAt(i+4))]%></td>
			  <td align="center"> 
				<%
				if(iAccessLevel ==2){%>
				<input type="image" src="../../images/delete.gif" onClick='DeleteAuthentication("<%=(String)vAuthList.elementAt(i)%>");'> 
				<%}else{%>
				No delete privilege
				<%}%>
			  </td>
			</tr>
			<%
		i = i+4;
		}
	}//if vAuthList is not null
	else{%>
	 <tr> 
		  <td height="35" colspan="5" valign="bottom"><%=ipFilter.getErrMsg()%></td>
		</tr>
	<%}%> </table>
<%}else{//show for page IP Filter information .%>
	  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
		<tr> 
		  <td height="25" width="20%"><div align="center"><font size="1"><strong>PAGE URL</strong></font></div></td>
		  <td width="39%"><div align="center"><strong><font size="1">DESCRIPTION</font></strong></div></td>
		  <td width="15%"> <div align="center"><font size="1"><strong>IP ADDRESS</strong></font></div></td>
		  <td width="13%" align="center"><strong><font size="1">STATUS</font></strong></td>
		  <td width="13%" align="center">&nbsp;</td>
		</tr>
	<%
	if(vAuthList != null && vAuthList.size() > 0){
	//System.out.println(vAuthList);
		for(int i = 0; i< vAuthList.size(); ++i)
		{
			strTemp = (String)vAuthList.elementAt(i+1);
			if(strTemp == null || strTemp.compareTo("0") ==0) strTemp = "ALL";
			else	strTemp = WI.getStrValue(vAuthList.elementAt(i+1));
		
			strTemp2 = (String)vAuthList.elementAt(i+2);
			if(strTemp2 == null || strTemp2.compareTo("0") ==0) strTemp2 = "ALL";
			else	strTemp2 = WI.getStrValue(vAuthList.elementAt(i+2),"&nbsp;");
		%>
			<tr> 
			  <td height="25" align="center"><%=strTemp%></td>
			  <td align="center"><%=strTemp2%></td>
			  <td align="center"><%=(String)vAuthList.elementAt(i+3)%></td>
			  <td align="center"><%=strAccessStatus[Integer.parseInt((String)vAuthList.elementAt(i+4))]%></td>
			  <td align="center"> 
				<%
				if(iAccessLevel ==2){%>
				<input type="image" src="../../images/delete.gif" onClick='DeleteAuthentication("<%=(String)vAuthList.elementAt(i)%>");'> 
				<%}else{%>
				No delete privilege
				<%}%>
			  </td>
			</tr>
			<%
		i = i+4;
		}
	}//if vAuthList is not null
	else{%>
	 <tr> 
		  <td height="35" colspan="5" valign="bottom"><%=ipFilter.getErrMsg()%></td>
		</tr>
	<%}%> </table>
<%}//page URL IP filter information ends here.
%>
	 <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
      </tr>
  </table>
  <input type="hidden" name="reloadPage" value="0">
<input type="hidden" name="page_action">
<input type="hidden" name="info_index">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
