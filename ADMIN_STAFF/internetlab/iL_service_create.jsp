<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function viewList(table,indexname,colname,labelname){
	var loadPg = "../HR/hr_updatelist.jsp?opner_form_name=form_&tablename=" + table + "&indexname=" + 
		indexname + "&colname=" + colname+"&label="+labelname;
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	if(strAction == "1")
		document.form_.hide_save.src = "../../images/blank.gif";
	document.form_.submit();
}
function PrepareToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.prepareToEdit.value = "1";
	document.form_.submit();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,iCafe.ICafeOtherService,java.util.Vector " buffer="16kb" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Internet Cafe Management-INTERNET OTHER SERVICES - Create service",
								"iL_service_create.jsp");
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
														"Internet Cafe Management",
														"INTERNET OTHER SERVICES",request.getRemoteAddr(),
														"iL_service_create.jsp");
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
ICafeOtherService othService = new ICafeOtherService();
Vector vEditInfo = null;
Vector vRetResult = null;
String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(othService.operateOnOtherService(dbOP, request, Integer.parseInt(strTemp)) == null) {
		strErrMsg = othService.getErrMsg();		
	}
	else {	
		strErrMsg = "Operation is successful.";
		strPrepareToEdit = "0";
	}
}
//I have to get here information.
if(strPrepareToEdit.compareTo("0") != 0) {
	vEditInfo = othService.operateOnOtherService(dbOP, request, 3);
	if(vEditInfo == null)
		strErrMsg = othService.getErrMsg();
}
//I have to get here the services created so far.
vRetResult = othService.operateOnOtherService(dbOP, request, 4);
if(strErrMsg == null && vRetResult == null)
	strErrMsg = othService.getErrMsg();



%>
<form action="./iL_service_create.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          INTERNET OTHER SERVICES - CREATE PAGE::::</strong></font></div></td>
    </tr>
    <tr >
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="46%">DATE - TIME : <%=WI.getTodaysDateTime()%></td>
      <td width="52%"> ATTENDANT NAME : <%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1)%></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="28%">Service Category</td>
      <td width="70%">
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("catg_index");
%>
	  <select name="catg_index">
          <%=dbOP.loadCombo("CATG_INDEX","CATG_NAME"," FROM IC_SERVICE_CATG order by catg_name",
		  	strTemp,false)%> </select> <a href='javascript:viewList("IC_SERVICE_CATG","CATG_INDEX","CATG_NAME","SERVICE CATEGORY");'> 
        <img src="../../images/update.gif" border="0"></a> <font size="1">click 
        to update Service Catg</font> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Service Code</td>
      <td> 
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(3);
else	
	strTemp = WI.fillTextValue("service_code");
%>	  <input name="service_code" type="text" length="16" maxlength="16" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"> 
      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Service Name</td>
      <td> 
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("service_name");
%>	  <input name="service_name" maxlength="64" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"> 
      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td valign="top">Fee Rate</td>
      <td valign="top">
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(4);
else	
	strTemp = WI.fillTextValue("amount");
%>        <input name="amount" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;">        
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(5);
else	
	strTemp = WI.fillTextValue("amt_unit");
%>        <select name="amt_unit">
          <option value="1">per page</option>
          <option value="2">per request</option>
          <option value="3">per usage</option>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td valign="top">Remarks </td>
      <td valign="top">
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(6);
else	
	strTemp = WI.fillTextValue("remark");
%>	  <textarea name="remark" cols="40" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp)%></textarea></td>
    </tr>
  </table>
	
<%if(iAccessLevel > 1){%>	  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr> 
      <td width="30%" height="59">&nbsp;</td>
      <td width="70%" height="59">
	  <%if(strPrepareToEdit.compareTo("0") == 0) {%>
	  <a href='javascript:PageAction("1","");'><img src="../../images/save.gif" border="0" name="hide_save"></a>
	  <%}else{%>
	  <a href='javascript:PageAction("2","");'><img src="../../images/edit.gif" border="0"></a>
	  <%}%>
	  <font size="1">click to save entries/changes 
	  <a href="./iL_service_create.jsp"><img src="../../images/cancel.gif" border="0"></a>click to cancel/clear 
        entries </font></td>
    </tr>
  </table>
<%}//if iAccessLevel > 1

if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#FFFF9F"> 
      <td height="23" colspan="7"><div align="center"><font color="#0000FF"><strong>LIST 
          OF INTERNET OTHER SERVICES</strong></font></div></td>
    </tr>
    <tr> 
      <td width="14%" height="23"><font size="1"><strong>SERVICE CODE</strong></font></td>
      <td width="12%"><font size="1"><strong>SERVICE CATEGORY</strong></font></td>
      <td width="22%"><font size="1"><strong>SERVICE NAME</strong></font></td>
      <td width="16%"><font size="1"><strong>FEE RATE</strong></font></td>
      <td width="23%"><font size="1"><strong>REMARKS</strong></font></td>
      <td width="6%">&nbsp;</td>
      <td width="7%">&nbsp;</td>
    </tr>
<%
for(int i = 0; i < vRetResult.size() ; i += 8){%>
   <tr> 
      <td><font size="1"><%=(String)vRetResult.elementAt(i + 3)%></font></td>
      <td><font size="1"><%=(String)vRetResult.elementAt(i + 7)%></font></td>
      <td><font size="1"><%=(String)vRetResult.elementAt(i + 2)%></font></td>
      <td><font size="1"><%=(String)vRetResult.elementAt(i + 4)%> <%=(String)vRetResult.elementAt(i + 5)%></font></td>
      <td><font size="1"><%=WI.getStrValue(vRetResult.elementAt(i + 6),"&nbsp;")%></font></td>
      <td>
<%if(iAccessLevel > 1){%>
	  <a href="javascript:PrepareToEdit(<%=(String)vRetResult.elementAt(i)%>);"><img src="../../images/edit.gif" border="0"></a>
<%}%>  </td>
      <td>
<%if(iAccessLevel == 2){%>
	  <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'><img src="../../images/delete.gif" border="0"></a>
<%}%>
	  </td>
    </tr>
<%}//end of for loop%>
  </table>
<%}//end of if vRetResult is not null.%>

  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td width="87%" height="25">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>