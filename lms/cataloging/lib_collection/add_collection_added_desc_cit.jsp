<%
WebInterface WI = new WebInterface(request);
String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
if(strSchCode == null)
	strSchCode = "";


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

<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
//called for add or edit.
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
function viewList(table,indexname,colname,labelname){
	var loadPg = "../../../ADMIN_STAFF/HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + 
	"&colname=" + colname+"&label="+escape(labelname)+"&opner_form_name=form_";
	var win=window.open(loadPg,"myfile",'dependent=yes,width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function focusID() {
	document.form_.series.focus();
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
								"LIB_Cataloging-LIBRARY COLLECTION","add_collection_added_desc.jsp");
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
														"add_collection_added_desc.jsp");
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

	Vector vEditInfo  = null;

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0 && strBookIndex != null) {
		if(ctlgLibCol.operateOnAddedDescription(dbOP, strBookIndex, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = ctlgLibCol.getErrMsg();
		else {
			if(strTemp.compareTo("1") == 0)
				strErrMsg = "Added description information successfully added.";
			if(strTemp.compareTo("2") == 0)
				strErrMsg = "Added description information successfully edited.";
			if(strTemp.compareTo("0") == 0)
				strErrMsg = "Added description information successfully removed.";
		}
	}

	

if(strBookIndex != null) {
	vEditInfo  = ctlgLibCol.operateOnAddedDescription(dbOP, strBookIndex, request,4);
	if(vEditInfo == null && vEditInfo == null && strErrMsg == null)
		strErrMsg = ctlgLibCol.getErrMsg();
}
%>


<body bgcolor="#F2DFD2" onLoad="focusID();">
<form action="./add_collection_added_desc_cit.jsp" method="post" name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A8A8D5"> 
      <td height="25" colspan="8" bgcolor="#A8A8D5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CATALOGING - LIBRARY COLLECTION - ADD TITLE - ADDED DESCRIPTION PAGE 
          ::::</strong></font></div></td>
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
<%if(strBookIndex != null) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="19" colspan="4">&nbsp;</td>
    </tr>
    <tr> 
      <td height="20" bgcolor="#DDDDEE">&nbsp;</td>
      <td height="20" colspan="3" bgcolor="#DDDDEE"><font color="#FF0000">SERIES 
        STATEMENT/ADDED ENTRY--TITLE :</font></td>
    </tr>
    <tr> 
      <td width="49" height="28">&nbsp;</td>
      <td width="142" height="28">Series</td>
      <td height="28" colspan="2"> 
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("series");
%>	  <input type="text" name="series" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="60" maxlength="512"> </td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29">Volume</td>
      <td width="1041" height="29">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("volume");
%>	  <input type="text" name="volume" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="60" maxlength="512"> </td>
    </tr>
    <tr> 
      <td height="10" colspan="4"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="20" bgcolor="#DDDDEE">&nbsp;</td>
      <td height="20" colspan="3" bgcolor="#DDDDEE"><font color="#FF0000">NOTE FIELDS :</font></td>
    </tr>
	
	

	<tr>
	    <td height="28">&nbsp;</td>
	    <td>General</td>
	    <td><%
				if(vEditInfo != null && vEditInfo.size() > 0) 
					strErrMsg = (String)vEditInfo.elementAt(3);
				else	
					strErrMsg = WI.fillTextValue("gen");
			%>	  
				<textarea name="gen" rows="4" cols="60"><%=WI.getStrValue(strErrMsg)%></textarea></td>
	    </tr>
	<tr>
	    <td height="28">&nbsp;</td>
	    <td>Dissertation</td>
	    <td><%
				if(vEditInfo != null && vEditInfo.size() > 0) 
					strErrMsg = (String)vEditInfo.elementAt(15);
				else	
					strErrMsg = WI.fillTextValue("dissertation");
			%>	  <textarea name="dissertation" rows="4" cols="60"><%=WI.getStrValue(strErrMsg)%></textarea></td>
	    </tr>
	<tr>
	    <td height="28">&nbsp;</td>
	    <td>Bibliography</td>
	    <td><%
				if(vEditInfo != null && vEditInfo.size() > 0) 
					strErrMsg = (String)vEditInfo.elementAt(16);
				else	
					strErrMsg = WI.fillTextValue("bibliography");
			%>	  <textarea name="bibliography" rows="4" cols="60"><%=WI.getStrValue(strErrMsg)%></textarea></td>
	    </tr>
	<tr>
	    <td height="28">&nbsp;</td>
	    <td>Contents</td>
	    
		<td><%
				if(vEditInfo != null && vEditInfo.size() > 0) 
					strErrMsg = (String)vEditInfo.elementAt(17);
				else	
					strErrMsg = WI.fillTextValue("contents");
			%>	  <textarea name="contents" rows="4" cols="60"><%=WI.getStrValue(strErrMsg)%></textarea>
			</td>
	    </tr>
	<tr>
	    <td height="28">&nbsp;</td>
	    <td>Scale</td>
	    <td><%
				if(vEditInfo != null && vEditInfo.size() > 0) 
					strErrMsg = (String)vEditInfo.elementAt(18);
				else	
					strErrMsg = WI.fillTextValue("scale");
			%>	  <textarea name="scale" rows="4" cols="60"><%=WI.getStrValue(strErrMsg)%></textarea>
			</td>
	    </tr>
	<tr>
	    <td height="28">&nbsp;</td>
	    <td>Creation</td>
	    <td><%
				if(vEditInfo != null && vEditInfo.size() > 0) 
					strErrMsg = (String)vEditInfo.elementAt(19);
				else	
					strErrMsg = WI.fillTextValue("creation");
			%>	  <textarea name="creation" rows="4" cols="60"><%=WI.getStrValue(strErrMsg)%></textarea>
			</td>
	    </tr>
	<tr>
	    <td height="28">&nbsp;</td>
	    <td>Summary</td>
	    <td><%
				if(vEditInfo != null && vEditInfo.size() > 0) 
					strErrMsg = (String)vEditInfo.elementAt(4);
				else	
					strErrMsg = WI.fillTextValue("summary");
			%>	  <textarea name="summary" rows="4" cols="60"><%=WI.getStrValue(strErrMsg)%></textarea>
			</td>
	    </tr>
	<tr>
	    <td height="28">&nbsp;</td>
	    <td>Production</td>
	    <td><%
				if(vEditInfo != null && vEditInfo.size() > 0) 
					strErrMsg = (String)vEditInfo.elementAt(20);
				else	
					strErrMsg = WI.fillTextValue("production");
			%>	  <textarea name="production" rows="4" cols="60"><%=WI.getStrValue(strErrMsg)%></textarea>
			</td>
	    </tr>
	<tr>
	    <td height="28">&nbsp;</td>
	    <td>System Details</td>
	    <td><%
				if(vEditInfo != null && vEditInfo.size() > 0) 
					strErrMsg = (String)vEditInfo.elementAt(21);
				else	
					strErrMsg = WI.fillTextValue("system_detials");
			%>	  <textarea name="system_detials" rows="4" cols="60"><%=WI.getStrValue(strErrMsg)%></textarea>
			</td>
	    </tr>
	<tr>
	    <td height="28">&nbsp;</td>
	    <td>Language</td>
	    <td><%
				if(vEditInfo != null && vEditInfo.size() > 0) 
					strErrMsg = (String)vEditInfo.elementAt(22);
				else	
					strErrMsg = WI.fillTextValue("language");
			%>	  <textarea name="language" rows="4" cols="60"><%=WI.getStrValue(strErrMsg)%></textarea>
			</td>
	    </tr>
	
	<tr>
        <td height="28">&nbsp;</td>
        <td height="28">Local</td>
        <td height="28" colspan="2"><%
				if(vEditInfo != null && vEditInfo.size() > 0) 
					strErrMsg = (String)vEditInfo.elementAt(23);
				else	
					strErrMsg = WI.fillTextValue("local");
			%>	  <textarea name="local" rows="4" cols="60"><%=WI.getStrValue(strErrMsg)%></textarea>
			</td>
    </tr>
	
	
	
	

	
	
	
	
	
	
	

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
    <tr> 
      <td height="15" colspan="4"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#DDDDEE"> 
      <td height="20" bgcolor="#DDDDEE">&nbsp;</td>
      <td height="20" colspan="2"><font color="#FF0000">TARGET AUDIENCE NOTE:</font></td>
    </tr>
<!--
    <tr> 
      <td height="28">&nbsp;</td>
      <td height="28">Target Audience Info.</td>
      <td height="28"><select name="select">
          <option></option>
          <option>Reading Grade Level</option>
          <option>Interest Age Level</option>
          <option>Interest Grade Level</option>
          <option>Special audience characteristics</option>
          <option>Motivation interest level</option>
        </select> <font size="1">&lt;add space or empty value in the list&gt;</font></td>
    </tr>
-->
    <tr> 
      <td height="28">&nbsp;</td>
      <td height="28">Reading Grade Level</td>
      <td height="28"> 
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(5);
else	
	strTemp = WI.fillTextValue("read_gl");
%>	  <input name="read_gl" type="text" size="2" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        <font size="1">(Can be between 0 - 25) </font></td>
    </tr>
    <tr> 
      <td width="48" height="28">&nbsp;</td>
      <td width="265" height="28">Interest Age Level</td>
      <td width="919" height="28">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(6);
else	
	strTemp = WI.fillTextValue("interest_al");
%>	  <select name="interest_al" 
	  style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10;">
          <%=dbOP.loadCombo("INTEREST_AL_INDEX","AGE_LEVEL"," from LMS_LC_BI_AD_IAL order by  AGE_LEVEL asc",
		  	strTemp, false)%> </select>
        <font size="1" ><a href='javascript:viewList("LMS_LC_BI_AD_IAL","INTEREST_AL_INDEX","AGE_LEVEL","AGE_LEVEL");'><img src="../../images/update_rec.gif" border="0"></a></font> 
        (<em>e.g. </em>03 - 05, 05 - 10, etc.) </td>
    </tr>
    <tr> 
      <td height="28">&nbsp;</td>
      <td height="28">Interest Grade Level</td>
      <td height="28">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(7);
else	
	strTemp = WI.fillTextValue("interest_gl");
%>	  <select name="interest_gl" 
	  style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10;">
          <%=dbOP.loadCombo("INTEREST_GL_INDEX","GRADE_LEVEL"," from LMS_LC_BI_AD_IGL order by  GRADE_LEVEL asc",
		  	strTemp, false)%> </select> </td>
    </tr>
    <tr> 
      <td height="28">&nbsp;</td>
      <td height="28">Special Audience Characteristics</td>
      <td height="28">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(8);
else	
	strTemp = WI.fillTextValue("spl_aud");
%>	  <input type="text" name="spl_aud" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="32" maxlength="64"> </td>
    </tr>
    <tr>
      <td height="28">&nbsp;</td>
      <td height="28">Motivation Interest Level</td>
      <td height="28">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(9);
else	
	strTemp = WI.fillTextValue("interest_ml");
%>	  <select name="interest_ml" 
	  style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10;">
          <%=dbOP.loadCombo("INTEREST_ML_INDEX","MOTIVATION_LEVEL"," from LMS_LC_BI_AD_IML order by  MOTIVATION_LEVEL asc",
		  	strTemp, false)%> </select>
        <font size="1"><a href='javascript:viewList("LMS_LC_BI_AD_IML","INTEREST_ML_INDEX","MOTIVATION_LEVEL","MOTIVATION_LEVEL");'><img src="../../images/update_rec.gif" border="0"></a>click 
        to update list of motivation interest level</font
        ></td>
    </tr>
    <tr> 
      <td height="15" colspan="3"> 
        <hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#DDDDEE"> 
      <td height="20" bgcolor="#DDDDEE">&nbsp;</td>
      <td height="20" colspan="2"><font color="#FF0000">ELECTRONIC LOCATION AND 
        ACCESS :</font></td>
    </tr>
    <tr> 
      <td width="4%" height="28">&nbsp;</td>
      <td width="12%" height="28">Web URL</td>
      <td width="84%" height="28">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(10);
else	
	strTemp = WI.fillTextValue("url");
%>	  <input type="text" name="url" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="64" maxlength="256"></td>
    </tr>
    <tr> 
      <td height="28">&nbsp;</td>
      <td height="28">Note/Desc.</td>
      <td height="28">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(11);
else	
	strTemp = WI.fillTextValue("desc");
%>	  <input type="text" name="desc" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="64" maxlength="512"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <%
if(iAccessLevel > 1) {%>
    <tr> 
      <td height="35" colspan="5" valign="bottom"><div align="center"><font size="1"> 
          <%if(strPrepareToEdit.compareTo("1") != 0) {%>
          <a href='javascript:PageAction(1,"");'><img src="../../images/save_recommend.gif" border="0" name="hide_save"></a> 
          Click to save entries 
          <%}else{%>
          <a href='javascript:PageAction(2, "");'><img src="../../images/edit_recommend.gif" border="0"></a> 
          Click to edit event 
          <%}%>
          <a href="./add_collection_added_desc.jsp?ACCESSION_NO=
		<%=response.encodeRedirectURL(WI.fillTextValue("ACCESSION_NO"))%>"><img src="../../images/cancel_recommend.gif" border="0"></a> 
          Click to clear entries </font></div></td>
    </tr>
<%}%>	
  </table>
<%}//show only if book information is found."
%>
<input type="hidden" name="page_action">
<input type="hidden" name="info_index">
<input type="hidden" name="ACCESSION_NO" value="<%=WI.fillTextValue("ACCESSION_NO")%>">

</form>
	
</body>
</html>
<%
dbOP.cleanUP();
%>