<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>

<script language="JavaScript">
//called for add or edit.
function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
function PrepareToEdit(strInfoIndex) {
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
</script>

<%@ page language="java" import="utility.*,lms.MgmtCirculation,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
	String strErrMsg = null;
	String strTemp   = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"lms-Administration-CIRCULATION","fine_type.jsp");
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
														"LIB_Administration","CIRCULATION",request.getRemoteAddr(),
														"fine_type.jsp");
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
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");

	MgmtCirculation mgmtFineType = new MgmtCirculation();
	Vector vEditInfo  = null;Vector vRetResult = null;

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(mgmtFineType.operateOnFineType(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = mgmtFineType.getErrMsg();
		else {
			if(strTemp.compareTo("0") == 0)
				strErrMsg = "Fine Type successfully removed.";
			if(strTemp.compareTo("1") == 0)
				strErrMsg = "Fine Type successfully added.";
			if(strTemp.compareTo("2") == 0)
				strErrMsg = "Fine Type successfully edited.";

			strPrepareToEdit = "0";
		}
	}

	vRetResult = mgmtFineType.operateOnFineType(dbOP, request,4);	
	
	//get vEditInfoIf it is called.
	if(strPrepareToEdit.compareTo("1") == 0) {
		vEditInfo = mgmtFineType.operateOnFineType(dbOP, request,3);
		if(vEditInfo == null)
			strErrMsg = mgmtFineType.getErrMsg();
	}
%>

<body bgcolor="#DEC9CC">
<form action="./fine_type.jsp" method="post" name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A8A8D5"> 
      <td height="25" colspan="8" bgcolor="#A8A8D5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CIRCULATION MANAGEMENT - FINE TYPE SETUP PAGE ::::</strong></font></div></td>
    </tr>
	</table>
	  
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3"><a href="fines.htm"><img src="../../images/go_back.gif" width="48" height="28" border="0"></a>&nbsp;&nbsp;&nbsp;<font size="3" color="#FF0000"><strong> 
        <%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Fine Code</td>
      <td width="82%">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("FINE_CODE");
%>	  <input type="text" name="FINE_CODE" size="16" maxlength="16" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Fine Description</td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("DESCRIPTION");
%>	  <input type="text" name="DESCRIPTION" size="48" maxlength="64" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"></td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td colspan="2"> 
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(3);
else	
	strTemp = WI.fillTextValue("EDIT_DEL_STAT");
if(strTemp.compareTo("0") == 0)
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>	  <input type="radio" name="EDIT_DEL_STAT" value="0"<%=strErrMsg%>>
        Default (Can be edited and deleted) &nbsp; &nbsp; &nbsp; 
<%
if(strTemp.compareTo("1") == 0)
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>		<input type="radio" name="EDIT_DEL_STAT" value="1"<%=strErrMsg%>>
        Cannot be Edited&nbsp; &nbsp; &nbsp; 
<%
if(strTemp.compareTo("2") == 0)
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>		<input type="radio" name="EDIT_DEL_STAT" value="2"<%=strErrMsg%>>
        Cannot be Deleted</td>
    </tr>
<%
if(iAccessLevel > 1) {%>
    <tr> 
      <td height="50">&nbsp;</td>
      <td width="12%">&nbsp;</td>
      <td><font size="1"> 
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>
        <a href='javascript:PageAction(1,"");'><img src="../../images/save.gif" border="0"></a> 
        Click to save entries 
        <%}else{%>
        <a href='javascript:PageAction(2, "");'><img src="../../images/edit.gif" border="0"></a> 
        Click to edit event 
        <%}%>
        <a href="./fine_type.jsp"><img src="../../images/cancel.gif" border="0"></a> 
        Click to clear entries </font></td>
    </tr>
<%}%>	
  </table>

<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" cellspacing="0" cellpadding="0" class="thinborder">
    <tr bgcolor="#DDDDEE"> 
      <td height="26" colspan="4" class="thinborder"> <div align="center"><font color="#FF0000"><strong>LIST 
          OF FINE TYPE SETUP PARAMETERS </strong></font></div></td>
    </tr>
    <tr> 
      <td width="23%" height="25" class="thinborder"><div align="center"><strong><font size="1">FINE 
          CODE </font></strong></div></td>
      <td width="38%" class="thinborder"><div align="center"><strong><font size="1">FINE DESCRIPTION</font></strong></div></td>
      <td width="23%" class="thinborder"><div align="center"><strong><font size="1">TYPE MODE</font></strong></div></td>
      <td width="16%" class="thinborder" align="center"><strong><font size="1">OPERATION</font></strong></td>
    </tr>
<%
int iTypeMode = 0;
String[] astrConvertTypeMode = {"Can be edited and deleted","Can't be edited","Can't be deleted","System generated"};
for(int i = 0; i < vRetResult.size(); i += 4){	
		iTypeMode = Integer.parseInt((String)vRetResult.elementAt(i + 3));
%>
    <tr> 
      <td height="25" class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i + 2)%></font></td>
      <td class="thinborder"><font size="1">&nbsp;
	  <%=astrConvertTypeMode[iTypeMode]%></font></td>
      <td class="thinborder"><font size="1">&nbsp;
        <%
if((iAccessLevel > 1 && (iTypeMode == 0 || iTypeMode == 2)) || strSchoolCode.startsWith("CIT")){%>
        <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../images/edit.gif" border="0"></a> 
<%}if((iAccessLevel == 2 && iTypeMode < 2) && strSchoolCode.startsWith("CIT")){%>
        <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'><img src="../../images/delete.gif" border="0"></a> 
<%}%>
        </font></td>
    </tr>
<%}%>
  </table>
<%}//end of vRetResult%>
<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">

</form>
	
</body>
</html>
<%
dbOP.cleanUP();
%>