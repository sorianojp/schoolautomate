<%	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	String strInfo5   = (String)request.getSession(false).getAttribute("info5");
%>
	
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function OpenSearch() {
	var pgLoc = "../../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

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
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.form_.stud_id.value = strID;
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}


function ReloadPage(){
	document.form_.submit();
}

function FocusID(){
	if(document.form_.ship_name)
		document.form_.ship_name.focus();
	else	
		document.form_.stud_id.focus();
}

function PageAction(strAction, strInfoIndex){
	if(strAction == "0"){
		if(!confirm("Do you want to delete this information?"))
			return ;
	}
	
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	document.form_.submit();
}

</script>

<body bgcolor="#D2AE72" onLoad="FocusID();">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-REPORTS","school_days_present_mpc.jsp");
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
														"Registrar Management","REPORTS",request.getRemoteAddr(),
														"school_days_present_mpc.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}
//end of authenticaion code.

enrollment.OfflineAdmission offlineAdm = new enrollment.OfflineAdmission();
enrollment.ReportRegistrarExtn rprtReg = new enrollment.ReportRegistrarExtn();




Vector vRetResult = null;
Vector vStudInfo = null;
Vector vSubList = new Vector();
java.sql.ResultSet rs = null;
String strStudID = WI.fillTextValue("stud_id");
String strSubIndex = WI.fillTextValue("sub_index");
String strUserIndex = null;
if(strStudID.length() > 0){
	strUserIndex = dbOP.mapUIDToUIndex(strStudID, 4);
	if(strUserIndex == null)
		strErrMsg = "Student does not exists or is invalidated.";
	else{
		/**I need to get the list of student subject in g_sheet_final
		so  they can selecy which subject they will encode  the apprentice
		*/
	
		strTemp = " select sub_index, sub_code, sub_name from g_sheet_final  "+
				" join subject on (sub_index = s_index)  "+
				" join STUD_CURRICULUM_HIST on (STUD_CURRICULUM_HIST.CUR_HIST_INDEX = G_SHEET_FINAL.CUR_HIST_INDEX) "+
				" where g_sheet_final.is_valid =1 and user_index_ = "+strUserIndex+
				" order by sy_from, semester, SUB_NAME ";
		rs = dbOP.executeQuery(strTemp);
		while(rs.next()){
			vSubList.addElement(rs.getString(1));
			vSubList.addElement(rs.getString(2));
			vSubList.addElement(rs.getString(3));
		}rs.close();
	}	
}

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(rprtReg.operateOnApprenticeInfoWNU(dbOP, request, Integer.parseInt(strTemp), strUserIndex) == null)
		strErrMsg = rprtReg.getErrMsg();
	else{
		if(strTemp.equals("0"))
			strErrMsg = "Information successfully deleted.";
		if(strTemp.equals("1"))
			strErrMsg = "Information successfully updated.";			
	}
}


if(vSubList.size() > 0)
	vRetResult = rprtReg.operateOnApprenticeInfoWNU(dbOP, request, 4, strUserIndex);


%>
<form action="./encode_apprentice_info.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr bgcolor="#A49A6A">
		<td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: APPRENTICE INFORMATION ENCODING PAGE ::::</strong></font></div></td>
	</tr>
	<tr bgcolor="#FFFFFF"><td width="3%" height="25">&nbsp;</td><td><font color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td></tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="17%">ID Number</td>
		<td width="13%">
			<input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
			  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');">		</td>
		<td width="67%">
			<a href="javascript:OpenSearch();"><img src="../../../../images/search.gif" width="37" height="30" border="0" align="absmiddle"></a>
			<a href="javascript:ReloadPage();"><img src="../../../../images/form_proceed.gif" border="0" align="absmiddle"></a>
			  <label id="coa_info" style="font-size:11px; width:400px; position:absolute;"></label>		</td>
	</tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>&nbsp;</td>
	    <td>&nbsp;</td>
	    <td>&nbsp;</td>
	    </tr>
</table>

<%if(vSubList != null && vSubList.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td width="3%" height="25">&nbsp;</td>
		<td width="24%">Subject List</td>
		<td width="73%">
			<select name="sub_index" style="width:300px;" onChange="ReloadPage();">
				<option value="">Please select a subject</option>
				<%
				strTemp = WI.fillTextValue("sub_index");				
				for(int i = 0 ; i < vSubList.size(); i+=3){
					if(strTemp.equals(vSubList.elementAt(i)))
						strErrMsg = "selected";
					else
						strErrMsg = "";
				%>
				<option value="<%=vSubList.elementAt(i)%>" <%=strErrMsg%>><%=vSubList.elementAt(i+1)%> (<%=vSubList.elementAt(i+2)%>)</option>
				<%}%>
			</select>		</td>
	</tr>
	<%if(strSubIndex.length() > 0){%>
	<tr>
		<td height="25">&nbsp;</td>
		<td>Name of Ship</td>
		<%
		strTemp = WI.fillTextValue("ship_name");
		if(vRetResult != null && vRetResult.size() > 0)
			strTemp = (String)vRetResult.elementAt(5);		
		%>
		<td><input name="ship_name" type="text" size="25" value="<%=strTemp%>" class="textbox" maxlength="64"
			  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>		
	</tr>
<!--	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Grade</td>
		<%
		strTemp = WI.fillTextValue("apprentice_grade");
		if(vRetResult != null && vRetResult.size() > 0)
			strTemp = (String)vRetResult.elementAt(6);		
		%>
	    <td>
		<input name="apprentice_grade" type="text" size="4" value="<%=strTemp%>" class="textbox" maxlength="4"
			  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyFloat('form_','apprentice_grade')">
		</td>
	    </tr>-->
		<input type="hidden" name="apprentice_grade" value="0">
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Duration of Duty</td>
		<%
		strTemp = WI.fillTextValue("duration_of_duty");
		if(vRetResult != null && vRetResult.size() > 0)
			strTemp = (String)vRetResult.elementAt(7);		
		%>
	    <td><input name="duration_of_duty" type="text" size="30" value="<%=strTemp%>" class="textbox" maxlength="128"
			  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Contract From</td>
		<%
		strTemp = WI.fillTextValue("contract_from");
		if(vRetResult != null && vRetResult.size() > 0)
			strTemp = (String)vRetResult.elementAt(8);		
		%>
	    <td>
		<input name="contract_from" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.contract_from');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>		</td>
	    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Contract To</td>
		<%
		strTemp = WI.fillTextValue("contract_to");
		if(vRetResult != null && vRetResult.size() > 0)
			strTemp = (String)vRetResult.elementAt(9);		
		%>
	    <td>
		<input name="contract_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.contract_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>		</td>
	    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Gross Tonnage of Ship</td>
		<%
		strTemp = WI.fillTextValue("ship_tonnage");
		if(vRetResult != null && vRetResult.size() > 0)
			strTemp = (String)vRetResult.elementAt(10);		
		%>
	    <td><input name="ship_tonnage" type="text" size="25" value="<%=strTemp%>" class="textbox" maxlength="64"
			  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Ship Registry number</td>
		<%
		strTemp = WI.fillTextValue("registry_number");
		if(vRetResult != null && vRetResult.size() > 0)
			strTemp = (String)vRetResult.elementAt(11);		
		%>
	    <td><input name="registry_number" type="text" size="25" value="<%=strTemp%>" class="textbox" maxlength="64"
			  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Remarks</td>
		<%
		strTemp = WI.fillTextValue("remarks_");
		if(vRetResult != null && vRetResult.size() > 0)
			strTemp = (String)vRetResult.elementAt(12);		
		%>
	    <td>
			<textarea name="remarks_" rows="2" cols="40"><%=WI.getStrValue(strTemp)%></textarea>
		</td>
	    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>&nbsp;</td>
		<%
		strTemp = "";
		if(vRetResult != null && vRetResult.size() > 0)
			strTemp = (String)vRetResult.elementAt(0);
		%>
	    <td>
		<a href="javascript:PageAction('1','<%=strTemp%>');"><img src="../../../../images/update.gif" border="0"></a>
		<font size="1">Click to update information</font>
		<%
		if(vRetResult != null && vRetResult.size() > 0){
		%>
		<a href="javascript:PageAction('0','<%=vRetResult.elementAt(0)%>');"><img src="../../../../images/delete.gif" border="0"></a>
		<font size="1">Click to delete information</font>
		<%}%>		</td>
	    </tr>
	<%}%>
</table>
<%}
%>



<table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
<tr><td height="25" bgcolor="#FFFFFF">&nbsp;</td></tr>
  <tr><td height="25" bgcolor="#A49A6A">&nbsp;</td></tr>
</table>
<%
strTemp = "";
if(vRetResult != null && vRetResult.size() > 0)
	strTemp = (String)vRetResult.elementAt(0);
%>
<input type="hidden" name="info_index" value="<%=strTemp%>">
<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
