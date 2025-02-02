<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/td.js"></script>
<script language="JavaScript">
function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
}
function AddToList() {
	var strList = document.form_.sub_list.value;
	var strSubToAdd = document.form_.sub_index[document.form_.sub_index.selectedIndex].value;
	if(strList.length == 0)
		strList = strSubToAdd;
	else {
		if(strList.indexOf(strSubToAdd) == -1)
			strList = strList + ","+strSubToAdd;
	}
	document.form_.sub_list.value = strList;
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.ReportRegistrarExtn,java.util.Vector " %>
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
//authenticate this user.

//end of authenticaion code.
boolean bolIsSuccess = false;
ReportRegistrarExtn rR = new ReportRegistrarExtn();
Vector vRetResult  = null;
String strPageAction = WI.fillTextValue("page_action");
if(strPageAction.length() > 0) {
	if(rR.operateOnCappingSubEquivalence(dbOP, request, Integer.parseInt(strPageAction)) == null) {
		strErrMsg = rR.getErrMsg();
	}
	else {
		strErrMsg = "Operation successful.";
		bolIsSuccess = true;
	} 
}
vRetResult = rR.operateOnCappingSubEquivalence(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = rR.getErrMsg();

%>

<form name="form_" action="./capping_and_similar_config_slist.jsp" method="post" onSubmit="SubmitOnceButton(this);">
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="4" align="center"><font color="#FFFFFF"><strong>:::: ADD SUBJECT LIST ::::</strong></font></td>
    </tr>
    <tr> 
      <td width="1%" height="25" >&nbsp;</td>
      <td height="25" colspan="3" >&nbsp;&nbsp;&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr> 
      <td width="1%" height="25" >&nbsp;</td>
      <td width="5%" height="25" >&nbsp;</td>
      <td width="17%" >Subject Heading </td>
      <td width="77%">
	  <select name="subject_heading">
<%
Vector vTemp = rR.viewCappingSubList(dbOP);
if(vTemp != null && vTemp.size() > 0) {
	for(int i = 0; i < vTemp.size(); ++i) {%>
	<option value="<%=vTemp.elementAt(i)%>"><%=vTemp.elementAt(i)%></option>
	<%}
}%>		  
	  </select></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td >Subject code </td>
      <td><select name="sub_index" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 11;">
        <%=dbOP.loadCombo("sub_code","sub_code"," from subject where IS_DEL=0 order by sub_code asc", strTemp, false)%>
      </select>
        <font size="1"><a href="javascript:AddToList();"><img src="../../../../images/add.gif" border="0"></a> &nbsp;&nbsp; <a href="#"> <img src="../../../../images/clear.gif" border="0" onClick="document.form_.sub_list.value=''"></a></font></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td >&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td >&nbsp;</td>
      <td valign="top">Enter subject code for this heading </td>
      <td >
<%
if(bolIsSuccess)
	strTemp = "";
else	
	strTemp = WI.fillTextValue("sub_list");
%>	  <textarea name="sub_list" class="textbox" rows="5" cols="55" readonly="readonly"
	  	onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea>
        <br>
        <font size="2" color="#0000FF"><b>NOTE : Enter subject code in comma separated Value</b></font></td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td >&nbsp;</td>
      <td colspan="2" align="center"><input type="submit" name="1" value="<<< Save subjects >>>" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="PageAction('1', '');"></td>
    </tr>
    
    <tr> 
      <td colspan="4" height="10" >&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr style="font-weight:bold">
      <td height="25" class="thinborder" width="25%">Subject</td>
      <td class="thinborder" width="60%">Subject code </td>
      <td class="thinborder" width="15%">Remove</td>
    </tr>
<%for(int i = 0; i < vRetResult.size(); i += 3) {%>
    <tr>
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder">&nbsp;
	  <input type="submit" name="12" value=" Delete " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="PageAction('0','<%=(String)vRetResult.elementAt(i)%>');"></td>
    </tr>
<%}%>
  </table>
<%}%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable4">
    <tr>
      <td colspan="8" height="25">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="8" height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
