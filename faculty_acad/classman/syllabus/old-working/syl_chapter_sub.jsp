<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
function GoToParentWnd() {
	//to get off focus.
	if(document.form_.reload_page.value == '')
		window.opener.childWnd = null;
	window.opener.document.form_.submit();
}
function PageAction(strAction) {
	//called for clear 
	document.form_.reload_page.value = '1';
	if(strAction == '-1') {
		document.form_.sub_chap_name.value = "";
		document.form_.hours.value = "";
		document.form_.description.value = "";
		
		return;
	}
	document.form_.page_action.value = strAction;
	if(strAction == '')
		document.form_.preparedToEdit.value = "";
}
function PreparedToEdit(strInfoIndex) {
	document.form_.reload_page.value = '1';
	document.form_.info_index.value = strInfoIndex;
	document.form_.preparedToEdit.value = "1";
}
</script>


<%@ page language="java" import="utility.*,java.util.Vector,ClassMgmt.CMSyllabus" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
	
	//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FACULTY/ACAD. ADMIN-CLASS MANAGEMENT"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FACULTY/ACAD. ADMIN"),"0"));
		}
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../faculty_acad/faculty_acad_bottom_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out.Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

	//end of authenticaion code.

	try {
		dbOP = new DBOperation();
	}
	catch(Exception exp) {
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"><%=strErrMsg%></p>
		<%
		return;
	}

CMSyllabus cms = new CMSyllabus();
boolean bolRetainVal = false;
String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"), "0");

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(cms.operateOnSubChapter(dbOP, request, Integer.parseInt(strTemp)) == null) {
		bolRetainVal = true;//retain prev value, do not get from vEditInfo.
		strErrMsg = cms.getErrMsg();
	}
	else {
		strErrMsg = "Operation successful.";
		strPreparedToEdit = "0";
	}
}
	vRetResult = cms.operateOnSubChapter(dbOP, request, 4);
	if(vRetResult == null && strErrMsg == null) 
		strErrMsg = cms.getErrMsg();

Vector vEditInfo = null;
if(strPreparedToEdit.equals("1"))
	vEditInfo = cms.operateOnSubChapter(dbOP, request, 3);



%>
<body bgcolor="#93B5BB" onUnload="GoToParentWnd();">
<form name="form_" method="post" action="./syl_chapter_sub.jsp" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#6A99A2">
      <td width="786" height="25"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          COURSE OUTLINE MAINTENANCE PAGE::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;<font style="font-size:14px; color:#FF0000;"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="5" cellspacing="0">
    <tr>
      <td>Sub-Chapter # </td>
      <td>
	  <select name="order_no">
<%
if(vEditInfo != null && !bolRetainVal)
	strTemp = (String)vEditInfo.elementAt(4);
else	
	strTemp = WI.getStrValue(WI.fillTextValue("order_no"), "1");
int iOrderNo = Integer.parseInt(strTemp);
for(int i = 1; i < 100; ++i) {
	if(iOrderNo == i)
		strTemp = " selected";
	else	
		strTemp = "";
%>	
		<option value="<%=i%>"<%=strTemp%>><%=i%></option>	  
<%}%>
	  </select>	  </td>
    </tr>
    <tr>
      <td width="17%">Sub-Chapter Title </td>
      <td width="83%">
<%
if(vEditInfo != null && !bolRetainVal)
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("sub_chap_name");
%>
	  <input name="sub_chap_name" type="text" size="67" maxlength="256" class="textbox" value="<%=strTemp%>"
	   onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:11px;"></td></tr>
    <tr>
      <td valign="top">Duration(hrs)</td>
      <td>
<%
if(vEditInfo != null && !bolRetainVal)
	strTemp = (String)vEditInfo.elementAt(3);
else	
	strTemp = WI.fillTextValue("hours");
%>
	  <input name="hours" type="text" size="4" maxlength="4" class="textbox" value="<%=strTemp%>"
	   onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','hours');style.backgroundColor='white'" style="font-size:11px;"
	   onKeyUp="AllowOnlyFloat('form_','hours');"> 
      (no of hours) </td>
    </tr>
    <tr>
      <td valign="top">Topic</td>
      <td>
<%
if(vEditInfo != null && !bolRetainVal)
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("description");
%>
	   <textarea name="description" cols="70" rows="8" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" class="textbox" style="font-size:11px;"><%=WI.getStrValue(strTemp)%></textarea></td>
    </tr>
    
    <tr>
      <td colspan="2"> <div align="center">
          <%
 	strTemp = strPreparedToEdit;
    if(WI.getStrValue(strTemp,"0").compareTo("0") == 0) {
		if (iAccessLevel > 1){
%>
          <input type="submit" value="Save Information" style="font-size:11px; height:28px;border: 1px solid #FF0000;"
	  onClick="PageAction('1');">
	  &nbsp;&nbsp;
	  <input type="button" value="Clear fields " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
	  onClick="PageAction('-1');">
          <%     }
  }else{ %>
          <input type="submit" value="Edit Information" style="font-size:11px; height:28px;border: 1px solid #FF0000;"
	  onClick="PageAction('2');">
      &nbsp;&nbsp;    
	  <input type="submit" value="Cancel Edit" style="font-size:11px; height:28px;border: 1px solid #FF0000;"
	  onClick="PageAction('');">
          
  <%}%>
          &nbsp;</div></td>
    </tr>
    <tr>
      <td colspan="2"><hr size="1" noshade></td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#BDD5DF">
      <td width="100%" height="25" colspan="5" class="thinborder" align="center"><strong>COURSE OUTLINE</strong></td>
    </tr>
    <tr>
      <td height="25" class="thinborder" style="font-size:9px" width="35%"><strong>SUB-CHAPTER</strong></td>
      <td class="thinborder" style="font-size:9px" width="5%"><strong>HOURS</strong></td>
      <td class="thinborder" style="font-size:9px" width="45%"><strong>TOPIC</strong></td>
      <td class="thinborder" style="font-size:9px" width="7%"><strong>EDIT</strong></td>
      <td class="thinborder" style="font-size:9px" width="8%"><strong>REMOVE</strong></td>
    </tr>
<%for(int i =0; i < vRetResult.size(); i += 5){%>
    <tr>
      <td height="25" class="thinborder" style="font-size:9px" width="20%">&nbsp;<%=(String)vRetResult.elementAt(i + 4)%>.<%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder" style="font-size:9px"><%=(String)vRetResult.elementAt(i + 3)%>&nbsp;</td>
      <td class="thinborder" style="font-size:9px"><span class="thinborder" style="font-size:9px">
	  <%=ConversionTable.replaceString(WI.getStrValue(vRetResult.elementAt(i + 2),"&nbsp;"), "\r\n","<br>")%></span></td>
      <td class="thinborder" style="font-size:9px">
	  <input name="submit" type="submit" style="font-size:11px; height:28px;border: 1px solid #FF0000;"
	  onClick="PreparedToEdit('<%=vRetResult.elementAt(i)%>');" value="&nbsp;Edit&nbsp;"></td>
      <td class="thinborder" style="font-size:9px"><span class="thinborder" style="font-size:9px">
        <input name="submit2" type="submit" style="font-size:11px; height:28px;border: 1px solid #FF0000;"
	  onClick="PageAction('0');document.form_.info_index.value=<%=vRetResult.elementAt(i)%>" value="Delete">
      </span></td>
    </tr>
<%}%>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="2" cellspacing="0">
  <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
  </tr>
  <tr bgcolor="#6A99A2">
    <td height="25">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="reload_page">
<input type="hidden" name="page_action">
<input type="hidden" name="chapter_index" value="<%=WI.fillTextValue("chapter_index")%>">
<input type="hidden" name="preparedToEdit" value="<%=strPreparedToEdit%>">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
