<%
WebInterface WI = new WebInterface(request);
String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
if(strSchCode == null)
	strSchCode = "";
	
boolean bolIsCIT = strSchCode.startsWith("CIT");

if(strSchCode.startsWith("CIT") && false){
	response.sendRedirect("add_collection_added_entries_cit.jsp?ACCESSION_NO="+WI.fillTextValue("ACCESSION_NO"));	
return;}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache");
%>
</head>

<script language="JavaScript">
function viewList(table,indexname,colname,labelname){
	var loadPg = "../../../ADMIN_STAFF/HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+
	labelname+"&opner_form_name=form_";
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	if(strAction == 1) 
		document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.submit();
}
function PrepareToEdit(strInfoIndex) {
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
function ReloadPage() {
	document.form_.page_action.value = "";
	document.form_.submit();
}
</script>

<%@ page language="java" import="utility.*,lms.CatalogLibCol,java.util.Vector" %>
<%

	DBOperation dbOP = null;	
	String strErrMsg = null;
	String strTemp   = null;
	
	String strInfoIndex = null;
	String strPageAction = null;
	
	String strBookIndex = WI.fillTextValue("ACCESSION_NO");
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"LIB_Cataloging-LIBRARY COLLECTION","add_collection_added_entries.jsp");
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
														"LIB_Cataloging","LIBRARY COLLECTION",request.getRemoteAddr(),
														"add_collection_added_entries.jsp");
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

	CatalogLibCol ctlgLibCol = new CatalogLibCol();
	strBookIndex = dbOP.mapBookIDToBookIndex(strBookIndex);
	if(strBookIndex == null) 
		strErrMsg = dbOP.getErrMsg();

	Vector vEditInfo  = null;Vector vRetResult = null;

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0 && strBookIndex != null) {
		if(ctlgLibCol.operateOnAddedEntry(dbOP, strBookIndex, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = ctlgLibCol.getErrMsg();
		else {
			strPrepareToEdit = "0";
			if(strTemp.compareTo("1") == 0)
				strErrMsg = "Added entries information successfully added.";
			if(strTemp.compareTo("2") == 0)
				strErrMsg = "Added entries information successfully edited.";
			if(strTemp.compareTo("0") == 0)
				strErrMsg = "Added entries information successfully removed.";
		}
	}

	
//get vEditInfoIf it is called.
if(strPrepareToEdit.compareTo("1") == 0) {
	vEditInfo = ctlgLibCol.operateOnAddedEntry(dbOP, strBookIndex, request,3);
	if(vEditInfo == null)
		strErrMsg = ctlgLibCol.getErrMsg();
}

if(strBookIndex != null) {
	vRetResult  = ctlgLibCol.operateOnAddedEntry(dbOP, strBookIndex, request,4);
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = ctlgLibCol.getErrMsg();
}
%>


<body bgcolor="#F2DFD2">
<form action="./add_collection_added_entries.jsp" method="post" name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A8A8D5"> 
      <td height="25" colspan="8" bgcolor="#A8A8D5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CATALOGING - LIBRARY COLLECTION - ADD TITLE - ADDED ENTRIES PAGE ::::</strong></font></div></td>
    </tr>
	</table>
	  
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="24" colspan="2">&nbsp;&nbsp;&nbsp;<font size="3" color="#FF0000"><strong> 
        <%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font></td>
    </tr>
    <tr> 
      <td width="4%" height="20">&nbsp;</td>
      <td width="96%"><strong>BOOK ACCESSION NUMBER : <%=WI.fillTextValue("ACCESSION_NO")%></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="97%" height="25"> <%
if(vEditInfo != null && vEditInfo.size() > 0) {
	if(vEditInfo.elementAt(1) != null)
		strTemp = "1";
	else	
		strTemp = "";
}
else	
	strTemp = WI.fillTextValue("radiobutton");

if(strTemp.compareTo("0") == 0 || strTemp.length()  == 0)
	strTemp = "checked";
else	
	strTemp = "";
%> <input type="radio" name="radiobutton" value="0" <%=strTemp%> onClick="ReloadPage();">
        Enter Author Information 
        <%
if(strTemp.length() > 0) 
	strTemp = "";
else	
	strTemp = " checked";
%> <input type="radio" name="radiobutton" value="1"<%=strTemp%> onClick="ReloadPage();">
        Enter Uncontrolled Name Information</td>
    </tr>
  </table>
<%
if(strTemp.length() == 0 && strBookIndex != null){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="20" bgcolor="#DDDDEE">&nbsp;</td>
      <td height="20" colspan="4" bgcolor="#DDDDEE"><font color="#FF0000"> PERSONAL 
        NAME (AUTHOR) : </font></td>
    </tr>
    <tr> 
      <td height="25" width="24">&nbsp;</td>
      <td width="67" height="30">Name<font style="font-weight:bold; color:#FF0000">*</font></td>
      <td width="327">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("name");
%>	  <input type="text" name="name" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="32" maxlength="64"></td>
      <td width="89">Dates </td>
      <td width="325">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(3);
else	
	strTemp = WI.fillTextValue("dates");
%>	  <input type="text" name="dates" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="24" maxlength="32"></td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
      <td height="30">Title</td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(4);
else	
	strTemp = WI.fillTextValue("title");
%>	  <input type="text" name="title" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="32" maxlength="64"></td>
      <td>Numeration</td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(5);
else	
	strTemp = WI.fillTextValue("numeration");
%>	  <input type="text" name="numeration" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="24" maxlength="32"></td>
    </tr>
  </table>
 
 <%}else if(strBookIndex != null) {//show if UNCONTROLLED name is selected%>
 
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="3%" height="20" bgcolor="#DDDDEE">&nbsp;</td>
      <td height="20" colspan="2" bgcolor="#DDDDEE"><font color="#FF0000"> UNCONTOLLED 
        NAME (EDITOR, INVENTOR, ETC.) : </font></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td width="8%" height="30">Name<font style="font-weight:bold; color:#FF0000">*</font></td>
      <td width="89%">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("name");
%>	  <input type="text" name="name" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="32" maxlength="64"></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td height="30">Relator</td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("relator");
%>	  <select name="relator" 
	  style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 14;">
<%=dbOP.loadCombo("AUTHOR_RELATOR_INDEX","RELATOR"," from LMS_LC_BI_AE_RELATOR order by  RELATOR asc",strTemp, false)%> </select>
		<a href='javascript:viewList("LMS_LC_BI_AE_RELATOR","AUTHOR_RELATOR_INDEX","RELATOR","RELATOR");'><img src="../../images/update_rec.gif" border="0"></a> 
        <font size="1" >(editor, inventor, scriptwriter, etc)</font></td>
    </tr>
  </table>
<%}//end of showing uncontrolled names. 
if(iAccessLevel > 1 && strBookIndex != null){%>
<table width="100%"  border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="25" align="center"><font size="1">
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>
        <a href='javascript:PageAction(1,"");'><img src="../../images/save_recommend.gif" border="0" name="hide_save"></a> 
        Click to save entries 
        <%}else{%>
        <a href='javascript:PageAction(2, "");'><img src="../../images/edit_recommend.gif" border="0"></a> 
        Click to edit event 
        <%}%>
        <a href="./add_collection_added_entries.jsp?ACCESSION_NO=
		<%=response.encodeRedirectURL(WI.fillTextValue("ACCESSION_NO"))%>"><img src="../../images/cancel_recommend.gif" border="0"></a> 
        Click to clear entries </font></td>
    </tr>
</table>
<%}
if(vRetResult != null && vRetResult.size() > 0){%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr bgcolor="#DDDDEE"> 
      <td height="25" colspan="5" class="thinborder"><div align="center"><font color="#FF0000">LIST 
          OF ADDED ENTRIES</font></div></td>
    </tr>
    <tr> 
      <td width="25%" height="25" class="thinborder"><div align="center"><font size="1"><strong> 
          NAME</strong></font></div></td>
      <td width="32%" class="thinborder"><div align="center"><font size="1"><strong>TITLE/RELATOR</strong></font></div></td>
      <td width="16%" class="thinborder"><div align="center"><font size="1"><strong>NUMERATION</strong></font></div></td>
      <td width="11%" class="thinborder"><div align="center"><font size="1"><strong>DATES</strong></font></div></td>
      <td class="thinborder"><div align="center"><font size="1"><strong>OPTIONS</strong></font></div></td>
    </tr>
    <%
for(int i = 0; i < vRetResult.size(); i += 8){%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i + 4))%>
	  <%=WI.getStrValue(vRetResult.elementAt(i + 6))%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i + 5))%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i + 3))%></td>
      <td width="16%" class="thinborder"><div align="center">
          <%
if(iAccessLevel > 1){%>
          <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i + 7)%>");'><img src="../../images/edit_recommend.gif" width="53" height="28" border="0"></a> 
          <%}if(iAccessLevel == 2){%>
          <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i + 7)%>");'><img src="../../images/delete_recommend.gif" width="53" height="26" border="0"></a> 
          <%}%>
          </div></td>
    </tr>
    <%}//for loop%>
  </table>
<%}%>
<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="ACCESSION_NO" value="<%=WI.fillTextValue("ACCESSION_NO")%>">

</form>
	
</body>
</html>
<%
dbOP.cleanUP();
%>