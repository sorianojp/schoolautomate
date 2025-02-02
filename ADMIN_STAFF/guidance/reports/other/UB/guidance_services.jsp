<%@ page language="java" import="utility.*,java.util.Vector,enrollment.CourseRequirement,osaGuidance.GDTrackerServices" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Guidance Services</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
.trigger{
cursor: pointer;
cursor: hand;
}
.branch1{
display: none;
margin-left: 16px;
}
</style>
</head>
<script language="JavaScript" src="../../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../../jscript/common.js"></script>
<script language="javascript" src="../../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
//function AjaxSaveData2(strFieldName, strBranch){	   
//	if(!this.AjaxSaveData(strFieldName,'1')){
//		strFieldName = eval('document.form_.'+strFieldName);
//		if(strFieldName.checked == false)
//			strFieldName.checked = true;
//		else
//			strFieldName.checked = false;
//		return;
//	}	
//	this.showBranch(strBranch);
//}
//function AjaxSaveData(strFieldName, strFieldType){ 
//	
//	if(document.form_.stud_id.value.length == 0){
//		alert("Please provide student id.");
//		return false;
//	}
//	
//	var objCOAInput = eval('document.form_.'+strFieldName);
//	
//	
//	
//	var strValue = "";
//	if(strFieldType == '1'){//checkbox
//		if(objCOAInput.checked)
//			strValue = "1";
//		else
//			strValue = "";
//    }else
//		strValue = objCOAInput.value;
//		
//	//this are syFrom
//	if(strFieldName == 'field_12' || strFieldName == 'field_15' || strFieldName == 'field_18' || strFieldName == 'field_21'){		
//		if(strValue.length != 4)
//			return false;
//	}
//		
//	
//	//return true;*/
//	
//	this.InitXmlHttpObject2(objCOAInput, 1, "");
//	if(this.xmlHttp == null) {
//		alert("Failed to init xmlHttp.");
//		return false;
//	}
//	var strURL = "../../../../../Ajax/AjaxInterface.jsp?methodRef=6403&stud_id="+document.form_.stud_id.value+
//		"&field_name="+escape(strFieldName)+
//		"&field_value="+strValue+
//		"&sy_from="+document.form_.sy_from.value+
//		"&sy_to="+document.form_.sy_to.value+
//		"&semester="+document.form_.semester.value;
//	this.processRequest(strURL);
//	
//	if( strFieldName.indexOf("_date") != -1 )
//		return true;
//		
//	strFieldName = strFieldName.substring(strFieldName.indexOf("field_")+6);
//	
//	//this are sy_from. I cant save SY-to bec. its read only
//	if(strFieldName == '12' || strFieldName == '15' || strFieldName == '18' || strFieldName == '21'){
//		strFieldName = parseInt(strFieldName)+1;
//		SaveSYFromAndTo(strFieldName);
//	}
//	
//	return true;	
//}
//function SaveSYFromAndTo(strFieldNo){
//	window.setTimeout("AjaxSaveData('field_"+strFieldNo+"','0')", 100);
//}
function AjaxMapName() {
	var strCompleteName = document.form_.stud_id.value;
	var objCOAInput = document.getElementById("coa_info");
	
	if(strCompleteName.length <=2) {
		objCOAInput.innerHTML = "";
		return ;
	}

	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+escape(strCompleteName);
	this.processRequest(strURL);
	//RefreshPage();
}
function UpdateID(strID, strUserIndex) {
	document.form_.stud_id.value = strID;
	document.getElementById("coa_info").innerHTML = "";	
	RefreshPage();
}
function UpdateName(strFName, strMName, strLName) {
//do nothing.
}
function UpdateNameFormat(strName) {
//do nothing.
}
function StudSearch() {
	var pgLoc = "../../../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",
	'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function RefreshPage(){
	document.form_.reload_page.value="1";	
	document.form_.page_action.value = "";
	document.form_.submit();
}

function PageAction(){
	document.form_.page_action.value = "1";
	document.form_.reload_page.value="1";	
	document.form_.submit();
}

//function UpdateRecord(){
//	document.form_.page_action.value = "1";
//	document.form_.reload_page.value="1";
//	document.form_.submit();
//}
//function EditRecord(strInfoIndex){		
//	document.form_.info_index.value = strInfoIndex;
//	document.form_.page_action.value = "2";
//	document.form_.reload_page.value="1";
//	document.form_.submit();
//}
///////////////////////////////////////// used to collapse and expand filter ////////////////////
//function showBranch(branch){
//	var objBranch = document.getElementById(branch).style;
//	if(objBranch.display=="block")
//		objBranch.display="none";
//	else
//		objBranch.display="block";
//}
//function showBranchOnLoad(branch,strStyle){	
//	var objBranch = document.getElementById(branch).style;
//	if(strStyle.length > 0)
//		objBranch.display=strStyle;
//}
</script>
<body bgcolor="#D2AE72">
<%
	String strTemp = null;	
	String strErrMsg = null;
	String strStyle = null;
	String strDisable = null;
	String strServiceIndex = WI.fillTextValue("service_index");
	java.sql.ResultSet rs =null;
//add security here.
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
				"Admin/staff-Students Affairs-Guidance-Reports-Other(Guidance Services)","guidance_services.jsp");
	}catch(Exception exp){
		exp.printStackTrace();%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%return;
	}
//authenticate this user.
/*	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
										"Guidance","REPORTS",request.getRemoteAddr(),"guidance_services.jsp");
	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
		response.sendRedirect("../../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		dbOP.cleanUP();
		response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
		return;
	}*/

	//end of authenticaion code.	

	Vector vStudInfo  = null;
	
	String strSYFrom = null; 
	String strSYTo = null; 
	String strSemester  = null;
	String strUserIndex = null;
	String strIsTempStud = "0";
	String strIsBasic = "0";
	
	boolean bolIsEncoded = false;
	
	CourseRequirement cRequirement = new CourseRequirement();	
	GDTrackerServices guidanceServ =new GDTrackerServices ();
	enrollment.OfflineAdmission OA = new enrollment.OfflineAdmission();
	
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(!guidanceServ.saveStudService(dbOP, request))
			strErrMsg = guidanceServ.getErrMsg();
		else
			strErrMsg = "Information successfully saved.";
	}
	

	if (WI.fillTextValue("stud_id").length() > 0){
		vStudInfo = OA.getStudentBasicInfo(dbOP,WI.fillTextValue("stud_id"));
		if (vStudInfo == null) 
			strErrMsg= OA.getErrMsg();	  
			
		strTemp = dbOP.mapUIDToUIndex(WI.fillTextValue("stud_id"),4);
		if (strTemp != null)
			strIsTempStud = "0";
		else
		  	strIsTempStud = "1";
	}
	if(vStudInfo != null && vStudInfo.size() > 0) {			
		strSYFrom = (String)vStudInfo.elementAt(10);
		strSYTo = (String)vStudInfo.elementAt(11);
		strSemester = (String)vStudInfo.elementAt(9);
		strUserIndex = (String)vStudInfo.elementAt(12);
		
		strTemp = "select course_index from stud_curriculum_hist where is_valid =1 and sy_from = "+strSYFrom+
			" and semester = "+strSemester+" and user_index = "+strUserIndex;
		strTemp = dbOP.getResultOfAQuery(strTemp, 0);
		if(strTemp == null || strTemp.equals("0"))
			strIsBasic = "1";
			
		
		
		
		strTemp = "select SY_FROM, SEMESTER from GD_SERVICES where is_valid =1 and USER_INDEX = "+(String)vStudInfo.elementAt(12);
		rs = dbOP.executeQuery(strTemp);
		if(rs.next()){
			if(!strSemester.equals(rs.getString(2)) || !strSYFrom.equals(rs.getString(1)))
				bolIsEncoded = true;			
		}rs.close();		
		
		
			
	}	
	String[] astrConvertToSem = {"SUMMER","1ST SEM","2ND SEM","3RD SEM","4TH SEM"};
	if(strIsBasic.equals("1")){
		astrConvertToSem[0] = "Summer";
		astrConvertToSem[1] = "Regular";
	}
		
	String[] astrConvertToYr  = {"N/A","1ST YR","2ND YR","3RD YR","4TH YR","5TH YR","6TH YR","7TH YR"};     

%>
<form action="./guidance_services.jsp" method="post" name="form_">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" id="myID1">
		<tr bgcolor="#A49A6A">
			<td width="100%" height="25" colspan="4" bgcolor="#A49A6A">
				<div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif">
				<strong>:::: GUIDANCE SERVICES ::::</strong></font></div>
			</td>
		</tr>
		<tr bgcolor="#FFFFFF"><td width="88%" height="25" style="padding-left:30px;"><font color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></td>
	    <td width="12%" align="right">
		<a href="main.jsp"><img src="../../../../../images/go_back.gif" border="0"></a>		</td>
	</tr>
	</table>  	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr> 
			<td width="2%">&nbsp;</td>
			<td width="15%">ID Number</td>
			<td width="20%"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" 
			class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
			onKeyUp="AjaxMapName('1');"></td>
			<td colspan="2" >			
			<a href="javascript:StudSearch();"><img src="../../../../../images/search.gif" border="0" ></a>
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
			<td colspan="4">
			<a href="javascript:RefreshPage();"><img src="../../../../../images/form_proceed.gif" border="0"></a></td>	
		</tr>
	</table>
<% 

if(vStudInfo != null && vStudInfo.size() > 0 && WI.fillTextValue("reload_page").length()>0){
String strSelectField = " from gd_services  "+
	" where is_valid =1 and user_index = "+strUserIndex+
	" and is_temp_stud = "+strIsTempStud;


%>
<input type="hidden" name="stud_index" value="<%=strUserIndex%>">
<input type="hidden" name="is_temp_stud" value="<%=strIsTempStud%>">
<input type="hidden" name="sy_from" value="<%=strSYFrom%>">
<input type="hidden" name="sy_to" value="<%=strSYTo%>">
<input type="hidden" name="semester" value="<%=strSemester%>">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td width="2%" height="25">&nbsp;</td>
			<td width="18%">Student Name</td>
			<%
			strTemp = WebInterface.formatName((String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(1),(String)vStudInfo.elementAt(2),4);
			%>
			<td width="33%"><strong><%=strTemp%></strong></td>
			<td width="47%">&nbsp;</td>
		</tr>
	<%
	if(!strIsBasic.equals("1")){
	%>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Course/Major(cy)</td>
			<td colspan="2"><strong><%=(String)vStudInfo.elementAt(7)%>
			<%if(vStudInfo.elementAt(8) != null){%>
			/<%=(String)vStudInfo.elementAt(8)%>
			<%}%>
			(<%=(String)vStudInfo.elementAt(3)%> to <%=(String)vStudInfo.elementAt(4)%>
			)</strong></td>
		</tr>
	<%}%>
		<tr>
			<td height="25">&nbsp;</td>
			<td>YEAR LEVEL</td>
			<%
			if(!strIsBasic.equals("1"))
				strTemp = astrConvertToYr[Integer.parseInt(WI.getStrValue(vStudInfo.elementAt(14),"0"))];
			else
				strTemp = dbOP.getBasicEducationLevelNew(Integer.parseInt(WI.getStrValue(vStudInfo.elementAt(14),"0")));
			%>
			<td><strong><%=strTemp%></strong></td>
			<td>SY (TERM ) &nbsp;&nbsp;: &nbsp;&nbsp;<%=strSYFrom + "-" +strSYTo%> 
			<%
			if(Integer.parseInt(strSemester) > 1 && strIsBasic.equals("1"))
				strSemester = "1";
			%>
			(<%=astrConvertToSem[Integer.parseInt(strSemester)]%>)</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Status</td>
			<%
			strTemp = WI.getStrValue(vStudInfo.elementAt(20));
			if(strTemp.length()  > 0){
				strTemp = "select status from user_status where STATUS_INDEX = "+strTemp;
				strTemp = dbOP.getResultOfAQuery(strTemp,0);
			}else
				strTemp = "";
			%>
			<td colspan="2"><strong><%=WI.getStrValue(strTemp)%></strong></td>
		</tr>
		
		<tr>
			<td height="25" colspan="4"><hr size="1"></td>
		</tr>
	</table>  
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td colspan="4" height="20">&nbsp;</td>
		</tr>
		<tr>
			<td width="6%" height="20">&nbsp;</td>
	      	<%	
			strTemp = "<input type='checkbox' name='field_1' value='1'>";
			if(dbOP.getResultOfAQuery("select service_index "+strSelectField+" and field_1 is not null ", 0) != null)
				strTemp = "<img src='../../../../../images/tick.gif' border='0'>";			
          	%>
			<td width="94%" height="20" colspan="2"><%=strTemp%> Counseling	
			<span class="branch" id="branch1">			
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	  	
				<tr>
					<td width="9%" height="20">&nbsp;</td>
					<%	
					strTemp = "<input type='checkbox' name='field_2' value='1'>";
					if(dbOP.getResultOfAQuery("select service_index "+strSelectField+" and field_2 is not null ", 0) != null)
						strTemp = "<img src='../../../../../images/tick.gif' border='0'>";			
					%>	
					<td height="20"><%=strTemp%> Individual</td>			   
				</tr>
				<tr>
					<td width="9%" height="20">&nbsp;</td>	
					<%	
					strTemp = "<input type='checkbox' name='field_3' value='1'>";
					if(dbOP.getResultOfAQuery("select service_index "+strSelectField+" and field_3 is not null ", 0) != null)
						strTemp = "<img src='../../../../../images/tick.gif' border='0'>";			
					%>				
					<td height="20"><%=strTemp%> Group Counseling
						<span class="branch" id="branch9"> 						
						<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
							<tr>				  
								<td width="22%" height="20" valign="bottom" style="padding-left:70px;">Data Needed:</td>	  
								<%									
								strTemp = dbOP.getResultOfAQuery("select field_4 "+strSelectField+" and field_4 is not null ", 0);											
								%>
								<td width="78%" valign="bottom">
								<%if(WI.getStrValue(strTemp).length() > 0){%><%=strTemp%><%}else{%>
									<input type="text" name="field_4" class="textbox"
									onFocus="style.backgroundColor='#D3EBFF'" 
									onBlur="style.backgroundColor='white';" size="30">
								<%}%>
								</td>
							</tr>											
							<tr>						
								<td width="22%" height="20" valign="bottom" style="padding-left:70px;">Date Attended:</td>
								<%	
								strTemp = "select field_6 "+strSelectField+" and field_6 is not null ";		
								rs = dbOP.executeQuery(strTemp);
								strTemp = null;								
								if(rs.next())
									strTemp = ConversionTable.convertMMDDYYYY(rs.getDate(1));
								rs.close();																	
								%>									
								<td width="78%" valign="bottom">
								<%if(WI.getStrValue(strTemp).length() > 0){%><%=strTemp%><%}else{%>	
								<input name="field_6_date" type="text" size="12" maxlength="12" readonly="yes"
								class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
								onBlur="style.backgroundColor='white';">
								<a href="javascript:show_calendar('form_.field_6_date');" title="Click to select date" 
								onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
								<img src="../../../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
								<%}%>
								</td>
							</tr>
							<tr>						
								<td width="22%" height="20" valign="bottom" style="padding-left:70px;">Facilitated by:</td>
								<%	
								strTemp = dbOP.getResultOfAQuery("select field_7 "+strSelectField+" and field_7 is not null ", 0);											
								%>								
								<td width="78%" valign="bottom">
								<%if(WI.getStrValue(strTemp).length() > 0){%><%=strTemp%><%}else{%>	
								<input type="text" name="field_7" class="textbox"
								onFocus="style.backgroundColor='#D3EBFF'" 
								onBlur="style.backgroundColor='white';" size="30">
								<%}%></td>
							</tr>						
						</table>
						</span>
					</td>	
				</tr>			
			</table>
			</span> 		
			</td>
		</tr>	
				
		<tr>
			<td width="6%" height="20">&nbsp;</td>
			<%	
			strTemp = "<input type='checkbox' name='field_8' value='1'>";
			if(dbOP.getResultOfAQuery("select service_index "+strSelectField+" and field_8 is not null ", 0) != null)
				strTemp = "<img src='../../../../../images/tick.gif' border='0'>";			
			%>			
			<td height="20" colspan="2"><%=strTemp%> Testing
			</td>	 
		</tr>
		<tr>
			<td width="6%" height="20">&nbsp;</td>
			<%	
			strTemp = "<input type='checkbox' name='field_9' value='1'>";
			if(dbOP.getResultOfAQuery("select service_index "+strSelectField+" and field_9 is not null ", 0) != null)
				strTemp = "<img src='../../../../../images/tick.gif' border='0'>";			
			%>
			<td height="20" colspan="2"><%=strTemp%> Individual Inventory</td>	 
		</tr>
		<tr>
			<td width="6%" height="20">&nbsp;</td>
			<%	
			strTemp = "<input type='checkbox' name='field_10' value='1'>";
			if(dbOP.getResultOfAQuery("select service_index "+strSelectField+" and field_10 is not null ", 0) != null)
				strTemp = "<img src='../../../../../images/tick.gif' border='0'>";			
			%>
			<td height="20" colspan="2"><%=strTemp%> Referral</td>	 
		</tr>
		<tr>
			<td width="6%" height="20">&nbsp;</td>	
			<%	
			strTemp = "<input type='checkbox' name='field_11' value='1'>";
			if(dbOP.getResultOfAQuery("select service_index "+strSelectField+" and field_11 is not null ", 0) != null)
				strTemp = "<img src='../../../../../images/tick.gif' border='0'>";			
			%>		
			<td height="20" colspan="2"><%=strTemp%> Orientation
			<span class="branch" id="branch2">			
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<tr>
					<td colspan="2" style="padding-left:50px;">
					<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
						<tr>
							<td width="3%" height="20">SY:</td>
							<%	
							strTemp = dbOP.getResultOfAQuery("select field_12 "+strSelectField+" and field_12 is not null ", 0);											
							%>
							<td width="17%">
							<%if(WI.getStrValue(strTemp).length() > 0){%><%=strTemp%><%}else{%>	
							<input name="field_12" type="text" size="4" maxlength="4" 
							class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
							onBlur="style.backgroundColor='white';DisplaySYTo('form_','field_12','field_13');"
							onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
							onKeyUp='DisplaySYTo("form_","field_12","field_13")'>
							<%}%>
							to 
							<%	
							strTemp = dbOP.getResultOfAQuery("select field_13 "+strSelectField+" and field_13 is not null ", 0);											
							if(WI.getStrValue(strTemp).length() > 0){%><%=strTemp%><%}else{%>	
							<input name="field_13" type="text" size="4" maxlength="4"
							class="textbox"	onfocus="style.backgroundColor='#D3EBFF'" 
							onBlur="style.backgroundColor='white';"
							readonly="yes" >
							<%}%>					
							</td>
							<td width="7%">Date:</td>
							<%	
							//strTemp = dbOP.getResultOfAQuery("select field_14 "+strSelectField+" and field_14 is not null ", 0);	
							strTemp = "select field_14 "+strSelectField+" and field_14 is not null ";		
							rs = dbOP.executeQuery(strTemp);
							strTemp = null;
							if(rs.next())
								strTemp = ConversionTable.convertMMDDYYYY(rs.getDate(1));
							rs.close();										
							%>
							<td width="73%">
							<%if(WI.getStrValue(strTemp).length() > 0){%><%=strTemp%><%}else{%>	
								<input name="field_14_date" type="text" size="12" maxlength="12" readonly="yes" 
								class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
								onBlur="style.backgroundColor='white';">
								<a href="javascript:show_calendar('form_.field_14_date');" title="Click to select date" 
								onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
								<img src="../../../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
							<%}%>
							</td>		   
						</tr>		  
					</table>			   
					</td>
				</tr>
				<tr>
					<td colspan="2" style="padding-left:50px;">
					<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
						<tr>
							<td width="3%" height="20">SY:</td>
							<%	
							strTemp = dbOP.getResultOfAQuery("select field_15 "+strSelectField+" and field_15 is not null ", 0);											
							%>
							<td width="17%">							   
							<%if(WI.getStrValue(strTemp).length() > 0){%><%=strTemp%><%}else{%>	
							<input name="field_15" type="text" size="4" maxlength="4"
							class="textbox" 
							onfocus="style.backgroundColor='#D3EBFF'" 
							onBlur="style.backgroundColor='white';DisplaySYTo('form_','field_15','field_16');"
							onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
							onKeyUp='DisplaySYTo("form_","field_15","field_16")'>
							<%}%>
							to 
							<%	
							strTemp = dbOP.getResultOfAQuery("select field_16 "+strSelectField+" and field_16 is not null ", 0);											
							if(WI.getStrValue(strTemp).length() > 0){%><%=strTemp%><%}else{%>	
							<input name="field_16" type="text" size="4" maxlength="4" 
							class="textbox" 
							onfocus="style.backgroundColor='#D3EBFF'" 
							onBlur="style.backgroundColor='white';"
							readonly="yes">					
							<%}%>
							</td>
							<td width="7%">Date:</td>
							<%	
							//strTemp = dbOP.getResultOfAQuery("select field_17 "+strSelectField+" and field_17 is not null ", 0);											
							strTemp = "select field_17 "+strSelectField+" and field_17 is not null ";		
							rs = dbOP.executeQuery(strTemp);
							strTemp = null;
							if(rs.next())
								strTemp = ConversionTable.convertMMDDYYYY(rs.getDate(1));
							rs.close();
							%>
							<td width="73%">
							<%if(WI.getStrValue(strTemp).length() > 0){%><%=strTemp%><%}else{%>	
							<input name="field_17_date" type="text" size="12" maxlength="12" readonly="yes" 
							
							class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
							onBlur="style.backgroundColor='white';">
							<a href="javascript:show_calendar('form_.field_17_date');" title="Click to select date" 
							onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
							<img src="../../../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
							<%}%>
							</td>		   
						</tr>		  
					</table>			   
					</td>
				</tr>
				<tr>
					<td colspan="2" style="padding-left:50px;">
					<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
						<tr>
							<td width="3%" height="20">SY:</td>
							<%	
							strTemp = dbOP.getResultOfAQuery("select field_18 "+strSelectField+" and field_18 is not null ", 0);											
							%>
							<td width="17%">
							<%if(WI.getStrValue(strTemp).length() > 0){%><%=strTemp%><%}else{%>	
							<input name="field_18" type="text" size="4" maxlength="4"
							class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
							onBlur="style.backgroundColor='white';DisplaySYTo('form_','field_18','field_19');"
							onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
							onKeyUp='DisplaySYTo("form_","field_18","field_19")'>
							
							<%}%>
							to 
							<%	
							strTemp = dbOP.getResultOfAQuery("select field_19 "+strSelectField+" and field_19 is not null ", 0);											
							if(WI.getStrValue(strTemp).length() > 0){%><%=strTemp%><%}else{%>	   
							<input name="field_19" type="text" size="4" maxlength="4"
							class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
							onBlur="style.backgroundColor='white';"
							readonly="yes">					
							<%}%></td>
							<td width="7%">Date:</td>
							<%	
							//strTemp = dbOP.getResultOfAQuery("select field_20 "+strSelectField+" and field_20 is not null ", 0);											
							strTemp = "select field_20 "+strSelectField+" and field_20 is not null ";		
							rs = dbOP.executeQuery(strTemp);
							strTemp = null;
							if(rs.next())
								strTemp = ConversionTable.convertMMDDYYYY(rs.getDate(1));
							rs.close();
							%>
							<td width="73%">
							<%if(WI.getStrValue(strTemp).length() > 0){%><%=strTemp%><%}else{%>	
							<input name="field_20_date" type="text" size="12" maxlength="12" readonly="yes"							
							class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
							onBlur="style.backgroundColor='white';">
							<a href="javascript:show_calendar('form_.field_20_date');" title="Click to select date" 
							onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
							<img src="../../../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
							<%}%>
							</td>		   
						</tr>		  
					</table>			   
					</td>
				</tr>
				<tr>
					<td colspan="2" style="padding-left:50px;">
					<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
						<tr>
							<td width="3%" height="20">SY:</td>
							<%	
							strTemp = dbOP.getResultOfAQuery("select field_21 "+strSelectField+" and field_21 is not null ", 0);											
							%>
							<td width="17%">
							<%if(WI.getStrValue(strTemp).length() > 0){%><%=strTemp%><%}else{%> 
							<input name="field_21" type="text" size="4" maxlength="4"
							class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
							onBlur="style.backgroundColor='white';DisplaySYTo('form_','field_21','field_22');"
							onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
							onKeyUp='DisplaySYTo("form_","field_21","field_22")' >
							<%}%>
							to 
							<%	
							strTemp = dbOP.getResultOfAQuery("select field_22 "+strSelectField+" and field_22 is not null ", 0);											
							if(WI.getStrValue(strTemp).length() > 0){%><%=strTemp%><%}else{%> 
							<input name="field_22" type="text" size="4" maxlength="4"
							class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
							onBlur="style.backgroundColor='white';"
							readonly="yes">	
							<%}%>
							</td>
							<td width="7%">Date:</td>
							<%	
							//strTemp = dbOP.getResultOfAQuery("select field_23 "+strSelectField+" and field_23 is not null ", 0);											
							strTemp = "select field_23 "+strSelectField+" and field_23 is not null ";		
							rs = dbOP.executeQuery(strTemp);
							strTemp = null;
							if(rs.next())
								strTemp = ConversionTable.convertMMDDYYYY(rs.getDate(1));
							rs.close();
							%>
							<td width="73%">
							<%if(WI.getStrValue(strTemp).length() > 0){%><%=strTemp%><%}else{%> 
							<input name="field_23_date" type="text" size="12" maxlength="12" readonly="yes"							
							class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
							onBlur="style.backgroundColor='white';">
							<a href="javascript:show_calendar('form_.field_23_date');" title="Click to select date" 
							onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
							<img src="../../../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
							<%}%>
							</td>		   
						</tr>		  
					</table>			   
					</td>
				</tr>	
			</table>
			</span>
			</td> 	 
		</tr>
		<tr>
			<td>&nbsp;</td>
			<%	
			strTemp = "<input type='checkbox' name='field_24' value='1'>";
			if(dbOP.getResultOfAQuery("select service_index "+strSelectField+" and field_24 is not null ", 0) != null)
				strTemp = "<img src='../../../../../images/tick.gif' border='0'>";			
			%>
			<td height="20" colspan="2"><%=strTemp%> Job Enhancement Program
			<span class="branch" id="branch3">			
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<tr>
					<td>&nbsp;</td>
					<%	
					strTemp = "<input type='checkbox' name='field_25' value='1'>";
					if(dbOP.getResultOfAQuery("select service_index "+strSelectField+" and field_25 is not null ", 0) != null)
						strTemp = "<img src='../../../../../images/tick.gif' border='0'>";			
					%>					
					<td height="20" colspan="2"><%=strTemp%> Module 1
					<span class="branch" id="branch4">
					
					<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
						<tr>
							<td width="23%" height="20" valign="bottom" style="padding-left:80px;">Data Needed :</td>	  
							<%	
							strTemp = dbOP.getResultOfAQuery("select field_26 "+strSelectField+" and field_26 is not null ", 0);											
							%>
							<td width="77%" valign="bottom">
							<%if(WI.getStrValue(strTemp).length() > 0){%><%=strTemp%><%}else{%> 
							<input type="text" name="field_26" class="textbox"
							onFocus="style.backgroundColor='#D3EBFF'" 
							onBlur="style.backgroundColor='white';" size="30">
							<%}%></td>
						</tr>	
						<tr>
							<td height="20" width="23%" valign="bottom" style="padding-left:80px;">Date:</td>
							<%	
							//strTemp = dbOP.getResultOfAQuery("select field_27 "+strSelectField+" and field_27 is not null ", 0);											
							strTemp = "select field_27 "+strSelectField+" and field_27 is not null ";		
							rs = dbOP.executeQuery(strTemp);
							strTemp = null;
							if(rs.next())
								strTemp = ConversionTable.convertMMDDYYYY(rs.getDate(1));
							rs.close();
							%>
							<td width="77%" valign="bottom">
							<%if(WI.getStrValue(strTemp).length() > 0){%><%=strTemp%><%}else{%> 
							<input name="field_27_date" type="text" size="12" maxlength="12" readonly="yes"							
							class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
							onBlur="style.backgroundColor='white';">
							<a href="javascript:show_calendar('form_.field_27_date');" title="Click to select date" 
							onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
							<img src="../../../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
							<%}%>
							</td>
						</tr>						
					</table>
					</span>
					</td>
				</tr>		
				<tr>
					<td>&nbsp;</td>
					<%	
					strTemp = "<input type='checkbox' name='field_29' value='1'>";
					if(dbOP.getResultOfAQuery("select service_index "+strSelectField+" and field_29 is not null ", 0) != null)
						strTemp = "<img src='../../../../../images/tick.gif' border='0'>";			
					%>	
					<td height="20" colspan="2"><%=strTemp%> Module 2
					<span class="branch" id="branch5">
					
					<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
						<tr>
							<td height="20" width="23%" valign="bottom" style="padding-left:80px;">Date:</td>
							<%	
							//strTemp = dbOP.getResultOfAQuery("select field_30 "+strSelectField+" and field_30 is not null ", 0);											
							strTemp = "select field_30 "+strSelectField+" and field_30 is not null ";		
							rs = dbOP.executeQuery(strTemp);
							strTemp = null;
							if(rs.next())
								strTemp = ConversionTable.convertMMDDYYYY(rs.getDate(1));
							rs.close();
							%>
							<td width="77%" valign="bottom">
							<%if(WI.getStrValue(strTemp).length() > 0){%><%=strTemp%><%}else{%> 
								<input name="field_30_date" type="text" size="12" maxlength="12" readonly="yes"								
								class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
								onBlur="style.backgroundColor='white';">
								<a href="javascript:show_calendar('form_.field_30_date');" title="Click to select date" 
								onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
								<img src="../../../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
							<%}%>
							</td>
						</tr>						
					</table>
					</span> 
					</td>
				</tr>
				<tr>
					<td width="9%" height="20">&nbsp;</td>
					<%	
					strTemp = "<input type='checkbox' name='field_32' value='1'>";
					if(dbOP.getResultOfAQuery("select service_index "+strSelectField+" and field_32 is not null ", 0) != null)
						strTemp = "<img src='../../../../../images/tick.gif' border='0'>";			
					%>
					<td height="20" colspan="2" ><%=strTemp%> Job Interview Simulation</td>	 
				</tr>	
				<tr>
					<td width="9%" height="20">&nbsp;</td>
					<%	
					strTemp = "<input type='checkbox' name='field_33' value='1'>";
					if(dbOP.getResultOfAQuery("select service_index "+strSelectField+" and field_33 is not null ", 0) != null)
						strTemp = "<img src='../../../../../images/tick.gif' border='0'>";			
					%>
					<td height="20" colspan="2"><%=strTemp%> i-trabajo</td>	 
				</tr>	
				<tr>
					<td width="9%" height="20">&nbsp;</td>
					<%	
					strTemp = "<input type='checkbox' name='field_34' value='1'>";
					if(dbOP.getResultOfAQuery("select service_index "+strSelectField+" and field_34 is not null ", 0) != null)
						strTemp = "<img src='../../../../../images/tick.gif' border='0'>";			
					%>
					<td height="20" colspan="2"><%=strTemp%> Directory of Graduates</td>	 
				</tr>
			</table>
			</span>		 
			</td>
		</tr>
		<tr>
			<td width="6%" height="20" >&nbsp;</td>
			<%	
			strTemp = "<input type='checkbox' name='field_35' value='1'>";
			if(dbOP.getResultOfAQuery("select service_index "+strSelectField+" and field_35 is not null ", 0) != null)
				strTemp = "<img src='../../../../../images/tick.gif' border='0'>";			
			%>
			<td height="20" colspan="2"><%=strTemp%> Career Orientation</td>	 
		</tr>
	
		<tr>
			<td width="6%" height="20">&nbsp;</td>			
			<td height="20" colspan="2">			
			<input type="checkbox" id="folder6" name="field_36"  value="1">Information
			<span class="branch" id="branch6">			
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
				<tr>
					<td width="9%">&nbsp;</td>					
					<td width="91%" height="20" colspan="2">					     		   
					<input type="checkbox" id="folder7" name="field_37"  value="1">Learning Session<span class="branch" id="branch7">
					
					<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
						<tr>
							<td width="23%" height="20" valign="bottom" style="padding-left:80px;">Data Needed :</td>	  							
							<td width="77%" valign="bottom">
							<input type="text" name="field_38" class="textbox"
							onFocus="style.backgroundColor='#D3EBFF'" 
							onBlur="style.backgroundColor='white';" size="30">
							
							</td>
						</tr>	
						<tr>
							<td height="20" width="23%" valign="bottom" style="padding-left:80px;">Date:</td>							
							<td width="77%" valign="bottom">
							<input name="field_39_date" type="text" size="12" maxlength="12" readonly="yes"							
							class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
							onBlur="style.backgroundColor='white';">
							<a href="javascript:show_calendar('form_.field_39_date');" title="Click to select date" 
							onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
							<img src="../../../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
							</td>
						</tr>
						<tr>
							<td width="23%" height="20" valign="bottom" style="padding-left:80px;">Title :</td>	  							
							<td width="77%" valign="bottom">
							<input type="text" name="field_40" class="textbox"
							onFocus="style.backgroundColor='#D3EBFF'" 
							onBlur="style.backgroundColor='white';" size="30">
							</td>
						</tr>				
					</table>
					</span>
					</td>
				</tr>				
				<tr>
					<td>&nbsp;</td>					
					<td height="20" colspan="2">			   					 
					<input type="checkbox" id="folder8" name="field_41"  value="1">Fora<span class="branch" id="branch8">
					
					<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
						<tr>
							<td height="20" width="23%" valign="bottom" style="padding-left:80px;">Date:</td>
							
							<td width="77%" valign="bottom">
							<input name="field_42_date" type="text" size="12" maxlength="12" readonly="yes"							
							class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
							onBlur="style.backgroundColor='white';">
							<a href="javascript:show_calendar('form_.field_42_date');" title="Click to select date" 
							onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
							<img src="../../../../../images/calendar_new.gif" width="20" height="16" border="0"></a>	
							</td>
						</tr>
						<tr>
							<td width="23%" height="20" valign="bottom" style="padding-left:80px;">Title :</td>	  							
							<td width="77%" valign="bottom">
							<input type="text" name="field_43" class="textbox"
							onFocus="style.backgroundColor='#D3EBFF'" 
							onBlur="style.backgroundColor='white';" size="30">
							</td>
						</tr>	
					</table>
					</span>
					</td>
				</tr>			
			</table>
			</span>
			</td>	 
		</tr>
		<tr>
			<td width="6%" height="20">&nbsp;</td>
			<%	
			strTemp = "<input type='checkbox' name='field_44' value='1'>";
			if(dbOP.getResultOfAQuery("select service_index "+strSelectField+" and field_44 is not null ", 0) != null)
				strTemp = "<img src='../../../../../images/tick.gif' border='0'>";			
			%>
			<td height="20" colspan="2"><%=strTemp%>Peer Facilitating Program</td>	 
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
				<a href="javascript:PageAction();"><img src="../../../../../images/save.gif" border="0"></a>
				<font size="1">click to save information</font>						
			</div>
			</td>
		</tr>
	</table> 
<%}//end of vCRSudInfo!=null%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myID4">
		<tr>
			<td height="25">&nbsp;</td>
		</tr>
		<tr bgcolor="#B8CDD1">
			<td height="25" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
<input type="hidden" name="no_of_fields" value="50">
<input type="hidden" name="page_action">
<input type="hidden" name="reload_page">
<input type="hidden" name="vDate" value="6,14,17,20,23,27,30,39,42">
<input type="hidden" name="service_index" value="<%=strServiceIndex%>">
<input type="hidden" name="is_basic" value="<%=strIsBasic%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>