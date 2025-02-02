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
			escape(strCompleteName)+ "&is_faculty=-1";
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
		<jsp:forward page="./health_exam_print_spc_high_school.jsp" />
	<% 
		return;}

	
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	String strViewFields = WI.getStrValue(WI.fillTextValue("view_fields"),"0");

	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-Health Examination Record","health_exam_entry_spc_high_school.jsp");
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
				"Health Monitoring","Health Examination Record",request.getRemoteAddr(),"health_exam_entry_spc_high_school.jsp");
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
<form action="health_exam_entry_spc_high_school.jsp" method="post" name="form_">
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
		        <label id="coa_info" style="font-size:11px; position:absolute; width:400px;"></label>	
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
					strTemp = WI.fillTextValue("field_176");		
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(177);		
					strTemp = WI.getStrValue(strTemp);
						
					if(strTemp.equals("1"))
						strErrMsg = "checked";
					else
						strErrMsg = "";
					%>
				  	<td height="20" width="16%"><input type="radio" name="field_176" value="1" <%=strErrMsg%>>Mother</td>
				  	<%
					if(strTemp.equals("2"))
						strErrMsg = "checked";
					else
						strErrMsg = "";
					%>
					<td height="20" width="16%"><input type="radio" name="field_176" value="2" <%=strErrMsg%>>Father</td>
				  	<%
					if(strTemp.equals("3"))
						strErrMsg = "checked";
					else
						strErrMsg = "";
					%>
					<td height="20" width="20%"><input type="radio" name="field_176" value="3" <%=strErrMsg%>>Both Parents</td>
				  	<%
					if(strTemp.equals("0"))
						strErrMsg = "checked";
					else
						strErrMsg = "";
					%>
					<td height="20" width="29%"><input type="radio" name="field_176" value="0" <%=strErrMsg%>>Guardian please specify</td>
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
	  strTemp = WI.fillTextValue("field_177");		
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(178);	
	  %>
	  <td height="20" colspan="4">
	  	<input type="text" name="field_177" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
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
					  strTemp = WI.fillTextValue("field_178");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(179);	
					  %>
					<td valign="bottom" height="20" width="77%">
					<input type="text" name="field_178" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
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
					  strTemp = WI.fillTextValue("field_179");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(180);	
					  %>
					<td valign="bottom" height="20" width="85%">
						<input type="text" name="field_179" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
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
		<td colspan="5" height="25">&nbsp;A. MEDICAL HISTORY</td>
	</tr>
	<tr>
		<td colspan="5">&nbsp;</td>
	</tr>
	<tr>
		<td width="6">&nbsp;</td>
		<td width="301" valign="top">
			<table  width="98%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"> 
				<tr>
					<td width="57%">&nbsp;</td>
					<td align="center" class="thinborderBOTTOM" width="20%">YES</td>
					<td width="21%" align="center" class="thinborderBOTTOM" >NO</td>
					<td width="2%">&nbsp;</td>
				</tr>
				<tr>
					<td width="57%">Illness</td>
					<%  strTemp = WI.fillTextValue("field_1");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(2);
							
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="20%" class="thinborderBOTTOMLEFTRIGHT" align="center">
	 					 <input type="radio" value="1" name="field_1" <%=strErrMsg%>></td>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
						<input type="radio" value="0" name="field_1" <%=strErrMsg%>></td>
					<td width="2%" rowspan="17">&nbsp;</td>
				</tr>
				<tr>
					<td width="57%">Allergy</td>
					<%	strTemp = WI.fillTextValue("field_4");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(5);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="20%" class="thinborderBOTTOMLEFTRIGHT" align="center">
					<input type="radio" value="1" name="field_4" <%=strErrMsg%>></td>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
					<input type="radio" value="0" name="field_4" <%=strErrMsg%>></td>
				</tr>
				<tr>
					<td width="57%">Anemia</td>
					<%	strTemp = WI.fillTextValue("field_7");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(8);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="20%" class="thinborderBOTTOMLEFTRIGHT" align="center">
	 				<input type="radio" value="1" name="field_7" <%=strErrMsg%>></td>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
					<input type="radio" value="0" name="field_7" <%=strErrMsg%>></td>
				</tr>
				<tr>
					<td width="57%">Asthma</td>
					<%	strTemp = WI.fillTextValue("field_10");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(11);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="20%" class="thinborderBOTTOMLEFTRIGHT" align="center">
	 				<input type="radio" value="1" name="field_10" <%=strErrMsg%>></td>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
					<input type="radio" value="0" name="field_10" <%=strErrMsg%>></td>
				</tr>
				<tr>
					<td width="57%">Behavior problem</td>
					<%	strTemp = WI.fillTextValue("field_13");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(14);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="20%" class="thinborderBOTTOMLEFTRIGHT" align="center">
					<input type="radio" value="1" name="field_13" <%=strErrMsg%>></td>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
					<input type="radio" value="0" name="field_13" <%=strErrMsg%>></td>
				</tr>
				<tr>
					<td width="57%">Bleeding problem</td>
					<%	strTemp = WI.fillTextValue("field_16");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(17);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="20%" class="thinborderBOTTOMLEFTRIGHT" align="center">
	 				<input type="radio" value="1" name="field_16" <%=strErrMsg%>></td>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
						<input type="radio" value="0" name="field_16" <%=strErrMsg%>></td>
				</tr>
				<tr>
					<td width="57%">Chicken pox</td>
					<%	strTemp = WI.fillTextValue("field_19");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(20);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="20%" class="thinborderBOTTOMLEFTRIGHT" align="center">
	 					 <input type="radio" value="1" name="field_19" <%=strErrMsg%>></td>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
					<input type="radio" value="0" name="field_19" <%=strErrMsg%>></td>
				</tr>
				<tr>
					<td width="57%">Convulsion</td>
					<%	strTemp = WI.fillTextValue("field_22");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(23);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="20%" class="thinborderBOTTOMLEFTRIGHT" align="center">
	 				<input type="radio" value="1" name="field_22" <%=strErrMsg%>></td>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
					<input type="radio" value="0" name="field_22" <%=strErrMsg%>></td>
				</tr>
				<tr>
					<td width="57%">Diabetes</td>
					<%	strTemp = WI.fillTextValue("field_25");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(26);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="20%" class="thinborderBOTTOMLEFTRIGHT" align="center">
					<input type="radio" value="1" name="field_25" <%=strErrMsg%>></td>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
					<input type="radio" value="0" name="field_25" <%=strErrMsg%>></td>
				</tr>
				<tr>
					<td  width="57%">Ear problem</td>
					<%	strTemp = WI.fillTextValue("field_28");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(29);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="20%" class="thinborderBOTTOMLEFTRIGHT" align="center">
				  	<input type="radio" value="1" name="field_28" <%=strErrMsg%>></td>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
					<input type="radio" value="0" name="field_28" <%=strErrMsg%>></td>
				</tr>
				<tr>
					<td width="57%">Eating disorder</td>
					<%	strTemp = WI.fillTextValue("field_30");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(31);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="20%" class="thinborderBOTTOMLEFTRIGHT" align="center">
				  	<input type="radio" value="1" name="field_30" <%=strErrMsg%>></td>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
					<input type="radio" value="0" name="field_30" <%=strErrMsg%>></td>
				</tr>
				<tr>
					<td width="57%">Eye problem</td>
					<%	strTemp = WI.fillTextValue("field_32");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(33);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="20%" class="thinborderBOTTOMLEFTRIGHT" align="center">
				  	<input type="radio" value="1" name="field_32" <%=strErrMsg%>></td>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
					<input type="radio" value="0" name="field_32" <%=strErrMsg%>></td>
				</tr>
				<tr>
					<td colspan="3">&nbsp;</td></tr>
				<tr>
					<td width="57%">&nbsp;</td>
					<td align="center" class="thinborderBOTTOM" width="20%">YES</td>
					<td width="21%" align="center" class="thinborderBOTTOM" >NO</td>
				</tr>
				<tr>
					<td width="57%">Illness</td>
					<%	strTemp = WI.fillTextValue("field_33");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(34);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="20%" class="thinborderBOTTOMLEFTRIGHT" align="center">
			  			<input type="radio" value="1" name="field_33" <%=strErrMsg%>></td>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
					<input type="radio" value="0" name="field_33" <%=strErrMsg%>></td>
				</tr>
				<tr>
					<td colspan="3">&nbsp;</td>
				</tr>
				<tr>
					<td colspan="3">&nbsp;</td>
				</tr>
				<tr>
					<td colspan="4" height="25"> B. FAMILY HISTORY</td>
	   			</tr>
				<tr>
					<td colspan="3">&nbsp;</td>
					<td rowspan="8">&nbsp;</td></tr>
				<tr>
					<td width="57%">&nbsp;</td>
					<td align="center" class="thinborderBOTTOM" width="20%">YES</td>
					<td width="21%" align="center" class="thinborderBOTTOM" >NO</td>
				</tr>
				<tr>
					<td width="13%">Disease</td>
					<%	strTemp = WI.fillTextValue("field_36");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(37);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="12%" class="thinborderBOTTOMLEFTRIGHT" align="center">
	 				<input type="radio" value="1" name="field_36" <%=strErrMsg%>></td>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
					<input type="radio" value="0" name="field_36" <%=strErrMsg%>></td>
				</tr>
				<tr>
					<td width="13%">Asthma</td>
					<%	strTemp = WI.fillTextValue("field_39");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(40);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="12%" class="thinborderBOTTOMLEFTRIGHT" align="center">
	  				<input type="radio" value="1" name="field_39" <%=strErrMsg%>></td>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
					<input type="radio" value="0" name="field_39" <%=strErrMsg%>></td>
				</tr>
				<tr>
					<td width="13%">Cancer</td>
					<%	strTemp = WI.fillTextValue("field_41");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(42);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="12%" class="thinborderBOTTOMLEFTRIGHT" align="center">
	 				<input type="radio" value="1" name="field_41" <%=strErrMsg%>></td>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
					<input type="radio" value="0" name="field_41" <%=strErrMsg%>></td>
				</tr>
				<tr>
					<td width="13%">Bleeding problem</td>
					<%	strTemp = WI.fillTextValue("field_43");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(44);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="12%" class="thinborderBOTTOMLEFTRIGHT" align="center">
	 					 <input type="radio" value="1" name="field_43" <%=strErrMsg%>></td>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
						<input type="radio" value="0" name="field_43" <%=strErrMsg%>></td>
				</tr>
				<tr>
					<td width="13%">Diabetes</td>
					<%	strTemp = WI.fillTextValue("field_45");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(46);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="12%" class="thinborderBOTTOMLEFTRIGHT" align="center">
				  	<input type="radio" value="1" name="field_45" <%=strErrMsg%>></td>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
					<input type="radio" value="0" name="field_45" <%=strErrMsg%>></td>
				</tr>
				<tr>
					<td width="13%">Epilepsy</td>
					<%	strTemp = WI.fillTextValue("field_47");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(48);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="12%" class="thinborderBOTTOMLEFTRIGHT" align="center">
				  	<input type="radio" value="1" name="field_47" <%=strErrMsg%>></td>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
					<input type="radio" value="0" name="field_47" <%=strErrMsg%>></td>
				</tr>
				<tr>
				  	<td colspan="4">&nbsp;</td>
				</tr>
				<tr>
					<td colspan="4">Has the student experienced:</td>
				</tr>
				<tr>
					<td colspan="4">&nbsp;</td>
				</tr>
				<tr>
					<td width="57%">&nbsp;</td>
					<td align="center" class="thinborderBOTTOM" width="20%">YES</td>
					<td width="21%" align="center" class="thinborderBOTTOM" >NO</td>
					<td rowspan="2">&nbsp;</td>
				</tr>
				<tr>
					<td width="13%">Hospitalization</td>
					<%	strTemp = WI.fillTextValue("field_49");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(50);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="12%" class="thinborderBOTTOMLEFTRIGHT" align="center">
				  	<input type="radio" value="1" name="field_49" <%=strErrMsg%>></td>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
					<input type="radio" value="0" name="field_49" <%=strErrMsg%>></td>
				</tr>
				<tr>
					<td colspan="4">&nbsp;</td>
				</tr>
				<tr>
					<td colspan="4">For Boys:&nbsp;</td>
				</tr>
				<tr>
					<td align="right">Circumcision:</td>
					<%  strTemp = WI.fillTextValue("field_52");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(53);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td colspan="2"> &nbsp;[<input type="radio" value="1" name="field_52" <%=strErrMsg%>>]Done</td>
				</tr>
				<tr>
					<td colspan="4">&nbsp;</td></tr>
				<tr>
					<td colspan="4" height="18">For Girls: menstrual history</td></tr>
				<tr>
					<td colspan="4">&nbsp;</td></tr>
					<%	strTemp = WI.fillTextValue("field_53");
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(54);
					%>
				<tr>
					<td align="right">Age of menarche: </td>
					<td colspan="2">
						<input type="text" name="field_53" value="<%=WI.getStrValue(strTemp)%>" class="textbox"   
						onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="11"></td></tr>
				<tr>
					<td colspan="4">&nbsp;</td></tr>
				<tr>
					<td width="13%" align="right" rowspan="2" valign="top">Cycle:</td>
					<td class="thinborderTOPLEFTBOTTOM" width="12%">Regular &nbsp;</td>
					<%	strTemp = WI.fillTextValue("field_55");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(56);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td class="thinborderTOPLEFTBOTTOM"align="center"><input type="radio" value="1" name="field_55" <%=strErrMsg%>></td>
					<td rowspan="2" class="thinborderLEFT">&nbsp;</td></tr>
				<tr>
				<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
						strErrMsg = "checked";
					else
						strErrMsg = "";
				%>
					<td class="thinborder" width="12%">Irregular</td>
					<td  class="thinborder" align="center">
					<input type="radio" value="0" name="field_55" <%=strErrMsg%>></td>
				</tr>
				<tr>
					<td colspan="4">&nbsp;</td></tr>
				<tr>
					<%	strTemp = WI.fillTextValue("field_56");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(57);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="13%" align="right" rowspan="3" valign="top">Flow:</td>
					<td class="thinborderTOPLEFTBOTTOM" width="12%">Minimal</td>
					<td class="thinborderTOPLEFTBOTTOM"align="center"><input type="radio" value="1" name="field_56" <%=strErrMsg%>></td>
					<td rowspan="3" class="thinborderLEFT">&nbsp;</td>
				</tr>
				<tr>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td class="thinborder" width="12%">Moderate</td>
					<td class="thinborder" align="center"><input type="radio" value="0" name="field_56" <%=strErrMsg%>></td>
				</tr>
				<tr>
					<%	if(WI.getStrValue(strTemp).equals("2") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td class="thinborder">Profuse</td>
					<td class="thinborder" align="center">
					<input type="radio" value="2" name="field_56" <%=strErrMsg%>></td>
				</tr>
			</table>
		 </td> 
		 <td width="328" valign="top"> 
 			<table  width="97%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"> 
				<tr>
					<td width="58%">&nbsp;</td>
					<td align="center" class="thinborderBOTTOM" width="21%">YES</td>
					<td align="center" class="thinborderBOTTOM" width="19%">NO</td>
					<td width="2%">&nbsp;</td>
				</tr>
				<tr>
					<td width="58%">Dengue</td>
					<%	strTemp = WI.fillTextValue("field_2");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(3);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="21%" class="thinborderBOTTOMLEFTRIGHT" align="center">
				 	<input type="radio" value="1" name="field_2" <%=strErrMsg%>></td>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
					<input type="radio" value="0" name="field_2" <%=strErrMsg%>></td>
					<td rowspan="36">&nbsp;</td>
				</tr>
				<tr>
					<td>Epilepsy</td>
					<%	strTemp = WI.fillTextValue("field_5");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(6);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="16%" class="thinborderBOTTOMLEFTRIGHT" align="center">
				  	<input type="radio" value="1" name="field_5" <%=strErrMsg%>></td>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
					<input type="radio" value="0" name="field_5" <%=strErrMsg%>></td>
				</tr>
				<tr>
					<td>Fainting</td>
					<%	strTemp = WI.fillTextValue("field_8");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(9);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="16%" class="thinborderBOTTOMLEFTRIGHT" align="center">
				  	<input type="radio" value="1" name="field_8" <%=strErrMsg%>></td>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
					<input type="radio" value="0" name="field_8" <%=strErrMsg%>></td>
				</tr>
				<tr>
					<td>Fracture</td>
					<%	strTemp = WI.fillTextValue("field_11");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(12);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="16%" class="thinborderBOTTOMLEFTRIGHT" align="center">
				 	<input type="radio" value="1" name="field_11" <%=strErrMsg%>></td>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
					<input type="radio" value="0" name="field_11" <%=strErrMsg%>></td>
				</tr>
				<tr>
					<td>Hearing problem</td>
					<%	strTemp = WI.fillTextValue("field_14");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(15);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="16%" class="thinborderBOTTOMLEFTRIGHT" align="center">
					<input type="radio" value="1" name="field_14" <%=strErrMsg%>></td>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
					<input type="radio" value="0" name="field_14" <%=strErrMsg%>></td>
				</tr>
				<tr>
					<td>Indigestion</td>
					<%	strTemp = WI.fillTextValue("field_17");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(18);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="16%" class="thinborderBOTTOMLEFTRIGHT" align="center">
				  	<input type="radio" value="1" name="field_17" <%=strErrMsg%>></td>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
					<input type="radio" value="0" name="field_17" <%=strErrMsg%>></td>
				</tr>
				<tr>
					<td>Insomnia</td>
					<%	strTemp = WI.fillTextValue("field_20");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(21);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="16%" class="thinborderBOTTOMLEFTRIGHT" align="center">
	 				<input type="radio" value="1" name="field_20" <%=strErrMsg%>></td>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
					<input type="radio" value="0" name="field_20" <%=strErrMsg%>></td>
				</tr>
				<tr>
					<td>Intestinal worms</td>
					<%	strTemp = WI.fillTextValue("field_23");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(24);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="16%" class="thinborderBOTTOMLEFTRIGHT" align="center">
				  	<input type="radio" value="1" name="field_23" <%=strErrMsg%>></td>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
					<input type="radio" value="0" name="field_23" <%=strErrMsg%>></td>
				</tr>
				<tr>
					<td>Kidney disease</td>
					<%	strTemp = WI.fillTextValue("field_26");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(27);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="16%" class="thinborderBOTTOMLEFTRIGHT" align="center">
				  	<input type="radio" value="1" name="field_26" <%=strErrMsg%>></td>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
					<input type="radio" value="0" name="field_26" <%=strErrMsg%>></td>
				</tr>
				<tr>
					<td>Liver disease</td>
					<%	strTemp = WI.fillTextValue("field_29");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(30);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="16%" class="thinborderBOTTOMLEFTRIGHT" align="center">
				  	<input type="radio" value="1" name="field_29" <%=strErrMsg%>></td>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
					<input type="radio" value="0" name="field_29" <%=strErrMsg%>></td>
				</tr>
				<tr>
					<td>Lung disease</td>
					<%	strTemp = WI.fillTextValue("field_31");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(32);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="16%" class="thinborderBOTTOMLEFTRIGHT" align="center">
				  	<input type="radio" value="1" name="field_31" <%=strErrMsg%>></td>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
					  <input type="radio" value="0" name="field_31" <%=strErrMsg%>></td>
				</tr>
				<tr>
					<td colspan="3">&nbsp;</td>
				</tr>
				<tr>
					<td colspan="3">&nbsp;</td>
				</tr>
				<tr>
					<td width="62%">&nbsp;</td>
					<td align="center" class="thinborderBOTTOM" width="18%">YES</td>
					<td width="18%" align="center" class="thinborderBOTTOM" >NO</td>
				</tr>
				<tr>
					<td width="13%">Illness</td>
					<%	strTemp = WI.fillTextValue("field_34");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(35);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="12%" class="thinborderBOTTOMLEFTRIGHT" align="center">
				 	<input type="radio" value="1" name="field_34" <%=strErrMsg%>></td>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
					<input type="radio" value="0" name="field_34" <%=strErrMsg%>></td>
				</tr>
				<tr>
					<td width="16%">Measles</td>
					<%	strTemp = WI.fillTextValue("field_35");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(36);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="10%" class="thinborderBOTTOMLEFTRIGHT" align="center">
				  	<input type="radio" value="1" name="field_35" <%=strErrMsg%>></td>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
					<input type="radio" value="0" name="field_35" <%=strErrMsg%>></td>
				</tr>
				<tr>
					<td colspan="3">&nbsp;</td>
				</tr>
				<tr>
					<td colspan="3" height="25">&nbsp;</td>
				</tr>
				<tr>
					<td colspan="3">&nbsp;</td>
				</tr>
				<tr>
					<td width="62%">&nbsp;</td>
					<td align="center" class="thinborderBOTTOM" width="18%">YES</td>
					<td width="18%" align="center" class="thinborderBOTTOM" >NO</td>
				</tr>
				<tr>
					<td width="16%">Hearth problem</td>
					<%	strTemp = WI.fillTextValue("field_37");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(38);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="10%" class="thinborderBOTTOMLEFTRIGHT" align="center">
				 	<input type="radio" value="1" name="field_37" <%=strErrMsg%>></td>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
					<input type="radio" value="0" name="field_37" <%=strErrMsg%>></td>
				</tr>
				<tr>
					<td>Hypertension</td>
					<%	strTemp = WI.fillTextValue("field_40");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(41);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="10%" class="thinborderBOTTOMLEFTRIGHT" align="center">
				  	<input type="radio" value="1" name="field_40" <%=strErrMsg%>></td>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
					<input type="radio" value="0" name="field_40" <%=strErrMsg%>></td>
				</tr>
				<tr>
					<td>Kidney disease</td>
					<%	strTemp = WI.fillTextValue("field_42");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(43);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="10%" class="thinborderBOTTOMLEFTRIGHT" align="center">
				  	<input type="radio" value="1" name="field_42" <%=strErrMsg%>></td>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
					<input type="radio" value="0" name="field_42" <%=strErrMsg%>></td></tr>
				<tr>
					<td>Mental problem</td>
					<%	strTemp = WI.fillTextValue("field_44");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(45);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="10%" class="thinborderBOTTOMLEFTRIGHT" align="center">
	  				<input type="radio" value="1" name="field_44" <%=strErrMsg%>></td>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
						<input type="radio" value="0" name="field_44" <%=strErrMsg%>></td>
				</tr>
				<tr>
					<td>Obesity</td>
					<%	strTemp = WI.fillTextValue("field_46");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(47);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="10%" class="thinborderBOTTOMLEFTRIGHT" align="center">
				 	<input type="radio" value="1" name="field_46" <%=strErrMsg%>></td>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
					<input type="radio" value="0" name="field_46" <%=strErrMsg%>></td>
				</tr>
				<tr>
					<td>Stroke</td>
					<%	strTemp = WI.fillTextValue("field_48");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(49);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="10%" class="thinborderBOTTOMLEFTRIGHT" align="center">
				  	<input type="radio" value="1" name="field_48" <%=strErrMsg%>></td>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
					<input type="radio" value="0" name="field_48" <%=strErrMsg%>></td>
				</tr>
				<tr>
					<td colspan="3">&nbsp;</td>
				</tr>
				<tr>
					<td colspan="3">&nbsp;</td>
				</tr>
				<tr>
					<td colspan="3">&nbsp;</td>
				</tr>
				<tr>
					<td width="62%">&nbsp;</td>
					<td align="center" class="thinborderBOTTOM" width="18%">YES</td>
					<td width="18%" align="center" class="thinborderBOTTOM" >NO</td>
				</tr>
				<tr>
					<td width="16%">Surgery/Operation</td>
					<%	strTemp = WI.fillTextValue("field_50");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(51);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="10%" class="thinborderBOTTOMLEFTRIGHT" align="center">
				  	<input type="radio" value="1" name="field_50" <%=strErrMsg%>></td>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
					<input type="radio" value="0" name="field_50" <%=strErrMsg%>></td>
				</tr>
				<tr>
					<td colspan="3">&nbsp;</td>
				</tr>
				<tr>
					<td colspan="3">&nbsp;</td>
				</tr>
					<%	strTemp = WI.fillTextValue("field_52");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(53);		
					  
					   	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
				<tr>
					<td colspan="3">[<input type="radio" value="0" name="field_52" <%=strErrMsg%>>] Not Done</td>
				</tr>
				<tr>
					<td colspan="3">&nbsp;</td>
				</tr>
				<tr>
					<td colspan="3">&nbsp;</td>
				</tr>
				<tr>
					<td colspan="4">&nbsp;</td>
				</tr>
				<tr>
					<td>Last menstrual period</td>
					<%	strTemp = WI.fillTextValue("field_54");
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(55);
					%>
					<td colspan="2">
						<input type="text" name="field_54" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
						onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="10"></td>
				</tr>
			</table>
 		</td>
 		<td width="317" valign="top"> 
 			<table  width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"> 
				<tr>
					<td width="58%">&nbsp;</td>
					<td align="center" class="thinborderBOTTOM" width="20%">YES</td>
					<td align="center" class="thinborderBOTTOM" width="19%">NO</td>
					<td width="3%">&nbsp;</td>
				</tr>
				<tr>
					<td width="8%">Mumps</td>
					<%	strTemp = WI.fillTextValue("field_3");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(4);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="3%" class="thinborderBOTTOMLEFTRIGHT" align="center">
					<input type="radio" value="1" name="field_3" <%=strErrMsg%>></td>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
					<input type="radio" value="0" name="field_3" <%=strErrMsg%>></td>
					<td rowspan="9">&nbsp;</td>
				</tr>
				<tr>
					<td>Pneumonia</td>
					<%	strTemp = WI.fillTextValue("field_6");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(7);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="3%" class="thinborderBOTTOMLEFTRIGHT" align="center">
				  	<input type="radio" value="1" name="field_6" <%=strErrMsg%>></td>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
					<input type="radio" value="0" name="field_6" <%=strErrMsg%>></td>
				</tr>
				<tr>
					<td>Skin problem</td>
					<%	strTemp = WI.fillTextValue("field_9");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(10);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="3%" class="thinborderBOTTOMLEFTRIGHT" align="center">
				 	<input type="radio" value="1" name="field_9" <%=strErrMsg%>></td>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
					<input type="radio" value="0" name="field_9" <%=strErrMsg%>></td>
				</tr>
				<tr>
					<td>Speech problem</td>
					<%	strTemp = WI.fillTextValue("field_12");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(13);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="3%" class="thinborderBOTTOMLEFTRIGHT" align="center">
				  	<input type="radio" value="1" name="field_12" <%=strErrMsg%>></td>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
					<input type="radio" value="0" name="field_12" <%=strErrMsg%>></td>
				</tr>
				<tr>
					<td>Spine disorder</td>
					<%	strTemp = WI.fillTextValue("field_15");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(16);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="3%" class="thinborderBOTTOMLEFTRIGHT" align="center">
				  	<input type="radio" value="1" name="field_15" <%=strErrMsg%>></td>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
					<input type="radio" value="0" name="field_15" <%=strErrMsg%>></td>
				</tr>
				<tr><td>Tonsillitis</td>
					<%	strTemp = WI.fillTextValue("field_18");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(19);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="3%" class="thinborderBOTTOMLEFTRIGHT" align="center">
				  	<input type="radio" value="1" name="field_18" <%=strErrMsg%>></td>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
					<input type="radio" value="0" name="field_18" <%=strErrMsg%>></td></tr>
				<tr>
					<td>Typhoid fever</td>
					<%	strTemp = WI.fillTextValue("field_21");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(22);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="3%" class="thinborderBOTTOMLEFTRIGHT" align="center">
				  	<input type="radio" value="1" name="field_21" <%=strErrMsg%>></td>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
					<input type="radio" value="0" name="field_21" <%=strErrMsg%>></td>
				</tr>
				<tr>
					<td>Vision problem</td>
					<%	strTemp = WI.fillTextValue("field_24");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(25);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="3%" class="thinborderBOTTOMLEFTRIGHT" align="center">
				  	<input type="radio" value="1" name="field_24" <%=strErrMsg%>></td>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
					<input type="radio" value="0" name="field_24" <%=strErrMsg%>></td>
				</tr>
				<tr>
					<td>others</td>
					<%	strTemp = WI.fillTextValue("field_27");
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(28);
							if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="3%" class="thinborderBOTTOMLEFTRIGHT" align="center">
			  		<input type="radio" value="1" name="field_27" <%=strErrMsg%>></td>
					<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
					<input type="radio" value="0" name="field_27" <%=strErrMsg%>></td>
		
				</tr>
				<tr><td colspan="4">&nbsp;</td></tr>
				<tr><td colspan="4">&nbsp;</td></tr>
				<tr><td colspan="4">&nbsp;</td></tr>
				<tr><td colspan="4">&nbsp;</td></tr>
				<tr><td colspan="4">&nbsp;</td></tr>
				<tr><td height="22" colspan="4">&nbsp;</td>
				</tr>
				<tr><td colspan="4">&nbsp;</td></tr>
				<tr><td colspan="4">&nbsp;</td></tr>
				<tr><td colspan="4" height="25">&nbsp;</td></tr>
				<tr><td colspan="4">&nbsp;</td></tr>
				<tr>
					<td width="58%">&nbsp;</td>
					<td align="center" class="thinborderBOTTOM" width="20%">YES</td>
					<td align="center" class="thinborderBOTTOM" width="19%">NO</td>
					<td width="3%" rowspan="2">&nbsp;</td>
				</tr>
				<tr>
					<td width="8%">Tuberculosis</td>
					<%	strTemp = WI.fillTextValue("field_38");		
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(39);		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="3%" class="thinborderBOTTOMLEFTRIGHT" align="center">
				  	<input type="radio" value="1" name="field_38" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("0") || strTemp.length() == 0)
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" class="thinborderBOTTOMRIGHT">
					<input type="radio" value="0" name="field_38" <%=strErrMsg%>></td>
				</tr>
				<tr><td colspan="4">&nbsp;</td></tr>
				<tr><td colspan="4">&nbsp;</td></tr>
				<tr><td colspan="4">&nbsp;</td></tr>
				<tr><td colspan="4">&nbsp;</td></tr>
				<tr><td colspan="4">&nbsp;</td></tr>
				<tr><td colspan="4">&nbsp;</td></tr>
				<tr><td colspan="4">&nbsp;</td></tr>
				<tr><td colspan="4">&nbsp;</td></tr>
				<tr><td colspan="4">&nbsp;</td></tr>
				<tr><td colspan="4">&nbsp;</td></tr>
				<tr>
				<%	strTemp = WI.fillTextValue("field_51");
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(52);
				%>
					<td colspan="4">If Yes, specify &nbsp;&nbsp;
					  	<input type="text" name="field_51" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
						onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="15"></td>
				</tr>
			</table>
 		</td>
 		<td width="6">&nbsp;</td>
	</tr>
	<tr>
		<td colspan="5">&nbsp;</td>
	</tr>	
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td colspan="6" height="25"> C. IMMUNIZATION</td>
  	</tr>
  	<tr>
		<td colspan="6">&nbsp;</td>
	</tr>
  	<tr>
		<td width="20%">VACCINCE</td>
		<td width="21%" class="thinborderBOTTOM">DATES</td>
		<td colspan="2">&nbsp;</td>
		<td width="24%" class="thinborderBOTTOM">DATES</td>
		<td width="10%" colspan="1" rowspan="8">&nbsp;</td>
  	</tr>
 	<tr>
		<td width="20%">BCG</td>
		<%	if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(58);
			else			
				strTemp = WI.fillTextValue("field_57_date");				
				
			//if(WI.getStrValue(strTemp).length() == 0)
			//	strTemp = WI.getTodaysDate(1);
		%>
		<td class="thinborderBOTTOMLEFTRIGHT" width="21%">
		<input name="field_57_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.field_57_date');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	    <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
		<td width="7%">&nbsp;</td>
		<td width="18%">Measles</td>
		<%	if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(59);
			else			
				strTemp = WI.fillTextValue("field_58_date");				
				
			//if(WI.getStrValue(strTemp).length() == 0)
			//	strTemp = WI.getTodaysDate(1);
		%>
		<td class="thinborderBOTTOMLEFTRIGHT" width="24%">
		<input name="field_58_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.field_58_date');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	    <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
    </tr>
	<tr>
		<td width="20%">Chiken pox</td>
		<%  if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(60);
			else			
				strTemp = WI.fillTextValue("field_59_date");				
				
			//if(WI.getStrValue(strTemp).length() == 0)
			//	strTemp = WI.getTodaysDate(1);
		%>
		<td class="thinborderBOTTOMLEFTRIGHT" width="21%">
		<input name="field_59_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.field_59_date');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	    <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
        <td>&nbsp;</td>
		<td>MMR</td>
		<%  if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(61);
			else			
				strTemp = WI.fillTextValue("field_60_date");				
				
			//if(WI.getStrValue(strTemp).length() == 0)
			//	strTemp = WI.getTodaysDate(1);
		%>
		<td class="thinborderBOTTOMLEFTRIGHT" width="24%">
		<input name="field_60_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.field_60_date');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	    <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
	</tr>
	<tr>
		<td width="20%">DPT/OPV I-III</td>
		<%  if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(62);
			else			
				strTemp = WI.fillTextValue("field_61_date");				
				
			//if(WI.getStrValue(strTemp).length() == 0)
			//	strTemp = WI.getTodaysDate(1);
		%>
		<td class="thinborderBOTTOMLEFTRIGHT" width="21%">
		<input name="field_61_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.field_61_date');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	    <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
		<td width="7%">&nbsp;</td>
		<td width="18%">Typhoid Fever</td>
		<%	if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(63);
			else			
				strTemp = WI.fillTextValue("field_62_date");				
				
			//if(WI.getStrValue(strTemp).length() == 0)
			//	strTemp = WI.getTodaysDate(1);
		%>
		<td class="thinborderBOTTOMLEFTRIGHT" width="24%">
		<input name="field_62_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.field_62_date');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	   	<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
	</tr>
	<tr>
		<td width="20%">DPT/OPV BOOSTER I-II</td>
		<%	if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(64);
			else			
				strTemp = WI.fillTextValue("field_63_date");				
				
			//if(WI.getStrValue(strTemp).length() == 0)
			//	strTemp = WI.getTodaysDate(1);
		%>
		<td class="thinborderBOTTOMLEFTRIGHT" width="24%">
		<input name="field_63_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.field_63_date');"  title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	    <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
		<td>&nbsp;</td>
		<td>Cervical Cancer</td>
		<%	if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(65);
			else			
				strTemp = WI.fillTextValue("field_64_date");				
				
			//if(WI.getStrValue(strTemp).length() == 0)
			//	strTemp = WI.getTodaysDate(1);
		%>
		<td class="thinborderBOTTOMLEFTRIGHT" width="24%">
		<input name="field_64_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.field_64_date');" title="Click to select date"
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	    <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
    </tr>
	<tr>
		<td width="20%">Hepatitis B I</td>
		<%  if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(66);
			else			
				strTemp = WI.fillTextValue("field_65_date");				
				
			//if(WI.getStrValue(strTemp).length() == 0)
			//	strTemp = WI.getTodaysDate(1);
		%>
		<td class="thinborderBOTTOMLEFTRIGHT" width="21%">
		<input name="field_65_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.field_65_date');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	    <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
        <td width="7%">&nbsp;</td>
		<td width="18%">Hepatitis A I</td>
		<%  if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(67);
			else			
				strTemp = WI.fillTextValue("field_66_date");				
				
			//if(WI.getStrValue(strTemp).length() == 0)
			//	strTemp = WI.getTodaysDate(1);
		%>
		<td class="thinborderBOTTOMLEFTRIGHT" width="24%">
		<input name="field_66_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.field_66_date');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	    <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
    </tr>
	<tr>
		<td width="20%">Hepatitis B II</td>
		<%  if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(68);
			else			
				strTemp = WI.fillTextValue("field_67_date");				
				
			//if(WI.getStrValue(strTemp).length() == 0)
			//	strTemp = WI.getTodaysDate(1);
		%>
		<td class="thinborderBOTTOMLEFTRIGHT" width="21%">
		<input name="field_67_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.field_67_date');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	    <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
        <td>&nbsp;</td>
		<td>Hepatitis A II</td>
		<%  if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(69);
			else			
				strTemp = WI.fillTextValue("field_68_date");				
				
			//if(WI.getStrValue(strTemp).length() == 0)
			//	strTemp = WI.getTodaysDate(1);
		%>
		<td class="thinborderBOTTOMLEFTRIGHT" width="24%">
		<input name="field_68_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.field_68_date');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	    <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
	</tr>
	<tr>
		<td width="20%">Hepatitis B III</td>
		<%  if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(70);
			else			
				strTemp = WI.fillTextValue("field_68_date");				
				
			//if(WI.getStrValue(strTemp).length() == 0)
			//	strTemp = WI.getTodaysDate(1);
		%>
		<td class="thinborderBOTTOMLEFTRIGHT" width="21%">
		<input name="field_69_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.field_69_date');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	    <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
        <td>&nbsp;</td>
		<td>Hepatitis A III</td>
		<%  if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(71);
			else			
				strTemp = WI.fillTextValue("field_70_date");				
				
			//if(WI.getStrValue(strTemp).length() == 0)
			//	strTemp = WI.getTodaysDate(1);
		%>
		<td class="thinborderBOTTOMLEFTRIGHT" width="24%">
		<input name="field_70_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.field_70_date');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	    <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
    </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td height="50">&nbsp;</td></tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td colspan="7" height="25" align="center"> <strong>PART 2 </strong>(To be filled up by the school physician)</td>
 	</tr>
  	<tr>
		<td colspan="7">&nbsp;</td>
	</tr>
	<tr>
		<td colspan="7">A. PSYCHOSOCIAL HISTORY</td>
	</tr>
	<tr>
		<td colspan="7">&nbsp;</td>
	</tr>
   	<tr>
		<td width="31%">&nbsp;</td>
		<td width="5%" class="thinborderBOTTOM">No</td>
		<td width="4%" class="thinborderBOTTOM">Yes</td>
		<td colspan="2">&nbsp;</td>
		<td width="8%">Details</td>
		<td width="25%">&nbsp;</td>
  	</tr>
 	<tr>
		<td width="31%">1. Do you have close friends?</td>
		<%	strTemp = WI.fillTextValue("field_71");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(72);		
				if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td class="thinborderBOTTOMLEFTRIGHT" width="5%" align="center">
			<input type="radio" value="0" name="field_71" <%=strErrMsg%>></td>
		<%	if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td class="thinborderBOTTOMRIGHT" align="center"><input type="radio" value="1" name="field_71" <%=strErrMsg%>></td>
		<td width="1%">&nbsp;</td>
		<%	strTemp = WI.fillTextValue("field_72");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(73);
		%>
		<td width="26%">Only 1? 
	  	<input type="text" name="field_72" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<td width="8%">&nbsp;</td>
		<%	strTemp = WI.fillTextValue("field_73");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(74);
		%>
		<td width="25%">More than 1 
	  	<input type="text" name="field_73" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
  	</tr>
	<tr>
		<td width="31%">2. Do yo drive?</td>
		<%	strTemp = WI.fillTextValue("field_74");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(75);		
			if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
	  	<td class="thinborderBOTTOMLEFTRIGHT" width="5%" align="center">
		<input type="radio" value="0" name="field_74" <%=strErrMsg%>></td>
		<%	if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td class="thinborderBOTTOMRIGHT" align="center"><input type="radio" value="1" name="field_74" <%=strErrMsg%>></td>
		<td>&nbsp;</td>
		<td>Regularly?</td>
		<%	strTemp = WI.fillTextValue("field_75");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(76);		
			if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="8%">Yes [<input type="radio" value="1" name="field_75" <%=strErrMsg%>>]</td>
		<%	if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="25%">No [<input type="radio" value="0" name="field_75" <%=strErrMsg%>>]</td>
	</tr>
	<tr>
		<td width="31%">3. Do you drink alcoholic beverages?</td>
		<%	strTemp = WI.fillTextValue("field_76");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(77);		
			if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
	   <td class="thinborderBOTTOMLEFTRIGHT" width="5%" align="center">
	   <input type="radio" value="0" name="field_76" <%=strErrMsg%>></td>
		<%	if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td class="thinborderBOTTOMRIGHT" align="center">
		<input type="radio" value="1" name="field_76" <%=strErrMsg%>></td>
		<td width="1%">&nbsp;</td>
		<%	strTemp = WI.fillTextValue("field_77");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(78);
		%>
		<td width="26%">How often?  
	    <input type="text" name="field_77" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<td width="8%">&nbsp;</td>
		<%	strTemp = WI.fillTextValue("field_78");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(79);
		%>
		<td width="25%">How much?  
	    <input type="text" name="field_78" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
 	</tr>
	<tr>
		<td width="31%">4. Do you smoke?</td>
		<%	strTemp = WI.fillTextValue("field_79");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(80);		
			if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
	 	<td class="thinborderBOTTOMLEFTRIGHT" width="5%" align="center">
		<input type="radio" value="0" name="field_79" <%=strErrMsg%>></td>
		<%	if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";	
		%>
		<td class="thinborderBOTTOMRIGHT" align="center"><input type="radio" value="1" name="field_79" <%=strErrMsg%>></td>
		<td>&nbsp;</td>
		<%	strTemp = WI.fillTextValue("field_80");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(81);
		%>
		<td>Sticks per day?   
		<input type="text" name="field_80" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<td width="8%">&nbsp;</td>
		<%	if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(82);
			else			
				strTemp = WI.fillTextValue("field_81_date");				
				
			//if(WI.getStrValue(strTemp).length() == 0)
			//	strTemp = WI.getTodaysDate(1);
		%>
		<td width="25%">Since when? 
		  <input name="field_81_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.getStrValue(strTemp)%>" 
		  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
          <a href="javascript:show_calendar('form_.field_81_date');" title="Click to select date" 
		  onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	  	  <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
	</tr>
	<tr>
		<td width="31%">5. Have you taken illicit drugs?</td>
		<%	strTemp = WI.fillTextValue("field_82");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(83);		
			if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
	  <td class="thinborderBOTTOMLEFTRIGHT" width="5%" align="center">
	  <input type="radio" value="0" name="field_82" <%=strErrMsg%>></td>
		<%	if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td class="thinborderBOTTOMRIGHT" align="center">
		<input type="radio" value="1" name="field_82" <%=strErrMsg%>></td>
		<td width="1%">&nbsp;</td>
 		<%	strTemp = WI.fillTextValue("field_83");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(84);
		%>
		<td colspan="3">Kind: 
	    <input type="text" name="field_83" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
	<tr>
		<td width="31%" height="22">&nbsp;</td>
		<td class="thinborderBOTTOMLEFTRIGHT" width="5%">&nbsp;</td>
		<td class="thinborderBOTTOMRIGHT">&nbsp;</td>
		<td>&nbsp;</td>
		<td>Regular use:</td>
		<%	strTemp = WI.fillTextValue("field_84");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(85);		
			if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td width="8%">No [
	    <input type="radio" value="0" name="field_84" <%=strErrMsg%>>]</td>
		<%	if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "checked";
			else
			strErrMsg = "";
		%>
		<td width="25%">Yes [
	    <input type="radio" value="1" name="field_84" <%=strErrMsg%>>]</td>
	</tr>
	<tr>
		<td width="31%">6. Experienced abuse:</td>
		<td class="thinborderBOTTOMLEFTRIGHT" width="5%">&nbsp;</td>
		<td class="thinborderBOTTOMRIGHT">&nbsp;</td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td width="8%">&nbsp;</td>
		<td width="25%">&nbsp;</td>
	</tr>
	<tr>
		<td width="31%">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Physical</td>
		<%	strTemp = WI.fillTextValue("field_85");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(86);		
			if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
	  	<td class="thinborderBOTTOMLEFTRIGHT" width="5%" align="center">
		<input type="radio" value="0" name="field_85" <%=strErrMsg%>></td>
		<%	if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td class="thinborderBOTTOMRIGHT" align="center">
		<input type="radio" value="1" name="field_85" <%=strErrMsg%>></td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td width="8%">&nbsp;</td>
		<td width="25%">&nbsp;</td>
	</tr>
	<tr>
		<td width="31%">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Sexual</td>
		<%	strTemp = WI.fillTextValue("field_86");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(87);		
			if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
	 	<td class="thinborderBOTTOMLEFTRIGHT" width="5%" align="center">
	  	<input type="radio" value="0" name="field_86" <%=strErrMsg%>></td>
		<%	if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td class="thinborderBOTTOMRIGHT" align="center">
		<input type="radio" value="1" name="field_86" <%=strErrMsg%>></td>
        <td>&nbsp;</td>
		<td>&nbsp;</td>
		<td width="8%">&nbsp;</td>
		<td width="25%">&nbsp;</td>
	</tr>
	<tr>
		<td width="31%">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Verbal</td>
		<%	strTemp = WI.fillTextValue("field_87");		
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(88);		
			if(WI.getStrValue(strTemp).equals("0") || WI.getStrValue(strTemp).length() == 0)
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
	  	<td class="thinborderBOTTOMLEFTRIGHT" width="5%" align="center">
	  	<input type="radio" value="0" name="field_87" <%=strErrMsg%>></td>
		<%	if(WI.getStrValue(strTemp).equals("1"))
				strErrMsg = "checked";
			else
				strErrMsg = "";
		%>
		<td class="thinborderBOTTOMRIGHT" align="center">
		<input type="radio" value="1" name="field_87" <%=strErrMsg%>></td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td width="8%">&nbsp;</td>
		<td width="25%">&nbsp;</td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td colspan="5">&nbsp;</td>
	</tr>
	<tr>
		<td colspan="5">B. PHYSICAL EXAMINATION</td>
	</tr>
	<tr>
		<td colspan="5">&nbsp;</td>
	</tr>
	<tr>
		<td height="30" width="16%" class="thinborderTOPLEFTBOTTOM">&nbsp;&nbsp;<strong>Date</strong></td>
		<%  if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(89);
			else			
				strTemp = WI.fillTextValue("field_88_date");				
				
			//if(WI.getStrValue(strTemp).length() == 0)
			//	strTemp = WI.getTodaysDate(1);
		%>
		<td width="20%" class="thinborderTOPLEFTBOTTOM">&nbsp;
		<input name="field_88_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.field_88_date');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	    <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
		<%	if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(90);
			else			
				strTemp = WI.fillTextValue("field_89_date");				
				
			//if(WI.getStrValue(strTemp).length() == 0)
			//	strTemp = WI.getTodaysDate(1);
		%>
		<td width="20%" class="thinborderTOPLEFTBOTTOM">&nbsp;
		<input name="field_89_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.field_89_date');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	    <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
	    <%  if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(91);
			else			
				strTemp = WI.fillTextValue("field_90_date");				
				
			//if(WI.getStrValue(strTemp).length() == 0)
			//	strTemp = WI.getTodaysDate(1);
		%>
        <td width="21%" class="thinborderTOPLEFTBOTTOM">&nbsp;
		<input name="field_90_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.field_90_date');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	    <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
		<%	if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(92);
			else			
				strTemp = WI.fillTextValue("field_91_date");				
				
			//if(WI.getStrValue(strTemp).length() == 0)
			//	strTemp = WI.getTodaysDate(1);
		%>
		<td width="23%" class="thinborderALL">&nbsp;
		<input name="field_91_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.field_91_date');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	    <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
	</tr>
	<tr>
		<td height="30" width="16%" class="thinborder">&nbsp;&nbsp;Weight</td>
		<%	strTemp = WI.fillTextValue("field_92");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(93);
		%>
		<td width="20%" class="thinborder">&nbsp; 
		<input type="text" name="field_92" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_93");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(94);
		%>
		<td width="20%" class="thinborder">&nbsp;
		<input type="text" name="field_93" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_94");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(95);
		%>
		<td width="21%" class="thinborder">&nbsp; 
		<input type="text" name="field_94" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_95");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(96);
		%>
		<td width="23%" class="thinborder">&nbsp; 
		<input type="text" name="field_95" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td height="30" width="16%" class="thinborder">&nbsp;&nbsp;Height</td>
		<%	strTemp = WI.fillTextValue("field_96");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(97);
		%>
		<td width="20%" class="thinborder">&nbsp; 
		<input type="text" name="field_96" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_97");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(98);
		%>
		<td width="20%" class="thinborder">&nbsp; 
		<input type="text" name="field_97" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_98");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(99);
		%>
		<td width="21%" class="thinborder">&nbsp; 
		<input type="text" name="field_98" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_99");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(100);
		%>
		<td width="23%" class="thinborder">&nbsp; 
		<input type="text" name="field_99" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td height="30" width="16%" class="thinborder">&nbsp;&nbsp;BP</td>
		<%	strTemp = WI.fillTextValue("field_100");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(101);
		%>
		<td width="20%" class="thinborder">&nbsp; 
		<input type="text" name="field_100" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_101");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(102);
		%>
		<td width="20%" class="thinborder">&nbsp; 
		<input type="text" name="field_101" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_102");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(103);
		%>
		<td width="21%" class="thinborder">&nbsp; 
		<input type="text" name="field_102" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_103");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(104);
		%>
		<td width="23%" class="thinborder">&nbsp; 
		<input type="text" name="field_103" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td height="30" width="16%" class="thinborder">&nbsp;&nbsp;Pulse</td>
		<%	strTemp = WI.fillTextValue("field_104");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(105);
		%>
		<td width="20%" class="thinborder">&nbsp; 
		<input type="text" name="field_104" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_105");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(106);
		%>
		<td width="20%" class="thinborder">&nbsp; 
		<input type="text" name="field_105" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_106");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(107);
		%>
		<td width="21%" class="thinborder">&nbsp; 
		<input type="text" name="field_106" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_107");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(108);
		%>
		<td width="23%" class="thinborder">&nbsp; 
		<input type="text" name="field_107" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td height="30" width="16%" class="thinborder">&nbsp;&nbsp;Skin</td>
		<%	strTemp = WI.fillTextValue("field_108");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(109);
		%>
		<td width="20%" class="thinborder">&nbsp; 
		<input type="text" name="field_108" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_109");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(110);
		%>
		<td width="20%" class="thinborder">&nbsp;
		<input type="text" name="field_109" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_110");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(111);
		%>
		<td width="21%" class="thinborder">&nbsp; 
		<input type="text" name="field_110" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_111");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(112);
		%>
		<td width="23%" class="thinborder">&nbsp; 
		<input type="text" name="field_111" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td height="30" width="16%" class="thinborder">&nbsp;&nbsp;Head</td>
		<%	strTemp = WI.fillTextValue("field_112");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(113);
		%>
		<td width="20%" class="thinborder">&nbsp;
		<input type="text" name="field_112" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_113");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(114);
		%>
		<td width="20%" class="thinborder">&nbsp;
		<input type="text" name="field_113" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_114");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(115);
		%>
		<td width="21%" class="thinborder">&nbsp; 
		<input type="text" name="field_114" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_115");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(116);
		%>
		<td width="23%" class="thinborder">&nbsp; 
		<input type="text" name="field_115" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td height="30" width="16%" class="thinborder">&nbsp;&nbsp;Eyes</td>
		<%	strTemp = WI.fillTextValue("field_116");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(117);
		%>
		<td width="20%" class="thinborder">&nbsp; 
		<input type="text" name="field_116" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_117");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(118);
		%>
		<td width="20%" class="thinborder">&nbsp; 
		<input type="text" name="field_117" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_118");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(119);
		%>
		<td width="21%" class="thinborder">&nbsp; 
		<input type="text" name="field_118" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_119");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(120);
		%>
		<td width="23%" class="thinborder">&nbsp; 
		<input type="text" name="field_119" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td height="30" width="16%" class="thinborder">&nbsp;&nbsp;Vision</td>
		<%	strTemp = WI.fillTextValue("field_120");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(121);
		%>
		<td width="20%" class="thinborder">&nbsp; 
		<input type="text" name="field_120" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_121");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(122);
		%>
		<td width="20%" class="thinborder">&nbsp; 
		<input type="text" name="field_121" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_122");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(123);
		%>
		<td width="21%" class="thinborder">&nbsp; 
		<input type="text" name="field_122" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_123");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(124);
		%>
		<td width="23%" class="thinborder">&nbsp; 
		<input type="text" name="field_123" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td height="30" width="16%" class="thinborder">&nbsp;&nbsp;Ears</td>
		<%	strTemp = WI.fillTextValue("field_124");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(125);
		%>
		<td width="20%" class="thinborder">&nbsp; 
		<input type="text" name="field_124" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_125");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(126);
		%>
		<td width="20%" class="thinborder">&nbsp; 
		<input type="text" name="field_125" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_126");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(127);
		%>
		<td width="21%" class="thinborder">&nbsp; 
		<input type="text" name="field_126" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_127");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(128);
		%>
		<td width="23%" class="thinborder">&nbsp; 
		<input type="text" name="field_127" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td height="30" width="16%" class="thinborder">&nbsp;&nbsp;Hearing</td>
		<%	strTemp = WI.fillTextValue("field_128");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(129);
		%>
		<td width="20%" class="thinborder">&nbsp; 
		<input type="text" name="field_128" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_129");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(130);
		%>
		<td width="20%" class="thinborder">&nbsp; 
		<input type="text" name="field_129" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_130");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(131);
		%>
		<td width="21%" class="thinborder">&nbsp; 
		<input type="text" name="field_130" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_131");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(132);
		%>
		<td width="23%" class="thinborder">&nbsp; 
		<input type="text" name="field_131" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td height="30" width="16%" class="thinborder">&nbsp;&nbsp;Nose</td>
		<%	strTemp = WI.fillTextValue("field_132");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(133);
		%>
		<td width="20%" class="thinborder">&nbsp; 
		<input type="text" name="field_132" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_133");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(134);
		%>
		<td width="20%" class="thinborder">&nbsp; 
		<input type="text" name="field_133" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_134");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(135);
		%>
		<td width="21%" class="thinborder">&nbsp; 
		<input type="text" name="field_134" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_135");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(136);
		%>
		<td width="23%" class="thinborder">&nbsp; 
		<input type="text" name="field_135" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td height="30" width="16%" class="thinborder">&nbsp;&nbsp;Throat</td>
		<%	strTemp = WI.fillTextValue("field_136");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(137);
		%>
		<td width="20%" class="thinborder">&nbsp; 
		<input type="text" name="field_136" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_137");
			if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(138);
		%>
		<td width="20%" class="thinborder">&nbsp; 
		<input type="text" name="field_137" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_138");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(139);
		%>
		<td width="21%" class="thinborder">&nbsp; 
		<input type="text" name="field_138" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_139");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(140);
		%>
		<td width="23%" class="thinborder">&nbsp; 
		<input type="text" name="field_139" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td height="30" width="16%" class="thinborder">&nbsp;&nbsp;Mouth</td>
		<%	strTemp = WI.fillTextValue("field_140");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(141);
		%>
		<td width="20%" class="thinborder">&nbsp; 
		<input type="text" name="field_140" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_141");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(142);
		%>
		<td width="20%" class="thinborder">&nbsp; 
		<input type="text" name="field_141" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_142");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(143);
		%>
		<td width="21%" class="thinborder">&nbsp; 
		<input type="text" name="field_142" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_143");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(144);
		%>
		<td width="23%" class="thinborder">&nbsp; 
		<input type="text" name="field_143" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td height="30" width="16%" class="thinborder">&nbsp;&nbsp;Gums</td>
		<%	strTemp = WI.fillTextValue("field_144");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(145);
		%>
		<td width="20%" class="thinborder">&nbsp; 
		<input type="text" name="field_144" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_145");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(146);
		%>
		<td width="20%" class="thinborder">&nbsp;
		<input type="text" name="field_145" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_146");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(147);
		%>
		<td width="21%" class="thinborder">&nbsp; 
		<input type="text" name="field_146" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_147");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(148);
		%>
		<td width="23%" class="thinborder">&nbsp; 
		<input type="text" name="field_147" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td height="30" width="16%" class="thinborder">&nbsp;&nbsp;Neck</td>
		<%	strTemp = WI.fillTextValue("field_148");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(149);
		%>
		<td width="20%"  class="thinborder">&nbsp;
		<input type="text" name="field_148" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_149");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(150);
		%>
		<td width="20%" class="thinborder">&nbsp;
		<input type="text" name="field_149" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_150");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(151);
		%>
		<td width="21%" class="thinborder">&nbsp; 
		<input type="text" name="field_150" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_151");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(152);
		%>
		<td width="23%" class="thinborder">&nbsp; 
		<input type="text" name="field_151" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td height="30" width="16%" class="thinborder">&nbsp;&nbsp;Chest</td>
		<%	strTemp = WI.fillTextValue("field_152");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(153);
		%>
		<td width="20%"  class="thinborder">&nbsp; 
		<input type="text" name="field_152" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_153");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(154);
		%>
		<td width="20%" class="thinborder">&nbsp; 
		<input type="text" name="field_153" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_154");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(155);
		%>
		<td width="21%" class="thinborder">&nbsp; 
		<input type="text" name="field_154" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_155");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(156);
		%>
		<td width="23%" class="thinborder">&nbsp; 
		<input type="text" name="field_155" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td height="30" width="16%" class="thinborder">&nbsp;&nbsp;Lungs</td>
		<%	strTemp = WI.fillTextValue("field_156");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(157);
		%>
		<td width="20%"  class="thinborder">&nbsp; 
		<input type="text" name="field_156" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_157");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(158);
		%>
		<td width="20%" class="thinborder">&nbsp; 
		<input type="text" name="field_157" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_158");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(159);
		%>
		<td width="21%" class="thinborder">&nbsp; 
		<input type="text" name="field_158" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_159");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(160);
		%>
		<td width="23%" class="thinborder">&nbsp; 
		<input type="text" name="field_159" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td height="30" width="16%" class="thinborder">&nbsp;&nbsp;Abdomen</td>
		<%	strTemp = WI.fillTextValue("field_160");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(161);
		%>
		<td width="20%"  class="thinborder">&nbsp; 
		<input type="text" name="field_160" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_161");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(162);
		%>
		<td width="20%" class="thinborder">&nbsp;
		<input type="text" name="field_161" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_162");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(163);
		%>
		<td width="21%" class="thinborder">&nbsp; 
		<input type="text" name="field_162" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_163");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(164);
		%>
		<td width="23%" class="thinborder">&nbsp; 
		<input type="text" name="field_163" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td height="30" width="16%" class="thinborder">&nbsp;&nbsp;Limbs</td>
		<%	strTemp = WI.fillTextValue("field_164");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(165);
		%>
		<td width="20%"  class="thinborder">&nbsp; 
		<input type="text" name="field_164" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_165");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(166);
		%>
		<td width="20%" class="thinborder">&nbsp;
		<input type="text" name="field_165" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_166");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(167);
		%>
		<td width="21%" class="thinborder">&nbsp; 
		<input type="text" name="field_166" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_167");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(168);
		%>
		<td width="23%" class="thinborder">&nbsp; 
		<input type="text" name="field_167" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td height="30" width="16%"  class="thinborder">&nbsp;&nbsp;Neuro</td>
		<%	strTemp = WI.fillTextValue("field_168");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(169);
		%>
		<td width="20%" class="thinborder">&nbsp; 
		<input type="text" name="field_168" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_169");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(170);
		%>
		<td width="20%" class="thinborder">&nbsp; 
		<input type="text" name="field_169" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_170");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(171);
		%>
		<td width="21%" class="thinborder">&nbsp; 
		<input type="text" name="field_170" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_171");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(172);
		%>
		<td width="23%" class="thinborder">&nbsp; 
		<input type="text" name="field_171" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td height="30" width="16%" class="thinborder">&nbsp;&nbsp;Tanner's</td>
		<%	strTemp = WI.fillTextValue("field_172");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(173);
		%>
		<td width="20%" class="thinborder">&nbsp; 
		<input type="text" name="field_172" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_173");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(174);
		%>
		<td width="20%" class="thinborder">&nbsp;
		<input type="text" name="field_173" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_174");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(175);
		%>
		<td width="21%" class="thinborder">&nbsp; 
		<input type="text" name="field_174" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		<%	strTemp = WI.fillTextValue("field_175");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(176);
		%>
		<td width="23%" class="thinborder">&nbsp; 
		<input type="text" name="field_175" value="<%=WI.getStrValue(strTemp)%>" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	<tr>
		<td colspan="5" height="20">&nbsp;</td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<Td colspan="3">&nbsp;</Td>
	</tr>
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
	<input type="hidden" name="no_of_fields" value="179" > <!-- get the last number of fields; used in java -->
	<input type="hidden" name="save_entry" >
	<input type="hidden" name="search_" >
	
	<input type="hidden" name="page_action">
	<input type="hidden" name="reload_page">
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="view_fields" value="<%=strViewFields%>">
	<input type="hidden" name="print_page" >
	<input type="hidden" name="vDate" value="57,58,59,60,61,62,63,64,65,66,67,68,69,70,81,88,89,90,91">
	<input type="hidden" name="edu_level" value="3" ><!---HIGH SCHOOL ONLY--->
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
