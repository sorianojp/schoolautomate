<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function PageAction(strAction)
{	
	document.daily_cash.page_action.value = strAction;
}
function PrepareToEdit(strInfoIndex)
{
	document.daily_cash.page_action.value =""; 
	document.daily_cash.prepareToEdit.value = 1;
	document.daily_cash.info_index.value = strInfoIndex;
	document.daily_cash.submit();	
}

function DeleteRecord(strInfoIndex)
{	
	document.daily_cash.page_action.value="0";
	document.daily_cash.prepareToEdit.value ="";
	document.daily_cash.info_index.value=strInfoIndex;
	document.daily_cash.submit();
}
function Refresh()
{
	document.daily_cash.page_action.value="";
	document.daily_cash.submit();
}
function CancelRecord()
{
	document.daily_cash.page_action.value="";
	document.daily_cash.prepareToEdit.value ="";
	document.daily_cash.info_index.value="";
	document.daily_cash.denomination.value="";
	document.daily_cash.submit();
}

function GoBack()
{
	location = "./cash_counting.jsp?emp_id="+escape(document.daily_cash.emp_id.value)+"&date_of_col="+escape(document.daily_cash.date_of_col.value);
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,EnrlReport.DailyCashCollection,java.util.Vector " %>
<%
 
	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	MessageConstant mConst = new MessageConstant();
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

	String strPrepareToEdit=WI.getStrValue(request.getParameter("prepareToEdit"),"0");

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","update_denomination.jsp");
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
														"Fee Assessment & Payments","Reports",request.getRemoteAddr(),
														"update_denomination.jsp");	
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
	
DailyCashCollection DC = new DailyCashCollection();
Vector vRetResult = new Vector();
Vector vEditInfo  = new Vector();

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0)
{
	vRetResult = DC.operateOnDenomination(dbOP,request,Integer.parseInt(strTemp));
	if(vRetResult != null)
		strPrepareToEdit = "0";
	else
		strErrMsg = DC.getErrMsg();
}

//get all levels created.
vRetResult =	DC.operateOnDenomination(dbOP,request,4);
if((vRetResult == null || vRetResult.size() ==0) && WI.fillTextValue("info_index").length() > 0 && strErrMsg == null)
	strErrMsg = DC.getErrMsg();

if(strPrepareToEdit != null && strPrepareToEdit.compareTo("1") ==0)
{
	vEditInfo = DC.operateOnDenomination(dbOP,request,3);
	if(vEditInfo == null)
		strErrMsg = DC.getErrMsg();
}
dbOP.cleanUP();

if(strErrMsg == null) strErrMsg = "";
%>


<form name="daily_cash" method="post" action="./update_denomination.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3"><div align="center"><font color="#FFFFFF"><strong>:::: 
          UPDATE DENOMINATION PAGE::::</strong></font></div></td>
    </tr>
    <tr> 
      <td colspan="3" height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=strErrMsg%></font></td>
    </tr>
    <tr> 
      <td height="25" width="3%">&nbsp;</td>
      <td colspan="2"><a href="javascript:GoBack();"><img src="../../../images/go_back.gif" border="0"></a> 
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:Refresh();"><img src="../../../images/refresh.gif" border="0"></a>Click 
        to refresh the page.</td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="17%"> Denomination: 
        <%
	if(vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(1);
	else
		strTemp = WI.fillTextValue("denomination");
	%>
        <input name="denomination" type="text" size="5" maxlength="5" value="<%=strTemp%>" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"> 
      </td>
      <td width="80%"> 
        <%
	if(iAccessLevel > 1)
	{
		if(strPrepareToEdit.compareTo("0") == 0)
		{%>
			<input type="image" src="../../../images/add.gif" onClick="PageAction(1);"> 
			<font size="1" >click to create denomination</font> 
			<%}else{%>
			<input type="image" src="../../../images/edit.gif" onClick="PageAction(2);"> 
			<font size="1">click to save changes</font> <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a><font size="1">click 
			to cancel edit</font> 
		<%}
	}else{%>N/A
	<%}%>
      </td>
    </tr>
    <tr> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border=0 bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="8"><div align="center">LIST OF EXISTING DENOMINATION</div></td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0)
{%>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">

<%
for(int i = 0 ; i< vRetResult.size() ; ++i)
{%>

    <tr> 
      <td width="27%">&nbsp;</td>
      <td width="36%"><strong><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+1),true)%></strong></td>
      <td width="10%" height="25">
<%if(iAccessLevel > 1){%>
	  <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a>
<%}%>	  </td>
      <td width="27%">
<%if(iAccessLevel ==2){%>
  <a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a>
<%}else{%>Not authorized to delete<%}%>  </td>
    </tr>
<%
i = i+1;
}//end of view all loops %>

  </table>  

<%}//end of view all display%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"></tr>
    <tr> 
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<!-- all hidden fields go here -->
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="page_action">  
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="emp_id" value="<%=WI.fillTextValue("emp_id")%>">
<input type="hidden" name="date_of_col" value="<%=WI.fillTextValue("date_of_col")%>">
</form>
</body>
</html>
