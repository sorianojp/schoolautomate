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
	document.form_.print_page.value = "";
	document.form_.submit();
}
function DeleteRecord(strInfoIndex){
	if(!confirm("Are you sure you want to delete this record?"))
		return;
	document.form_.prepareToEdit.value="";
	document.form_.info_index.value = strInfoIndex;
	document.form_.print_page.value = "";
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
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);
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
		<jsp:forward page="./health_exam_print_spc_grade_school.jsp" />
	<% 
		return;}

	
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	String strViewFields = WI.getStrValue(WI.fillTextValue("view_fields"),"0");

	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-Health Examination Record","health_exam_entry_spc_grade_school.jsp");
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
				"Health Monitoring","Health Examination Record",request.getRemoteAddr(),"health_exam_entry_spc_grade_school.jsp");
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
<form action="health_exam_entry_spc_grade_school.jsp" method="post" name="form_">
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
		<td width="20%"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" 
		                class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				 		onKeyUp="AjaxMapName('1');"></td>
		<td colspan="2" >
			        <a href="javascript:StudSearch();"><img src="../../../images/search.gif" border="0" ></a>
						<font size="1">Click to search for student </font><label id="coa_info" style="font-size:11px; position:absolute; width:400px;"></label>	
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
	<tr><td valign="bottom" height="20">Name:</td>
	   <td valign="bottom" height="20" colspan="3"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(0),"&nbsp;")%></div></td>
	   <td valign="bottom" height="20" style="padding-left:20px;">Sex:</td>
	<td valign="bottom" height="20"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(2),"&nbsp;")%></div></td>
	</tr>
	<tr>
		<td height="20" colspan="6">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
					<td valign="bottom" height="20" width="13%">Address:</td>
					<%
					strTemp = WI.getStrValue((String)vBasicInfo.elementAt(6));
					strErrMsg = WI.getStrValue((String)vBasicInfo.elementAt(7));
					if(strTemp.length() > 0 && strErrMsg.length() > 0 )
						strTemp += ", " + strErrMsg;
						
					strErrMsg = WI.getStrValue((String)vBasicInfo.elementAt(8));
					if(strTemp.length() > 0 && strErrMsg.length() > 0 )
						strTemp += ", " + strErrMsg;
					
					strErrMsg = WI.getStrValue((String)vBasicInfo.elementAt(9));
					if(strTemp.length() > 0 && strErrMsg.length() > 0 )
						strTemp += ", " + strErrMsg;
						
					strErrMsg = WI.getStrValue((String)vBasicInfo.elementAt(10));
					if(strTemp.length() > 0 && strErrMsg.length() > 0 )
						strTemp += ", " + strErrMsg;
					%>
					<td valign="bottom" height="20" width="57%"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue(strTemp, "N/A")%></div>				  </td>
					<td valign="bottom" height="20" width="14%" style="padding-left:20px;">Telephone No.:</td>
				   <td valign="bottom" width="16%"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(11),"N/A")%></div></td>
				</tr>
			</table>		</td>
	</tr>
	<tr>
	  <td valign="bottom" height="20">Nationality:</td>
	  <td valign="bottom" height="20"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(34),"&nbsp;")%></div></td>
	  <td valign="bottom" height="20" style="padding-left:20px;">Birthday:</td>
	  <td valign="bottom" height="20"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(13),"N/A")%></div></td>
	  <td valign="bottom" height="20" style="padding-left:20px;">Religion:</td>
	  <td valign="bottom" height="20"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(35),"&nbsp;")%></div></td>
	</tr>
	<tr>
		<td valign="bottom" height="20">Father's Name:</td>
	  	<td valign="bottom" width="22%"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(14),"N/A")%></div></td>
	   <td valign="bottom" height="20"  style="padding-left:20px;" width="14%">Occupation:</td>
	   <td valign="bottom" width="21%"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(23),"N/A")%></div></td>
	   <td valign="bottom" width="14%" style="padding-left:20px;" height="20">Contact Number:</td>
      <td valign="bottom" width="16%"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(15),"N/A")%></div></td>
   </tr>
	  <tr>
	  <td height="20" colspan="6">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
				<td height="20" width="7%">&nbsp;</td>
					<td valign="bottom" height="20" width="8%">Address:</td>
					<td valign="bottom" height="20" width="85%"><div style="border-bottom:solid 1px #000000;">
					<%=WI.getStrValue((String)vBasicInfo.elementAt(16),"N/A")%></div>				  </td>
				</tr>
			</table>		</td>
	  </tr>
	  <tr>
		<td valign="bottom" height="20" width="13%">Mother's Name:</td>
	   <td valign="bottom" width="22%"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(24),"N/A")%></div></td>
	   <td valign="bottom" height="20" width="14%" style="padding-left:20px;">Occupation:</td>

	   <td valign="bottom" width="21%"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(27),"N/A")%></div></td>
	   <td valign="bottom" width="14%" height="20" style="padding-left:20px;">Contact Number:</td>
      <td valign="bottom" width="16%"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(25),"N/A")%></div></td>
    </tr>
	  <tr>
	  <td height="20" colspan="6">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
				<td height="20" width="7%">&nbsp;</td>
					<td valign="bottom" height="20" width="8%">Address:</td>
					<td valign="bottom" height="20" width="85%">
						<div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(26),"N/A")%></div>				  </td>
				</tr>
			</table>		</td>
	 </tr>
	 <tr>
		<td valign="bottom" height="20">Guardian's's Name:</td>
	   <td valign="bottom" height="20"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(28),"N/A")%></div></td>
	   <td valign="bottom" height="20" style="padding-left:20px;">Occupation:</td>
	   <td valign="bottom" height="20"><div style="border-bottom:solid 1px #000000;">N/A</div></td>
	   <td valign="bottom" height="20" style="padding-left:20px;">Contact Number:</td>
      <td valign="bottom" height="20"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(33),"N/A")%></div></td>
	 </tr>
	  <tr>
	  <td height="20" colspan="6">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
				<td height="20" width="7%">&nbsp;</td>
					<td valign="bottom" height="20" width="8%">Address:</td>
					<%
					strTemp = WI.getStrValue((String)vBasicInfo.elementAt(30));
					strErrMsg = WI.getStrValue((String)vBasicInfo.elementAt(31));
					if(strTemp.length() > 0 && strErrMsg.length() > 0 )
						strTemp += ", " + strErrMsg;
						
					strErrMsg = WI.getStrValue((String)vBasicInfo.elementAt(32));
					if(strTemp.length() > 0 && strErrMsg.length() > 0 )
						strTemp += ", " + strErrMsg;
					%>
					<td valign="bottom" height="20" width="85%">
						<div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue(strTemp, "N/A")%></div>						</td>
				</tr>
			</table>		</td>
   </tr>
<%if(strViewFields.equals("1") || (vEditInfo != null && vEditInfo.size() > 0)){%>
<tr>
	  <td height="20" colspan="6">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
					<td height="20" width="19%">Living with: </td>
					<%
					strTemp = WI.fillTextValue("field_105");		
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(106);		
					strTemp = WI.getStrValue(strTemp);
						
					if(strTemp.equals("1"))
						strErrMsg = "checked";
					else
						strErrMsg = "";
					%>
				  	<td height="20" width="16%"><input type="radio" name="field_105" value="1" <%=strErrMsg%>>Mother</td>
				  	<%
					if(strTemp.equals("2"))
						strErrMsg = "checked";
					else
						strErrMsg = "";
					%>
					<td height="20" width="16%"><input type="radio" name="field_105" value="2" <%=strErrMsg%>>Father</td>
				  	<%
					if(strTemp.equals("3"))
						strErrMsg = "checked";
					else
						strErrMsg = "";
					%>
					<td height="20" width="20%"><input type="radio" name="field_105" value="3" <%=strErrMsg%>>Both Parents</td>
				  	<%
					if(strTemp.equals("0"))
						strErrMsg = "checked";
					else
						strErrMsg = "";
					%>
					<td height="20" width="29%"><input type="radio" name="field_105" value="0" <%=strErrMsg%>>Guardian please specify</td>
				</tr>
			</table>		</td>
	  </tr>
<%}%>
	  <tr>
	  <td height="20" colspan="6">In case of emergency please notify:</td></tr>
	  <tr>
	  <td height="20" colspan="6">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
				<td height="20" width="7%">&nbsp;</td>
					<td valign="bottom" height="20" width="8%">Name:</td>
					<td valign="bottom" width="20%"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(17),"N/A")%></div></td>
					<td valign="bottom" height="20" width="14%" style="padding-left:20px;">Relationship:</td>
					<td valign="bottom" width="21%"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(19),"N/A")%></div></td>
					<td valign="bottom" height="20" width="14%" style="padding-left:20px;">Contact Number:</td>
				   <td valign="bottom" width="16%"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vBasicInfo.elementAt(18),"N/A")%></div></td>
				</tr>
			</table>		</td>
   </tr>
		  <tr>
	  <td height="20" colspan="6">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
				<td height="20" width="7%">&nbsp;</td>
					<td valign="bottom" height="20" width="8%">Address:</td>
					<%
					strTemp = WI.getStrValue((String)vBasicInfo.elementAt(20));
					strErrMsg = WI.getStrValue((String)vBasicInfo.elementAt(21));
					if(strTemp.length() > 0 && strErrMsg.length() > 0 )
						strTemp += ", " + strErrMsg;
						
					strErrMsg = WI.getStrValue((String)vBasicInfo.elementAt(22));
					if(strTemp.length() > 0 && strErrMsg.length() > 0 )
						strTemp += ", " + strErrMsg;
					%>
					<td valign="bottom" height="20" width="85%"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue(strTemp, "N/A")%></div></td>					
				</tr>
			</table>		</td>
	 	  </tr>
<%if(strViewFields.equals("1")){%>
	<tr>
	  <td height="20" colspan="2">Hospital of choice for referral or admission:</td>
	  <%
	  strTemp = WI.fillTextValue("field_106");		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(107);	
	  %>
	  <td height="20" colspan="4">
	  	<input type="text" name="field_106" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="100%">
	  </td>
	  </tr>
	   <tr>
	  <td height="20" colspan="6">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
				<td height="20" width="7%">&nbsp;</td>
					<td valign="bottom" height="20" width="16%">Contact Number :</td>
					<%
					  strTemp = WI.fillTextValue("field_107");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(108);	
					  %>
					<td valign="bottom" height="20" width="77%">
					<input type="text" name="field_107" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
						onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="30">
					</td>
				</tr>
			</table>		</td>
   </tr>
	 <tr>
	  <td height="20" colspan="6">
			<table width="100%" border="0" cellpadding="0" cellspacing="0">
				<tr>
				<td height="20" width="7%">&nbsp;</td>
					<td valign="bottom" height="20" width="8%">Address:</td>
					<%
					  strTemp = WI.fillTextValue("field_108");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(109);	
					  %>
					<td valign="bottom" height="20" width="85%">
						<input type="text" name="field_108" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
						onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="100%">
					</td>
				</tr>
			</table>		</td>
   </tr>
<%}%>
</table>
<%if(strViewFields.equals("1")){%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
	   <td colspan="6" height="20">&nbsp;</td>
	   </tr>
	<tr>
		<td colspan="6" height="20">&nbsp;A. Immunization Record</td>
	</tr>
	<tr>
		<td width="95">&nbsp;</td>
		<td width="197" class="thinborderBOTTOM">&nbsp;</td>
		<td width="177" class="thinborderBOTTOM">Vaccination Dates</td>
		<td width="185" class="thinborderBOTTOM">&nbsp;</td>
		<td width="168" class="thinborderBOTTOM">Vaccination Dates</td>
		<td width="136">&nbsp;</td>
	</tr>
	<tr>
		<td width="95" rowspan="11">&nbsp;</td>
		<td width="197" class="thinborderBOTTOMLEFTRIGHT">BCG</td>
		<% if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(2);
		   else			
				strTemp = WI.fillTextValue("field_1_date");				
		   if(strTemp.length() == 0)
					strTemp = WI.getTodaysDate(1);
		%>
		<td width="177" class="thinborderBOTTOMRIGHT">&nbsp;
		<input name="field_1_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
		<a href="javascript:show_calendar('form_.field_1_date');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
		<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
		<td width="185" class="thinborderBOTTOMRIGHT">Hepatitis B I</td>
		<% if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(3);
		   else			
				strTemp = WI.fillTextValue("field_2_date");				
		   if(strTemp.length() == 0)
					strTemp = WI.getTodaysDate(1);
		%>
		<td width="168" class="thinborderBOTTOMRIGHT">&nbsp;
		<input name="field_2_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
		<a href="javascript:show_calendar('form_.field_2_date');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
		<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
		<td width="136" rowspan="11">&nbsp;</td>
	</tr>
	<tr>
		<td width="197" class="thinborderBOTTOMLEFTRIGHT">DPT/OPV I</td>
		<%  if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(4);
			else			
				strTemp = WI.fillTextValue("field_3_date");				
				
			if(strTemp.length() == 0)
				strTemp = WI.getTodaysDate(1);
		%>
		<td width="177" class="thinborderBOTTOMRIGHT">&nbsp;
		<input name="field_3_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.field_3_date');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	    <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
		<td width="185" class="thinborderBOTTOMRIGHT">Hepatitis B II</td>
		<%  if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(5);
			else			
				strTemp = WI.fillTextValue("field_4_date");				
				
			if(strTemp.length() == 0)
				strTemp = WI.getTodaysDate(1);
		%>
		<td width="168" class="thinborderBOTTOMRIGHT">&nbsp;
		<input name="field_4_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.field_4_date');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	    <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
	</tr>
	<tr>
		<td width="197" class="thinborderBOTTOMLEFTRIGHT">DPT/OPV II</td>
		<%  if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(6);
			else			
				strTemp = WI.fillTextValue("field_5_date");				
				
			if(strTemp.length() == 0)
				strTemp = WI.getTodaysDate(1);
		%>
		<td width="177" class="thinborderBOTTOMRIGHT">&nbsp;
		<input name="field_5_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.field_5_date');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	  	<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
		<td width="185" class="thinborderBOTTOMRIGHT">Hepatitis B III</td>
		<%  if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(7);
			else			
				strTemp = WI.fillTextValue("field_6_date");				
				
			if(strTemp.length() == 0)
				strTemp = WI.getTodaysDate(1);
		%>
		<td width="168" class="thinborderBOTTOMRIGHT">&nbsp;
		<input name="field_6_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.field_6_date');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	    <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
	</tr>
	<tr>
		<td width="197" class="thinborderBOTTOMLEFTRIGHT">DPT/OPV III</td>
		<%  if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(8);
			else			
				strTemp = WI.fillTextValue("field_7_date");				
				
			if(strTemp.length() == 0)
				strTemp = WI.getTodaysDate(1);
		%>
		<td width="177" class="thinborderBOTTOMRIGHT">&nbsp;
		<input name="field_7_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        		<a href="javascript:show_calendar('form_.field_7_date');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	 	<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
		<td width="185" class="thinborderBOTTOMRIGHT">MMR</td>
		<%	if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(9);
			else			
				strTemp = WI.fillTextValue("field_8_date");				
				
			if(strTemp.length() == 0)
				strTemp = WI.getTodaysDate(1);
		%>
		<td width="168" class="thinborderBOTTOMRIGHT">&nbsp;
		<input name="field_8_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.field_8_date');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	  	<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
	</tr>
	<tr>
		<td width="197" class="thinborderBOTTOMLEFTRIGHT">DPT/OPV booster 1</td>
		<%	if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(10);
			else			
				strTemp = WI.fillTextValue("field_9_date");				
				
			if(strTemp.length() == 0)
				strTemp = WI.getTodaysDate(1);
		%>
		<td width="177" class="thinborderBOTTOMRIGHT">&nbsp;
		<input name="field_9_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.field_9_date');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	    <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
		<td width="185" class="thinborderBOTTOMRIGHT">Chiken pox I</td>
		<%  if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(11);
			else			
				strTemp = WI.fillTextValue("field_10_date");				
				
			if(strTemp.length() == 0)
				strTemp = WI.getTodaysDate(1);
		%>
		<td width="168" class="thinborderBOTTOMRIGHT">&nbsp;
		<input name="field_10_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
       	<a href="javascript:show_calendar('form_.field_10_date');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	  	<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
	</tr>
	<tr>
		<td width="197" class="thinborderBOTTOMLEFTRIGHT">DPT/OPV booster 2</td>
		<%	if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(12);
			else			
				strTemp = WI.fillTextValue("field_11_date");				
				
			if(strTemp.length() == 0)
				strTemp = WI.getTodaysDate(1);
		%>
		<td width="177" class="thinborderBOTTOMRIGHT">&nbsp;
		<input name="field_11_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.field_11_date');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	  	<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
		<td width="185" class="thinborderBOTTOMRIGHT">Chiken pox II</td>
		<%  if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(13);
			else			
				strTemp = WI.fillTextValue("field_12_date");				
				
			if(strTemp.length() == 0)
				strTemp = WI.getTodaysDate(1);
		%>
		<td width="168" class="thinborderBOTTOMRIGHT">&nbsp;
		<input name="field_12_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.field_12_date');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	  	<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
	</tr>
	<tr>
		<td width="197" class="thinborderBOTTOMLEFTRIGHT">HiB I</td>
		<%  if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(14);
			else			
				strTemp = WI.fillTextValue("field_13_date");				
				
			if(strTemp.length() == 0)
				strTemp = WI.getTodaysDate(1);
		%>
		<td width="177" class="thinborderBOTTOMRIGHT">&nbsp;
		<input name="field_13_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.field_13_date');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	    <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
		<td width="185" class="thinborderBOTTOMRIGHT">Hepatitis A I</td>
		<%	if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(15);
			else			
				strTemp = WI.fillTextValue("field_14_date");				
				
			if(strTemp.length() == 0)
				strTemp = WI.getTodaysDate(1);
		%>
		<td width="168" class="thinborderBOTTOMRIGHT">&nbsp;
		<input name="field_14_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.field_14_date');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	  	<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
	</tr>
	<tr>
		<td width="197" class="thinborderBOTTOMLEFTRIGHT">HiB II</td>
		<%  if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(16);
			else			
				strTemp = WI.fillTextValue("field_15_date");				
				
			if(strTemp.length() == 0)
				strTemp = WI.getTodaysDate(1);
		%>
		<td width="177" class="thinborderBOTTOMRIGHT">&nbsp;
		<input name="field_15_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.field_15_date');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	    <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
		<td width="185" class="thinborderBOTTOMRIGHT">Hepatitis A II</td>
		<%  if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(17);
			else			
				strTemp = WI.fillTextValue("field_16_date");				
				
			if(strTemp.length() == 0)
				strTemp = WI.getTodaysDate(1);
		%>
		<td width="168" class="thinborderBOTTOMRIGHT">&nbsp;
		<input name="field_16_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.field_16_date');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	  	<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
	</tr>
	<tr>
		<td width="197" class="thinborderBOTTOMLEFTRIGHT">HiB III</td>
		<%   if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(18);
			else			
				strTemp = WI.fillTextValue("field_17_date");				
				
			if(strTemp.length() == 0)
				strTemp = WI.getTodaysDate(1);
		%>
		<td width="177" class="thinborderBOTTOMRIGHT">&nbsp;
		<input name="field_17_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.field_17_date');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	    <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
		<td width="185" class="thinborderBOTTOMRIGHT">Hepatitis A III</td>
		<%	if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(19);
			else			
				strTemp = WI.fillTextValue("field_18_date");				
				
			if(strTemp.length() == 0)
				strTemp = WI.getTodaysDate(1);
		%>
		<td width="168" class="thinborderBOTTOMRIGHT">&nbsp;
		<input name="field_18_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.field_18_date');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	  	<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
	</tr>
	<tr>
		<td width="197" class="thinborderBOTTOMLEFTRIGHT">Measles</td>
		<%	if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(20);
			else			
				strTemp = WI.fillTextValue("field_19_date");				
				
			if(strTemp.length() == 0)
				strTemp = WI.getTodaysDate(1);
		%>
		<td width="177" class="thinborderBOTTOMRIGHT">&nbsp;
		<input name="field_19_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.field_19_date');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	  	<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
		<td width="185" class="thinborderBOTTOMRIGHT">Others:</td>
		<%  strTemp = WI.fillTextValue("field_20");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(21);
		%>
		<td width="168" class="thinborderBOTTOMRIGHT">
		<input type="text" name="field_20" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="24"></td>
	</tr>
	<tr>
		<td width="197" class="thinborderBOTTOMLEFTRIGHT">Typhoid Fever</td>
		<%  if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(22);
			else			
				strTemp = WI.fillTextValue("field_21_date");				
				
			if(strTemp.length() == 0)
				strTemp = WI.getTodaysDate(1);
		%>
		<td width="177" class="thinborderBOTTOMRIGHT">&nbsp;
		<input name="field_21_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.field_21_date');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	    <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
		<td width="185" class="thinborderBOTTOMRIGHT">&nbsp;</td>
		<td width="168" class="thinborderBOTTOMRIGHT">&nbsp;</td>
	</tr>
	<tr>
		<td colspan="6">&nbsp;</td>
	</tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td colspan="8">&nbsp;B. MEDICAL HISTORY: <i>The child has suffered from: (please check NO or Yes)</i></td>
	</tr>
	<tr>
		<td colspan="8">&nbsp;</td>
	</tr>
	<tr>
		<td width="241" rowspan="17">&nbsp;</td>
		<td width="196" class="thinborderTOPLEFTRIGHT">Illness</td>
		<td width="88" class="thinborderTOPRIGHT" align="center">&nbsp;Yes</td>
		<td width="96" class="thinborderTOPRIGHT" align="center">&nbsp;No</td>
		<td width="174" class="thinborderTOPRIGHT">Illness</td>
		<td width="100" class="thinborderTOPRIGHT" align="center">&nbsp;Yes</td>
		<td width="108" class="thinborderTOPBOTTOM" align="center">&nbsp;No</td>
		<td width="291" rowspan="17" class="thinborderLEFT">&nbsp;</td>
	</tr>
	<tr>
		<td width="196" class="thinborderTOPLEFTRIGHT">Allergy</td>
		<%  strTemp = WI.fillTextValue("field_22");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(23);		
			if(strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="88" align="center" class="thinborderTOPRIGHT">
		<input type="radio" value="1" name="field_22" <%=strErrMsg%>></td>
		<%	if(strTemp.equals("0") || strTemp.length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="96" align="center" class="thinborderTOPRIGHT">
		<input type="radio" value="0" name="field_22" <%=strErrMsg%>></td>
		<td width="174" class="thinborderTOPRIGHT">Heart disorder</td>
		<%	strTemp = WI.fillTextValue("field_23");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(24);		
			if(strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="100" align="center" class="thinborderTOPRIGHT">
		<input type="radio" value="1" name="field_23" <%=strErrMsg%>></td>
		<%	if(strTemp.equals("0") || strTemp.length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="108" align="center" class="thinborderBOTTOM">
		<input type="radio" value="0" name="field_23" <%=strErrMsg%>></td>
	</tr>
	<tr>
		<td width="196" class="thinborderTOPLEFTRIGHT">Anemia</td>
		<%	strTemp = WI.fillTextValue("field_24");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(25);		
			if(strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="88" align="center" class="thinborderTOPRIGHT">
		<input type="radio" value="1" name="field_24" <%=strErrMsg%>></td>
		<%	if(strTemp.equals("0") || strTemp.length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="96" align="center" class="thinborderTOPRIGHT">
		<input type="radio" value="0" name="field_24" <%=strErrMsg%>></td>
		<td width="174" class="thinborderTOPRIGHT">Hyperactivity</td>
		<%  strTemp = WI.fillTextValue("field_25");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(26);		
			if(strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="100" align="center" class="thinborderTOPRIGHT">
		<input type="radio" value="1" name="field_25" <%=strErrMsg%>></td>
		<%	if(strTemp.equals("0") || strTemp.length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="108" align="center" class="thinborderBOTTOM"><input type="radio" value="0" name="field_25" <%=strErrMsg%>></td>
	</tr>
	<tr>
		<td width="196" class="thinborderTOPLEFTRIGHT">Asthma</td>
		<%	strTemp = WI.fillTextValue("field_26");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(27);		
			if(strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="88" align="center" class="thinborderTOPRIGHT">
		<input type="radio" value="1" name="field_26" <%=strErrMsg%>></td>
		<%	if(strTemp.equals("0") || strTemp.length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="96" align="center" class="thinborderTOPRIGHT">
		<input type="radio" value="0" name="field_26" <%=strErrMsg%>></td>
		<td width="174" class="thinborderTOPRIGHT">Indigestion</td>
		<%  strTemp = WI.fillTextValue("field_27");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(28);		
			if(strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="100" align="center" class="thinborderTOPRIGHT">
		<input type="radio" value="1" name="field_27" <%=strErrMsg%>></td>
		<%	if(strTemp.equals("0") || strTemp.length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="108" align="center" class="thinborderBOTTOM">
		<input type="radio" value="0" name="field_27" <%=strErrMsg%>></td>
	</tr>
	<tr>
		<td width="196" class="thinborderTOPLEFTRIGHT">Behavioral problem</td>
		<%  strTemp = WI.fillTextValue("field_28");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(29);		
			if(strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="88" align="center" class="thinborderTOPRIGHT">
		<input type="radio" value="1" name="field_28" <%=strErrMsg%>></td>
		<%	if(strTemp.equals("0") || strTemp.length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="96" align="center" class="thinborderTOPRIGHT">
		<input type="radio" value="0" name="field_28" <%=strErrMsg%>></td>
		<td width="174" class="thinborderTOPRIGHT">Insomia</td>
		<%  strTemp = WI.fillTextValue("field_29");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(30);		
			if(strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="100" align="center" class="thinborderTOPRIGHT">
		<input type="radio" value="1" name="field_29" <%=strErrMsg%>></td>
		<%	if(strTemp.equals("0") || strTemp.length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="108" align="center" class="thinborderBOTTOM"><input type="radio" value="0" name="field_29" <%=strErrMsg%>></td>
	</tr>
	<tr>
		<td width="196" class="thinborderTOPLEFTRIGHT">Bleeding problem</td>
		<%  strTemp = WI.fillTextValue("field_30");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(31);		
			if(strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="88" align="center" class="thinborderTOPRIGHT">
		<input type="radio" value="1" name="field_30" <%=strErrMsg%>></td>
		<%	if(strTemp.equals("0") || strTemp.length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="96" align="center" class="thinborderTOPRIGHT">
		<input type="radio" value="0" name="field_30" <%=strErrMsg%>></td>
		<td width="174" class="thinborderTOPRIGHT">Kidney problem</td>
		<%  strTemp = WI.fillTextValue("field_31");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(32);		
			if(strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="100" align="center" class="thinborderTOPRIGHT">
		<input type="radio" value="1" name="field_31" <%=strErrMsg%>></td>
		<%	if(strTemp.equals("0") || strTemp.length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="108" align="center" class="thinborderBOTTOM"><input type="radio" value="0" name="field_31" <%=strErrMsg%>></td>
	</tr>
	<tr>
		<td width="196" class="thinborderTOPLEFTRIGHT">Blood Abnormality</td>
		<%	strTemp = WI.fillTextValue("field_32");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(33);		
			if(strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="88" align="center" class="thinborderTOPRIGHT">
		<input type="radio" value="1" name="field_32" <%=strErrMsg%>></td>
		<%	if(strTemp.equals("0") || strTemp.length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="96" align="center" class="thinborderTOPRIGHT">
		<input type="radio" value="0" name="field_32" <%=strErrMsg%>></td>
		<td width="174" class="thinborderTOPRIGHT">Liver Problem</td>
		<%   strTemp = WI.fillTextValue("field_33");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(34);		
			if(strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="100" align="center" class="thinborderTOPRIGHT">
		<input type="radio" value="1" name="field_33" <%=strErrMsg%>></td>
		<%	if(strTemp.equals("0") || strTemp.length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="108" align="center" class="thinborderBOTTOM"><input type="radio" value="0" name="field_33" <%=strErrMsg%>></td>
	</tr>
	<tr>
		<td width="196" class="thinborderTOPLEFTRIGHT">Chiken pox</td>
		<%  strTemp = WI.fillTextValue("field_34");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(35);		
			if(strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="88" align="center" class="thinborderTOPRIGHT">
		<input type="radio" value="1" name="field_34" <%=strErrMsg%>></td>
		<%	if(strTemp.equals("0") || strTemp.length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="96" align="center" class="thinborderTOPRIGHT">
		<input type="radio" value="0" name="field_34" <%=strErrMsg%>></td>
		<td width="174" class="thinborderTOPRIGHT">Measles</td>
		<%	strTemp = WI.fillTextValue("field_35");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(36);		
			if(strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="100" align="center" class="thinborderTOPRIGHT">
		<input type="radio" value="1" name="field_35" <%=strErrMsg%>></td>
		<%	if(strTemp.equals("0") || strTemp.length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="108" align="center" class="thinborderBOTTOM"><input type="radio" value="0" name="field_35" <%=strErrMsg%>></td>
	</tr>
	<tr>
		<td width="196" class="thinborderTOPLEFTRIGHT">Convulsion</td>
		<%	strTemp = WI.fillTextValue("field_36");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(37);		
			if(strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="88" align="center" class="thinborderTOPRIGHT">
		<input type="radio" value="1" name="field_36" <%=strErrMsg%>></td>
		<%	if(strTemp.equals("0") || strTemp.length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="96" align="center" class="thinborderTOPRIGHT">
		<input type="radio" value="0" name="field_36" <%=strErrMsg%>></td>
		<td width="174" class="thinborderTOPRIGHT">Mumps</td>
		<%	strTemp = WI.fillTextValue("field_37");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(38);		
			if(strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="100" align="center" class="thinborderTOPRIGHT">
		<input type="radio" value="1" name="field_37" <%=strErrMsg%>></td>
		<%	if(strTemp.equals("0") || strTemp.length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="108" align="center" class="thinborderBOTTOM"><input type="radio" value="0" name="field_37" <%=strErrMsg%>></td>
	</tr>
	<tr>
		<td width="196" class="thinborderTOPLEFTRIGHT">Dengue</td>
		<%	strTemp = WI.fillTextValue("field_38");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(39);		
			if(strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="88" align="center" class="thinborderTOPRIGHT">
		<input type="radio" value="1" name="field_38" <%=strErrMsg%>></td>
		<%	if(strTemp.equals("0") || strTemp.length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="96" align="center" class="thinborderTOPRIGHT">
		<input type="radio" value="0" name="field_38" <%=strErrMsg%>></td>
		<td width="174" class="thinborderTOPRIGHT">Parasitism</td>
		<%	strTemp = WI.fillTextValue("field_39");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(40);		
			if(strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="100" align="center" class="thinborderTOPRIGHT">
		<input type="radio" value="1" name="field_39" <%=strErrMsg%>></td>
		<%	if(strTemp.equals("0") || strTemp.length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="108" align="center" class="thinborderBOTTOM"><input type="radio" value="0" name="field_39" <%=strErrMsg%>></td>
	</tr>
	<tr>
		<td width="196" class="thinborderTOPLEFTRIGHT">Diabetes</td>
		<%	strTemp = WI.fillTextValue("field_40");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(41);		
			if(strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="88" align="center" class="thinborderTOPRIGHT">
		<input type="radio" value="1" name="field_40" <%=strErrMsg%>></td>
		<%	if(strTemp.equals("0") || strTemp.length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="96" align="center" class="thinborderTOPRIGHT">
		<input type="radio" value="0" name="field_40" <%=strErrMsg%>></td>
		<td width="174" class="thinborderTOPRIGHT">Pneumonia</td>
		<%	strTemp = WI.fillTextValue("field_41");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(42);		
			if(strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="100" align="center" class="thinborderTOPRIGHT">
		<input type="radio" value="1" name="field_41" <%=strErrMsg%>></td>
		<%	if(strTemp.equals("0") || strTemp.length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="108" align="center" class="thinborderBOTTOM"><input type="radio" value="0" name="field_41" <%=strErrMsg%>></td>
	</tr>
	<tr>
		<td width="196" class="thinborderTOPLEFTRIGHT">Ear problem</td>
		<%	strTemp = WI.fillTextValue("field_42");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(43);		
			if(strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="88" align="center" class="thinborderTOPRIGHT">
		<input type="radio" value="1" name="field_42" <%=strErrMsg%>></td>
		<%	if(strTemp.equals("0") || strTemp.length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="96" align="center" class="thinborderTOPRIGHT">
		<input type="radio" value="0" name="field_42" <%=strErrMsg%>></td>
		<td width="174" class="thinborderTOPRIGHT">Primary complex</td>
		<%	strTemp = WI.fillTextValue("field_43");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(44);		
			if(strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="100" align="center" class="thinborderTOPRIGHT">
		<input type="radio" value="1" name="field_43" <%=strErrMsg%>></td>
		<%	if(strTemp.equals("0") || strTemp.length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="108" align="center" class="thinborderBOTTOM"><input type="radio" value="0" name="field_43" <%=strErrMsg%>></td>
	</tr>
	<tr>
		<td width="196" class="thinborderTOPLEFTRIGHT">Eating disorder</td>
		<%	strTemp = WI.fillTextValue("field_44");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(45);		
			if(strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="88" align="center" class="thinborderTOPRIGHT">
		<input type="radio" value="1" name="field_44" <%=strErrMsg%>></td>
		<%	if(strTemp.equals("0") || strTemp.length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="96" align="center" class="thinborderTOPRIGHT">
		<input type="radio" value="0" name="field_44" <%=strErrMsg%>></td>
		<td width="174" class="thinborderTOPRIGHT">Scoliosis</td>
		<%	strTemp = WI.fillTextValue("field_45");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(46);		
			if(strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="100" align="center" class="thinborderTOPRIGHT">
		<input type="radio" value="1" name="field_45" <%=strErrMsg%>></td>
		<%	if(strTemp.equals("0") || strTemp.length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="108" align="center" class="thinborderBOTTOM"><input type="radio" value="0" name="field_45" <%=strErrMsg%>></td>
	</tr>
	<tr>
		<td width="196" class="thinborderTOPLEFTRIGHT">Epilepsy</td>
		<%	strTemp = WI.fillTextValue("field_46");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(47);		
			if(strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="88" align="center" class="thinborderTOPRIGHT">
		<input type="radio" value="1" name="field_46" <%=strErrMsg%>></td>
		<%	if(strTemp.equals("0") || strTemp.length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="96" align="center" class="thinborderTOPRIGHT">
		<input type="radio" value="0" name="field_46" <%=strErrMsg%>></td>
		<td width="174" class="thinborderTOPRIGHT">Skin problem</td>
		<%	strTemp = WI.fillTextValue("field_47");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(48);		
			if(strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="100" align="center" class="thinborderTOPRIGHT">
		<input type="radio" value="1" name="field_47" <%=strErrMsg%>></td>
		<%	if(strTemp.equals("0") || strTemp.length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="108" align="center" class="thinborderBOTTOM"><input type="radio" value="0" name="field_47" <%=strErrMsg%>></td>
	</tr>
	<tr>
		<td width="196" class="thinborderTOPLEFTRIGHT">Eye problem</td>
		<%	strTemp = WI.fillTextValue("field_48");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(49);		
			if(strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="88" align="center" class="thinborderTOPRIGHT">
		<input type="radio" value="1" name="field_48" <%=strErrMsg%>></td>
		<%	if(strTemp.equals("0") || strTemp.length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="96" align="center" class="thinborderTOPRIGHT">
		<input type="radio" value="0" name="field_48" <%=strErrMsg%>></td>
		<td width="174" class="thinborderTOPRIGHT">Tonsilitis</td>
		<%	strTemp = WI.fillTextValue("field_49");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(50);		
			if(strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="100" align="center" class="thinborderTOPRIGHT">
		<input type="radio" value="1" name="field_49" <%=strErrMsg%>></td>
		<%	if(strTemp.equals("0") || strTemp.length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="108" align="center" class="thinborderBOTTOM"><input type="radio" value="0" name="field_49" <%=strErrMsg%>></td>
	</tr>
	<tr>
		<td width="196" class="thinborderTOPLEFTRIGHT">Fracture</td>
		<%	strTemp = WI.fillTextValue("field_50");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(51);		
			if(strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="88" align="center" class="thinborderTOPRIGHT">
		<input type="radio" value="1" name="field_50" <%=strErrMsg%>></td>
		<%	if(strTemp.equals("0") || strTemp.length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="96" align="center" class="thinborderTOPRIGHT">
		<input type="radio" value="0" name="field_50" <%=strErrMsg%>></td>
		<td width="174" class="thinborderTOPRIGHT">Typhoid fever</td>
		<%	strTemp = WI.fillTextValue("field_51");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(52);		
			if(strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="100" align="center"class="thinborderTOPRIGHT"><input type="radio" value="1" name="field_51" <%=strErrMsg%>></td>
		<%	if(strTemp.equals("0") || strTemp.length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="108" align="center" class="thinborderBOTTOM"><input type="radio" value="0" name="field_51" <%=strErrMsg%>></td>
	</tr>
	<tr>
		<td width="196" class="thinborderTOPLEFTBOTTOM">Hearing problem</td>
		<%	strTemp = WI.fillTextValue("field_52");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(53);		
			if(strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="88" align="center" class="thinborderTOPLEFTBOTTOM">
		<input type="radio" value="1" name="field_52" <%=strErrMsg%>></td>
		<%	if(strTemp.equals("0") || strTemp.length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="96" align="center" class="thinborderTOPLEFTBOTTOM">
		<input type="radio" value="0" name="field_52" <%=strErrMsg%>></td>
		<td width="174" class="thinborderTOPLEFTBOTTOM">Vision defect</td>
		<%	strTemp = WI.fillTextValue("field_53");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(54);		
			if(strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="100" align="center" class="thinborderTOPLEFTBOTTOM">
		<input type="radio" value="1" name="field_53" <%=strErrMsg%>></td>
		<%	if(strTemp.equals("0") || strTemp.length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="108" align="center" class="thinborderBOTTOMLEFT">
		<input type="radio" value="0" name="field_53" <%=strErrMsg%>></td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td height="20">&nbsp;</td></tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td colspan="6">&nbsp;C. <strong>FAMILY HISTORY</strong></td>
	</tr>
	<tr>
		<td width="158" rowspan="13" class="thinborderRIGHT">&nbsp;</td>
		<td width="279" align="center" class="thinborderTOPRIGHT">Disease</td>
		<td width="90" align="center" class="thinborderTOPRIGHT">Yes</td>
		<td width="94" align="center" class="thinborderTOPRIGHT">No</td>
		<td width="492" align="center" class="thinborderTOP">Relation(s) to Child</td>
		<td width="181" rowspan="13" class="thinborderLEFT">&nbsp;</td>
	</tr>
	<tr>
		<td width="279" class="thinborderTOPRIGHT">Asthma</td>
		<%	strTemp = WI.fillTextValue("field_54");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(55);		
			if(strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="90" class="thinborderTOPRIGHT" align="center"  >
		<input type="radio" value="1" name="field_54" <%=strErrMsg%>></td>
		<%	if(strTemp.equals("0") || strTemp.length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="94" align="center"  class="thinborderTOPRIGHT">
		<input type="radio" value="0" name="field_54" <%=strErrMsg%>></td>
		<%	strTemp = WI.fillTextValue("field_55");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(56);
		%>
		<td width="492" class="thinborderTOPBOTTOM"><input type="text" name="field_55" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox"	 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="41"></td>
	</tr>
	<tr>
		<td width="279"  class="thinborderTOPRIGHT">Bleeding Tendency</td>
		<%	strTemp = WI.fillTextValue("field_56");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(57);		
			if(strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="90" align="center"  class="thinborderTOPRIGHT">
		<input type="radio" value="1" name="field_56" <%=strErrMsg%>></td>
		<%	if(strTemp.equals("0") || strTemp.length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
	    <td width="94" align="center"  class="thinborderTOPRIGHT">
	    <input type="radio" value="0" name="field_56" <%=strErrMsg%>></td>
	    <%  strTemp = WI.fillTextValue("field_57");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(58);
		%>
	     <td width="492"><input type="text" name="field_57" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
			 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="41"></td>
	</tr>
	<tr>
	     <td width="279"  class="thinborderTOPRIGHT">Cancer</td>
	     <% strTemp = WI.fillTextValue("field_58");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(59);		
			if(strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		 %>
	     <td width="90" align="center"  class="thinborderTOPRIGHT">
		 <input type="radio" value="1" name="field_58" <%=strErrMsg%>></td>
	     <%	if(strTemp.equals("0") || strTemp.length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		 %>
	      <td width="94" align="center"  class="thinborderTOPRIGHT">
		  <input type="radio" value="0" name="field_58" <%=strErrMsg%>></td>
	     <% strTemp = WI.fillTextValue("field_59");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(60);
		 %>
	     <td width="492" class="thinborderTOPBOTTOM">
		 <input type="text" name="field_59" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="41"></td>
	</tr>
	<tr>
		 <td width="279"  class="thinborderTOPRIGHT">Diabetes</td>
		 <%	strTemp = WI.fillTextValue("field_60");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(61);		
			if(strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="90" align="center"  class="thinborderTOPRIGHT">
		<input type="radio" value="1" name="field_60" <%=strErrMsg%>></td>
		<%	if(strTemp.equals("0") || strTemp.length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
	    <td width="94" align="center"  class="thinborderTOPRIGHT">
		<input type="radio" value="0" name="field_60" <%=strErrMsg%>></td>
	    <%  strTemp = WI.fillTextValue("field_61");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(62);
		%>
	    <td width="492"><input type="text" name="field_61" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
			 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="41"></td>
	</tr>
	<tr>
	    <td width="279"  class="thinborderTOPRIGHT">Heart disorder</td>
	    <%  strTemp = WI.fillTextValue("field_62");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(63);		
			if(strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
	    <td width="90" align="center"  class="thinborderTOPRIGHT">
		<input type="radio" value="1" name="field_62" <%=strErrMsg%>></td>
	    <%	if(strTemp.equals("0") || strTemp.length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
	     <td width="94" align="center"  class="thinborderTOPRIGHT">
		 <input type="radio" value="0" name="field_62" <%=strErrMsg%>></td>
	    <%  strTemp = WI.fillTextValue("field_63");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(64);
		%>
	     <td width="492" class="thinborderTOPBOTTOM">
		 <input type="text" name="field_63" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="41"></td>
	</tr>
	<tr>
	     <td width="279"  class="thinborderTOPRIGHT">High Blood pressure</td>
	     <%	strTemp = WI.fillTextValue("field_64");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(65);		
			if(strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="90" align="center"  class="thinborderTOPRIGHT">
		<input type="radio" value="1" name="field_64" <%=strErrMsg%>></td>
	    <%	if(strTemp.equals("0") || strTemp.length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
	    <td width="94" align="center"  class="thinborderTOPRIGHT">
		<input type="radio" value="0" name="field_64" <%=strErrMsg%>></td>
	    <%  strTemp = WI.fillTextValue("field_65");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(66);
		%>
	    <td width="492"><input type="text" name="field_65" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
			 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="41"></td>
	</tr>
	<tr>
	    <td width="279"  class="thinborderTOPRIGHT">Kidney problem</td>
	    <%  strTemp = WI.fillTextValue("field_66");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(67);		
			if(strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
     	<td width="90" align="center"  class="thinborderTOPRIGHT">
		<input type="radio" value="1" name="field_66" <%=strErrMsg%>></td>
	    <%	if(strTemp.equals("0") || strTemp.length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
	     <td width="94" align="center"  class="thinborderTOPRIGHT">
		 <input type="radio" value="0" name="field_66" <%=strErrMsg%>></td>
	     <% strTemp = WI.fillTextValue("field_67");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(68);
		%>
	     <td width="492" class="thinborderTOPBOTTOM">
		 <input type="text" name="field_67" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
			 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="41"></td>
	</tr>
	<tr>
         <td width="279" class="thinborderTOPRIGHT">Mental disorder</td>
	     <% strTemp = WI.fillTextValue("field_68");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(69);		
			if(strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		 %>
	     <td width="90" align="center"  class="thinborderTOPRIGHT">
		 <input type="radio" value="1" name="field_68" <%=strErrMsg%>></td>
         <%	if(strTemp.equals("0") || strTemp.length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		 %>
	     <td width="94" align="center"  class="thinborderTOPRIGHT">
		 <input type="radio" value="0" name="field_68" <%=strErrMsg%>></td>
	     <%  strTemp = WI.fillTextValue("field_69");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(70);
		%>
		 <td width="492"><input type="text" name="field_69" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="41"></td>
	</tr>
	<tr>
		<td width="279"  class="thinborderTOPRIGHT">Obesity</td>
		<%	strTemp = WI.fillTextValue("field_70");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(71);		
			if(strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="90" align="center"  class="thinborderTOPRIGHT">
		<input type="radio" value="1" name="field_70" <%=strErrMsg%>></td>
		<%	if(strTemp.equals("0") || strTemp.length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
	    <td width="94" align="center"  class="thinborderTOPRIGHT">
		<input type="radio" value="0" name="field_70" <%=strErrMsg%>></td>
	    <%  strTemp = WI.fillTextValue("field_71");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(72);
		%>
	    <td width="492" class="thinborderTOPBOTTOM">
		<input type="text" name="field_71" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="41"></td>
	</tr>
	<tr>
	    <td width="279"  class="thinborderTOPRIGHT">Seizure</td>
	    <%  strTemp = WI.fillTextValue("field_72");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(73);		
			if(strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
	    <td width="90" align="center"  class="thinborderTOPRIGHT">
		<input type="radio" value="1" name="field_72" <%=strErrMsg%>></td>
	    <%	if(strTemp.equals("0") || strTemp.length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
	    <td width="94" align="center"  class="thinborderTOPRIGHT">
		<input type="radio" value="0" name="field_72" <%=strErrMsg%>></td>
	    <%  strTemp = WI.fillTextValue("field_73");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(74);
		%>
	    <td width="492"><input type="text" name="field_73" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
			 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="41"></td>
	</tr>
	<tr>
	    <td width="279"  class="thinborderTOPRIGHT">Stroke</td>
	    <%  strTemp = WI.fillTextValue("field_74");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(75);		
			if(strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
	    <td width="90" align="center"  class="thinborderTOPRIGHT">
		<input type="radio" value="1" name="field_74" <%=strErrMsg%>></td>
	    <%	if(strTemp.equals("0") || strTemp.length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
	    <td width="94" align="center"  class="thinborderTOPRIGHT">
		<input type="radio" value="0" name="field_74" <%=strErrMsg%>></td>
	    <%   strTemp = WI.fillTextValue("field_75");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(76);
		%>
	    <td width="492"  class="thinborderTOPBOTTOM">
		<input type="text" name="field_75" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="41"></td>
	</tr>
	<tr>
	    <td width="279" class="thinborderTOPBOTTOMRIGHT">Tuberculosis</td>
	    <%  strTemp = WI.fillTextValue("field_76");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(77);		
			if(strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
	   <td width="90" align="center"  class="thinborderTOPBOTTOMRIGHT">
	   <input type="radio" value="1" name="field_76" <%=strErrMsg%>></td>
	    <%	if(strTemp.equals("0") || strTemp.length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
	   <td width="94" align="center"  class="thinborderTOPBOTTOMRIGHT">
	   <input type="radio" value="0" name="field_76" <%=strErrMsg%>></td>
	   <%    strTemp = WI.fillTextValue("field_77");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(78);
	   %>
	   <td width="492" class="thinborderBOTTOM">
	   <input type="text" name="field_77" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	   onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="41"></td>
	</tr>
	<tr>
        <td colspan="6">&nbsp;</td>
	</tr>
	<tr>
		<td width="158" rowspan="4" class="thinborderRIGHT">&nbsp;</td>
		<td colspan="4" class="thinborderTOPBOTTOM"><i>The child has a history of:</i></td>
		<td width="181" rowspan="4" class="thinborderLEFT">&nbsp;</td>
	</tr>
	<tr>
		<td width="279" class="thinborderBOTTOMRIGHT">&nbsp;</td>
		<td width="90" align="center" class="thinborderBOTTOMRIGHT">Yes</td>
		<td width="94" align="center" class="thinborderBOTTOMRIGHT">No</td>
		<td width="492" align="center">Diagnosis / Operation done</td>
	</tr>
	<tr>
		<td width="279" class="thinborderBOTTOMRIGHT"><i>Hospitalization</i></td>
		<%	strTemp = WI.fillTextValue("field_78");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(79);		
			if(strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="90" align="center" class="thinborderBOTTOMRIGHT">
		<input type="radio" value="1" name="field_78" <%=strErrMsg%>></td>
		<%	if(strTemp.equals("0") || strTemp.length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="94" align="center" class="thinborderBOTTOMRIGHT">
		<input type="radio" value="0" name="field_78" <%=strErrMsg%>></td>
		<%	strTemp = WI.fillTextValue("field_79");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(80);
		%>
		<td width="492"  class="thinborderTOPBOTTOM">
		<input type="text" name="field_79" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="41"></td>
	</tr>
	<tr>
		<td width="279" class="thinborderBOTTOMRIGHT"><i>Surgical Operation</i></td>
		<%	strTemp = WI.fillTextValue("field_80");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(81);		
			if(strTemp.equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="90" align="center" class="thinborderBOTTOMRIGHT">
		<input type="radio" value="1" name="field_80" <%=strErrMsg%>></td>
	    <%	if(strTemp.equals("0") || strTemp.length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
	     <td width="94" align="center" class="thinborderBOTTOMRIGHT">
		 <input type="radio" value="0" name="field_80" <%=strErrMsg%>></td>
	    <%  strTemp = WI.fillTextValue("field_81");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(82);
		%>
	     <td width="492" class="thinborderBOTTOM">
		 <input type="text" name="field_81" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="41"></td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td height="20">&nbsp;</td></tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td width="101" rowspan="2">&nbsp;</td>
		<td width="313"><strong>Physical Examination by the Physician</strong></td>
		<td width="129">&nbsp;</td>
		<td width="110">Date:</td>
		<%	
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(1);
			else			
				strTemp = WI.fillTextValue("date_recorded");				
				
			if(WI.getStrValue(strTemp).length() == 0)
				strTemp = WI.getTodaysDate(1);
		%>
		<td width="187">
		<input name="date_recorded" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
		<a href="javascript:show_calendar('form_.date_recorded');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
		<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
		<td width="118" rowspan="2">&nbsp;</td>
	</tr>
	<tr>
		<td colspan="4">&nbsp;</td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td width="101" rowspan="19" class="thinborderRIGHT">&nbsp;</td>
		<td colspan="2" class="thinborderTOP">Weight (kilogram):
		<%	strTemp = WI.fillTextValue("field_83");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(84);
		%>  <input type="text" name="field_83" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" 
			onBlur="style.backgroundColor='white'" size="20">&nbsp;&nbsp;&nbsp;Height (cm):
		<%	strTemp = WI.fillTextValue("field_84");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(85);
		%>	<input type="text" name="field_84" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" 
			onBlur="style.backgroundColor='white'" size="20">&nbsp;&nbsp;&nbsp;BMI:
		<%	strTemp = WI.fillTextValue("field_85");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(86);
		%> 	<input type="text" name="field_85" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="20"></td>
		<td width="108" rowspan="19" class="thinborderLEFT">&nbsp;</td>
	</tr>
	<tr>
		<td width="132" height="24" >Blood Pressure:</td>
		<%	strTemp = WI.fillTextValue("field_86");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(87);
		%>
		<td width="617"><input type="text" name="field_86" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="83"></td>
	</tr>
	<tr>
		<td height="24">Scalp:</td>
		<%	strTemp = WI.fillTextValue("field_87");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(88);
		%>
		<td><input type="text" name="field_87" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="83"></td>
	</tr>
	<tr>
		<td height="24">Skin and nails:</td>
		<%	strTemp = WI.fillTextValue("field_88");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(89);
		%>
		<td><input type="text" name="field_88" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="83"></td>
	</tr>
	<tr>
		<td height="24">Eyes: </td>
		<%	strTemp = WI.fillTextValue("field_89");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(90);
		%>
		<td><input type="text" name="field_89" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="83"></td>
	</tr>
	<tr>
		<td height="24">Visual Acuity: </td>
		<%	strTemp = WI.fillTextValue("field_90");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(91);
		%>
		<td><input type="text" name="field_90" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="83"></td>
	</tr>
	<tr>
		<td height="24">Ears:</td>
		<%	strTemp = WI.fillTextValue("field_91");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(92);
		%>
		<td><input type="text" name="field_91" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="83"></td>
	</tr>
	<tr>
		<td height="24">Hearing Test: </td>
		<%	strTemp = WI.fillTextValue("field_92");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(93);
		%>
		<td><input type="text" name="field_92" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="83"></td>
	</tr>
	<tr>
		<td height="24">Nose:</td>
		<%	strTemp = WI.fillTextValue("field_93");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(94);
		%>
		<td><input type="text" name="field_93" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="83"></td>
	</tr>
	<tr>
		<td height="24">Throat:</td>
		<%	strTemp = WI.fillTextValue("field_94");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(95);
		%>
		<td><input type="text" name="field_94" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="83"></td>
	</tr>
	<tr>
		<td height="24">Mouth and tongue:</td>
		<%	strTemp = WI.fillTextValue("field_95");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(96);
		%>
		<td><input type="text" name="field_95" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="83"></td>
	</tr>
	<tr>
		<td height="24">Teeth and Gums:</td>
		<%	strTemp = WI.fillTextValue("field_96");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(97);
		%>
		<td><input type="text" name="field_96" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="83"></td>
	</tr>
	<tr>
		<td height="24">Chest, Breast:</td>
		<%	strTemp = WI.fillTextValue("field_97");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(98);
		%>
		<td><input type="text" name="field_97" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="83"></td>
	</tr>
	<tr>
		<td height="24">Heart:</td>
		<%	strTemp = WI.fillTextValue("field_98");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(99);
		%>
		<td><input type="text" name="field_98" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="83"></td>
	</tr>
	<tr>
		<td height="24">Lungs:</td>
		<%	strTemp = WI.fillTextValue("field_99");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(100);
		%>
		<td><input type="text" name="field_99" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="83"></td>
	</tr>
	<tr>
		<td height="24">Abdomen: </td>
		<%	strTemp = WI.fillTextValue("field_100");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(101);
		%>
		<td><input type="text" name="field_100" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="83"></td>
	</tr>
	<tr>
		<td height="24">Genitalia:</td>
		<%	strTemp = WI.fillTextValue("field_101");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(102);
		%>
		<td><input type="text" name="field_101" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="83"></td>
	</tr>
	<tr>
		<td height="24">Spine:</td>
		<%	strTemp = WI.fillTextValue("field_102");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(103);
		%>
		<td><input type="text" name="field_102" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="83"></td>
	</tr>
	<tr>
		<td height="24" class="thinborderBOTTOM">Other Findings:</td>
		<%	strTemp = WI.fillTextValue("field_103");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(104);
		%>
		<td class="thinborderBOTTOM">
		<input type="text" name="field_103" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="83"></td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td height="20">&nbsp;</td></tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td width="8%" rowspan="4">&nbsp;</td>
		<td width="79%">Recommendation/ Endorsement:</td>
		<%	strTemp = WI.fillTextValue("field_104");
			if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(105);
		%>
		<td width="13%" rowspan="4">&nbsp;</td>
	</tr>
	<tr>
		<td rowspan="3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	     <textarea name="field_104" cols="100" rows="3" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
		  onBlur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp)%></textarea></td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td height="20">&nbsp;</td></tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<Td colspan="3">&nbsp;</Td></tr>
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
<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td>&nbsp;</td></tr>
</table>
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
		<%}%>
		</td>
	</tr>
	<%}%>
</table>
<%}%>


<table  width="100%" border="0" cellpadding="0" cellspacing="0" >
	<tr>
		<td height="25" colspan="9" bgcolor="#FFFFFF">&nbsp;</td>
	</tr>
	<tr>
		<td height="25" colspan="9" bgcolor="#697A8F" class="footerDynamic">&nbsp;</td>
	</tr>
</table>
	<input type="hidden" name="no_of_fields" value="109" > <!-- get the last number of fields; used in java -->
	<input type="hidden" name="save_entry" >
	<input type="hidden" name="search_" >
	
	<input type="hidden" name="page_action">
	<input type="hidden" name="reload_page">
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="view_fields" value="<%=strViewFields%>">
	<input type="hidden" name="print_page" >
	<input type="hidden" name="vDate" value="1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,21,82">
	<input type="hidden" name="edu_level" value="1,2" ><!---Preparatory and Grade School Student only.---->
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
