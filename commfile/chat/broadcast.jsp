<%if(request.getSession(false).getAttribute("userIndex") == null) {%>
	<font color="#FF0000">You are already logged out. Please login again.</font>
<%return;}
	String strAuthIndex = (String)request.getSession(false).getAttribute("authTypeIndex");
    if(strAuthIndex != null && strAuthIndex.equals("4")) {%>
      <font color="#FF0000">Students do not have access to message broadcast.</font>
<%return;}%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript">
function BroadcastUser(chkboxObj, strID) {
	var strIDList = document.form_.send_to.value;
	var iIndexOf = strIDList.indexOf(strID);
	if(iIndexOf == -1) {
		if(strIDList.length < 3)
			strIDList = "";
		else	
			strIDList += ", ";
		strIDList = strIDList +strID;
		document.form_.send_to.value = strIDList;
		return;
	}
	if(chkboxObj.checked)
		return;
	//now it is not checked, i have to remove it.. 
	var iMaxDisp = document.form_.total_count.value;
	strIDList = "";	

	for(var i = 0; i < eval(iMaxDisp); ++i) {
		//alert(iMaxDisp+",,, "+i);
		eval('chkboxObj = document.form_._'+i);
		if(!chkboxObj || !chkboxObj.checked)
			continue;
		if(strIDList == "")
			strIDList = chkboxObj.value;
		else	
			strIDList = strIDList + ", "+chkboxObj.value;
	}
	document.form_.send_to.value = strIDList;
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

//add security here.
	try	{
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

Vector vRetResult = null;
strTemp = WI.fillTextValue("page_action");
utility.AjaxInterface AI = new utility.AjaxInterface();
if(strTemp.length() > 0) {
	vRetResult = AI.operateOnBroadCast(dbOP, request, Integer.parseInt(strTemp));
	strErrMsg = AI.getErrMsg();
}

%>
<form name="form_" method="post" action="./broadcast.jsp" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>::::
        BRAODCAST MESSAGE::::</strong></font></div></td>
    </tr>
</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td height="25" colspan="4" style="font-size:14px; font-weight:bold; color:#FF0000">&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25" style="font-size:11px; font-weight:bold" valign="top">Send to Users</td>
    <td height="25">&nbsp;</td>
    <td height="25">
	<textarea name="send_to" rows="4" cols="60" class="textbox"onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("send_to")%></textarea>	</td>
  </tr>
  <tr> 
    <td width="11%">&nbsp;</td>
    <td width="16%">&nbsp;</td>
    <td width="2%">&nbsp;</td>
    <td width="71%">&nbsp;</td>
  </tr>
  <tr> 
    <td width="11%" height="25">&nbsp;</td>
    <td width="16%" style="font-size:11px; font-weight:bold" valign="top">Message </td>
    <td width="2%" align="center">&nbsp;</td>
    <td width="71%">
	<textarea name="message_" rows="4" cols="60" class="textbox"onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("message_")%></textarea>	</td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25">&nbsp;</td>
    <td align="center">&nbsp;</td>
    <td>
        <input type="submit" name="12" value="Broadcase Message" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='1'">	</td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td height="25" colspan="2" style="font-size:9px; color:#0000FF;">&nbsp;&nbsp;
	<input type="checkbox" name="search_online" value=" checked"<%=WI.fillTextValue("search_online")%>> Show SB online users (idle time less than 15mins) &nbsp;
	<input type="checkbox" name="search_active" value=" checked"<%=WI.fillTextValue("search_active")%>>Show currently chatting &nbsp; 
<%
strTemp = WI.fillTextValue("student_");
if(strTemp.equals("1")) {
	strTemp = " checked";
	strErrMsg = "";
}else {	
	strTemp = "";
	strErrMsg = " checked";
}%>
	<input type="radio" value="1" name="student_"<%=strTemp%>> Show student &nbsp;	
	<input type="radio" value="0" name="student_"<%=strErrMsg%>> Show staff	</td>
    </tr>
  <tr> 
    <td width="11%" height="25">&nbsp;</td>
    <td width="89%" style="font-size:11px;">User ID/Last name: 
      <input name="user_id" type="text" class="textbox" style="font-size:11px" value="<%=WI.fillTextValue("user_id")%>"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="24">	  
      &nbsp;&nbsp;&nbsp;
      <input type="submit" name="12" value="Search Users" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='2'">	  </td>
    </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td style="font-size:11px;">&nbsp;</td>
  </tr>
</table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  <tr> 
    <td height="22" colspan="5" align="center" bgcolor="#CCCCCC" class="thinborder" style="font-size:11px; font-weight:bold">- Search Result - </td>
  </tr>
  <tr> 
    <td height="22" colspan="5" class="thinborder" style="font-size:11px; font-weight:bold">&nbsp;Total Result : <%=vRetResult.size()/4%> </td>
  </tr>
  <tr> 
    <td height="22" bgcolor="#EEEEEE" style="font-size:10px; font-weight:bold" class="thinborder" width="5%" align="center">Select</td>
    <td bgcolor="#EEEEEE" style="font-size:10px; font-weight:bold" class="thinborder" width="20%" align="center">ID Number</td>
    <td bgcolor="#EEEEEE" style="font-size:10px; font-weight:bold" class="thinborder" width="35%" align="center">Name (Lname, Fname, MI.)</td>
    <td bgcolor="#EEEEEE" style="font-size:10px; font-weight:bold" class="thinborder" width="20%" align="center">SB Activity</td>
    <td bgcolor="#EEEEEE" style="font-size:10px; font-weight:bold" class="thinborder" width="20%" align="center">Chat Activity</td>
  </tr>
<%int j = 0; 
for(int i = 0; i < vRetResult.size(); i += 4) {%>
  <tr>
    <td height="22" class="thinborder" align="center"><input type="checkbox" name="_<%=j%>" value="<%=vRetResult.elementAt(i)%>" onClick="BroadcastUser('document.form_._<%=j++%>','<%=vRetResult.elementAt(i)%>');"></td>
    <td class="thinborder">&nbsp;<%=vRetResult.elementAt(i)%></td>
    <td class="thinborder">&nbsp;<%=vRetResult.elementAt(i + 1)%></td>
    <td class="thinborder">&nbsp;<%=vRetResult.elementAt(i + 2)%></td>
    <td class="thinborder">&nbsp;<%=vRetResult.elementAt(i + 3)%></td>
  </tr>
<%}%>
</table>
<input type="hidden" name="total_count" value="<%=j%>">
<%}%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td width="8%" height="25">&nbsp;</td>
    <td width="66%" valign="middle">&nbsp;</td>
    <td width="26%" valign="middle"></td>
  </tr>
  <tr bgcolor="#A49A6A"> 
    <td height="25" colspan="3">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>