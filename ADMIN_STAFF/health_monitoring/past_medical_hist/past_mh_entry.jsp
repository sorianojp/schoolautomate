<%@ page language="java" import="utility.*,health.RecordHealthInformation,java.util.Vector " %>
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
<title>Patient Health Status..</title>
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

	function UpdateBG() {
		if(document.form_.stud_id.value.length == 0) {
			alert("Please enter student ID.");
			return;
		}
	
		var loadPg = "./blood_group.jsp?stud_id="+escape(document.form_.stud_id.value);
		var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
	
	function FocusID() {
		document.form_.stud_id.focus();
	}
	
	function ReloadPage() {
		document.form_.view_fields.value = "";
		document.form_.prepareToEdit.value = "";
		document.form_.reload_page.value = "1";
		document.form_.page_action.value = "";
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
	
	function EmpSearch() {
		var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.stud_id";
		var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
	
	function PrepareToEdit(strInfoIndex) {
		document.form_.view_fields.value = "1";
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "1";
		document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
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

	boolean bolNoRecord = true; //it is false if there is error in edit info.
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	String strViewFields = WI.getStrValue(WI.fillTextValue("view_fields"),"0");

	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-PAST MEDICAL HISTORY","past_mh_entry.jsp");
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
															"Health Monitoring","PAST MEDICAL HISTORY",request.getRemoteAddr(),
															"past_mh_entry.jsp");
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
	
	Vector vBasicInfo = null; Vector vHealthInfo = null; Vector vAdditionalInfo = null;
	Vector vLTInfo    = null; Vector vUTestInfo  = null; Vector vRecords = null;
	boolean bolIsStaff = false;
	boolean bolIsStudEnrolled = false;//true only if enrolled to current sy / sem.
	enrollment.OfflineAdmission OAdm = new enrollment.OfflineAdmission();
	RecordHealthInformation RH = new RecordHealthInformation();
	
	//get all levels created.
	if(WI.fillTextValue("stud_id").length() > 0) {	
		strTemp = dbOP.mapUIDToUIndex(WI.fillTextValue("stud_id"));
		if(strTemp == null)
			strErrMsg = "ID number does not exist or is invalidated.";
	}
	
	//if(WI.fillTextValue("stud_id").length() > 0) {	
	if(strTemp != null){
		if(bolIsSchool)
			vBasicInfo = OAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"));
			
		if(vBasicInfo == null) //may be it is the teacher/staff
		{
			request.setAttribute("emp_id",request.getParameter("stud_id"));
			vBasicInfo = new enrollment.Authentication().operateOnBasicInfo(dbOP, request,"0");
			if(vBasicInfo != null)
				bolIsStaff = true;
		}
		else if(bolIsSchool) {//check if student is currently enrolled
			Vector vTempBasicInfo = OAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"),
			(String)vBasicInfo.elementAt(10),(String)vBasicInfo.elementAt(11),(String)vBasicInfo.elementAt(9));
			if(vTempBasicInfo != null)
				bolIsStudEnrolled = true;
		}
		if(vBasicInfo == null)
			strErrMsg = OAdm.getErrMsg();
	}
	
	//gets health info.
	if(vBasicInfo!= null) {
		strTemp = WI.fillTextValue("page_action");
		if(strTemp.length() > 0){
			//I have to add / edit here.
			if(RH.operateOnPastHealthInfo(dbOP, request, Integer.parseInt(strTemp)) == null)
				strErrMsg = RH.getErrMsg();
			else{
				if(strTemp.equals("0"))
					strErrMsg = "Health Record successfully removed.";
				if(strTemp.equals("1"))
					strErrMsg = "Health Record successfully recorded.";
				if(strTemp.equals("2"))
					strErrMsg = "Health Record successfully edited.";
					
				strPrepareToEdit = "0";
				strViewFields = "0";
			}
		}
		
		if(strPrepareToEdit.equals("1")) 
			vHealthInfo = RH.operateOnPastHealthInfo(dbOP, request,4);
		else{
			if(strViewFields.equals("1"))
				vHealthInfo = RH.operateOnPastHealthInfo(dbOP, request,3);
			else
				vHealthInfo = null;
		}
		
		if(vHealthInfo == null){
			if(strViewFields.equals("1"))
				strErrMsg = RH.getErrMsg();
		}
		else {
			if(strPrepareToEdit.equals("1")) 
				bolIsEdit = true;
			vAdditionalInfo = (Vector)vHealthInfo.elementAt(0);
			vLTInfo = (Vector)vHealthInfo.elementAt(1);
			if(vLTInfo == null)
				strErrMsg = RH.getErrMsg();
			vUTestInfo = (Vector)vHealthInfo.elementAt(2);
			if(vUTestInfo == null)
				strErrMsg = RH.getErrMsg();
			else if(vUTestInfo.size() == 0)
				vUTestInfo = null;
			
			if(vAdditionalInfo.size() == 0)
				vAdditionalInfo = null;
		}
		
		vRecords = RH.operateOnPastHealthInfo(dbOP, request, 5);
		if(vRecords == null && strViewFields.equals("0") && WI.fillTextValue("page_action").length() == 0)
			strErrMsg = RH.getErrMsg();
	}
%>
<form action="past_mh_entry.jsp" method="post" name="form_">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="28" colspan="6" bgcolor="#697A8F" class="footerDynamic"><div align="center">
				<font color="#FFFFFF" ><strong>:::: PAST MEDICAL RECORD ENTRY PAGE ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" colspan="6">&nbsp;&nbsp;&nbsp;&nbsp;
				<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
	    </tr>
		<tr>
			<td width="2%">&nbsp;</td>
			<td width="15%">Enter ID No. :</td>
			<td width="20%">
				<input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
					 onKeyUp="AjaxMapName('1');"></td>
			<td colspan="2" >
				<%if(bolIsSchool){%>
					<a href="javascript:StudSearch();"><img src="../../../images/search.gif" border="0" ></a>
						<font size="1">Click to search for student </font>
				<%}%>
				<a href="javascript:EmpSearch();"><img src="../../../images/search.gif" border="0" ></a>
					<font size="1"> Click to search for employee </font>
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
			<td><a href="javascript:RefreshPage('');"><img src="../../../images/form_proceed.gif" border="0"></a></td>
			<td colspan="3" ><a href="javascript:RefreshPage('1');">Click to create new record.</a></td>
		</tr>
	</table>
	
<%if(vBasicInfo != null){%>
	<table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
		<tr>
			<td height="15"><hr size="1"></td>
		</tr>
	</table>

	<%if(strViewFields.equals("1")){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Effective Date: </td>
		    <td colspan="4">
				<%
					if(vAdditionalInfo != null)
						strTemp = (String)vAdditionalInfo.elementAt(7);
					else
						strTemp = WI.fillTextValue("date_fr");
						
					if(strTemp.length() == 0)
						strTemp = WI.getTodaysDate(1);
				%>
        			<input name="date_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
						class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        			<a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" 
						onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
					<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></font>
				-
				<%
					if(vAdditionalInfo != null)
						strTemp = (String)vAdditionalInfo.elementAt(8);
					else
						strTemp = WI.fillTextValue("date_to");
						
					if(strTemp.length() ==0)
						strTemp = WI.getTodaysDate(1);
				%>
        			<input name="date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
						class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        			<a href="javascript:show_calendar('form_.date_to');" title="Click to select date" 
						onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
					<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></font></td>
	    </tr>
		<tr>
			<td>&nbsp;</td>
			<td>Date Recorded: </td>
			<td><font size="1">
				<%
					if(vAdditionalInfo != null)
						strTemp = (String)vAdditionalInfo.elementAt(0);
					else
						strTemp = WI.fillTextValue("date_recorded");
						
					if(strTemp.length() == 0)
						strTemp = WI.getTodaysDate(1);
				%>
        		<input name="date_recorded" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        		<a href="javascript:show_calendar('form_.date_recorded');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></font></td>
      		<td valign="top" >
				<table width="100%" border="1" cellpadding="0" cellspacing="0" bordercolor="#B0B0FF">
					<tr>
         				<td><font size="1">Record Last Updated :
              				<%if(vAdditionalInfo != null){%>
            					<%=(String)vAdditionalInfo.elementAt(5)%>
            				<%}%>
            				<br><br>
							</font><font size="1">Updated by :
							<%if(vAdditionalInfo != null){%>
								<%=(String)vAdditionalInfo.elementAt(6)%>
							<%}%>
							</font></td>
					</tr>
				</table></td>
      		<td valign="top" >&nbsp;</td>
		</tr>
		<tr>
			<td height="15" width="2%">&nbsp;</td>
		    <td width="15%">&nbsp;</td>
		    <td width="40%">&nbsp;</td>
		    <td width="40%">&nbsp;</td>
			<td width="3%">&nbsp;</td>
		</tr>
	</table>
	<%}%>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<%if(!bolIsStaff){%>
		<tr >
			<td  width="2%" height="25">&nbsp;</td>
			<td width="15%" >Student Name : </td>
			<td width="46%" >
				<%=WebInterface.formatName((String)vBasicInfo.elementAt(0), (String)vBasicInfo.elementAt(1),(String)vBasicInfo.elementAt(2),4)%></td>
			<td width="13%" >Status : </td>
			<td width="24%" > 
				<%if(bolIsStudEnrolled){%>
					Currently Enrolled
				<%}else{%>
					Not Currently Enrolled
				<%}%>			</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Course/Major :</td>
			<td colspan="3" ><%=(String)vBasicInfo.elementAt(7)%> <%=WI.getStrValue((String)vBasicInfo.elementAt(8),"/","","")%></td>
		</tr>
		<tr >
			<td height="25">&nbsp;</td>
			<td>Year :</td>
			<td><%=WI.getStrValue((String)vBasicInfo.elementAt(14),"N/A")%></td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
		</tr>
		<%}//if not staff
		else{%>
		<tr >
			<td height="25">&nbsp;</td>
			<td>Emp. Name :</td>
			<td><strong><%=WebInterface.formatName((String)vBasicInfo.elementAt(1),(String)vBasicInfo.elementAt(2),(String)vBasicInfo.elementAt(3),4)%></strong></td>
			<td>Emp. Status :</td>
			<td><strong><%=(String)vBasicInfo.elementAt(16)%></strong></td>
		</tr>
		<tr >
			<td height="25">&nbsp;</td>
			<td ><%if(bolIsSchool){%>College/Office<%}else{%>Division<%}%> :</td>
			<td ><strong><%=WI.getStrValue(vBasicInfo.elementAt(13))%>/ <%=WI.getStrValue(vBasicInfo.elementAt(14))%></strong></td>
			<td >Designation :</td>
			<td ><strong><%=(String)vBasicInfo.elementAt(15)%></strong></td>
		</tr>
		<%}//only if staff %>
	</table>
<%}///only if vBasicInfo is not null

if(vBasicInfo != null && vHealthInfo != null && WI.fillTextValue("view_fields").equals("1")){%>

	<table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#FFFF9F">
			<td width="38%" height="25">&nbsp;</td>
			<td width="7%"><div align="center">Yes</div></td>
			<td width="7%"><div align="center">No</div></td>
			<td width="48%">Remark</td>
		</tr>
		<%
			int j = 0 ;
			for(int i = 3 ; i < vHealthInfo.size(); i += 4, ++j){
				if(bolIsEdit)
					strTemp = WI.getStrValue((String)vHealthInfo.elementAt(i + 2),"0");
				else
					strTemp = WI.getStrValue(WI.fillTextValue("health_info"+j), "0");
		%>		
		<input type="hidden" name="HM_ENTRY_INDEX<%=j%>" value="<%=(String)vHealthInfo.elementAt(i)%>">
		<tr>
			<td height="25"><%=(String)vHealthInfo.elementAt(i + 1)%></td>
			<td><div align="center">
				<%
				if(strTemp.equals("1"))
					strTemp = " checked";
				else
					strTemp = "";
				%>
				<input type="radio" name="health_info<%=j%>" value="1"<%=strTemp%>></div></td>
			<td><div align="center">
				<%
				if(strTemp.length() > 0)
					strTemp = "";
				else
					strTemp = " checked";
				%>
          		<input type="radio" name="health_info<%=j%>" value="0"<%=strTemp%>></div></td>
			<td>
				<%
				strTemp = null;
				if(vHealthInfo != null)
					strTemp = (String)vHealthInfo.elementAt(i + 3);
				if(strTemp == null)
					strTemp = WI.fillTextValue("remark"+j);
				%>
				<input name="remark<%=j%>" type="text" size="30" value="<%=strTemp%>" class="textbox" maxlength="256"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
	<%}//end of for loop%>
	<input type="hidden" name="health_record_count" value="<%=j%>">
	</table>
	
	<table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr valign="bottom"  >
			<td height="25">Surgical Operations (pls specify) :</td>
		</tr>
		<tr>
			<td height="25">
				<%
					strTemp = null;
					if(vAdditionalInfo != null)
						strTemp = (String)vAdditionalInfo.elementAt(1);
					if(strTemp == null)
						strTemp = WI.fillTextValue("SURGICAL_OPERATION");
				%>
				<input name="SURGICAL_OPERATION" type="text" size="85" value="<%=strTemp%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	  </tr>
		<tr valign="bottom"  >
			<td height="25">Last hospitalization Date: <font size="1">
				<%
					strTemp = null;
					if(vAdditionalInfo != null)
						strTemp = (String)vAdditionalInfo.elementAt(2);
					if(strTemp == null)
						strTemp = WI.fillTextValue("LAST_HOS_DATE");
				%>
				<input name="LAST_HOS_DATE" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
					class="textbox"	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				<a href="javascript:show_calendar('form_.LAST_HOS_DATE');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></font></td>
		</tr>
		<tr valign="bottom"  >
			<td height="25">Hospitalization Reason :&nbsp;&nbsp;
				<%
					strTemp = null;
					if(vAdditionalInfo != null)
						strTemp = (String)vAdditionalInfo.elementAt(3);
					if(strTemp == null)
						strTemp = WI.fillTextValue("HOS_REASON");
				%>
				<input name="HOS_REASON" type="text" size="50" value="<%=strTemp%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr valign="bottom"  >
			<td height="25">Others (pls specify) : </td>
		</tr>
		<tr>
			<td height="25">
			<%
				strTemp = null;
				if(vAdditionalInfo != null)
					strTemp = (String)vAdditionalInfo.elementAt(4);
				if(strTemp == null)
					strTemp = WI.fillTextValue("OTHERS");
			%>
				<input name="OTHERS" type="text" size="85" value="<%=strTemp%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
	</table>
	
<%if(vLTInfo != null && vLTInfo.size() > 0){%>
	<table width="100%" border="0" cellpadding="3" cellspacing="1" bgcolor="#808080">
		<tr bgcolor="#FFFF9F">
			<td width="36%" height="25"><strong>Last Taken</strong></td>
			<td width="23%"><div align="center"><strong>Date</strong></div></td>
			<td width="41%"><strong>Result/Remarks</strong></td>
		</tr>
		<%
			j = 0;
			for(int i = 0 ; i < vLTInfo.size() ; i+= 4, ++j) {%>
		<input type="hidden" name="HM_ENTRY_INDEX_LT<%=j%>" value="<%=(String)vLTInfo.elementAt(i)%>">
		<tr bgcolor="#FFFFFF">
			<td height="25"><%=(String)vLTInfo.elementAt(i+1)%></td>
			<td><div align="center"><font size="1">
				<%
				strTemp = null;
				if(vLTInfo != null)
					strTemp = (String)vLTInfo.elementAt(i + 2);
				if(strTemp == null)
					strTemp = WI.fillTextValue("date_taken_lt"+j);
				%>
					<input name="date_taken_lt<%=j%>" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" 
						class="textbox"	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
					<a href="javascript:show_calendar('form_.date_taken_lt<%=j%>');" title="Click to select date" 
						onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
					<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></font></div></td>
			<td>
				<%
					strTemp = null;
					if(vLTInfo != null)
						strTemp = (String)vLTInfo.elementAt(i + 3);
					if(strTemp == null)
						strTemp = WI.fillTextValue("result_lt"+j);
				%>
				<input name="result_lt<%=j%>" type="text" size="20" value="<%=strTemp%>" class="textbox" maxlength="256"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<%}//end of for loop%>
		<input type="hidden" name="lt_count" value="<%=j%>">
		<tr bgcolor="#FFFFFF">
			<td height="25">&nbsp;</td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
		</tr>
	</table>
<%}//only if vLTInfo is not null%>

	<table width="100%" border="0" cellpadding="3" cellspacing="1" bgcolor="#808080">
		<tr bgcolor="#FFFFFF">
			<td height="25" colspan="2"><strong>Urine Test (Quantitative Analysis)</strong></td>
			<td width="31%">Date : <font size="1">
				<%
					if(vUTestInfo != null)
						strTemp = (String)vUTestInfo.elementAt(20);
					else
						strTemp = WI.fillTextValue("UT_DATE");
					if(strTemp.length() ==0)
						strTemp = WI.getTodaysDate(1);
				%>
				<input name="UT_DATE" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				<a href="javascript:show_calendar('form_.UT_DATE');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></font></td>
		</tr>
		<tr bgcolor="#FFFFFF">
			<td width="57%" height="25">&nbsp;</td>
			<td width="12%"><div align="center"><strong>Normal/Negative<br><font size="1">(Specific Value)</font></strong></div></td>
			<td><div align="center"><strong>Not Normal/ Positive<br><font size="1">(Specific Value)</font></strong></div></td>
		</tr>
		<tr bgcolor="#FFFFFF">
			<td height="25">Urobilinogen</td>
			<td>
				<%
					if(vUTestInfo != null)
						strTemp = WI.getStrValue(vUTestInfo.elementAt(0));
					else
						strTemp = WI.fillTextValue("UROBIL_NORMAL");
				%>
				<input name="UROBIL_NORMAL" type="text" size="12" value="<%=strTemp%>" class="textbox" maxlength="24"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
			<td>
			<%
				if(vUTestInfo != null)
					strTemp = WI.getStrValue(vUTestInfo.elementAt(1));
				else
					strTemp = WI.fillTextValue("UROBIL_NOTNORMAL");
			%>
			<input name="UROBIL_NOTNORMAL" type="text" size="12" value="<%=strTemp%>" class="textbox" maxlength="24"
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr bgcolor="#FFFFFF">
			<td height="25">Glucose</td>
			<td>
				<%
					if(vUTestInfo != null)
						strTemp = WI.getStrValue(vUTestInfo.elementAt(2));
					else
						strTemp = WI.fillTextValue("GLUCOSE_NORMAL");
				%>
				<input name="GLUCOSE_NORMAL" type="text" size="12" value="<%=strTemp%>" class="textbox" maxlength="24"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
			<td>
				<%
					if(vUTestInfo != null)
						strTemp = WI.getStrValue(vUTestInfo.elementAt(3));
					else
						strTemp = WI.fillTextValue("GLUCOSE_NOTNORMAL");
				%>
				<input name="GLUCOSE_NOTNORMAL" type="text" size="12" value="<%=strTemp%>" class="textbox" maxlength="24"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr bgcolor="#FFFFFF">
			<td height="25">Ketones</td>
			<td>
				<%
					if(vUTestInfo != null)
						strTemp = WI.getStrValue(vUTestInfo.elementAt(4));
					else
						strTemp = WI.fillTextValue("KETONES_NORMAL");
				%>
				<input name="KETONES_NORMAL" type="text" size="12" value="<%=strTemp%>" class="textbox" maxlength="24"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
			<td>
				<%
					if(vUTestInfo != null)
						strTemp = WI.getStrValue(vUTestInfo.elementAt(5));
					else
						strTemp = WI.fillTextValue("KETONES_NOTNORMAL");
				%>
				<input name="KETONES_NOTNORMAL" type="text" size="12" value="<%=strTemp%>" class="textbox" maxlength="24"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr bgcolor="#FFFFFF">
			<td height="25">Bilirubin</td>
			<td>
				<%
				if(vUTestInfo != null)
					strTemp = WI.getStrValue(vUTestInfo.elementAt(6));
				else
					strTemp = WI.fillTextValue("BILIRUBIN_NORMAL");
				%>
				<input name="BILIRUBIN_NORMAL" type="text" size="12" value="<%=strTemp%>" class="textbox" maxlength="24"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
			<td>
			<%
				if(vUTestInfo != null)
					strTemp = WI.getStrValue(vUTestInfo.elementAt(7));
				else
					strTemp = WI.fillTextValue("BILIRUBIN_NOTNORMAL");
			%>
			<input name="BILIRUBIN_NOTNORMAL" type="text" size="12" value="<%=strTemp%>" class="textbox" maxlength="24"
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr bgcolor="#FFFFFF">
			<td height="25">Protein</td>
			<td>
				<%
					if(vUTestInfo != null)
						strTemp = WI.getStrValue(vUTestInfo.elementAt(8));
					else
						strTemp = WI.fillTextValue("PROTEIN_NORMAL");
				%>
				<input name="PROTEIN_NORMAL" type="text" size="12" value="<%=strTemp%>" class="textbox" maxlength="24"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
			<td>
				<%
					if(vUTestInfo != null)
						strTemp = WI.getStrValue(vUTestInfo.elementAt(9));
					else
						strTemp = WI.fillTextValue("PROTEIN_NOTNORMAL");
				%>
				<input name="PROTEIN_NOTNORMAL" type="text" size="12" value="<%=strTemp%>" class="textbox" maxlength="24"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr bgcolor="#FFFFFF">
			<td height="25">Nitrite</td>
			<td>
				<%
					if(vUTestInfo != null)
						strTemp = WI.getStrValue(vUTestInfo.elementAt(10));
					else
						strTemp = WI.fillTextValue("NITRITE_NORMAL");
				%>
				<input name="NITRITE_NORMAL" type="text" size="12" value="<%=strTemp%>" class="textbox" maxlength="24"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
			<td>
				<%
					if(vUTestInfo != null)
						strTemp = WI.getStrValue(vUTestInfo.elementAt(11));
					else
						strTemp = WI.fillTextValue("NITRITE_NOTNORMAL");
				%>
				<input name="NITRITE_NOTNORMAL" type="text" size="12" value="<%=strTemp%>" class="textbox" maxlength="24"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr bgcolor="#FFFFFF">
			<td height="25">pH</td>
			<td>
				<%
					if(vUTestInfo != null)
						strTemp = WI.getStrValue(vUTestInfo.elementAt(12));
					else
						strTemp = WI.fillTextValue("PH_NORMAL");
				%>
				<input name="PH_NORMAL" type="text" size="12" value="<%=strTemp%>" class="textbox" maxlength="24"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
			<td>
				<%
					if(vUTestInfo != null)
						strTemp = WI.getStrValue(vUTestInfo.elementAt(13));
					else
						strTemp = WI.fillTextValue("PH_NOTNORMAL");
				%>
				<input name="PH_NOTNORMAL" type="text" size="12" value="<%=strTemp%>" class="textbox" maxlength="24"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr bgcolor="#FFFFFF">
			<td height="25">Blood</td>
			<td>
				<%
					if(vUTestInfo != null)
						strTemp = WI.getStrValue(vUTestInfo.elementAt(14));
					else
						strTemp = WI.fillTextValue("BLOOD_NORMAL");
				%>
				<input name="BLOOD_NORMAL" type="text" size="12" value="<%=strTemp%>" class="textbox" maxlength="24"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
			<td>
				<%
					if(vUTestInfo != null)
						strTemp = WI.getStrValue(vUTestInfo.elementAt(15));
					else
						strTemp = WI.fillTextValue("BLOOD_NOTNORMAL");
				%>
				<input name="BLOOD_NOTNORMAL" type="text" size="12" value="<%=strTemp%>" class="textbox" maxlength="24"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr bgcolor="#FFFFFF">
			<td height="25">Specific Gravity</td>
			<td>
				<%
					if(vUTestInfo != null)
						strTemp = WI.getStrValue(vUTestInfo.elementAt(16));
					else
						strTemp = WI.fillTextValue("SP_GRAVITY_NORMAL");
				%>
				<input name="SP_GRAVITY_NORMAL" type="text" size="12" value="<%=strTemp%>" class="textbox" maxlength="24"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
			<td>
				<%
					if(vUTestInfo != null)
						strTemp = WI.getStrValue(vUTestInfo.elementAt(17));
					else
						strTemp = WI.fillTextValue("SP_GRAVITY_NOTNORMAL");
				%>
				<input name="SP_GRAVITY_NOTNORMAL" type="text" size="12" value="<%=strTemp%>" class="textbox" maxlength="24"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr bgcolor="#FFFFFF">
			<td height="25">Leukocytes</td>
			<td>
				<%
					if(vUTestInfo != null)
						strTemp = WI.getStrValue(vUTestInfo.elementAt(18));
					else
						strTemp = WI.fillTextValue("LEUKO_NORMAL");
				%>
				<input name="LEUKO_NORMAL" type="text" size="12" value="<%=strTemp%>" class="textbox" maxlength="24"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
			<td>
				<%
					if(vUTestInfo != null)
						strTemp = WI.getStrValue(vUTestInfo.elementAt(19));
					else
						strTemp = WI.fillTextValue("LEUKO_NOTNORMAL");
				%>
				<input name="LEUKO_NOTNORMAL" type="text" size="12" value="<%=strTemp%>" class="textbox" maxlength="24"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="10" colspan="5">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="5"><div align="center">
				<%if(iAccessLevel > 1){
					if(bolIsEdit){%>
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
				<a href="./past_mh_entry.jsp"><img src="../../../images/cancel.gif" border="0"></a>
					<font size="1">click to cancel/erase entries</font></font></div></td>
		</tr>
		<tr>
			<td height="10" colspan="5">&nbsp;</td>
		</tr>
	</table>
		
<%}//only if vBasicInfo is not null%>

	<%if(vRecords != null && vRecords.size() > 0){%>
		<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
			<tr> 
		  		<td height="20" colspan="6" bgcolor="#B9B292" class="thinborder" align="center">
					<strong>::: LIST OF PAST RECORDS :::</strong></td>
			</tr>
			<tr>
				<td height="25" width="5%" align="center" class="thinborder"><strong>Count</strong></td>
				<td width="20%" align="center" class="thinborder"><strong>Effective Date</strong></td>
				<td width="15%" align="center" class="thinborder"><strong>Recorded Date</strong></td>
				<td width="15%" align="center" class="thinborder"><strong>Updated Date</strong></td>
				<td width="25%" align="center" class="thinborder"><strong>Updated By</strong></td>
				<td width="20%" align="center" class="thinborder"><strong>Options</strong></td>
			</tr>
		<%	int iCount = 1;
			for(int i = 0; i < vRecords.size(); i+=7,iCount++){%>
			<tr>
				<td height="25" align="center" class="thinborder"><%=iCount%></td>
			    <td class="thinborder"><%=(String)vRecords.elementAt(i+2)%> - <%=(String)vRecords.elementAt(i+3)%></td>
			    <td class="thinborder"><%=(String)vRecords.elementAt(i+1)%></td>
			    <td class="thinborder"><%=(String)vRecords.elementAt(i+4)%></td>
			    <td class="thinborder"><%=(String)vRecords.elementAt(i+5)%>
					<%=WI.getStrValue((String)vRecords.elementAt(i+6), "(", ")", "&nbsp;")%></td>
			    <td align="center" class="thinborder">
				<%if(iAccessLevel > 1){%>
					<a href="javascript:PrepareToEdit('<%=(String)vRecords.elementAt(i)%>');">
						<img src="../../../images/edit.gif" border="0"></a>
					<%if(iAccessLevel == 2){%>
						&nbsp;
						<a href="javascript:DeleteRecord('<%=(String)vRecords.elementAt(i)%>')">
							<img src="../../../images/delete.gif" border="0"></a>
					<%}
				}else{%>
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
	
	<input type="hidden" name="page_action">
	<input type="hidden" name="reload_page">
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="view_fields" value="<%=strViewFields%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
