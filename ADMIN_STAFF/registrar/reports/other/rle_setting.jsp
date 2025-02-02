<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
}
function PreparedToEdit(strInfoIndex) {
	document.form_.preparedToEdit.value = "1";
	document.form_.page_action.value = '';
	document.form_.info_index.value = strInfoIndex;
}
function OpenSearch() {
	var pgLoc = "../../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.RLEInformation,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-Reports-Others","rle_setting.jsp");
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
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT"),"0"));
		}
	}

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"),"0");
RLEInformation rleInfo = new RLEInformation();
Vector vRetResult  = null;
Vector vEditInfo   = null;

String strPageAction = WI.fillTextValue("page_action");
if(strPageAction.length() > 0) {
	if(rleInfo.operateOnRLESubject(dbOP, request, Integer.parseInt(strPageAction)) == null) 
		strErrMsg = rleInfo.getErrMsg();
	else {
		strPreparedToEdit = "0";
		strErrMsg = "Operation successful.";
	}
}
if(strPreparedToEdit.equals("1")) {
	//vEditInfo = rleInfo.operateOnCappingConfig(dbOP, request, 3);
	if(vEditInfo == null)
		strErrMsg = rleInfo.getErrMsg();
}
vRetResult = rleInfo.operateOnRLESubject(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = rleInfo.getErrMsg();

%>

<form name="form_" action="./rle_setting.jsp" method="post" onSubmit="SubmitOnceButton(this);">
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="4" align="center"><font color="#FFFFFF"><strong>:::: 
        RLE SETTING ::::</strong></font></td>
    </tr>
    <tr> 
      <td width="1%" height="25" >&nbsp;</td>
      <td height="25" colspan="3" style="font-size:14px; color:#FF0000; font-weight:bold"><a href="./rle_main.jsp"><img src="../../../../images/go_back.gif" border="0"></a>&nbsp;&nbsp;
  	  <%=WI.getStrValue(strErrMsg)%></td>
    </tr>
    <tr> 
      <td width="1%" height="25" >&nbsp;</td>
      <td width="11%">Subject</td>
      <td colspan="2" ><font size="1">
        <input type="text" name="scroll_sub" size="12" style="font-size:10px" class="textbox"
	  onKeyUp = "AutoScrollListSubject('scroll_sub','sub_index',true,'form_');">
      (scroll) Display Order Number : </font>
	  <select name="order_no">
	  <%strTemp = WI.fillTextValue("order_no");
	  if(strTemp.length() == 0) 
	  	strTemp = "0";
	  int iOrderNo = Integer.parseInt(strTemp);
	  for(int i = 1; i < 21; ++i){
	  	if(iOrderNo == i)
			strTemp = " selected";
		else	
			strTemp = "";
		%>
		<option value="<%=i%>"><%=i%></option>
	   <%}%>
	   </select>	  </td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td colspan="3">
	  <select name="sub_index" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10px;">
        <%=dbOP.loadCombo("sub_index","sub_code + ' ::: ' + sub_name"," from subject where IS_DEL=0 "+
			" order by sub_code asc", WI.fillTextValue("sub_index"), false)%>
      </select></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td valign="top"><br>Duty Name </td>
      <td colspan="2"><textarea name="duty_name" rows="10" cols="75" class="textbox" style="font-size:11px;"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("duty_name")%></textarea></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td valign="top"><br>Reqd. Hour </td>
      <td width="17%"><textarea name="duty_hour" rows="10" cols="5" class="textbox" style="font-size:11px;"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("duty_hour")%></textarea></td>
      <td width="71%"><strong>Note</strong> : 
	  Please enter multiple Duty name and duty required hour one per row. You can enter multiple entries 
	  for example in Duty Name Enter <br>
	  <font color="#0000FF">Skills Building - Skills Lab (17 weeks) <br>
	  Community</font><br><br>
	  and in duty required hour enter<br>
	  <font color="#0000FF">51 <br>
	  102</font><br><br>
	  and click save.</td>
    </tr>
    <tr>
	  <td height="25" align="center">&nbsp;</td>
		<td colspan="3" align="center"><%if(iAccessLevel > 1){%>
        <input type="submit" name="1" value=" Save All" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="PageAction('1', '');">
        <%}%>
&nbsp;&nbsp;</td>   
	</tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {
Vector vSubInfo = (Vector)vRetResult.remove(0);%>  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr bgcolor="#6699FF">
	  <td height="25" colspan="4" class="thinborder"><div align="center"><strong><font color="#FFFFFF">:: LIST OF SUPPORTING ENTRIES ::</font></strong></div></td>
	</tr>
	<tr>
	  <td height="25" colspan="4" class="thinborder"><font size="1"><strong>TOTAL SUBJECTS : <%=vSubInfo.size()/2%></strong></font></td>
    </tr>
	<tr>
	  <td width="70%" height="25" class="thinborder"><div align="center"><font size="1"><strong> NAME OF DUTY </strong></font></div></td>
	  <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>HOUR</strong></font></div></td>
	  <td width="10%" class="thinborder">&nbsp;</td>
	  <td width="10%" class="thinborder">&nbsp;</td>
	</tr>
	<%
for(int i = 0; i < vSubInfo.size(); i += 5){%>
	<tr>
	  <td height="25" class="thinborder" style="font-weight:bold; color:#0000FF">
	  <%=vSubInfo.elementAt(i + 4)%>. <%=vSubInfo.elementAt(i + 1)%> (<%=vSubInfo.elementAt(i + 2)%>)</td>
	  <td class="thinborder" style="font-weight:bold; color:#0000FF"><%=vSubInfo.elementAt(i + 3)%></td>
	  <td class="thinborder">&nbsp;</td>
	  <td class="thinborder">&nbsp;</td>
	</tr>
<%while(vRetResult.size()> 0){
	if(!vRetResult.elementAt(3).equals(vSubInfo.elementAt(i)))
		break;%>
	<tr>
	  <td height="25" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(1),"&nbsp;")%></td>
	  <td class="thinborder"><%=vRetResult.elementAt(2)%></td>
	  <td class="thinborder"><input type="submit" name="1242" value=" Edit " style="font-size:11px; height:22px;border: 1px solid #FF0000;"
	 onClick="PreparedToEdit('<%=(String)vRetResult.elementAt(0)%>');"></td>
	  <td class="thinborder"><input type="submit" name="1243" value=" Delete " style="font-size:11px; height:22px;border: 1px solid #FF0000;"
	 onClick="PageAction('0','<%=(String)vRetResult.elementAt(0)%>');"></td>
	</tr>
<%		vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);vRetResult.removeElementAt(0);
		vRetResult.removeElementAt(0);
	}//end of vRetResult;
}//end of vSubInfo%>
  </table>
<%}//end of vRetResult..%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable4">
    <tr>
      <td colspan="8" height="25">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="8" height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="page_action">
<input type="hidden" name="preparedToEdit" value="<%=strPreparedToEdit%>">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">

<!-- add in pages with subject scroll -->
<%=dbOP.constructAutoScrollHiddenField()%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
