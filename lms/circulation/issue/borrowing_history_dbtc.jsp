<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../css/reportlink.css" rel="stylesheet" type="text/css">

<style>
.trigger{
	cursor: pointer;
	cursor: hand;
}
.branch{
	display: block;
	margin-left: 16px;
}
</style>
</head>
<script src="../../../Ajax/ajax.js"></script>
<script src="../../../jscript/common.js"></script>
<script src="../../../jscript/date-picker.js"></script>

<script language="JavaScript">

function viewHistory(){
	document.form_._search.value = '1';
	document.form_.submit();
}

function ViewBorrowingHistory(strUserId){
	var loadPg = "";
	var win=window.open(loadPg,"ViewBorrowingHistory",'dependent=no,width=900,height=655,top=5,left=5,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<%@ page language="java" import="utility.*,lms.Search,java.util.Vector" %>
<%
	String strTemp = null;
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strUserIndex  = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"LIB_Circulation-ISSUE/RENEW","borrowing_history_dbtc.jsp");
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
														"LIB_Circulation","ISSUE/RENEW",request.getRemoteAddr(),
														"borrowing_history_dbtc.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../lms/");
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
Search search = new Search(request);
Vector vRetResult = new Vector();

if(WI.fillTextValue("user_id").length() > 0){
	vRetResult = search.viewStudentBorrowingHistory(dbOP, WI.fillTextValue("user_id"));
	if(vRetResult == null);
		strErrMsg = search.getErrMsg();
	
}

%>
<body bgcolor="#D0E19D">
<form action="./borrowing_history_dbtc.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#77A251"> 
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CIRCULATION : ISSUE PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;<font size="3" color="#FF0000"><strong> 
        <%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font></td>
    </tr>
	
    <tr> 
      <td width="10%" height="23"><font size="1">Patron ID</font> </td>
      <td width="20%"> <%=WI.fillTextValue("user_id")%></td>
	  <td>&nbsp;</td>
    </tr>
	
	<tr> 
      <td width="10%" height="23"><font size="1">School Year</font> </td>
      <td width="50%">
<%
if(request.getParameter("sy_from") == null)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
else	
	strTemp = WI.fillTextValue("sy_from");
if(strTemp != null && strTemp.length() != 4)
	strTemp = "";
%>
	  <input name="sy_from" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")' maxlength=4>
        to 
<%
if(strTemp != null && strTemp.length() > 0) 
	strTemp = Integer.toString(Integer.parseInt(strTemp) + 1) ;
else	
	strTemp = "";
%>
      <input name="sy_to" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly> &nbsp;&nbsp; <select name="semester">
          <option value="">N/A</option>
 <%
if(request.getParameter("sy_from") == null)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
else	
	strTemp = WI.fillTextValue("semester");
if(strTemp == null)
	strTemp = "";
		
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}		  
		  if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select></td>
	  <td>&nbsp;</td>
    </tr>
	<tr><td colspan="3" height="15">&nbsp;</td></tr>
	<tr>  
	  <td>&nbsp;</td>     
      <td width="" colspan="2">&nbsp;
	  <a href="javascript:viewHistory();">
	  <img src="../../images/form_proceed.gif" border="0"></a>
	  
	  <font size="1">Click to view history</font>
	  
	  </td>	  
    </tr>
	
    <tr> 
      <td height="19" colspan="4"><div align="right">  
          <hr size="1">
        </div></td>
    </tr>
  </table>
  
 
<%if(vRetResult != null && vRetResult.size() > 0){%> 
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td height="25" align="center"><strong>Search Result</strong></td></tr>
</table>  


<table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr>
		<td width="5%" class="thinborder" align="center">Count</td>
		<td width="15%" class="thinborder" align="center" height="25">Date Issued</td>
		<td width="15%" class="thinborder" align="center">Date Returned</td>
		<td width="30%" class="thinborder" align="center">Book Title</td>
		<td width="15%" class="thinborder" align="center">Author</td>
		<td width="10%" class="thinborder" align="center">Accession No</td>
		<td width="10%" class="thinborder" align="center">Call No</td>
	</tr>
	
	<%
	int iCount = 1;
	for(int i =0; i<vRetResult.size(); i+=10){
	%>
	<tr>
		<td class="thinborder" align="center" height="25"><%=iCount++%></td>
		<td class="thinborder" align="center">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+1))%></td>
		<td class="thinborder" align="center">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+2))%></td>
		
		<td class="thinborder" align="left">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+5))%></td>
		<td class="thinborder" align="left">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+8))%></td>
		<td class="thinborder" align="left">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+7))%></td>
		<td class="thinborder" align="left">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+6))%></td>
	</tr>
	<%}%>

</table>
<%}%>
  
<input type="hidden" name="user_id" value="<%=WI.fillTextValue("user_id")%>"  />
<input type="hidden" name="_search" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>