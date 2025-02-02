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
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function PageAction(strInfoIndex,strAction) {
	document.form_.print_page.value="";
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
	document.form_.print_page.value="";
	document.form_.submit();
}

function ReloadPage() {
	document.form_.reload_page.value = "1";
	document.form_.page_action.value = "";
	document.form_.print_page.value="";
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
	document.form_.print_page.value="";
	var pgLoc = "../search/srch_org.jsp?opner_info=form_.organization_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function OpenSearch2() {
	var pgLoc = "../search/srch_mem.jsp?opner_info=form_.REQUESTED_BY";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function PrintPg(){
	document.form_.print_page.value="1";
	document.form_.submit();
}

var objCOA;
var objCOAInput;
function AjaxMapName() {
	var strIDNumber = document.form_.REQUESTED_BY.value;
	objCOAInput = document.getElementById("coa_info");
	
	eval('objCOA=document.form_.REQUESTED_BY');
	if(strIDNumber.length < 3) {
		objCOAInput.innerHTML = "";
		return ;
	}
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+escape(strIDNumber);
	
	this.processRequest(strURL);
}

function UpdateID(strID, strUserIndex) {
	objCOA.value = strID;
	//objCOAInput.innerHTML = "";	
	this.AjaxMapName();
}

function UpdateName(strFName, strMName, strLName) {
		//do nothing.
}

function UpdateNameFormat(strName) {
	//do nothing.
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
	if (request.getParameter("print_page") != null && 
			request.getParameter("print_page").equals("1")){ %>
		<jsp:forward page="./activities_add_print.jsp" />
<%			
	return;}


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

java.sql.ResultSet rs = null;
String strAuthID = (String)request.getSession(false).getAttribute("userIndex");

Vector vOrganizationDtl = null;
boolean bolRetainValue = false;//if it is true, use wi.fillTextValue(..);

String strOrgIndex = null;
Organization organization = new Organization();
Vector vRetResult = null;
Vector vEditInfo  = null;
Vector vDocSubList = new Vector();

String strPrevOrgID = WI.fillTextValue("org_id_prev");
if(strPrevOrgID.length() == 0)
	strPrevOrgID = WI.fillTextValue("organization_id");

if(WI.fillTextValue("organization_id").length() > 0 && WI.fillTextValue("organization_id").compareTo(strPrevOrgID) == 0 && WI.fillTextValue("sy_from").length() > 0){
	vOrganizationDtl = organization.operateOnOrganization(dbOP, request,3);
	if(vOrganizationDtl == null)
		strErrMsg = organization.getErrMsg();
	else {
		strOrgIndex = (String)vOrganizationDtl.elementAt(0);
		request.setAttribute("organization_index",strOrgIndex);
	}
}


String strSQLQuery = null;
String strOrgActivityIndex = null;
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0 && WI.fillTextValue("sy_from").length() > 0){
	if(organization.operateOnActivity(dbOP, request,Integer.parseInt(strTemp)) == null)
		strErrMsg = organization.getErrMsg();
	else {
		///////this code below is to save/edit/delete the document submitted.
		
		//i have to get the ORG_ACTIVITY_INDEX first before i can insert.
		if(strTemp.equals("1") || strTemp.equals("2") || strTemp.equals("0")){
			
			//for delete and update, i will get the org_activity_index from info_index.
			if(strTemp.equals("2") || strTemp.equals("0")){
				strOrgActivityIndex = WI.fillTextValue("info_index");

				strSQLQuery = "delete from OSA_ORG_ACTIVITY_DOC_SUBMITTED where ORG_ACTIVITY_INDEX = "+strOrgActivityIndex;
				dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
			}
			
			//for insert i have to query the new added org_activity_index
			if(strTemp.equals("1")){
				strSQLQuery = "select ORG_ACTIVITY_INDEX from OSA_ORG_ACTIVITY where is_valid = 1 and encoded_by = "+strAuthID+
					" and create_date='"+WI.getTodaysDate()+"' and sy_from="+WI.fillTextValue("sy_from")+
					" and semester = "+WI.fillTextValue("semester");
				strOrgActivityIndex = dbOP.getResultOfAQuery(strSQLQuery,0);
			}		
			
				
			//for insert and update. i have to delete first before i can update.
			if(strTemp.equals("1") || strTemp.equals("2")){
				strSQLQuery = " insert into OSA_ORG_ACTIVITY_DOC_SUBMITTED(DOC_SUBMITTED_INDEX, ORG_ACTIVITY_INDEX) "+
					" values(?, "+strOrgActivityIndex+")";
				java.sql.PreparedStatement pstmtInsert = dbOP.getPreparedStatement(strSQLQuery);
				
				int iMaxItems = Integer.parseInt(WI.getStrValue(WI.fillTextValue("item_count"), "0"));
				String strDocSubIndex = null;
				for(int i = 1; i < iMaxItems; i++){
					strDocSubIndex = WI.fillTextValue("doc_sub_"+i);
					if(strDocSubIndex.length() == 0)
						  continue;
						  
					pstmtInsert.setString(1, strDocSubIndex);
					pstmtInsert.executeUpdate();
				}
			}			
		}
	
		strPrepareToEdit = "0";
		strErrMsg = "Operation successful";
	}
}
if(strPrepareToEdit.compareTo("1") == 0 && WI.fillTextValue("sy_from").length() > 0){
	vEditInfo = organization.operateOnActivity(dbOP, request,3);
	if(vEditInfo == null)
		strErrMsg = organization.getErrMsg();
	else{
		strOrgActivityIndex = WI.fillTextValue("info_index");
		
		strSQLQuery =  " select OSA_PRELOAD_DOC_SUBMITTED.DOC_SUBMITTED_INDEX, DOC_NAME  "+
			" from OSA_ORG_ACTIVITY_DOC_SUBMITTED "+
			" join OSA_PRELOAD_DOC_SUBMITTED on (OSA_PRELOAD_DOC_SUBMITTED.DOC_SUBMITTED_INDEX = OSA_ORG_ACTIVITY_DOC_SUBMITTED.DOC_SUBMITTED_INDEX) "+
			" where ORG_ACTIVITY_INDEX = "+strOrgActivityIndex;	
		rs = dbOP.executeQuery(strSQLQuery);
		while(rs.next()){
			vDocSubList.addElement(rs.getString(1));
			vDocSubList.addElement(rs.getString(2));
		}rs.close();		
	}	
		
}
if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("organization_id").compareTo(strPrevOrgID) == 0)
	vRetResult = organization.operateOnActivity(dbOP, request,4);
if(WI.fillTextValue("reload_page").compareTo("1") == 0 || vEditInfo == null)
	bolRetainValue = true;

String[] astrConvertSem     = {"SUMMER","1ST SEM","2ND SEM","3RD SEM","4TH SEM"};
String[] astrConvertToDur   = {"hours","days","weeks","months"};
String[] astrConvertToYesNo = {"No","Yes"};
%>

<body bgcolor="#D2AE72" onLoad="FocusID();">
<form action="./activities_add.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25"><div align="center"><font color="#FFFFFF" ><strong>::::
          ORGANIZATIONS - ACTIVITIES PAGE ::::</strong></font></div></td>
    </tr>
    <tr >
      <td height="25">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="19%" >Organization ID</td>
      <td width="18%"> <input name="organization_id" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  	value="<%=WI.fillTextValue("organization_id")%>" size="16"></td>
      <td width="7%"> <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
      <td width="54%"><input name="image" type="image" src="../../../images/form_proceed.gif"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td >School Year - Term</td>
      <td colspan="3">
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        - 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        - 
        <select name="semester">
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0 && WI.fillTextValue("page_value").length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select></td>
    </tr>
  </table>
<%
if(vOrganizationDtl != null && vOrganizationDtl.size() > 0){%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="48%" height="25">Organization name : <strong><%=(String)vOrganizationDtl.elementAt(2)%></strong></td>
      <td width="50%" height="25">Date accredited: <strong><%=(String)vOrganizationDtl.elementAt(3)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">College/Department : <strong><%=WI.getStrValue(vOrganizationDtl.elementAt(5))%><%=WI.getStrValue((String)vOrganizationDtl.elementAt(7),"/","","")%></strong></td>
    </tr>
<!--    <tr>
      <td height="25" colspan="3"><div align="right"><font size="1"><font size="1"><a href="activities_view_all.htm"><img src="../../../images/view.gif" width="40" height="31" border="0"></a>c<font size="1">lick
          to view other activities of the organization</font></font></font></div></td>
    </tr> -->
    <tr>
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%" height="26">&nbsp;</td>
      <td width="15%" height="26">Date Filed</td>
      <td width="31%"><font size="1"> 
        <%
if(bolRetainValue)
	strTemp = WI.fillTextValue("DATE_FILED");
else
	strTemp = (String)vEditInfo.elementAt(1);
%>
        <input name="DATE_FILED" type="text" value="<%=strTemp%>" size="15" readonly="true" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" >
        <a href="javascript:show_calendar('form_.DATE_FILED');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        </font></td>
      <td width="23%">Requested by(ID): 
      <%
if(bolRetainValue)
	strTemp = WI.fillTextValue("REQUESTED_BY");
else
	strTemp = (String)vEditInfo.elementAt(2);
%> <input name="REQUESTED_BY" size="12" type="text" class="textbox" 
	onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
  	value="<%=strTemp%>"  onKeyUp="AjaxMapName();"></td>
      <td width="29%"><a href="javascript:OpenSearch2();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a>
	  <label id="coa_info" style="width:300px; position:absolute"></label>
	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Name of Activity</td>
      <td height="25"> <%
if(bolRetainValue)
	strTemp = WI.fillTextValue("ACTIVITY_INDEX");
else
	strTemp = (String)vEditInfo.elementAt(3);
%> <select name="ACTIVITY_INDEX">
          <%
if(WI.fillTextValue("sy_from").length() > 0){%>
          <%=dbOP.loadCombo("distinct OSA_ORG_ACTION_PLAN.ACTIVITY_INDEX","ACTIVITY_NAME",
		  	" FROM OSA_ORG_ACTION_PLAN join OSA_PRELOAD_ORG_ACTIVITY on (OSA_PRELOAD_ORG_ACTIVITY.activity_index= "+
			"OSA_ORG_ACTION_PLAN.activity_index) where OSA_ORG_ACTION_PLAN.is_valid = 1 and OSA_ORG_ACTION_PLAN.organization_index = "+strOrgIndex+
			" and OSA_ORG_ACTION_PLAN.sy_from="+WI.fillTextValue("sy_from")+" order by ACTIVITY_NAME ",strTemp,false)%> 
          <%}%>
        </select></td>
      <td height="25" colspan="2">Nature of Activity 
        <%
if(bolRetainValue)
	strTemp = WI.fillTextValue("ACTIVITY_NATURE");
else
	strTemp = (String)vEditInfo.elementAt(5);
%> <input name="ACTIVITY_NATURE" type="text"
			class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  	value="<%=strTemp%>" size="25"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Start Date</td>
      <td height="25"><font size="1"> 
        <%
if(bolRetainValue)
	strTemp = WI.fillTextValue("START_DATE");
else
	strTemp = (String)vEditInfo.elementAt(6);
%>
        <input name="START_DATE" type="text" value="<%=strTemp%>" size="15" readonly="true" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" >
        <a href="javascript:show_calendar('form_.START_DATE');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        </font></td>
      <td height="25" colspan="2">Duration 
        <%
if(bolRetainValue)
	strTemp = WI.fillTextValue("DURATION");
else
	strTemp = (String)vEditInfo.elementAt(7);
%> <input name="DURATION" type="text" size="5" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"> 
        <%
if(bolRetainValue)
	strTemp = WI.fillTextValue("DURATION_UNIT");
else
	strTemp = (String)vEditInfo.elementAt(8);
%> <select name="DURATION_UNIT">
          <option value="0">hour(s)</option>
          <%
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>day(s)</option>
          <%}else{%>
          <option value="1">day(s)</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>week(s)</option>
          <%}else{%>
          <option value="2">week(s)</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>month(s)</option>
          <%}else{%>
          <option value="3">month(s)</option>
          <%}%>
        </select> </td>
    </tr>
    <tr> 
      <td height="25" colspan="5"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      
      <td width="43%" height="25">Objectives <font size="1">(press enter after
        each line)</font></td>     
    </tr>
    <tr>     
      <td height="25" rowspan="">
<%
if(bolRetainValue)
	strTemp = WI.fillTextValue("OBJECTIVE");
else
	strTemp = (String)vEditInfo.elementAt(9);
%>
	  <textarea name="OBJECTIVE" cols="70" rows="3" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  class="textbox"><%=strTemp%></textarea></td>     
    </tr>
  
 <%
Vector vDocSubmitted = new Vector();
strTemp = "select doc_submitted_index, doc_name from osa_preload_doc_submitted order by doc_name";
rs = dbOP.executeQuery(strTemp);
while(rs.next()){
	vDocSubmitted.addElement(rs.getString(1));//[0]doc_submitted_index
	vDocSubmitted.addElement(rs.getString(2));//[1]doc_name
}rs.close();
%> 
 
    <tr>      
      <td>
	  	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
			<tr><td height="25" colspan="4">Documents Submitted   
			<a href='javascript:viewList("osa_preload_doc_submitted","doc_submitted_index","doc_name","DOCUMENTS SUBMITTED", "osa_org_activity_doc_submitted", "doc_submitted_index"," and is_valid = 1 ","","");'><img src="../../../images/update.gif" border="0" height="25" width="60" align="absmiddle"></a></td></tr>
			
			<%
			int iCount = 1;
			int iIndexOf = 0;
			for(int i = 0; i < vDocSubmitted.size(); i+=2){
			
				strTemp = WI.fillTextValue("doc_sub_"+iCount);
				
				if(vEditInfo != null && vEditInfo.size() > 0){
					iIndexOf = vDocSubList.indexOf((String)vDocSubmitted.elementAt(i));
					if(iIndexOf == -1)
						strErrMsg = "";
					else
						strErrMsg = "checked";
				}else{
					if(strTemp.equals((String)vDocSubmitted.elementAt(i)))
						strErrMsg = "checked";
					else
						strErrMsg = "";
				}	
			
			%>
			<tr>
				<td style="text-indent:50px;">
					<input type="checkbox" name="doc_sub_<%=iCount++%>" <%=strErrMsg%> value="<%=(String)vDocSubmitted.elementAt(i)%>"> <%=vDocSubmitted.elementAt(i+1)%>
				</td>
			</tr>
    		<%}%>
			
			<input type="hidden" name="item_count" value="<%=iCount%>">
    	<tr><td height="10"></td></tr>
			<tr>
			  <td height="13">Submitted by :
		<%
		if(bolRetainValue)
			strTemp = WI.fillTextValue("SUBMITTED_BY");
		else
			strTemp = (String)vEditInfo.elementAt(13);
		%>
				<input name="SUBMITTED_BY" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				value="<%=strTemp%>"></td>
			</tr>
		</table>	  
	  </td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td height="10">Financial Report Submitted
<%

if(bolRetainValue)
	strTemp = WI.fillTextValue("FINANCIAL_R_SUBMIT");
else
	strTemp = (String)vEditInfo.elementAt(14);

if(strTemp == null || strTemp.length() == 0 || strTemp.compareTo("0") ==0)
	strTemp = "";
else
	strTemp = "checked";
%>        <input type="radio" name="FINANCIAL_R_SUBMIT" value="1" <%=strTemp%>>
        YES
<%
if(strTemp.length() ==0)
	strTemp = "checked";
else
	strTemp = "";
%>        <input type="radio" name="FINANCIAL_R_SUBMIT" value="0" <%=strTemp%>>
        NO</td>
      <td width="20%" height="10">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="3"><div align="center">
          <%if(iAccessLevel > 1){
	if(strPrepareToEdit.compareTo("0")  == 0){%>
          <a href='javascript:PageAction("","1");'> <img src="../../../images/save.gif" border="0" name="hide_save"></a><font size="1">click
          to save &nbsp;&nbsp;&nbsp; <a href="javascript:ClearEntries();"><img src="../../../images/clear.gif" border="0"></a>
          <%}else{%>
          <a href='javascript:PageAction("","2");'> <img src="../../../images/edit.gif" border="0" name="hide_save"></a>click
          to edit &nbsp;&nbsp; </font> <a href="javascript:ClearEntries();"><img src="../../../images/cancel.gif" border="0"></a>
          <font size="1">click to cancel </font>
          <%}
    }%>
        </div></td>
    </tr>
    <tr>
      <td height="18" colspan="3">&nbsp;</td>
    </tr>
  </table>

<%}//only if organization detail is not null//
if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25"><div align="right"><font size="1"><a href="javascript:PrintPg()"><img src="../../../images/print.gif" border="0" ></a>click
          to print action plan</font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="10" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>ACTIVITY
          LIST FOR SCHOOL YEAR <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%>(
		  <%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%>)</strong></font></div></td>
    </tr>
    <tr>
      <td width="11%" height="27" class="thinborder" ><div align="center"><font size="1"><strong>DATE
          FILED </strong></font></div></td>
      <td width="11%" height="27" class="thinborder"><div align="center"><font size="1"><strong>REQUESTED
          BY</strong></font></div></td>
      <td width="11%" height="27" class="thinborder"><div align="center"><font size="1"><strong>POSITION</strong></font></div></td>
      <td width="11%" class="thinborder"><div align="center"><font size="1"><strong>ACTIVITY</strong></font></div></td>
      <td width="11%" class="thinborder"><div align="center"><font size="1"><strong>NATURE OF ACTIVITY</strong></font></div></td>
      <td width="11%" class="thinborder"><div align="center"><font size="1"><strong>START DATE</strong></font></div></td>
      <td width="11%" class="thinborder"><div align="center"><font size="1"><strong>DURATION</strong></font></div></td>
      <td width="9%" class="thinborder"><div align="center"><font size="1"><strong>FINANCIAL STAT.
          SUB </strong></font></div></td>
      <td width="6%" class="thinborder"><div align="center"><font size="1">&nbsp;<strong>EDIT</strong></font></div></td>
      <td width="8%" height="27" class="thinborder"><div align="center"><font size="1"><strong><font size="1">DELETE</font></strong></font></div></td>
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
      <td class="thinborder"><%if(iAccessLevel > 1){%>
	  <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'>
	  		<img src="../../../images/edit.gif" border="0"></a>
	  <%}%></td>
      <td class="thinborder"><%if(iAccessLevel == 2){%>
	  <a href='javascript:PageAction("<%=(String)vRetResult.elementAt(i)%>","0");'>
	  	<img src="../../../images/delete.gif" border="0"></a>
		<%}%></td>
    </tr>
<%}%>
  </table>
<%}%>

  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="org_id_prev" value="<%=WI.fillTextValue("organization_id")%>">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="page_action">
<input type="hidden" name="reload_page">
<input type="hidden" name="print_page">

<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
