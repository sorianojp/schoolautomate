<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PageAction(strInfoIndex,strAction) {
	document.form_.page_action.value = strAction;
	if(strAction == 1)
		document.form_.hide_save.src = "../../../images/blank.gif";
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
function PrepareToEdit(strInfoIndex) {
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
function Cancel() {
	document.form_.prepareToEdit.value = "0";
	document.form_.submit();
}
function ReloadPage() {
	document.form_.reload_page.value = "1";
	document.form_.page_action.value = "";
	document.form_.submit();
}
function ClearEntries() {
	location = "./activities_add.jsp?sy_from="+escape(document.form_.sy_from.value)+
		"&sy_to="+escape(document.form_.sy_to.value)+"&semester="+
		document.form_.semester[document.form_.semester.selectedIndex].value+
		"&organization_id="+
		escape(document.form_.organization_id.value);
}
function FocusID() {
	document.form_.organization_id.focus();
}
function OpenSearch() {
	var pgLoc = "../search/srch_org.jsp?opner_info=form_.organization_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function OpenSearch2() {
	var pgLoc = "../search/srch_mem.jsp?opner_info=form_.REQUESTED_BY";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

</script>
<%@ page language="java" import="utility.*,java.util.Vector,osaGuidance.Organization"%>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-OSA - Organization","activities_add.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Student Affairs",
														"ORGANIZATIONS",request.getRemoteAddr(),
														"activities_add.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
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
Vector vOrganizationDtl = null;
boolean bolRetainValue = false;//if it is true, use wi.fillTextValue(..);
String[] astrStatus ={"Regular", "Probationary","Failed", "(No Status)","Accredited"};


String strOrgIndex = null;
Organization organization = new Organization();
Vector vRetResult = null;
Vector vEditInfo  = null;
String strPrevOrgID = WI.fillTextValue("org_id_prev");
if(strPrevOrgID.length() == 0)
	strPrevOrgID = WI.fillTextValue("organization_id");

if(WI.fillTextValue("organization_id").length() > 0 && 
		WI.fillTextValue("organization_id").equals(strPrevOrgID)){
	vOrganizationDtl = organization.operateOnOrganization(dbOP, request,3);
	if(vOrganizationDtl == null)
		strErrMsg = organization.getErrMsg();
	else {
		strOrgIndex = (String)vOrganizationDtl.elementAt(0);
		request.setAttribute("organization_index",strOrgIndex);
	}
}

if(WI.fillTextValue("sy_from").length() > 0 
		&& WI.fillTextValue("organization_id").equals(strPrevOrgID))
	vRetResult = organization.operateOnActivity(dbOP, request,4);


String[] astrConvertSem = {"SUMMER","1ST SEM","2ND SEM","3RD SEM","4TH SEM"};
String[] astrConvertToDur = {"hours","days","weeks","months"};
String[] astrConvertToYesNo={"No","Yes"};
%>

<body onLoad="javascript:window.print()">
<% if (strErrMsg != null) {%> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td height="25">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
<% }if(vOrganizationDtl != null && vOrganizationDtl.size() > 0){%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="3" align="center"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Organization ID : <strong><%=WI.fillTextValue("organization_id")%></strong>
  	  </td>
      <td height="25">Status : 
	  	<strong><%=astrStatus[Integer.parseInt(WI.getStrValue((String)vOrganizationDtl.elementAt(16),"3"))]%>	  	</strong></td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="62%" height="25">Organization name : <strong><%=(String)vOrganizationDtl.elementAt(2)%></strong></td>
      <td width="35%" height="25">Date accredited: <strong><%=(String)vOrganizationDtl.elementAt(3)%></strong></td>
    </tr>
<!--
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">College/Department : <strong><%=WI.getStrValue(vOrganizationDtl.elementAt(5))%><%=WI.getStrValue((String)vOrganizationDtl.elementAt(7),"/","","")%></strong></td>
    </tr>
    <tr>
      <td height="25" colspan="3"><div align="right"><font size="1"><font size="1"><a 	href="activities_view_all.htm"><img src="../../../images/view.gif" width="40" height="31" border="0"></a>c<font size="1">lick
          to view other activities of the organization</font></font></font></div></td>
    </tr> -->
    <tr>
      <td height="18" colspan="3">&nbsp;</td>
    </tr>
  </table>
  <%}//only if organization detail is not null//
if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="8" ><div align="center"><strong>ACTIVITY
          LIST FOR SCHOOL YEAR <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%>(
		  <%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%>)</strong></div></td>
    </tr>
 </table>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td width="10%" height="27" class="thinborder" ><div align="center"><font size="1"><strong>DATE
          FILED </strong></font></div></td>
      <td width="14%" height="27" class="thinborder"><div align="center"><font size="1"><strong>REQUESTED
          BY</strong></font></div></td>
      <td width="14%" height="27" class="thinborder"><div align="center"><font size="1"><strong>POSITION</strong></font></div></td>
      <td width="14%" class="thinborder"><div align="center"><font size="1"><strong>ACTIVITY</strong></font></div></td>
      <td width="18%" class="thinborder"><div align="center"><font size="1"><strong>NATURE OF ACTIVITY</strong></font></div></td>
      <td width="12%" class="thinborder"><div align="center"><font size="1"><strong>START DATE</strong></font></div></td>
      <td width="9%" class="thinborder"><div align="center"><font size="1"><strong>DURATION</strong></font></div></td>
      <td width="9%" class="thinborder"><div align="center"><font size="1"><strong>FINANCIAL STAT.
          SUB </strong></font></div></td>
    </tr>
<%
for(int i = 0 ; i < vRetResult.size(); i += 16){%>
    <tr>
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 15),"&nbsp;")%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 4)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 5)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 6)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 7)%>
	  	(<%=astrConvertToDur[Integer.parseInt((String)vRetResult.elementAt(i + 8))]%>)</td>
      <td class="thinborder"><%=astrConvertToYesNo[Integer.parseInt((String)vRetResult.elementAt(i + 14))]%></td>
    </tr>
<%}%>
  </table>
<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>
