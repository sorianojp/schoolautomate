<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script src="../../../jscript/common.js"></script>
<script src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function ReloadPage() {
	document.form_.page_action.value = "";
	document.form_.submit();
}
function EditInfo() {
	document.form_.page_action.value = "2";
}
</script>
<body bgcolor="#F2DFD2">
<%@ page language="java" import="utility.*,lms.CatalogLibCol,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;
	boolean bolError = false;
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"LIB_Cataloging-LIBRARY COLLECTION","copy_information_edit.jsp");
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
														"copy_information_edit.jsp");
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
	Vector vRetResult = null;
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(ctlgLibCol.operateOnEditCopyInfo(dbOP, request, 2) == null) {
			strErrMsg = ctlgLibCol.getErrMsg();
			bolError = true;
		}
		else {
			strErrMsg = "Copy information successfully changed.";
		}
	}

//get all copy information.
vRetResult = ctlgLibCol.operateOnEditCopyInfo(dbOP, request, 3);
if(vRetResult == null) 
	strErrMsg = ctlgLibCol.getErrMsg();
%>

<form action="./copy_information_edit.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" bgcolor="#A8A8D5"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          CATALOGING - LIBRARY COLLECTION - COPY INFORMATION - EDIT PAGE ::::</strong></font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="20" colspan="4">
<%if(bolError){%>
<a href="javascript:history.back();"><img src="../../images/go_back_rec.gif" border="0"></a>
<%}%>
	  &nbsp;&nbsp;&nbsp;&nbsp;<font size="3" color="#FF0000"><strong> 
        <%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font>
</td>
    </tr>
	</table>
<%
if(vRetResult != null && vRetResult.size() > 0 && !bolError) {%>	  
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="3%" height="28">&nbsp;</td>
      <td width="13%" height="28">Material Type :</td>
      <td width="84%" height="28" colspan="2"> <strong><%=(String)vRetResult.elementAt(0)%></strong></td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29">Title :</td>
      <td height="29"><strong><%=(String)vRetResult.elementAt(1)%></strong></td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29">Author :</td>
      <td height="29"><strong><%=(String)vRetResult.elementAt(2)%></strong></td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29">Publisher :</td>
      <td height="29"><strong><%=(String)vRetResult.elementAt(3)%></strong></td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29">Call Number :</td>
      <td height="29"><strong><%=(String)vRetResult.elementAt(4)%></strong></td>
    </tr>
    <tr> 
      <td height="15" colspan="4"><hr size="1"></td>
    </tr>
	</table>
	  
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="3%" height="28">&nbsp;</td>
      <td height="28" colspan="2">Accession No.</td>
      <td width="84%" height="28"><input type="text" name="ACCESSION_NO" value="<%=(String)vRetResult.elementAt(5)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="32" maxlength="32"></td>
    </tr>
    <tr>
      <td height="28">&nbsp;</td>
      <td height="28" colspan="2">Barcode No.</td>
      <td height="28"><input type="text" name="barcode_no" value="<%=(String)vRetResult.elementAt(6)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="32" maxlength="32"></td>
    </tr>
    <tr> 
      <td height="28">&nbsp;</td>
      <td height="28" colspan="2">Call Number :</td>
      <td height="28"><input type="text" name="CALL_NUMBER" value="<%=(String)vRetResult.elementAt(4)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="32" maxlength="32"> </td>
    </tr>
    <tr> 
      <td height="28">&nbsp;</td>
      <td height="28" colspan="2"><div align="left"><u><font color="#FF0000">Description</font></u></div></td>
      <td height="28">&nbsp; </td>
    </tr>
    <tr> 
      <td height="28">&nbsp;</td>
      <td width="3%" height="28">&nbsp;&nbsp;&nbsp;&nbsp;</td>
      <td width="10%">Physical :</td>
      <td height="28"> <select name="MATERIAL_TYPE_PD_INDEX"
	  style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 14;">
	  <%//System.out.println(vRetResult);%>
          <%=dbOP.loadCombo("MATERIAL_TYPE_PD_INDEX","MATERIAL_TYPE_PD"," from LMS_MAT_TYPE_PD order by  MATERIAL_TYPE_PD asc",
		  	(String)vRetResult.elementAt(7), false)%> </select></td>
    </tr>
    <tr> 
      <td height="28">&nbsp;</td>
      <td height="28">&nbsp;</td>
      <td height="28">Series :</td>
      <td height="28"><input type="text" name="series" value="<%=WI.getStrValue((String)vRetResult.elementAt(8))%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="60" maxlength="128"></td>
    </tr>
    <tr> 
      <td height="28">&nbsp;</td>
      <td height="28">&nbsp;</td>
      <td height="28">Volume :</td>
      <td height="28"><input type="text" name="volume" value="<%=WI.getStrValue((String)vRetResult.elementAt(9))%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" size="60" maxlength="128"></td>
    </tr>
    <tr> 
      <td height="15" colspan="4"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="37" height="28">&nbsp;</td>
      <td width="145" height="28">Acquisition Date :</td>
      <td height="28" colspan="2"> <input name="date_received" type="text" size="12" readonly="true" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
		value="<%=WI.getStrValue((String)vRetResult.elementAt(10))%>"> <a href="javascript:show_calendar('form_.date_received');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>&nbsp;</td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29">Price :</td>
      <td width="1040" height="29"><input name="amount" type="text" size="12" value="<%=WI.getStrValue((String)vRetResult.elementAt(11))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td height="30">Funding Source :</td>
      <td height="30"> <select name="fs_index" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 11;">
          <%=dbOP.loadCombo("FUNDING_SOURCE_INDEX","FS_CODE + ' ('+FS_NAME+')'",
	" from LMS_FS_PROFILE WHERE is_valid = 1 and is_del = 0 and fs_stat = 1 order by fs_code asc", (String)vRetResult.elementAt(12), false)%> 
        </select> </td>
    </tr>
    <tr> 
      <td height="28">&nbsp;</td>
      <td height="28">Supplier :</td>
      <td height="28"> <select name="sup_index" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10;">
          <%=dbOP.loadCombo("SUPPLIER_INDEX","SUPPLIER_CODE + ' ('+SUPPLIER_NAME+')'",
	" from LMS_ACQ_SUPPLIER WHERE is_valid = 1 order by SUPPLIER_CODE asc", (String)vRetResult.elementAt(13), false)%> 
        </select> <font color="#3366CC" size="1">For suppliers not in the list, 
        inform Purchasing to add the supplier in the list</font></td>
    </tr>
    <tr> 
      <td height="15" colspan="4"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="37" height="28">&nbsp;</td>
      <td width="145" height="28">Circulation Type :</td>
      <td height="28" colspan="2"> <strong> 
        <select name="CTYPE_INDEX"
	  	  style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10;">
          <%=dbOP.loadCombo("CTYPE_INDEX","DESCRIPTION"," from LMS_CLOG_CTYPE WHERE IS_VALID = 1 AND IS_DEL = 0 order by DESCRIPTION asc",
		  	(String)vRetResult.elementAt(14), false)%> 
        </select>
        </strong></td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29">Collection Status :</td>
      <td width="1040" height="29"><font size="1"> 
<%
//if issued, do not edit.
strTemp = (String)vRetResult.elementAt(16);
if(strTemp != null && strTemp.compareTo("2") == 0) {%>
	<strong><%=(String)vRetResult.elementAt(15)%></strong>
<%}else{%>
        <select name="COL_STATUS" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 14;">
<%=dbOP.loadCombo("BS_REF_INDEX","STATUS"," from LMS_BOOK_STAT_REF WHERE BS_REF_INDEX <> 2 order by BS_REF_INDEX asc",
		  	(String)vRetResult.elementAt(16), false)%> 
        </select>
<%}%>		
        </font></td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29" valign="top">Circulation Alert:</td>
      <td height="29"><textarea name="cir_alert" cols="32" rows="3" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  maxlength="256" onkeyup='return isMaxLen(this)'><%=WI.getStrValue((String)vRetResult.elementAt(17))%></textarea> 
        <font color="#0066FF" size="1"><em>write here the alert message for circulation 
        when issuing this collection</em></font></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td height="29" valign="top">Collection Note:</td>
      <td height="29"><textarea name="col_note" cols="32" rows="3" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  maxlength="256" onkeyup='return isMaxLen(this)'><%=WI.getStrValue((String)vRetResult.elementAt(18))%></textarea>
        <font color="#0066FF" size="1"><em>write here the collection special note 
        (e.g. &quot;signed by author during book convention&quot;)</em></font></td>
    </tr>
    <tr> 
      <td height="15" colspan="4"><hr size="1"></td>
    </tr>
  </table>  
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="97%"><input type="image" src="../../images/save_recommend.gif" onClick="EditInfo();"> <font size="1">click 
        to save changes&nbsp; &nbsp;&nbsp;&nbsp;<a href="javascript:ReloadPage();"><img src="../../images/cancel_recommend.gif" border="0"></a> <font size="1">click 
        to cancel/clear changes </font></font></td>
    </tr>
  </table>
<%}%>

<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">  
<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
