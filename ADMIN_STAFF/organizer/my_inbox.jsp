<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<script language="javascript"  src ="../../jscript/common.js" ></script>
</head>
<script language="JavaScript">
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}

function ReloadPage()
{
	this.SubmitOnce('form_');
	document.form_.page_action.value = "";
}
function ChangeOrder(strField)
{
	document.form_.extrasort.value = strField;
	document.form_.page_action.value = "";
	this.SubmitOnce('form_');
}
function CheckAll()
{
	var iMaxDisp = document.form_.msgCtr.value;
	if (iMaxDisp.length == 0)
		return;	
	if (document.form_.selAll.checked ){
		for (var i = 1 ; i <= eval(iMaxDisp)-1;++i)
			eval('document.form_.msg'+i+'.checked=true');
	}
	else
		for (var i = 1 ; i <= eval(iMaxDisp)-1;++i)
			eval('document.form_.msg'+i+'.checked=false');
	document.form_.page_action.value = "";		
}
</script>
<style>
a:link {
	color: #000000;
	text-decoration: none;
}
a:visited {
	color: #000000;
	text-decoration: none;

}
a:hover {
	font-weight: bold;
	color: #000000;
	text-decoration: underline;

}
a:active {
	font-weight: bold;
	color: #000000;
	text-decoration: none;

}
</style>
<%@ page language="java" import="utility.*, organizer.SBEmail, java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;
	Vector vEditInfo = null;
	int iMsgs = 1;

	int iSearchResult = 0;
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Organizer-Message Board","my_inbox.jsp");
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
/**
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Organizer","Message Board",request.getRemoteAddr(),
														"my_inbox.jsp");
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
**/
//end of authenticaion code.
	SBEmail myMailBox = new SBEmail();
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(myMailBox.operateOnMailBox(dbOP, request, Integer.parseInt(strTemp)) != null ) {
			strErrMsg = "Operation successful.";
		}
		else
			strErrMsg = myMailBox.getErrMsg();
	}
	vRetResult = myMailBox.operateOnMailBox(dbOP, request, 4);

	if (vRetResult == null)
		strErrMsg = myMailBox.getErrMsg();
	else
		iSearchResult = myMailBox.getSearchCount();

%>
<body bgcolor="#8C9AAA" >
<form action="./my_inbox.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#697A8F"> 
      <td height="28" colspan="7" bgcolor="#697A8F"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          MY INBOX ::::</strong></font></div></td>
    </tr>
       <tr>
   <td colspan="3" height="25" valign="middle"><strong><%=WI.getStrValue(strErrMsg, "&nbsp;")%></strong></td>
   </tr>
   <tr>
	   <td width="2%%" align="left" >&nbsp;</td>
	   <td width="98%%" align="left" colspan="2"><a href='javascript:PageAction("0","")'>Delete Messages</a>&nbsp;&nbsp;&nbsp;&nbsp;<a href="./send_msg.jsp">Compose Mail</a></td>
   </tr>
      <tr>
   <td colspan="3" >&nbsp;</td>
   </tr>
</table>
<%if (vRetResult!=null && vRetResult.size()>0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
   <tr>
	  	<td colspan="5" height="25"><%
	  	int iMaxSize = myMailBox.getMaxInboxSize();
	  	float fInbox = (float)iSearchResult/iMaxSize;
	  	if (iSearchResult>(iMaxSize/2)){%>
	  	<font color="red" size="1">&nbsp;WARNING! YOU ARE CONSUMING <%=(fInbox*100)%>% OF YOUR INBOX</font>
	  	<%}else{%>
	  	<font size="1">&nbsp;YOU ARE CONSUMING <%=(fInbox*100)%>% OF YOUR INBOX</font>
	  	<%}%>
	  	</td>
   </tr>
   <tr> 
      <td colspan="3" height="25"><font size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>&nbsp;TOTAL MESSAGES
        : <%=iSearchResult%>/<%=myMailBox.getMaxInboxSize()%></strong></font></td>
      <td colspan="2"><font size="1"><div align="right"> <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/myMailBox.defSearchSize;
		if(iSearchResult % myMailBox.defSearchSize > 0) ++iPageCount;
		if(iPageCount > 1)
		{%>Jump To page: 
          <select name="jumpto" onChange="ReloadPage();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( int i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
            <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%	}
			}
			%>
          </select>
          <%} else {%>&nbsp;<%}%>
          </div>
        </td>
    </tr>
   <tr bgcolor="#DBEAF5">
	   <td width="2%" valign="middle"><div align="center"><strong><font size="1"><a href="javascript:ChangeOrder('priority')">	<img src="../../images/prior_h.gif" border="0"></a></font></strong></div></td>
	   <td width="2%%"  height="25" align="center" valign="middle"><strong><input type="checkbox" name="selAll" value="0" onClick="CheckAll();"><font size="1">&nbsp;</font></strong></td>
	   <td width="33%"><div align="left"><strong><font size="1"><a href="javascript:ChangeOrder('lname')">From</a></font></strong></div></td>
	   <td width="43%"><div align="left"><strong><font size="1">Subject</font></strong></div></td>
	   	   <td width="15%"><div align="left"><strong><font size="1"><a href="javascript:ChangeOrder('ORG_EMAIL.create_date')">Date</a></font></strong></div></td>
   </tr>
   <%for (int i=0; i<vRetResult.size();i+=12, iMsgs++) {%>
   <tr>
	   <td class="thinborderBOTTOM"><div align="center"><%if (((String)vRetResult.elementAt(i+5)).compareTo("1")==0){%>
   	<img src="../../images/prior_h.gif" border="0"><%}else{%>
   	<img src="../../images/prior_l.gif" border="0"><%}%></div></td>
	   <td class="thinborderBOTTOM" align="center" height="25"><input type="checkbox" name="msg<%=iMsgs%>" value="<%=(String)vRetResult.elementAt(i)%>"></td>
	   <td class="thinborderBOTTOM"><a href='./view_message.jsp?info_index=<%=(String)vRetResult.elementAt(i)%>&box_type=1&viewAll=0'>
	   <%if (((String)vRetResult.elementAt(i+7)).compareTo("0")==0){%><strong>
	   <%=WI.formatName((String)vRetResult.elementAt(i+9), (String)vRetResult.elementAt(i+10), (String)vRetResult.elementAt(i+11),4)%>(<%=(String)vRetResult.elementAt(i+1)%>)</strong>
	   <%}else{%>
	   <%=WI.formatName((String)vRetResult.elementAt(i+9), (String)vRetResult.elementAt(i+10), (String)vRetResult.elementAt(i+11),4)%>(<%=(String)vRetResult.elementAt(i+1)%>)<%}%>
	   </a></td>
	   <td class="thinborderBOTTOM"><%if (((String)vRetResult.elementAt(i+7)).compareTo("0")==0){%><strong>
	   <%=(String)vRetResult.elementAt(i+4)%></strong><%}else{%>
	  <%=(String)vRetResult.elementAt(i+4)%><%}%></td>
   <td class="thinborderBOTTOM"><%if (((String)vRetResult.elementAt(i+7)).compareTo("0")==0){%>
	   <strong><%=WI.formatDate((String)vRetResult.elementAt(i+8),10)%></strong>
   		<%}else{%>
   		<%=WI.formatDate((String)vRetResult.elementAt(i+8),10)%><%}%>
	   </td>
   </tr>
   <%}%>
   <tr>
	  	<td colspan="5">&nbsp;</td>
   </tr>
</table>
<%}%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="10">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" colspan="9" bgcolor="#697A8F">&nbsp;</td>
    </tr>
  </table>
  	<input type="hidden" name="msgCtr" value ="<%=iMsgs%>">
  	<input name="viewAll" type="hidden" value="<%=WI.fillTextValue("viewAll")%>">
	<input name="box_type" type="hidden" value="<%=WI.fillTextValue("box_type")%>">
  	<input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="page_action">
	<input name = "extrasort" type = "hidden"  value="<%=WI.fillTextValue("extrasort")%>">
	<%strTemp = WI.fillTextValue("ordersort");
	if (strTemp.length() == 0 || strTemp.compareTo("asc")==0 )
		strTemp = "desc";
	else
		strTemp = "asc";
	%>
	<input name = "ordersort" type = "hidden"  value="<%=strTemp%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>