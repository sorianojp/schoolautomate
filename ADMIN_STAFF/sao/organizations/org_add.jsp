<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
	body{
		font-family:Verdana, Arial, Helvetica, sans-serif;
		font-size:11px;
	}
	td{
		font-family:Verdana, Arial, Helvetica, sans-serif;
		font-size:11px;
	}
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="Javascript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function UpdateMember(){
	if(document.form_.info_index.value.length == 0){
		alert("Organization reference is missing. Please try again.");
		return;
	}
	var pgLoc = "./org_member_update.jsp?org_index="+document.form_.info_index.value+"&organization_id="+
		escape(document.form_.organization_id.value) + "&sy_from="+ document.form_.sy_from.value +
		"&sy_to="+ document.form_.sy_to.value;
//	var win=window.open(pgLoc,"myfile",'dependent=yes,width=800,height=600,top=0,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
//	win.focus();
	location = pgLoc;

}
function ViewInfo(){
	document.form_.page_action.value = "3";
	document.form_.submit();
}

function AddRecord(){
	document.form_.page_action.value="1";
	document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.submit();
}

function EditRecord(){

	document.form_.page_action.value="2";
	document.form_.submit();
}

function CancelRecord(){
	location = "./org_add.jsp?organization_id="+document.form_.organization_id.value;
}

function FocusID() {
	document.form_.organization_id.focus();
}
function ReloadPage() {
	document.form_.reload_page.value = "1";
	this.ViewInfo();
}
function OpenSearch() {
	var pgLoc = "../search/srch_org.jsp?opner_info=form_.organization_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function viewList(table,indexname,colname,labelname,tablelist, 
									strIndexes, strExtraTableCond,strExtraCond,
									strFormField){				
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+
	"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>


<%@ page language="java" import="utility.*,java.util.Vector,osaGuidance.Organization"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strInfoIndex = null;


//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-OSA - Organization","org_add.jsp");
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
														"org_add.jsp");

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
Vector vRetEdit = null;
Vector vRetResult  = null;
Vector vRetMembers = null;

boolean bolNoRecord = false;
boolean bolRetainValue = false;//if it is true, use wi.fillTextValue(..);
String strHistory = "0";
Organization organization = new Organization();


int iAction =  0;
iAction = Integer.parseInt(WI.getStrValue(request.getParameter("page_action"),"3"));
strTemp = WI.fillTextValue("organization_id");
if (strTemp.trim().length()> 1 && WI.fillTextValue("sy_from").length() > 0){
	vRetEdit = organization.operateOnOrganization(dbOP, request,iAction);
	if(vRetEdit == null) {
		strErrMsg = organization.getErrMsg();
		bolRetainValue = true;
		vRetEdit = organization.operateOnOrganization(dbOP, request,3);
	}
	else if(iAction != 3) {
		strErrMsg = "Operation successful.";
		vRetEdit = organization.operateOnOrganization(dbOP, request,3);
	}
	
	vRetResult = organization.operateOnOrgMember(dbOP, request, 5);

}

if (vRetEdit == null || vRetEdit.size() < 1){
	bolNoRecord = true;
}
else
	strInfoIndex = (String)vRetEdit.elementAt(0);
if(!bolRetainValue && WI.fillTextValue("reload_page").compareTo("1") == 0)
	bolRetainValue = true;


String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>
<body bgcolor="#D2AE72" onLoad="FocusID()">
<form action="./org_add.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25"><div align="center"><font color="#FFFFFF" ><strong>::::
          ORGANIZATIONS - ADD/CREATE PAGE ::::</strong></font></div></td>
    </tr>
    <tr >
      <td height="25">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="30">&nbsp;</td>
      <td><div align="right">Organization ID  :&nbsp;</div></td>
      <td height="30"><input name="organization_id" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  	value="<%=WI.fillTextValue("organization_id")%>" size="25"></td>
      <td height="30"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
      <td><font size="1"><a href="javascript:ViewInfo();"><img src="../../../images/refresh.gif" border="0"></a></font></td>
    </tr>
    <tr> 
      <td height="24" width="2%">&nbsp;</td>
      <td width="15%"><div align="right">School Year :&nbsp;</div></td>
      <td width="25%" height="24"><%
	strTemp = WI.fillTextValue("sy_from");
	if (strTemp.length() == 0) 
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>

      <input name="sy_from" type="text" size="4"  class="textbox" value="<%=strTemp%>"
			onFocus="style.backgroundColor='#D3EBFF'"  maxlength="4"
			onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','sy_from')" 
			onKeyUp="DisplaySYTo('form_','sy_from','sy_to')"> 
      - 
<%
	strTemp = WI.fillTextValue("sy_to");
	if (strTemp.length() == 0) 
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>

      <input name="sy_to" type="text"  class="textbox" size="4"  value="<%=strTemp%>" readonly></td>
      <td width="5%" height="24">&nbsp;</td>
      <td width="53%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="5"><hr size="1"></td>
    </tr>
  </table>
<% if(WI.fillTextValue("organization_id").length() > 0 
		&& WI.fillTextValue("sy_from").length() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
<%
	if(bolNoRecord || bolRetainValue)
		strTemp = WI.fillTextValue("org_catg_index");
	else
		strTemp = WI.getStrValue((String)vRetEdit.elementAt(18));
%>
      <td height="25">Category : 
        <select name="org_catg_index">
		<%=dbOP.loadCombo("org_catg_index", "ORG_CATEGORY", 
			" from OSA_PRELOAD_ORG_CATG order by org_category",strTemp,false)%>
        </select>
<%if(strSchCode.startsWith("SPC")){%>		
		 <font size="1"><a href='javascript:viewList("OSA_PRELOAD_ORG_CATG","org_catg_index","ORG_CATEGORY","ORGANIZATION CATEGORY", "OSA_ORGANIZATION", "org_catg_index"," and is_valid = 1 ","","");'><img src="../../../images/update.gif" border="0"></a> 
        click to update list of CATEGORY</font>
<%}%>	
		</td>
    </tr>
    <tr> 
      <td width="2%" height="31">&nbsp;</td>
      <td width="98%" height="31">Organization name : 
        <%
if(bolNoRecord || bolRetainValue)
	strTemp = WI.fillTextValue("name");
else
	strTemp = (String)vRetEdit.elementAt(2);
%>
        <input name="name" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
			onBlur="style.backgroundColor='white'" 	value="<%=strTemp%>" size="48" maxlength="64"></td>
    </tr>
<!--
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">College : 
        <select name="c_index" onChange="ReloadPage();">
          <option value="0">N/A</option>
          <%
if(bolNoRecord || bolRetainValue)
	strTemp = WI.fillTextValue("c_index");
else
	strTemp = (String)vRetEdit.elementAt(4);

if(strTemp == null || strTemp.trim().length() == 0) strTemp = "0";
if(strTemp.compareTo("0") ==0)
	strTemp2 = "Offices : ";
else
	strTemp2 = "Department : ";
%>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> 
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"><%=strTemp2%>
        <select name="d_index">
          <%
strTemp3 = "";
if(bolNoRecord || bolRetainValue)
	strTemp3 = WI.fillTextValue("d_index");
else
	strTemp3 = (String)vRetEdit.elementAt(6);

if(strTemp.compareTo("0") == 0 || strTemp.length() ==0)
	strTemp = " and c_index is null";
else
	strTemp = " and c_index = "+strTemp;
%>
          <option value="">N/A</option>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 "+strTemp+" order by d_name asc",strTemp3, false)%>
        </select></td>
    </tr>
-->
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Date of Election of Officers : 
	  
	  <% 
	  	strTemp = WI.fillTextValue("date_election");
	  %>
        <input name="date_election" type="text" size="10"  class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'"  maxlength="10" value="<%=strTemp%>"
			onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','date_election','/')" 
			onKeyUp="AllowOnlyIntegerExtn('form_','date_election','/')"> 
        <a href="javascript:show_calendar('form_.date_election');" title="Click to select date" 
			onMouseOver="window.status='Select date';return true;" 	
			onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Advisor 1 : 
<%
	if(bolNoRecord || bolRetainValue){
		strTemp = WI.fillTextValue("advisor");
	}else{
		strTemp = WI.getStrValue((String)vRetEdit.elementAt(8));
		if (strTemp.length() == 0) 
			strHistory = "1";
	}
%>
        <input name="advisor" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
			onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="48" maxlength="64">
        <font size="1">(Lastname, Firstname Middlename) </font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Advisor 2 : 
<%
	if(bolNoRecord || bolRetainValue){
		strTemp = WI.fillTextValue("advisor2");
	}else{
		strTemp = WI.getStrValue((String)vRetEdit.elementAt(14));
	}
%>
        <input name="advisor2" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
		 onBlur="style.backgroundColor='white'" size="48" value="<%=strTemp%>" maxlength="64">
        <font size="1">        (Lastname, Firstname Middlename) </font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Advisor 3 : 
<%
	if(bolNoRecord || bolRetainValue){
		strTemp = WI.fillTextValue("advisor3");
	}else{
		strTemp = WI.getStrValue((String)vRetEdit.elementAt(15));
	}
%>
       <input name="advisor3" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
	   	onBlur="style.backgroundColor='white'" size="48" value="<%=strTemp%>" maxlength="64">
        <font size="1">(Lastname, Firstname Middlename) </font></td>
    </tr>
    <tr> 
      <td height="28">&nbsp;</td>
      <td height="28">Organization type/description: </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" style="font-size:9px"> 
        <%
if(bolNoRecord || bolRetainValue)
	strTemp = WI.fillTextValue("organization_type");
else
	strTemp = (String)vRetEdit.elementAt(11);
%>
        <textarea name="organization_type" cols="50" rows="2" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  class="textbox"><%=strTemp%></textarea>(Max 256 chars)</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Organization vision : 
      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"> 
        <%
if(bolNoRecord || bolRetainValue)
	strTemp = WI.fillTextValue("vision");
else
	strTemp = (String)vRetEdit.elementAt(12);
%>
        <textarea name="vision" cols="50" rows="2" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  class="textbox"><%=strTemp%></textarea></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Organization mission : </td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10"><div align="left"> 
          <%
if(bolNoRecord || bolRetainValue)
	strTemp = WI.fillTextValue("mission");
else
	strTemp = (String)vRetEdit.elementAt(13);
%>
          <textarea name="mission" cols="50" rows="2" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  class="textbox"><%=strTemp%></textarea>
        </div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td width="35%" height="10">&nbsp;&nbsp;Status :
  <%
	if(bolNoRecord || bolRetainValue)
		strTemp = WI.fillTextValue("status_index");
	else
		strTemp = WI.getStrValue((String)vRetEdit.elementAt(16));
  
  
  String strNameOfStat = null;
  if(strSchCode.startsWith("SPC"))
  	strNameOfStat = "Recognized";
  else	
  	strNameOfStat = "Regular";
  	
  %>
        <select name="status_index">
		  <option value=""></option>
		  <% if (strTemp.equals("0")){%> 
	          <option value="0" selected><%=strNameOfStat%></option>
		  <%}else{%> 
	          <option value="0" ><%=strNameOfStat%></option>
		   <%} if (strTemp.equals("1")){%> 
	          <option value="1" selected>Probationary</option>
		   <%}else{%> 
	          <option value="1" >Probationary</option>
  		   <%} if (strTemp.equals("4")){%> 
	          <option value="4" selected>Accredited</option>
		   <%}else{%> 
	          <option value="4">Accredited</option>
  		   <%}%> 
        </select></td>
      <td width="23%" height="10">Date accredited/approved:</td>
      <td width="42%"><font size="1">
        <%
if(bolNoRecord || bolRetainValue)
	strTemp = WI.fillTextValue("date_accredited");
else
	strTemp = WI.getStrValue((String)vRetEdit.elementAt(3));
%>
        <input name="date_accredited" type="text" value="<%=strTemp%>" size="10" readonly="true" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" >
      <a href="javascript:show_calendar('form_.date_accredited');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> </font></td>
    </tr>
    <tr>
      <td height="20" colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="3"><div align="center">
<% if (iAccessLevel > 1){
	if(bolNoRecord || strHistory.equals("1")) {%>
            <a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0" name="hide_save"></a>
            <font size="1">click to save entries&nbsp;</font>
            <%}else{%>
            <a href="javascript:EditRecord();"><img src="../../../images/edit.gif" border="0"></a>
            <font size="1">click to save changes &nbsp;
			<a href='javascript:CancelRecord();'><img src="../../../images/cancel.gif" border="0"></a>		
				click to cancel and clear entries</font>
            <%}
}%>	 </div> </td>
    </tr>
    <tr>
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
  </table>
<% if(!bolNoRecord && !strHistory.equals("1")){%>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  
 <% if (vRetResult != null && vRetResult.size() > 1) {
 		vRetMembers = (Vector)vRetResult.elementAt(0);
 
  %> 
  
    <tr bgcolor="#BFD9F9">
      <td height="25"><div align="center"><strong>LIST OF OFFICERS AND MEMBERS</strong></div></td>
    </tr>
    <tr>
      <td height="10">
	  
	 <% if (vRetMembers != null && vRetMembers.size() > 0) {%> 
	  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr>
      <td height="25" colspan="6" bgcolor="#B9B292" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>LIST
          OF OFFICERS FOR SCHOOL YEAR <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%></strong></font></div></td>
    </tr>
    <tr>
	  <td width="13%" class="thinborder"><div align="center"><font size="1"><strong>Position</strong></font></div></td>	
      <td width="13%" class="thinborder"><font size="1"><strong>Student ID </strong></font></td>
      <td width="23%" height="18" class="thinborder"><div align="center"><font size="1"><strong>Name</strong></font></div></td>
      <td width="14%" class="thinborder"><div align="center"><font size="1"><strong>Course &amp;Year </strong></font></div></td>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>Contact No. </strong></font></div></td>
      <td width="27%" class="thinborder"><div align="center"><font size="1"><strong>Address</strong></font></div></td>
      </tr>
<%if (vRetMembers != null) 
	for(int i =0 ; i < vRetMembers.size(); i += 12){%>
    <tr>
      <td class="thinborder"><%=(String)vRetMembers.elementAt(i + 2)%></td>
      <td class="thinborder"><%=(String)vRetMembers.elementAt(i + 4)%></td>
      <td height="25" class="thinborder"><%=(String)vRetMembers.elementAt(i + 5)%></td>
      <td class="thinborder">
	  		<%=WI.getStrValue((String)vRetMembers.elementAt(i + 6),"&nbsp;")%>
			<%=WI.getStrValue((String)vRetMembers.elementAt(i + 7),"(",")","")%>&nbsp;
			<%=WI.getStrValue(vRetMembers.elementAt(i + 8),"&nbsp;")%>
	  </td>
      <td class="thinborder">
	  		<%=WI.getStrValue((String)vRetMembers.elementAt(i+11),"&nbsp;")%>
	  </td>
	  <% strTemp = 	WI.getStrValue((String)vRetMembers.elementAt(i+9));
	  	  if (strTemp.length() > 0) 
		  	strTemp += ", ";
		 strTemp +=  WI.getStrValue((String)vRetMembers.elementAt(i+10));
	  %>
      <td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
      </tr>
<%}%>
  </table>
 <%}%> 
      </td>
    </tr>
    <tr>
      <td height="10">
<%
	vRetMembers = (Vector) vRetResult.elementAt(1);
	if (vRetMembers != null && vRetMembers.size() > 1) { 
%>
	  
	  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr>
      <td height="25" colspan="6" bgcolor="#B9B292" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>LIST
          OF MEMBERS FOR SCHOOL YEAR <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%></strong></font></div></td>
    </tr>
    <tr>
      <td width="4%" class="thinborder"><strong><font size="1">No.</font></strong></td>
      <td width="10%" class="thinborder"><strong><font size="1">Student ID </font></strong></td>
      <td width="22%" height="25" class="thinborder"><div align="center"><font size="1"><strong>Name</strong></font></div></td>
      <td width="11%" class="thinborder"><div align="center"><font size="1"><strong>Course &amp; Year </strong></font></div></td>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>Contact No. </strong></font></div></td>
      <td width="30%" class="thinborder"><div align="center"><font size="1"><strong>Address</strong></font></div></td>
      </tr>
<%
if (vRetMembers != null) 
for(int i = 0,iCtr = 1 ; i < vRetMembers.size(); i += 12, iCtr++){%>
    <tr>
      <td class="thinborder">&nbsp;<%=iCtr%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetMembers.elementAt(i + 4)%></td>
      <td class="thinborder" height="25"><%=(String)vRetMembers.elementAt(i + 5)%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetMembers.elementAt(i + 6),"&nbsp;")%>
	  						<%=WI.getStrValue((String)vRetMembers.elementAt(i + 7),"(",")","")%>
							<%=WI.getStrValue((String)vRetMembers.elementAt(i + 8),"&nbsp;","","")%></td>
      <td class="thinborder">
	  		<%=WI.getStrValue((String)vRetMembers.elementAt(i+11),"&nbsp;")%>
	  </td>
	  <% strTemp = 	WI.getStrValue((String)vRetMembers.elementAt(i+9));
	  	  if (strTemp.length() > 0) 
		  	strTemp += ", ";
		 strTemp +=  WI.getStrValue((String)vRetMembers.elementAt(i+10));
	  %>
      <td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
      </tr>
<%}%>
  </table>
  
<%}%>
	  </td>
    </tr>
<%}%> 
    <tr>
      <td height="10" align="center">
	  	<a href="javascript:UpdateMember();"><img src="../../../images/update.gif" border="0"></a>
		 <font size="1">Click to create/update members in this organization</font></td>
    </tr>

  </table>
  <%}
  
 } 
 %>

  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="10" align="center">&nbsp;</td>
    </tr>

    <tr >
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="info_index" value="<%=WI.getStrValue(strInfoIndex)%>">
<input type="hidden" name="page_action">
<input type="hidden" name="reload_page">
<input type="hidden" name="cur_org_id" value="<%=WI.fillTextValue("organization_id")%>">
<input type="hidden" name="is_history" value="<%=strHistory%>">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
