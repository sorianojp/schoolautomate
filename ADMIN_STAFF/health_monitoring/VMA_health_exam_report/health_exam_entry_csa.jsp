<%@ page language="java" import="utility.*,health.HealthReport,java.util.Vector " %>
<%
	///added code for HR/companies.
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
	String[] strColorScheme = CommonUtil.getColorScheme(8);
	//strColorScheme is never null. it has value always.
	
	boolean bolIsEdit = false;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript">

function SaveEntry(){
	document.form_.save_entry.value = '1';
	document.form_.submit();
}

function PrintPg(strInfoIndex){
	document.form_.info_index.value = strInfoIndex;
	document.form_.print_page.value = "1";
	document.form_.submit();
}

function FocusID() {
	document.form_.stud_id.focus();
}

function ReloadPage(){
	document.form_.view_fields.value = "";
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	document.form_.info_index.value = "";
	document.form_.print_page.value = "";
	document.form_.submit();
}

function PrepareToEdit(strInfoIndex) {
	document.form_.view_fields.value = "1";
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}

function DeleteRecord(strInfoIndex){
	if(!confirm("Are you sure you want to delete this record?"))
		return;
	document.form_.prepareToEdit.value="";
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "0";
	document.form_.submit();
}

function UpdateRecord(){
	document.form_.prepareToEdit.value="";
	document.form_.page_action.value = "1";
	document.form_.submit();
}

function EditRecord(strInfoIndex){		
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "2";
	document.form_.submit();
}
	
function StudSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function RefreshPage(strViewFields){
	document.form_.view_fields.value = strViewFields;
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	document.form_.info_index.value = "";	
	document.form_.submit();
}
	
function AjaxMapName(strPos) {
		var strCompleteName;
			strCompleteName = document.form_.stud_id.value;

		if(strCompleteName.length <=2)
			return;

		var objCOAInput = document.getElementById("coa_info");

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?is_faculty=-1&methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName)+ "&is_faculty=1";
		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.stud_id.value = strID;
	document.form_.stud_id.focus();
	document.getElementById("coa_info").innerHTML = "";
}
function UpdateName(strFName, strMName, strLName) {

}
function UpdateNameFormat(strName) {
	//do nothing..
}</script>
<body bgcolor="#8C9AAA" onLoad="FocusID();" class="bgDynamic">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null; String strTemp2 = null;
	
	if (WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./health_exam_print_csa.jsp" />
	<% 
		return;}

	
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	String strViewFields = WI.getStrValue(WI.fillTextValue("view_fields"),"0");

	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-Health Examination Record","health_exam_entry.jsp");
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
															"Health Monitoring","Health Examination Record",request.getRemoteAddr(),
															"health_exam_entry.jsp");
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
	//end of authenticaion code.	
Vector vRetResult = new Vector();
Vector vBasicInfo = new Vector();
Vector vRecords   = new Vector();
Vector vEditInfo  = new Vector();

HealthReport HR = new HealthReport();




strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(HR.operateOnHealthRecord(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = HR.getErrMsg();
	else{
		if(strTemp.equals("0"))
			strErrMsg = "Entry Succesfully Deleted.";
		if(strTemp.equals("1"))
			strErrMsg = "Entry Succesfully Saved.";
		if(strTemp.equals("2"))
			strErrMsg = "Entry Succesfully Updated.";
		strPrepareToEdit = "0";
		strViewFields = "0";	
			
	}
}




if(strPrepareToEdit.equals("1")){
	vEditInfo = HR.operateOnHealthRecord(dbOP, request, 3);
	if(vEditInfo == null)
		strErrMsg = HR.getErrMsg();	
}

if(WI.fillTextValue("stud_id").length() > 0){
	vBasicInfo = HR.operateOnHealthRecord(dbOP, request, 5);
	if(vBasicInfo == null)
		strErrMsg = HR.getErrMsg();
	else{
		vRecords = HR.operateOnHealthRecord(dbOP, request, 6);		
	}
}
	
%>
<form action="health_exam_entry_csa.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td height="28" colspan="6" bgcolor="#697A8F" class="footerDynamic"><div align="center">
			<font color="#FFFFFF" ><strong>:::: HEALTH EXAMINATION ::::</strong></font></div></td>
	</tr>
	<tr>
		<td height="25" colspan="6">&nbsp;&nbsp;&nbsp;&nbsp;
			<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td width="2%">&nbsp;</td>
		<td width="15%">Enter ID No. :</td>
		<td width="20%">
			<input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				 onKeyUp="AjaxMapName('1');"></td>
		<td colspan="2" >
			
				<a href="javascript:StudSearch();"><img src="../../../images/search.gif" border="0" ></a>
					<font size="1">Click to search for student </font>			
		<label id="coa_info" style="font-size:11px;"></label>	
		</td>
		<td width="3%" valign="top" >&nbsp;</td>
	</tr>
	<tr>
		<td height="15" colspan="6">&nbsp;</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td colspan="1"><a href="javascript:RefreshPage('');"><img src="../../../images/form_proceed.gif" border="0"></a></td>	
		<td colspan="3" ><a href="javascript:RefreshPage('1');">Click to create new record.</a></td>	
	</tr>
</table>

<table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
	<tr>
		<td height="15"><hr size="1"></td>
	</tr>
</table>

<%if(vBasicInfo != null && vBasicInfo.size() > 0){%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td colspan="3" height="25">School Year: <u>&nbsp;</u>__________</td></tr>
	<tr>
		<td height="25">Student ID: <u><%=WI.fillTextValue("stud_id")%></u>__________</td>
		<td>Name: <u><%=vBasicInfo.elementAt(0)%></u>__________</td>
		<td>Course/Year: <u><%=WI.getStrValue((String)vBasicInfo.elementAt(4))%><%=WI.getStrValue((String)vBasicInfo.elementAt(5),"/","","")%></u>__________</td>
	</tr>
	<tr><td height="25" colspan="3">
		<table width="100%">
			<tr>
				<td width="10%">Address</td>
				<td><div style="border-bottom:solid 1px #000000; width:90%;">
					<%=WI.getStrValue((String)vBasicInfo.elementAt(6))%> <%=WI.getStrValue((String)vBasicInfo.elementAt(7))%>
					<%=WI.getStrValue((String)vBasicInfo.elementAt(8))%> <%=WI.getStrValue((String)vBasicInfo.elementAt(9))%> 
					<%=WI.getStrValue((String)vBasicInfo.elementAt(10))%>
					</div>
				</td>
			</tr>
		</table>
	</td></tr>
	<tr><td height="25">Birthdate: <u><%=WI.getStrValue((String)vBasicInfo.elementAt(13))%></u>__________</td>
		<td>Age: <u><%=WI.getStrValue((String)vBasicInfo.elementAt(1))%></u>__________</td></tr>
	<tr>
		<td height="25" colspan="2">Parent's Name: <u><%=WI.getStrValue((String)vBasicInfo.elementAt(14))%></u>__________</td>
		<td>Phone Number: <u><%=WI.getStrValue((String)vBasicInfo.elementAt(15))%></u>__________</td>
	</tr>
	<tr><td height="25" colspan="3">
		<table width="100%">
			<tr>
				<td width="10%">Address</td>
				<td>
					<div style="border-bottom:solid 1px #000000; width:90%;"><%=WI.getStrValue((String)vBasicInfo.elementAt(16),"&nbsp;")%></div>
				</td>
			</tr>
		</table>
	</td></tr>
	<tr><td height="25" colspan="2">Person to contact in case of emergency: <u><%=WI.getStrValue((String)vBasicInfo.elementAt(17))%></u>__________</td>
	<td>Phone Number: <u><%=WI.getStrValue((String)vBasicInfo.elementAt(18))%></u>__________</td></tr>
</table>



<%if(strViewFields.equals("1")){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
	<tr>
		<td height="25" colspan="3"><strong>Medical History</strong></td>
		<td align="center" width="7%"><strong>YES</strong></td>
		<td align="center" width="7%"><strong>NO</strong></td>
		<td align="center"><strong>Remarks</strong></td>
	</tr>
	<tr>
		<td width="3%">&nbsp;</td>
		<td colspan="2">1. Presently Taking Medications:</td>
		<%
		strTemp = WI.fillTextValue("field_1");		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(2);		
		if(strTemp.equals("1"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="1" name="field_1" <%=strErrMsg%>></td>
		<%		
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="0" name="field_1" <%=strErrMsg%>></td>
		<%
		strTemp = WI.fillTextValue("field_2");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(3);
		%>
		<td><input type="text" name="field_2" value="<%=strTemp%>" class="textbox" style="width:100%;" 
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td height="25" colspan="5">2. Medical Condition:</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td width="20%">&nbsp;</td>
		<td width="23%">Asthma</td>
		<%
		strTemp = WI.fillTextValue("field_3");		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(4);		
		if(strTemp.equals("1"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="1" name="field_3" <%=strErrMsg%>></td>
		<%		
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="0" name="field_3" <%=strErrMsg%>></td>
		<%
		strTemp = WI.fillTextValue("field_4");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(5);
		%>
		<td><input type="text" name="field_4" value="<%=strTemp%>" class="textbox" style="width:100%;"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	
	<tr>
		<td>&nbsp;</td>
		<td width="20%">&nbsp;</td>
		<td width="23%">HPN</td>
		<%
		strTemp = WI.fillTextValue("field_5");		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(6);		
		if(strTemp.equals("1"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="1" name="field_5" <%=strErrMsg%>></td>
		<%		
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="0" name="field_5" <%=strErrMsg%>></td>
		<%
		strTemp = WI.fillTextValue("field_6");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(7);
		%>
		<td><input type="text" name="field_6" value="<%=strTemp%>" class="textbox" style="width:100%;"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td width="20%">&nbsp;</td>
		<td width="23%">DM</td>
		<%
		strTemp = WI.fillTextValue("field_7");		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(8);		
		if(strTemp.equals("1"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="1" name="field_7" <%=strErrMsg%>></td>
		<%		
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="0" name="field_7" <%=strErrMsg%>></td>
		<%
		strTemp = WI.fillTextValue("field_8");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(9);
		%>
		<td><input type="text" name="field_8" value="<%=strTemp%>" class="textbox" style="width:100%;"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td width="20%">&nbsp;</td>
		<td width="23%">CHD</td>
		<%
		strTemp = WI.fillTextValue("field_9");		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(10);		
		if(strTemp.equals("1"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="1" name="field_9" <%=strErrMsg%>></td>
		<%		
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="0" name="field_9" <%=strErrMsg%>></td>
		<%
		strTemp = WI.fillTextValue("field_10");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(11);
		%>
		<td><input type="text" name="field_10" value="<%=strTemp%>" class="textbox" style="width:100%;"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td width="20%">&nbsp;</td>
		<td width="23%">PTB</td>
		<%
		strTemp = WI.fillTextValue("field_11");		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(12);		
		if(strTemp.equals("1"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="1" name="field_11" <%=strErrMsg%>></td>
		<%		
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="0" name="field_11" <%=strErrMsg%>></td>
		<%
		strTemp = WI.fillTextValue("field_12");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(13);
		%>
		<td><input type="text" name="field_12" value="<%=strTemp%>" class="textbox" style="width:100%;"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td width="20%">&nbsp;</td>
		<td width="23%">Measles</td>
		<%
		strTemp = WI.fillTextValue("field_13");		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(14);		
		if(strTemp.equals("1"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="1" name="field_13" <%=strErrMsg%>></td>
		<%		
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="0" name="field_13" <%=strErrMsg%>></td>
		<%
		strTemp = WI.fillTextValue("field_14");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(15);
		%>
		<td><input type="text" name="field_14" value="<%=strTemp%>" class="textbox" style="width:100%;"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td width="20%">&nbsp;</td>
		<td width="23%">Chicken Pox</td>
		<%
		strTemp = WI.fillTextValue("field_15");		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(16);		
		if(strTemp.equals("1"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="1" name="field_15" <%=strErrMsg%>></td>
		<%		
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="0" name="field_15" <%=strErrMsg%>></td>
		<%
		strTemp = WI.fillTextValue("field_16");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(17);
		%>
		<td><input type="text" name="field_16" value="<%=strTemp%>" class="textbox" style="width:100%;"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td width="20%">&nbsp;</td>
		<td width="23%">German Measles</td>
		<%
		strTemp = WI.fillTextValue("field_17");		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(18);		
		if(strTemp.equals("1"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="1" name="field_17" <%=strErrMsg%>></td>
		<%		
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="0" name="field_17" <%=strErrMsg%>></td>
		<%
		strTemp = WI.fillTextValue("field_18");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(19);
		%>
		<td><input type="text" name="field_18" value="<%=strTemp%>" class="textbox" style="width:100%;"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td width="20%">&nbsp;</td>
		<td width="23%">Others (pls specify)</td>
		<%
		strTemp = WI.fillTextValue("field_19");		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(20);		
		if(strTemp.equals("1"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="1" name="field_19" <%=strErrMsg%>></td>
		<%		
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="0" name="field_19" <%=strErrMsg%>></td>
		<%
		strTemp = WI.fillTextValue("field_20");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(21);
		%>
		<td><input type="text" name="field_20" value="<%=strTemp%>" class="textbox" style="width:100%;"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td height="25" colspan="5">3. Allergies:</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td width="20%">&nbsp;</td>
		<td width="23%">Food</td>
		<%
		strTemp = WI.fillTextValue("field_21");		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(22);		
		if(strTemp.equals("1"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="1" name="field_21" <%=strErrMsg%>></td>
		<%		
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="0" name="field_21" <%=strErrMsg%>></td>
		<%
		strTemp = WI.fillTextValue("field_22");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(23);
		%>
		<td><input type="text" name="field_22" value="<%=strTemp%>" class="textbox" style="width:100%;"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	
	<tr>
		<td>&nbsp;</td>
		<td width="20%">&nbsp;</td>
		<td width="23%">Drug</td>
		<%
		strTemp = WI.fillTextValue("field_23");		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(24);		
		if(strTemp.equals("1"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="1" name="field_23" <%=strErrMsg%>></td>
		<%		
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="0" name="field_23" <%=strErrMsg%>></td>
		<%
		strTemp = WI.fillTextValue("field_24");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(25);
		%>
		<td><input type="text" name="field_24" value="<%=strTemp%>" class="textbox" style="width:100%;"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	
	<tr>
		<td>&nbsp;</td>
		<td height="25" colspan="5">4. Immunizations:</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td width="20%">&nbsp;</td>
		<td width="23%">BCG</td>
		<%
		strTemp = WI.fillTextValue("field_25");		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(26);		
		if(strTemp.equals("1"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="1" name="field_25" <%=strErrMsg%>></td>
		<%		
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="0" name="field_25" <%=strErrMsg%>></td>
		<%
		strTemp = WI.fillTextValue("field_26");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(27);
		%>
		<td><input type="text" name="field_26" value="<%=strTemp%>" class="textbox" style="width:100%;"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	
	<tr>
		<td>&nbsp;</td>
		<td width="20%">&nbsp;</td>
		<td width="23%">DPT</td>
		<%
		strTemp = WI.fillTextValue("field_27");		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(28);		
		if(strTemp.equals("1"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="1" name="field_27" <%=strErrMsg%>></td>
		<%		
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="0" name="field_27" <%=strErrMsg%>></td>
		<%
		strTemp = WI.fillTextValue("field_28");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(29);
		%>
		<td><input type="text" name="field_28" value="<%=strTemp%>" class="textbox" style="width:100%;"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td width="20%">&nbsp;</td>
		<td width="23%">Polio</td>
		<%
		strTemp = WI.fillTextValue("field_29");		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(30);		
		if(strTemp.equals("1"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="1" name="field_29" <%=strErrMsg%>></td>
		<%		
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="0" name="field_29" <%=strErrMsg%>></td>
		<%
		strTemp = WI.fillTextValue("field_30");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(31);
		%>
		<td><input type="text" name="field_30" value="<%=strTemp%>" class="textbox" style="width:100%;"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td width="20%">&nbsp;</td>
		<td width="23%">Hepa A</td>
		<%
		strTemp = WI.fillTextValue("field_31");		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(32);		
		if(strTemp.equals("1"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="1" name="field_31" <%=strErrMsg%>></td>
		<%		
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="0" name="field_31" <%=strErrMsg%>></td>
		<%
		strTemp = WI.fillTextValue("field_32");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(33);
		%>
		<td><input type="text" name="field_32" value="<%=strTemp%>" class="textbox" style="width:100%;"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td width="20%">&nbsp;</td>
		<td width="23%">Hepa B</td>
		<%
		strTemp = WI.fillTextValue("field_33");		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(34);		
		if(strTemp.equals("1"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="1" name="field_33" <%=strErrMsg%>></td>
		<%		
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="0" name="field_33" <%=strErrMsg%>></td>
		<%
		strTemp = WI.fillTextValue("field_34");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(35);
		%>
		<td><input type="text" name="field_34" value="<%=strTemp%>" class="textbox" style="width:100%;"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td width="20%">&nbsp;</td>
		<td width="23%">Measles</td>
		<%
		strTemp = WI.fillTextValue("field_35");		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(36);		
		if(strTemp.equals("1"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="1" name="field_35" <%=strErrMsg%>></td>
		<%		
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="0" name="field_35" <%=strErrMsg%>></td>
		<%
		strTemp = WI.fillTextValue("field_36");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(37);
		%>
		<td><input type="text" name="field_36" value="<%=strTemp%>" class="textbox" style="width:100%;"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td width="20%">&nbsp;</td>
		<td width="23%">Typhoid Fever</td>
		<%
		strTemp = WI.fillTextValue("field_37");		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(38);		
		if(strTemp.equals("1"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="1" name="field_37" <%=strErrMsg%>></td>
		<%		
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="0" name="field_37" <%=strErrMsg%>></td>
		<%
		strTemp = WI.fillTextValue("field_38");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(39);
		%>
		<td><input type="text" name="field_38" value="<%=strTemp%>" class="textbox" style="width:100%;"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td width="20%">&nbsp;</td>
		<td width="23%">Chicken Pox</td>
		<%
		strTemp = WI.fillTextValue("field_39");		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(40);		
		if(strTemp.equals("1"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="1" name="field_39" <%=strErrMsg%>></td>
		<%		
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="0" name="field_39" <%=strErrMsg%>></td>
		<%
		strTemp = WI.fillTextValue("field_40");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(41);
		%>
		<td><input type="text" name="field_40" value="<%=strTemp%>" class="textbox" style="width:100%;"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td width="20%">&nbsp;</td>
		<td width="23%">HIB</td>
		<%
		strTemp = WI.fillTextValue("field_41");		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(42);		
		if(strTemp.equals("1"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="1" name="field_41" <%=strErrMsg%>></td>
		<%		
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="0" name="field_41" <%=strErrMsg%>></td>
		<%
		strTemp = WI.fillTextValue("field_42");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(43);
		%>
		<td><input type="text" name="field_42" value="<%=strTemp%>" class="textbox" style="width:100%;"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td width="20%">&nbsp;</td>
		<td width="23%">Mumps</td>
		<%
		strTemp = WI.fillTextValue("field_43");		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(44);		
		if(strTemp.equals("1"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="1" name="field_43" <%=strErrMsg%>></td>
		<%		
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="0" name="field_43" <%=strErrMsg%>></td>
		<%
		strTemp = WI.fillTextValue("field_44");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(45);
		%>
		<td><input type="text" name="field_44" value="<%=strTemp%>" class="textbox" style="width:100%;"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td width="20%">&nbsp;</td>
		<td width="23%">Flu</td>
		<%
		strTemp = WI.fillTextValue("field_45");		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(46);		
		if(strTemp.equals("1"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="1" name="field_45" <%=strErrMsg%>></td>
		<%		
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="0" name="field_45" <%=strErrMsg%>></td>
		<%
		strTemp = WI.fillTextValue("field_46");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(47);
		%>
		<td><input type="text" name="field_46" value="<%=strTemp%>" class="textbox" style="width:100%;"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	
	
	<tr>
		<td>&nbsp;</td>
		<td>5. Past surgical operations:</td>
		<%
		strTemp = WI.fillTextValue("field_47");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(48);
		%>
		<td colspan="4"><input type="text" name="field_47" value="<%=strTemp%>" class="textbox" style="width:100%;"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td>6. Recent hospitalization:</td>
		<%
		strTemp = WI.fillTextValue("field_48");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(49);
		%>
		<td colspan="4"><input type="text" name="field_48" value="<%=strTemp%>" class="textbox" style="width:100%;"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	
		
	<tr><td colspan="7">&nbsp;</td></tr>
</table>


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td height="25" colspan="2"><strong>Personal Habits</strong></td>
		<td align="center" width="7%"><strong>YES</strong></td>
		<td align="center" width="7%"><strong>NO</strong></td>
		<td align="center"><strong>Remarks</strong></td>
	</tr>
	
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="43%">1. Smoking</td>
		<%
		strTemp = WI.fillTextValue("field_49");		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(50);		
		if(strTemp.equals("1"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="1" name="field_49" <%=strErrMsg%>></td>
		<%		
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="0" name="field_49" <%=strErrMsg%>></td>
		<%
		strTemp = WI.fillTextValue("field_50");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(51);
		%>
		<td><input type="text" name="field_50" value="<%=strTemp%>" class="textbox" style="width:100%;"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="43%">2. Alcohol</td>
		<%
		strTemp = WI.fillTextValue("field_51");		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(52);		
		if(strTemp.equals("1"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="1" name="field_51" <%=strErrMsg%>></td>
		<%		
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="0" name="field_51" <%=strErrMsg%>></td>
		<%
		strTemp = WI.fillTextValue("field_52");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(53);
		%>
		<td><input type="text" name="field_52" value="<%=strTemp%>" class="textbox" style="width:100%;"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="43%">3. Non-Medical Drugs</td>
		<%
		strTemp = WI.fillTextValue("field_53");		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(54);		
		if(strTemp.equals("1"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="1" name="field_53" <%=strErrMsg%>></td>
		<%		
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="0" name="field_53" <%=strErrMsg%>></td>
		<%
		strTemp = WI.fillTextValue("field_54");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(55);
		%>
		<td><input type="text" name="field_54" value="<%=strTemp%>" class="textbox" style="width:100%;"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="43%">4. Eating Disorders</td>
		<%
		strTemp = WI.fillTextValue("field_55");		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(56);		
		if(strTemp.equals("1"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="1" name="field_55" <%=strErrMsg%>></td>
		<%		
		if(strTemp.equals("0") || strTemp.length() == 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="0" name="field_55" <%=strErrMsg%>></td>
		<%
		strTemp = WI.fillTextValue("field_56");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(57);
		%>
		<td><input type="text" name="field_56" value="<%=strTemp%>" class="textbox" style="width:100%;"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr><td colspan="7">&nbsp;</td></tr>
</table>



<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td height="25" colspan="2"><strong>Physical Examination</strong></td>		
	</tr>
	<tr>
		<%
		strTemp = WI.fillTextValue("field_57");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(58);
		%>
		<td height="25">Height: <input type="text" name="field_57" value="<%=strTemp%>" class="textbox"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%
		strTemp = WI.fillTextValue("field_58");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(59);
		%>
		<td height="25">Weight: <input type="text" name="field_58" value="<%=strTemp%>" class="textbox"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%
		strTemp = WI.fillTextValue("field_59");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(60);
		%> 
		<td height="25">Blood Pressure: <input type="text" name="field_59" value="<%=strTemp%>" class="textbox"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<%
		strTemp = WI.fillTextValue("field_60");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(61);
		%>
		<td height="25">Pulse: <input type="text" name="field_60" value="<%=strTemp%>" class="textbox"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%
		strTemp = WI.fillTextValue("field_61");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(62);
		%> 
		<td height="25">RR: <input type="text" name="field_61" value="<%=strTemp%>" class="textbox"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>		
	</tr>
	<tr>
		<%
		strTemp = WI.fillTextValue("field_62");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(63);
		%>
		<td height="25" colspan="3">Visual Acuity: Right: <input type="text" name="field_62" value="<%=strTemp%>" class="textbox"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<%
		strTemp = WI.fillTextValue("field_63");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(64);
		%>
		<td height="25" colspan="3" style="text-indent:88px;">Left: <input type="text" name="field_63" value="<%=strTemp%>" class="textbox"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td height="25" colspan="2">&nbsp;</td>
		<td colspan="2" align="center"><strong>Is Normal?</strong></td>
		<td align="center">&nbsp;</td>
	</tr>
	<tr>
		<td height="25" colspan="2">&nbsp;</td>
		<td align="center" width="7%"><strong>YES</strong></td>
		<td align="center" width="7%"><strong>NO</strong></td>
		<td align="center"><strong>Remarks</strong></td>
	</tr>
	<tr>
		<td width="3%" height="25">&nbsp;</td>
		<td width="43%">1. General Appearance</td>
		<%
		strTemp = WI.fillTextValue("field_64");		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(65);		
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="1" name="field_64" <%=strErrMsg%>></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="0" name="field_64" <%=strErrMsg%>></td>
		<%
		strTemp = WI.fillTextValue("field_65");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(66);
		%>
		<td><input type="text" name="field_65" value="<%=strTemp%>" class="textbox" style="width:100%;"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td width="3%" height="25">&nbsp;</td>
		<td width="43%">2. Skin</td>
		<%
		strTemp = WI.fillTextValue("field_66");		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(67);		
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="1" name="field_66" <%=strErrMsg%>></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="0" name="field_66" <%=strErrMsg%>></td>		
		<%
		strTemp = WI.fillTextValue("field_67");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(68);
		%>
		<td><input type="text" name="field_67" value="<%=strTemp%>" class="textbox" style="width:100%;"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td width="3%" height="25">&nbsp;</td>
		<td width="43%">3. HEENT</td>
		<%
		strTemp = WI.fillTextValue("field_68");		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(69);		
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="1" name="field_68" <%=strErrMsg%>></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="0" name="field_68" <%=strErrMsg%>></td>
		<%
		strTemp = WI.fillTextValue("field_69");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(70);
		%>
		<td><input type="text" name="field_69" value="<%=strTemp%>" class="textbox" style="width:100%;"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td width="3%" height="25">&nbsp;</td>
		<td width="43%">4. Lungs</td>
		<%
		strTemp = WI.fillTextValue("field_70");		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(71);		
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="1" name="field_70" <%=strErrMsg%>></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="0" name="field_70" <%=strErrMsg%>></td>
		<%
		strTemp = WI.fillTextValue("field_71");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(72);
		%>
		<td><input type="text" name="field_71" value="<%=strTemp%>" class="textbox" style="width:100%;"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td width="3%" height="25">&nbsp;</td>
		<td width="43%">5. Heart</td>
		<%
		strTemp = WI.fillTextValue("field_72");		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(73);		
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="1" name="field_72" <%=strErrMsg%>></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="0" name="field_72" <%=strErrMsg%>></td>
		<%
		strTemp = WI.fillTextValue("field_73");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(74);
		%>
		<td><input type="text" name="field_73" value="<%=strTemp%>" class="textbox" style="width:100%;"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td width="3%" height="25">&nbsp;</td>
		<td width="43%">6. Abdomen</td>
		<%
		strTemp = WI.fillTextValue("field_74");		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(75);		
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="1" name="field_74" <%=strErrMsg%>></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="0" name="field_74" <%=strErrMsg%>></td>
		<%
		strTemp = WI.fillTextValue("field_75");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(76);
		%>
		<td><input type="text" name="field_75" value="<%=strTemp%>" class="textbox" style="width:100%;"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td width="3%" height="25">&nbsp;</td>
		<td width="43%">7. Musculoskeletal</td>
		<%
		strTemp = WI.fillTextValue("field_76");		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(77);		
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="1" name="field_76" <%=strErrMsg%>></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="0" name="field_76" <%=strErrMsg%>></td>
		<%
		strTemp = WI.fillTextValue("field_77");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(78);
		%>
		<td><input type="text" name="field_77" value="<%=strTemp%>" class="textbox" style="width:100%;"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td width="3%" height="25">&nbsp;</td>
		<td width="43%">8. Genitalia</td>
		<%
		strTemp = WI.fillTextValue("field_78");		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(79);		
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="1" name="field_78" <%=strErrMsg%>></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="0" name="field_78" <%=strErrMsg%>></td>
		<%
		strTemp = WI.fillTextValue("field_79");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(80);
		%>
		<td><input type="text" name="field_79" value="<%=strTemp%>" class="textbox" style="width:100%;"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td width="3%" height="25">&nbsp;</td>
		<td width="43%">9. Peripheral Pulses</td>
		<%
		strTemp = WI.fillTextValue("field_80");		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(81);		
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="1" name="field_80" <%=strErrMsg%>></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="0" name="field_80" <%=strErrMsg%>></td>
		<%
		strTemp = WI.fillTextValue("field_81");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(82);
		%>
		<td><input type="text" name="field_81" value="<%=strTemp%>" class="textbox" style="width:100%;"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td width="3%" height="25">&nbsp;</td>
		<td width="43%">10. Neurologic</td>
		<%
		strTemp = WI.fillTextValue("field_82");		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(83);		
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="1" name="field_82" <%=strErrMsg%>></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="0" name="field_82" <%=strErrMsg%>></td>
		<%
		strTemp = WI.fillTextValue("field_83");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(84);
		%>
		<td><input type="text" name="field_83" value="<%=strTemp%>" class="textbox" style="width:100%;"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td width="3%" height="25">&nbsp;</td>
		<td width="43%">11. Mental Status</td>
		<%
		strTemp = WI.fillTextValue("field_84");		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(85);		
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="1" name="field_84" <%=strErrMsg%>></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="0" name="field_84" <%=strErrMsg%>></td>
		<%
		strTemp = WI.fillTextValue("field_85");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(86);
		%>
		<td><input type="text" name="field_85" value="<%=strTemp%>" class="textbox" style="width:100%;"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr><td colspan="6">&nbsp;</td></tr>
</table>




<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
	<tr>
		<td height="25" colspan="2"><strong>Laboratories/Diagnostic Test:</strong></td>
		<td align="center" width="7%"><strong>YES</strong></td>
		<td align="center" width="7%"><strong>NO</strong></td>
		<td align="center"><strong>Remarks</strong></td>
	</tr>
	<tr>
		<td width="5%" height="25">&nbsp;</td>
		<td width="41%">CBC:</td>
		<%
		strTemp = WI.fillTextValue("field_86");		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(87);		
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="1" name="field_86" <%=strErrMsg%>></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="0" name="field_86" <%=strErrMsg%>></td>
		<%
		strTemp = WI.fillTextValue("field_87");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(88);
		%>
		<td><input type="text" name="field_87" value="<%=strTemp%>" class="textbox" style="width:100%;"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td>U/A:</td>
		<%
		strTemp = WI.fillTextValue("field_88");		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(89);		
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="1" name="field_88" <%=strErrMsg%>></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="0" name="field_88" <%=strErrMsg%>></td>
		<%
		strTemp = WI.fillTextValue("field_89");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(90);
		%>
		<td><input type="text" name="field_89" value="<%=strTemp%>" class="textbox" style="width:100%;"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td>F/E:</td>
		<%
		strTemp = WI.fillTextValue("field_90");		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(91);		
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="1" name="field_90" <%=strErrMsg%>></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="0" name="field_90" <%=strErrMsg%>></td>
		<%
		strTemp = WI.fillTextValue("field_91");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(92);
		%>
		<td><input type="text" name="field_91" value="<%=strTemp%>" class="textbox" style="width:100%;"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td>HbS Antigen:</td>
		<%
		strTemp = WI.fillTextValue("field_92");		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(93);		
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="1" name="field_92" <%=strErrMsg%>></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="0" name="field_92" <%=strErrMsg%>></td>
		<%
		strTemp = WI.fillTextValue("field_93");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(94);
		%>
		<td><input type="text" name="field_93" value="<%=strTemp%>" class="textbox" style="width:100%;"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td>X-Ray:</td>
		<%
		strTemp = WI.fillTextValue("field_94");		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(95);		
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="1" name="field_94" <%=strErrMsg%>></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="0" name="field_94" <%=strErrMsg%>></td>
		<%
		strTemp = WI.fillTextValue("field_95");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(96);
		%>
		<td><input type="text" name="field_95" value="<%=strTemp%>" class="textbox" style="width:100%;"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td>ECG:</td>
		<%
		strTemp = WI.fillTextValue("field_96");		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(97);		
		if(strTemp.equals("1") || strTemp.length() == 0)
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="1" name="field_96" <%=strErrMsg%>></td>
		<%		
		if(strTemp.equals("0"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		<td align="center"><input type="radio" value="0" name="field_96" <%=strErrMsg%>></td>
		<%
		strTemp = WI.fillTextValue("field_97");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(98);
		%>
		<td><input type="text" name="field_97" value="<%=strTemp%>" class="textbox" style="width:100%;"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr><td height="30" colspan="6">&nbsp;</td></tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td width="5%" height="35">&nbsp;</td>
		<td width="7%" valign="top" >Remarks : </td>
		<%
		strTemp = WI.fillTextValue("field_98");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(99);
		%>
		<td><textarea style="width:100%; height:100%;" name="field_98" 
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
	</tr>
	<tr><td height="30" colspan="6">&nbsp;</td></tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td width="5%" height="25">&nbsp;</td>
		<td width="15%">Examination Date</td>
		<%
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(1);
			else			
				strTemp = WI.fillTextValue("date_recorded");				
				
			if(strTemp.length() == 0)
				strTemp = WI.getTodaysDate(1);
		%>
		<td colspan="6"><input name="date_recorded" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        		<a href="javascript:show_calendar('form_.date_recorded');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></font></td>
	</tr>
	
	<tr>
		<td width="5%" height="25">&nbsp;</td>
		<td width="10%">Physician Name:</td>
		<%
		strTemp = WI.fillTextValue("field_99");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(100);
		%>
	  <td width="40%"><input type="text" name="field_99" value="<%=strTemp%>" class="textbox" 
	  	onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
				
		<td width="10%">License No.</td>
		<%
		strTemp = WI.fillTextValue("field_100");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(101);
		%>
		<td><input type="text" name="field_100" value="<%=strTemp%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>


</table>





	






<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">

	
	
	
	<tr><Td colspan="3">&nbsp;</Td></tr>
	<tr>
			<td height="25" colspan="5"><div align="center">
				<%if(iAccessLevel > 1){
					if(strPrepareToEdit.equals("1")){%>
						<a href="javascript:EditRecord('<%=WI.fillTextValue("info_index")%>');">
							<img src="../../../images/edit.gif" border="0"></a>
						<font size="1">click to edit entries</font>
					<%}else{%>
						<a href="javascript:UpdateRecord();"><img src="../../../images/save.gif" border="0"></a>
							<font size="1">click to save entries</font>
					<%}
				}else{%>
					<font size="1">Not authorized to change information</font>
				<%}%>
				<a href="javascript:ReloadPage();"><img src="../../../images/cancel.gif" border="0"></a>
					<font size="1">click to cancel/erase entries</font></font></div></td>
	</tr>
</table>
<%}//end of view fields
}//end of vBasic not null%>

<%if(vRecords != null && vRecords.size() > 0){%>
		<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
			<tr> 
		  		<td height="20" colspan="6" bgcolor="#B9B292" class="thinborder" align="center">
					<strong>::: LIST OF STUDENT RECORDS :::</strong></td>
			</tr>
			<tr>
				<td height="25" width="5%" align="center" class="thinborder"><strong>Count</strong></td>				
				<td width="15%" align="center" class="thinborder"><strong>Recorded Date</strong></td>
				<td width="15%" align="center" class="thinborder"><strong>Updated Date</strong></td>
				<td width="25%" align="center" class="thinborder"><strong>Updated By</strong></td>
				<td width="20%" align="center" class="thinborder"><strong>Options</strong></td>
			</tr>
		<%	int iCount = 1;
			for(int i = 0; i < vRecords.size(); i+=4){%>
			<tr>
				<td height="25" align="center" class="thinborder"><%=iCount++%></td>			    
			    <td class="thinborder"><%=WI.getStrValue((String)vRecords.elementAt(i+1),"&nbsp;")%></td>
			    <td class="thinborder"><%=WI.getStrValue((String)vRecords.elementAt(i+2),"&nbsp;")%></td>
			    <td class="thinborder"><%=WI.getStrValue((String)vRecords.elementAt(i+3),"&nbsp;")%></td>
			    <td align="center" class="thinborder">
				<%if(iAccessLevel > 1){%>
					<a href="javascript:PrepareToEdit('<%=(String)vRecords.elementAt(i)%>');">
						<img src="../../../images/edit.gif" border="0"></a>
					<%if(iAccessLevel == 2){%>
						&nbsp;
						<a href="javascript:DeleteRecord('<%=(String)vRecords.elementAt(i)%>')">
							<img src="../../../images/delete.gif" border="0"></a>
					<%}%>
					<a href="javascript:PrintPg('<%=(String)vRecords.elementAt(i)%>');">
					<img src="../../../images/print.gif" border="0"></a>
				<%}else{%>
					No edit/delete privilege.
				<%}%></td>
			</tr>
		<%}%>
		</table>
<%}%>


<table  width="100%" border="0" cellpadding="0" cellspacing="0" >
	<tr >
		<td height="25" colspan="9" bgcolor="#FFFFFF">&nbsp;</td>
	</tr>
	<tr >
		<td height="25" colspan="9" bgcolor="#697A8F" class="footerDynamic">&nbsp;</td>
	</tr>
</table>
	<input type="hidden" name="no_of_fields" value="100" > <!-- get the last number of fields; used in java -->
	<input type="hidden" name="save_entry" >
	<input type="hidden" name="search_" >
	
	<input type="hidden" name="page_action">
	<input type="hidden" name="reload_page">
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="view_fields" value="<%=strViewFields%>">
	<input type="hidden" name="print_page" >
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
