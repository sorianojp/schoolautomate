<%@ page language="java" import="utility.*, osaGuidance.ViolationConflict, enrollment.OfflineAdmission, java.util.Vector"%>
<%
WebInterface WI = new WebInterface(request);
boolean bolIsBasic = WI.fillTextValue("is_basic").equals("1");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="javascript"  src ="../../../Ajax/ajax.js" ></script>
<script language="javascript">
function ReloadPage()
{
	this.SubmitOnce('form_');
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function UpdateViolation(strIndex)
{
	location = "../vio_conflict/vio_conflict_update.jsp?info_index="+strIndex+"&allowEdit=0&parent_url=../stud_track/disciplinary_stat_track.jsp";
}


//// - all about ajax..
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.form_.stud_id.value;
		if(strCompleteName.length < 2)
			return;

		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.form_.stud_id.value = strID;
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing
}
function UpdateNameFormat(strName) {
	//do nothing
}
</script>
</head>

<body bgcolor="#D2AE72">
<%
	//authenticate user access level
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");

	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("STUDENT AFFAIRS-STUDENT TRACKER"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("STUDENT AFFAIRS"),"0"));
		}
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("Guidance & Counseling-STUDENT TRACKER".toUpperCase()),"0"));
		}
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("Guidance & Counseling".toUpperCase()),"0"));
		}
	}

	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

	DBOperation dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"STUDENT AFFAIRS-STUDENT TRACKER","membership_track.jsp");

	Vector vRetResult = null;
	Vector vStudDtls = null;
	int i = 0;
	String strErrMsg = null;

	String strTemp = null;
	int iSearchResult = 0;

	ViolationConflict vConf = new ViolationConflict();
	OfflineAdmission oAdm = new OfflineAdmission();


	if (WI.fillTextValue("stud_id").length()>0)
	{
		vStudDtls = oAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"));
		if (vStudDtls == null)
			strErrMsg = oAdm.getErrMsg();
		else if( vStudDtls.elementAt(7) == null)
			bolIsBasic = true;
		vRetResult = vConf.getViolations(dbOP, WI.fillTextValue("stud_id"));
		if (vRetResult== null && strErrMsg== null)
			strErrMsg = vConf.getErrMsg();
	}

String strTRCol = null;

%>
<form action="./disciplinary_stat_track.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF" ><strong>::::
          STUDENT DISCIPLINARY STATUS PAGE ::::</strong></font></div></td>
    </tr>
    <tr >
      <td height="25" colspan="4">&nbsp;<font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr valign="top">
      <td height="25" width="9%"></td>
      <td width="11%" height="25">Student ID</td>
      <td width="26%">
      <%strTemp = WI.fillTextValue("stud_id");%>
      <input name="stud_id" type="text" class="textbox" size="20" maxlength="20" value="<%=strTemp%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');" >
      </td>
      <td width="54%"><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label></td>
    </tr>
    <tr >
      <td height="25"></td>
      <td height="25">&nbsp;</td>
      <td colspan="2"><input name="image" type="image" src="../../../images/form_proceed.gif"></td>
    </tr>
    <tr >
      <td height="25" colspan="4"><hr size="1"></td>
    </tr>
	</table>
<%
if (WI.fillTextValue("stud_id").length()>0){
if (vStudDtls != null && vStudDtls.size()>0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="16%" height="25">Student Name : </td>
      <td width="37%" height="25">&nbsp;<%=WI.formatName((String)vStudDtls.elementAt(0),(String)vStudDtls.elementAt(1),(String)vStudDtls.elementAt(2),7)%></td>
      <td width="45%" height="25"><%if(!bolIsBasic){%>
	  	Year : &nbsp;<%=(String)vStudDtls.elementAt(14)%>
	  <%}%>
	  </td>
    </tr>
<%if(bolIsBasic) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Education Level  :  </td>
      <td height="25"><%=dbOP.getBasicEducationLevel(Integer.parseInt((String)vStudDtls.elementAt(14)))%></td>
      <td align="right">&nbsp;</td>
    </tr>
<%}else{%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Course/Major : </td>
      <td height="25">&nbsp;<%=(String)vStudDtls.elementAt(7)%> <%=WI.getStrValue((String)vStudDtls.elementAt(8), " - ","","")%></td>
      <td align="right">&nbsp;</td>
    </tr>
<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td align="right">&nbsp;</td>
    </tr>
  </table>
<%if (vRetResult != null && vRetResult.size()>0) {%>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="7"><div align="center"><font color="#FFFFFF">LIST
          OF DISCIPLINARY/COMPLAINTS FOR STUDENT <strong><%=WI.formatName((String)vStudDtls.elementAt(0),(String)vStudDtls.elementAt(1),(String)vStudDtls.elementAt(2),7 )%></strong></font></div></td>
    </tr>
    <tr>
      <td width="9%" height="26" ><div align="center"><font size="1"><strong>DATE</strong></font></div></td>
      <td width="11%" height="26"><div align="center"><font size="1"><strong>CASE
          # </strong></font></div></td>
      <td width="12%" height="26"><div align="center"><font size="1"><strong>INCIDENT
          TYPE </strong></font></div></td>
      <td width="22%"><div align="center"><font size="1"><strong>INCIDENT</strong></font></div></td>
      <td width="21%"><div align="center"><font size="1"><strong>COMPLAINANT NAME(S)</strong></font></div></td>
      <td width="20%"><div align="center"><font size="1"><strong>DESCRIPTION</strong></font></div></td>
      <td width="5%">&nbsp;</td>
    </tr>
    <%//System.out.println(vRetResult);
	 for (i = 0; i< vRetResult.size(); i+=9) {
    if (((String)vRetResult.elementAt(i+7)).equals("1"))
    	strTRCol = " bgcolor = '#DDDDDD'";
    	else
	   	strTRCol = " bgcolor = '#FFFFFF'";
    %>
    <tr <%=strTRCol%>>
      <td height="25"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></font></td>
      <td><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></font></td>
      <td><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></font></td>
      <td><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></font></td>
      <td><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+5)%></font></td>
      <td><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+6)%></font></td>
      <td><a href="javascript:UpdateViolation(<%=(String)vRetResult.elementAt(i)%>)"><img src="../../../images/view.gif" border="0"></a></td>
    </tr>
    <%}%>
  </table>
  <%}}}%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
