<%@ page language="java" import="utility.*,java.util.Vector,osaGuidance.Organization"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript"  src ="../../../Ajax/ajax.js" ></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">

function AjaxMapName() {
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
	
	document.form_.stud_id.value = strID;
	
}
function UpdateName(strFName, strMName, strLName) {
	
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}

function viewList(table,indexname,colname,labelname){
	var loadPg = "../../HR/hr_updatelist.jsp?opner_form_name=form_&tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+labelname;
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function GoBack() {
	location = "./org_add.jsp?organization_id="+escape(document.form_.organization_id.value)+
	"&sy_from="+document.form_.sy_from.value+"&sy_to="+document.form_.sy_to.value;
}
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	document.form_.print_pg.value="";
	this.SubmitOnce('form_');
}
function ReloadPage() {
	document.form_.page_action.value = "";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PrepareToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	document.form_.print_pg.value="";
	this.SubmitOnce('form_');
}
function Cancel() 
{
	document.form_.info_index.value = "";
	document.form_.page_action.value = "";
	document.form_.print_pg.value="";
	document.form_.prepareToEdit.value = "";
	this.SubmitOnce('form_');
}
function PrintPage(){
	document.form_.print_pg.value = "1";
	this.SubmitOnce("form_");
}
function UpdatePosition()
{
	var pgLoc = "./org_position_update.jsp";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<body bgcolor="#D2AE72">

<%
	if(WI.fillTextValue("print_pg").compareTo("1") == 0) {%>
		<jsp:forward page="./org_member_list_print.jsp" />
	<%}

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strPrepareToEdit = null;

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-OSA - Organization","org_member_update.jsp");
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
														"org_member_update.jsp");
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
Vector vRetResult = null;
Vector vEditInfo = null;
Vector vTemp = null;
Organization organization = new Organization();

strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");
strTemp = WI.fillTextValue("page_action");

if(strTemp.length() > 0){
	if(organization.operateOnOrgMember(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg =organization.getErrMsg();
	else
	{
		strErrMsg = "Operation is successful.";
		strPrepareToEdit = "0";
	}
}

if(strPrepareToEdit.compareTo("1") == 0) {
	vEditInfo = organization.operateOnOrgMember(dbOP, request, 3);	
	if(vEditInfo == null && strErrMsg == null ) 
		strErrMsg = organization.getErrMsg();
}

//I have to get here all information.
vRetResult = organization.operateOnOrgMember(dbOP, request, 5);

%>
<form action="./org_member_update.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2"><div align="center"><font color="#FFFFFF" ><strong>::::
          ORGANIZATIONS - UPDATE MEMBER PAGE ::::</strong></font></div></td>
    </tr>
    <tr >
      <td width="2%" height="25">&nbsp;</td>
      <td width="98%"><a href="javascript:GoBack();"><img src="../../../images/go_back.gif" width="50" height="27" border="0"></a>&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="6" bgcolor="#E0EBFC"><div align="center"><strong>&nbsp;MEMBERSHIP INFORMATION OF <%=WI.fillTextValue("organization_id")%></strong></div></td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td>School Year  :</td>
      <td colspan="4">
        <%strTemp = WI.fillTextValue("sy_from");
		if(strTemp.length() ==0)
			strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        -
        <%strTemp = WI.fillTextValue("sy_to");
		if(strTemp.length() ==0)
			strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");%>
      <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
      <a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td width="3%" height="24">&nbsp;</td>
      <td width="12%">Stud ID : </td>
      <td width="19%"><%
      	if (vEditInfo!=null && vEditInfo.size()>0)
      		strTemp = (String)vEditInfo.elementAt(4);
      	else
      		strTemp = WI.fillTextValue("stud_id");%>
        <input name="stud_id" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  	value="<%=strTemp%>" size="16" onKeyUp="AjaxMapName();"></td>
      <td width="19%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td width="10%">Position : </td>
      <td width="37%"><%if (vEditInfo!= null && vEditInfo.size()>0) 
      		strTemp = ((String)vEditInfo.elementAt(1)).trim();
   		else
      		strTemp = WI.fillTextValue("off_pos_index");%>
        <select name="off_pos_index">
          <option value="">Select position</option>
          <%=dbOP.loadCombo("official_pos_index","position_name"," from osa_preload_org_official_pos order by position_order", strTemp, false)%>
        </select>
      <a href='javascript:UpdatePosition();'><img src="../../../images/update.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4">
		<label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF; position:absolute; width:300px;"></label>
		</td>
    </tr>
  </table>

  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="25" width="2%">&nbsp;</td>
      <td height="25" valign="top"><font size="1">
	  <% if (iAccessLevel > 1){%>
	 <%if(!strPrepareToEdit.equals("1")) {%> 
	 	<a href='javascript:PageAction(1,"");'><img src="../../../images/add.gif" border="0" name="hide_save"></a> Add member 
        <%}else{%> <a href='javascript:PageAction(2, "");'><img src="../../../images/edit.gif" border="0"></a>Edit Member <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a> 
        Cencel operation 
        <%}%><%}%></font></td>
    </tr>
    <%if (vRetResult!= null && vRetResult.size()>0){%>
    <tr>
    	<td colspan="2" align="right">&nbsp;</td>
    </tr>
    <%}%>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){
vTemp = (Vector) vRetResult.elementAt(0);
if (vTemp != null && vTemp.size()>0){%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
     <tr>
      <td height="25" ><div align="right"><a href="javascript:PrintPage()"><img src="../../../images/print.gif" border="0"></a><font size="1">click to print  list&nbsp;</font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr>
      <td height="25" colspan="8" bgcolor="#B9B292" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>LIST
          OF OFFICERS FOR SCHOOL YEAR <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%></strong></font></div></td>
    </tr>
    <tr>
	  <td width="9%" class="thinborder"><div align="center"><font size="1"><strong>Position</strong></font></div></td>	
      <td width="8%" class="thinborder"><font size="1"><strong>Student ID </strong></font></td>
      <td width="22%" height="25" class="thinborder"><div align="center"><font size="1"><strong>Name</strong></font></div></td>
      <td width="11%" class="thinborder"><div align="center"><font size="1"><strong>Course Year </strong></font></div></td>
      <td width="12%" class="thinborder"><font size="1"><strong>Contact No. </strong></font></td>
      <td width="24%" class="thinborder"><div align="center"><font size="1"><strong>Address</strong></font></div></td>
      <td colspan="2" class="thinborder"><div align="center"><font size="1"></font></div>         </td>
    </tr>
<%
for(int i = 0 ; i < vTemp.size(); i += 12){%>
    <tr>
      <td class="thinborder"><%=(String)vTemp.elementAt(i + 2)%></td>
      <td class="thinborder"><%=(String)vTemp.elementAt(i + 4)%></td>
      <td height="25" class="thinborder"><%=(String)vTemp.elementAt(i + 5)%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vTemp.elementAt(i + 6),"&nbsp;")%><%=WI.getStrValue((String)vTemp.elementAt(i + 7),"(",")","")%>&nbsp;<%=WI.getStrValue(vTemp.elementAt(i + 8),"&nbsp;")%></td>
	  <td class="thinborder"><%=WI.getStrValue((String)vTemp.elementAt(i+11),"&nbsp;")%></td>
	  <% strTemp = 	WI.getStrValue((String)vTemp.elementAt(i+9));
	  	  if (strTemp.length() > 0) 
		  	strTemp += ", ";
		 strTemp +=  WI.getStrValue((String)vTemp.elementAt(i+10));
	  %>
      <td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
      <td width="6%" class="thinborder">
	  <% if (iAccessLevel == 2){%>
	  <a href='javascript:PrepareToEdit("<%=(String)vTemp.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a>
	  <%}%></td>
      <td width="8%" class="thinborder">
	  <% if (iAccessLevel == 2){%>
	  <a href='javascript:PageAction(0,"<%=vTemp.elementAt(i)%>");'><img src="../../../images/delete.gif" border="0"></a>
	  <%}%></td>
    </tr>
<%}%>
  </table>
<%
}//if list of officers is found
vTemp = (Vector) vRetResult.elementAt(1);
if (vTemp != null && vTemp.size()>0){%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
     <tr>
      <td height="25" >&nbsp;</td>
    </tr>
</table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr>
      <td height="25" colspan="8" bgcolor="#B9B292" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>LIST
          OF MEMBERS FOR SCHOOL YEAR <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%></strong></font></div></td>
    </tr>
    <tr>
      <td width="4%" class="thinborder"><strong><font size="1">No.</font></strong></td>
      <td width="10%" class="thinborder"><strong><font size="1">Student ID </font></strong></td>
      <td width="22%" height="25" class="thinborder"><div align="center"><font size="1"><strong>Name</strong></font></div></td>
      <td width="11%" class="thinborder"><div align="center"><font size="1"><strong>Course Year </strong></font></div></td>
      <td width="10%" class="thinborder"><font size="1"><strong>Contact No. </strong></font></td>
      <td width="30%" class="thinborder"><div align="center"><font size="1"><strong>Address</strong></font></div></td>
      <td colspan="2" class="thinborder"><div align="center"><font size="1"><font size="1"><font size="1"></font></font></font></div>         </td>
    </tr>
<%
for(int i = 0,iCtr = 1 ; i < vTemp.size(); i += 12, iCtr++){%>
    <tr>
      <td class="thinborder">&nbsp;<%=iCtr%></td>
      <td class="thinborder">&nbsp;<%=(String)vTemp.elementAt(i + 4)%></td>
      <td class="thinborder" height="25"><%=(String)vTemp.elementAt(i + 5)%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vTemp.elementAt(i + 6),"&nbsp;")%><%=WI.getStrValue((String)vTemp.elementAt(i + 7),"(",")","")%>&nbsp;<%=WI.getStrValue(vTemp.elementAt(i + 8),"&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vTemp.elementAt(i+11),"&nbsp;")%></td>
	  <% strTemp = 	WI.getStrValue((String)vTemp.elementAt(i+9));
	  	  if (strTemp.length() > 0) 
		  	strTemp += ", ";
		 strTemp +=  WI.getStrValue((String)vTemp.elementAt(i+10));
	  %>
      <td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
      <td width="5%" class="thinborder">
	  <% if (iAccessLevel == 2){%>
	  <a href='javascript:PrepareToEdit("<%=(String)vTemp.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a>
	  <%}%></td>
      <td width="8%" class="thinborder">
	  <% if (iAccessLevel == 2){%>
	  <a href='javascript:PageAction(0,"<%=vTemp.elementAt(i)%>");'><img src="../../../images/delete.gif" border="0"></a>
	  <%}%></td>
    </tr>
<%}%>
  </table>
<%}//if list of members is found
}//vRetResult > 0
%>

  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="page_action">
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
  <input type="hidden" name="print_pg">
  <input type="hidden" name="organization_id" value="<%=WI.fillTextValue("organization_id")%>">
  <input type="hidden" name="org_index" value="<%=WI.fillTextValue("org_index")%>">
  <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
