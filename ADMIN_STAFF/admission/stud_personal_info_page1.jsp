<%
//I have to make sure this is temp or perm ID.
boolean bolIsTempID = false;
String strTemp = request.getParameter("stud_id");
if(strTemp == null || strTemp.length() == 0) 
	strTemp = "";
else {
	//String strSQLQuery = "select application_index from new_application where temp_id ='"+strTemp+"'";
	utility.DBOperation dbOP = new utility.DBOperation();
	//strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0) ;
	if(dbOP.mapUIDToUIndex(strTemp) == null) 
		bolIsTempID = true;
	dbOP.cleanUP();
	
	//forward the page accordingly.. 
	if(bolIsTempID) {
		request.getSession(false).setAttribute("tempId",request.getParameter("stud_id"));
		response.sendRedirect(response.encodeURL("../../PARENTS_STUDENTS/ADMISSION MODULE PAGES/single file items/ADMISSION FOR NEW_TRANSFERRE STUDENTS/gspis_page_edit_temp.jsp"));
		return;
	}%>
		<jsp:forward page="./stud_personal_info_page2.jsp"></jsp:forward>
<%	
}%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript"  src ="../../Ajax/ajax.js" ></script>
<script language="JavaScript">
function OpenSearch() {
	var pgLoc = "../../search/srch_stud.jsp?opner_info=offlineRegd.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function RelayPrint()
{
	if (document.offlineRegd.stud_id.value.length > 0) 
		location = "./stud_personal_info_print.jsp?stud_id="+document.offlineRegd.stud_id.value;
	else
		alert (" Please enter student ID");
}
function FocusID() {
	document.offlineRegd.stud_id.focus();
}

//// - all about ajax.. 
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.offlineRegd.stud_id.value;
		if(strCompleteName.length < 2)
			return;
		
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.offlineRegd.stud_id.value = strID;
	document.offlineRegd.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.offlineRegd.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}
</script>


<body bgcolor="#D2AE72" onLoad="FocusID();">
<form action="./stud_personal_info_page1.jsp" method="post" name="offlineRegd">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF" ><strong>::::
          STUDENT PERSONAL INFO PAGE ::::</strong></font></div></td>
    </tr>
    <tr >
      <td height="25" width="6%"></td>
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    <tr valign="top">
      <td height="25" width="6%"></td>
      <td width="21%" height="25">Temp/ Perm Student ID</td>
      <td width="20%"><input type="text" name="stud_id" size="20" maxlength="32" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');"></td>
      <td width="5%"><a href="javascript:OpenSearch();"><img src="../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td width="48%">
	  <label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label>
	  </td>
    </tr>
    <tr >
      <td height="25"></td>
      <td height="25">&nbsp;</td>
      <td colspan="3"><input name="image" type="image" src="../../images/form_proceed.gif">
      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      <a href="javascript:RelayPrint()"><img src="../../images/print.gif" border="0"></a>      </td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td width="86%" height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
</form>
</body>
</html>
