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
.branch{
display: none;
margin-left: 16px;
}
</style>
</head>
<script language="JavaScript" src="../../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../../jscript/common.js"></script>
<script language="javascript" src="../../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
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
	document.form_.submit();
}
function UpdateRecord(){
	document.form_.page_action.value = "1";
	document.form_.reload_page.value="1";
	document.form_.submit();
}
function EditRecord(strInfoIndex){		
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "2";
	document.form_.reload_page.value="1";
	document.form_.submit();
}
///////////////////////////////////////// used to collapse and expand filter ////////////////////
function showBranch(branch){
	var objBranch = document.getElementById(branch).style;
	if(objBranch.display=="block")
		objBranch.display="none";
	else
		objBranch.display="block";
}
function showBranchOnLoad(branch,strStyle){	
	var objBranch = document.getElementById(branch).style;
	if(strStyle.length > 0)
		objBranch.display=strStyle;
}
</script>
<body bgcolor="#D2AE72">
<%
	String strTemp = null;	
	String strErrMsg = null;
	String strStyle = null;
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
	CommonUtil comUtil = new CommonUtil();
/*	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
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
	Vector vRetResult  =null;
	Vector vStudInfo  = null;
	Vector vCRStudInfo = null;
	Vector vFirstEnrl = null;
	String strSYFrom = null; 
	String strSYTo = null; 
	String strSemester  = null;
	
	boolean bolIsEncoded = false;
	
	CourseRequirement cRequirement = new CourseRequirement();	
	GDTrackerServices guidanceServ =new GDTrackerServices ();
	enrollment.OfflineAdmission OA = new enrollment.OfflineAdmission();

	if (WI.fillTextValue("stud_id").length() > 0){
		vStudInfo = OA.getStudentBasicInfo(dbOP,WI.fillTextValue("stud_id"));
		if (vStudInfo == null) 
			strErrMsg= OA.getErrMsg();	  
	}
	if(vStudInfo != null && vStudInfo.size() > 0) {			
		
		
		strSYFrom = (String)vStudInfo.elementAt(10);
		strSYTo = (String)vStudInfo.elementAt(11);
		strSemester = (String)vStudInfo.elementAt(9);
		
		strTemp = "select SY_FROM, SEMESTER from GD_SERVICES where is_valid =1 and USER_INDEX = "+(String)vStudInfo.elementAt(12);
		java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
		if(rs.next()){
			if(!strSemester.equals(rs.getString(2)) || !strSYFrom.equals(rs.getString(1)))
				bolIsEncoded = true;			
		}rs.close();
		//if (vFirstEnrl != null) {
		//strSYFrom = (String)vFirstEnrl.elementAt(0);
		//strSYTo = (String)vFirstEnrl.elementAt(1);
		//strSemester = (String)vFirstEnrl.elementAt(2);
		//}else{
		
		//}
		vCRStudInfo = cRequirement.getStudInfo(dbOP, request.getParameter("stud_id"),strSYFrom,strSYTo,strSemester);
		if(vCRStudInfo == null) 
			strErrMsg = cRequirement.getErrMsg();
		
		strTemp = WI.fillTextValue("page_action");
		if(strTemp.length() > 0){
			if(guidanceServ.operateOnGuidance(dbOP, request, Integer.parseInt(strTemp),(String)vCRStudInfo.elementAt(0),
				strSYFrom,strSemester) == null)
				strErrMsg = guidanceServ.getErrMsg();
			else{
				if(strTemp.equals("1"))
					strErrMsg = "Student profile information successfully saved.";
				if(strTemp.equals("2"))
					strErrMsg = "Student profile information successfully updated.";
			}
		}  

		if(WI.fillTextValue("reload_page").length()>0) {
			vRetResult = guidanceServ.operateOnGuidance(dbOP, request, 4,(String)vCRStudInfo.elementAt(0),strSYFrom,strSemester);
			if(vRetResult == null)
				strErrMsg = guidanceServ.getErrMsg();
		}	 
	}	
	String[] astrConvertToSem = {"SUMMER","1ST SEM","2ND SEM","3RD SEM","4TH SEM"};
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
		<tr bgcolor="#FFFFFF">
			<td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
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
<% if(vCRStudInfo != null && WI.fillTextValue("reload_page").length()>0){%>
<input type="hidden" name="stud_index" value="<%=(String)vCRStudInfo.elementAt(0)%>">
<input type="hidden" name="is_temp_stud" value="<%=(String)vCRStudInfo.elementAt(10)%>">
<input type="hidden" name="sy_from" value="<%=strSYFrom%>">
<input type="hidden" name="sy_to" value="<%=strSYTo%>">
<input type="hidden" name="semester" value="<%=strSemester%>">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td width="2%" height="25">&nbsp;</td>
			<td width="18%">Student Name</td>
			<td width="33%"><strong><%=(String)vCRStudInfo.elementAt(1)%></strong></td>
			<td width="47%">&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Course/Major(cy)</td>
			<td colspan="2"><strong><%=(String)vCRStudInfo.elementAt(7)%>
			<%if(vCRStudInfo.elementAt(8) != null){%>
			/<%=(String)vCRStudInfo.elementAt(8)%>
			<%}%>
			(<%=(String)vCRStudInfo.elementAt(4)%> to <%=(String)vCRStudInfo.elementAt(5)%>
			)</strong></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>YEAR LEVEL</td>
			<td><strong><%=astrConvertToYr[Integer.parseInt(WI.getStrValue(vCRStudInfo.elementAt(6),"0"))]%></strong></td>
			<td>SY (TERM ) &nbsp;&nbsp;: &nbsp;&nbsp;<%=strSYFrom + "-" +strSYTo%> 
			(<%=astrConvertToSem[Integer.parseInt(strSemester)]%>)</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Status</td>
			<td colspan="2"><strong><%=(String)vCRStudInfo.elementAt(11)%></strong></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Foreign Student</td>
			<td colspan="2"><font color="#9900FF"><strong>
			<%if( ((String)vCRStudInfo.elementAt(16)).compareTo("1") ==0){%>
			YES
			<%}else{%>
			NO<%}%></strong></font></td>
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
			<%	if(vRetResult != null && vRetResult.size() > 0){
					strTemp = (String)vRetResult.elementAt(1);		
					if(WI.getStrValue(strTemp).equals("1"))
						strErrMsg = "checked";
					else
						strErrMsg = "";
				}else{
					strTemp = WI.fillTextValue("field_1");	
					strErrMsg = "";
				}	
			%>
			<td width="94%" height="20" colspan="2">	   	
			<%	if(strErrMsg.length() > 0)
					strStyle = "block";
				else
					strStyle = "";
			%>			
			<input type="checkbox" onClick="showBranch('branch1');" id="folder1" name="field_1" value="1" <%=strErrMsg%>>
			Counseling	
			<span class="branch" id="branch1">
			<script>
				<%if(strStyle.length()  >0){%>
					showBranchOnLoad('branch1','<%=strStyle%>');
				    <%strStyle = "";		
				  }%>
			</script>
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	  	
				<tr>
					<td width="9%" height="20">&nbsp;</td>
						<%	if(vRetResult != null && vRetResult.size() > 0){
								strTemp = (String)vRetResult.elementAt(2);		
								if(WI.getStrValue(strTemp).equals("1"))
									strErrMsg = "checked";
								else
									strErrMsg = "";
							}else{
								strTemp = WI.fillTextValue("field_2");		
								strErrMsg = "";
							}			
						%>
					<td height="20">
						<input type="checkbox" name="field_2" value="1" <%=strErrMsg%>>Individual
					</td>			   
				</tr>
				<tr>
					<td width="9%" height="20">&nbsp;</td>
					<%	if(vRetResult != null && vRetResult.size() > 0){
							strTemp = (String)vRetResult.elementAt(3);		
							if(WI.getStrValue(strTemp).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						}else{
							strTemp = WI.fillTextValue("field_3");		  
							strErrMsg = "";
						}
					%>
					<td height="20">	
					<%if(strErrMsg.length() > 0)
						strStyle = "block";
					  else
						strStyle = "";
					%>   	
						<input type="checkbox"  onClick="showBranch('branch9');" id="folder9" name="field_3" value="1" 
						<%=strErrMsg%>>Group Counseling
						<span class="branch" id="branch9"> 
						<script>
							<%if(strStyle.length()  >0){%>
								showBranchOnLoad('branch9','<%=strStyle%>');
								<%strStyle = "";		
							  }%>
						</script>
						<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
							<tr>				  
								<td width="22%" height="20" valign="bottom" style="padding-left:70px;">Data Needed</td>	  
								<%	if(vRetResult != null && vRetResult.size() > 0)
										strTemp = (String)vRetResult.elementAt(4);	
									else
										strTemp =null; 					
								%>
								<td width="78%">
								<input type="text" name="field_4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
								onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="30"></td>
							</tr>	
							<!--<tr>						
								<td width="22%" height="20" valign="bottom" style="padding-left:70px;">Course :</td>	  
								<td>
								<select name="field_5" style="width:400px;">
								<%	if(vRetResult != null && vRetResult.size() > 0)
										strTemp = (String)vRetResult.elementAt(5);	
									else
										strTemp = null;								
								%>	
								<option value="">N/A</option>
								<%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 and is_valid=1 order by course_name asc", strTemp, false)%> 		
								</select></td>
							</tr>-->			
							<tr>						
								<td width="22%" height="20" valign="bottom" style="padding-left:70px;">Date Attended</td>
								<%	if(vRetResult != null && vRetResult.size() > 0)
								strTemp = (String)vRetResult.elementAt(6);	
								else
								strTemp = null;				
								%>	
								<td width="78%">
								<input name="field_6_date" type="text" size="12" maxlength="12" readonly="yes"
								value="<%=WI.getStrValue(strTemp)%>" 
								class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
								<a href="javascript:show_calendar('form_.field_6_date');" title="Click to select date" 
								onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
								<img src="../../../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
								</td>
							</tr>
							<tr>						
								<td width="22%" height="20" valign="bottom" style="padding-left:70px;">Facilitated by</td>
								<%	if(vRetResult != null && vRetResult.size() > 0)
										strTemp = (String)vRetResult.elementAt(7);
									else
										strTemp =null; 		
								%>
								<td width="78%">
								<input type="text" name="field_7" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
								onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="30"></td>
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
			<%	if(vRetResult != null && vRetResult.size() > 0){
					strTemp = (String)vRetResult.elementAt(8);		
					if(WI.getStrValue(strTemp).equals("1"))
						strErrMsg = "checked";
					else
						strErrMsg = "";
				}else{
					strTemp = WI.fillTextValue("field_8");
					strErrMsg = "";
				}
			%>
			<td height="20" colspan="2">
			<input type="checkbox" name="field_8" value="1" <%=strErrMsg%>>Testing</td>	 
		</tr>
		<tr>
			<td width="6%" height="20">&nbsp;</td>
			<%	if(vRetResult != null && vRetResult.size() > 0){
					strTemp = (String)vRetResult.elementAt(9);		
					if(WI.getStrValue(strTemp).equals("1"))
						strErrMsg = "checked";
					else
						strErrMsg = "";
				}else{
					strTemp = WI.fillTextValue("field_9");	
					strErrMsg = "";
				}			
			%>
			<td height="20" colspan="2">
			<input type="checkbox" name="field_9" value="1" <%=strErrMsg%>>Individual Inventory</td>	 
		</tr>
		<tr>
			<td width="6%" height="20">&nbsp;</td>
			<%	if(vRetResult != null && vRetResult.size() > 0){
					strTemp = (String)vRetResult.elementAt(10);		
					if(WI.getStrValue(strTemp).equals("1"))
						strErrMsg = "checked";
					else
						strErrMsg = "";
				}else{
					strTemp = WI.fillTextValue("field_10");		
					strErrMsg = "";	
				}	
			%>
			<td height="20" colspan="2">
			<input type="checkbox" name="field_10" value="1" <%=strErrMsg%>>Referral</td>	 
		</tr>
		<tr>
			<td width="6%" height="20">&nbsp;</td>
			<%	if(vRetResult != null && vRetResult.size() > 0){
					strTemp = (String)vRetResult.elementAt(11);		
					if(WI.getStrValue(strTemp).equals("1"))
						strErrMsg = "checked";
					else
						strErrMsg = "";
				}else{
					strTemp = WI.fillTextValue("field_11");	
					strErrMsg = "";
				}			
			%>
			<td height="20" colspan="2">
			<%	if(strErrMsg.length() > 0)
					strStyle = "block";
				else
					strStyle = "";
			%>   			
			<input type="checkbox" onClick="showBranch('branch2');" name="field_11" id="folder2" value="1" <%=strErrMsg%>>
			Orientation
			<span class="branch" id="branch2">
			<script>
			<%if(strStyle.length()  >0){%>
				showBranchOnLoad('branch2','<%=strStyle%>');
				<%strStyle = "";		
			  }%>
			</script>
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<tr>
					<td colspan="2" style="padding-left:50px;">
					<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
						<tr>
							<td width="3%" height="20">SY:</td>
							<td width="17%">
							<%	if(vRetResult != null && vRetResult.size() > 0)
									strTemp = (String)vRetResult.elementAt(12);
								else
									strTemp =null;		
							%>
							<input name="field_12" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" 
							class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
							onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
							onKeyUp='DisplaySYTo("form_","field_12","field_13")'>
							to 
							<%	if(vRetResult != null && vRetResult.size() > 0)
									strTemp = (String)vRetResult.elementAt(13);
								else
									strTemp =null;
							%>    
							<input name="field_13" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" 
							class="textbox"	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
							readonly="yes" >					
							</td>
							<td width="7%">Date:</td>
							<%	if(vRetResult != null && vRetResult.size() > 0)
									strTemp = (String)vRetResult.elementAt(14);
								else
									strTemp =null; 	
							%>
							<td width="73%">
								<input name="field_14_date" type="text" size="12" maxlength="12" readonly="yes" 
								value="<%=WI.getStrValue(strTemp)%>" 
								class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
								<a href="javascript:show_calendar('form_.field_14_date');" title="Click to select date" 
								onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
								<img src="../../../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
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
							<td width="17%">
							<%	if(vRetResult != null && vRetResult.size() > 0)
									strTemp = (String)vRetResult.elementAt(15);
								else
									strTemp =null; 
							%>    <input name="field_15" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" 
							class="textbox" 
							onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
							onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
							onKeyUp='DisplaySYTo("form_","field_15","field_16")'>
							to 
							<%	if(vRetResult != null && vRetResult.size() > 0)
									strTemp = (String)vRetResult.elementAt(16);
								else
									strTemp =null; 
							%>    <input name="field_16" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" 
							class="textbox" 
							onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
							readonly="yes">					</td>
							<td width="7%">Date:</td>
							<%	if(vRetResult != null && vRetResult.size() > 0)
									strTemp = (String)vRetResult.elementAt(17);
								else
									strTemp =null; 
							%>
							<td width="73%">
							<input name="field_17_date" type="text" size="12" maxlength="12" readonly="yes" 
							value="<%=WI.getStrValue(strTemp)%>" 
							class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
							<a href="javascript:show_calendar('form_.field_17_date');" title="Click to select date" 
							onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
							<img src="../../../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
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
							<td width="17%">
							<%	if(vRetResult != null && vRetResult.size() > 0)
									strTemp = (String)vRetResult.elementAt(18);
								else
									strTemp =null; 
							%>    
							<input name="field_18" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" 
							class="textbox"	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
							onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
							onKeyUp='DisplaySYTo("form_","field_18","field_19")'>
							to 
							<%	if(vRetResult != null && vRetResult.size() > 0)
									strTemp = (String)vRetResult.elementAt(19);
								else
									strTemp =null; 
							%>    
							<input name="field_19" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" 
							class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
							readonly="yes">					</td>
							<td width="7%">Date:</td>
							<%	if(vRetResult != null && vRetResult.size() > 0)
									strTemp = (String)vRetResult.elementAt(20);
								else
									strTemp =null; 
							%>
							<td width="73%">
							<input name="field_20_date" type="text" size="12" maxlength="12" readonly="yes"
							value="<%=WI.getStrValue(strTemp)%>" 
							class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
							<a href="javascript:show_calendar('form_.field_20_date');" title="Click to select date" 
							onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
							<img src="../../../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
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
							<td width="17%">
							<%	if(vRetResult != null && vRetResult.size() > 0)
									strTemp = (String)vRetResult.elementAt(21);
								else
									strTemp =null; 
							%>    
							<input name="field_21" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" 
							class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
							onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
							onKeyUp='DisplaySYTo("form_","field_21","field_22")' >
							to 
							<%	if(vRetResult != null && vRetResult.size() > 0)
									strTemp = (String)vRetResult.elementAt(22);
								else
									strTemp =null; 
							%>    
							<input name="field_22" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" 
							class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
							readonly="yes">					</td>
							<td width="7%">Date:</td>
							<%	if(vRetResult != null && vRetResult.size() > 0)
									strTemp = (String)vRetResult.elementAt(23);
								else
									strTemp =null; 	
							%>
							<td width="73%">
							<input name="field_23_date" type="text" size="12" maxlength="12" readonly="yes"
							value="<%=WI.getStrValue(strTemp)%>" 
							class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
							<a href="javascript:show_calendar('form_.field_23_date');" title="Click to select date" 
							onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
							<img src="../../../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
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
			<%	if(vRetResult != null && vRetResult.size() > 0){
					strTemp = (String)vRetResult.elementAt(24);		
					if(WI.getStrValue(strTemp).equals("1"))
						strErrMsg = "checked";
					else
						strErrMsg = "";
				}else{				
					strTemp = WI.fillTextValue("field_24");		
					strErrMsg = "";
				}			
			%>
			<td height="20" colspan="2"> 
			<%	if(strErrMsg.length() > 0)
					strStyle = "block";
				else
					strStyle = "";
			%>   
			<input type="checkbox" onClick="showBranch('branch3');" name="field_24"  id="folder3" value="1" <%=strErrMsg%>>
			Job Enhancement Program<span class="branch" id="branch3">
			<script>
			<%if(strStyle.length()  >0){%>
					showBranchOnLoad('branch3','<%=strStyle%>');
					<%strStyle = "";		
			  }%>
			</script>
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<tr>
					<td>&nbsp;</td>
					<%  if(vRetResult != null && vRetResult.size() > 0){
							strTemp = (String)vRetResult.elementAt(25);		
							if(WI.getStrValue(strTemp).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						}else{
							strTemp = WI.fillTextValue("field_25");
							strErrMsg = "";
						}			
					%>
					<td height="20" colspan="2">
					<%	if(strErrMsg.length() > 0)
							strStyle = "block";
						else
							strStyle = "";
					%>   		   
					<input  type="checkbox" onClick="showBranch('branch4');" id="folder4" name="field_25"  value="1" 
					<%=strErrMsg%>>Module 1
					<span class="branch" id="branch4">
					<script>
					<%if(strStyle.length()  >0){%>
							showBranchOnLoad('branch4','<%=strStyle%>');
							<%strStyle = "";		
					  }%>
					</script>
					<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
						<tr>
							<td width="23%" height="20" valign="bottom" style="padding-left:80px;">Data Needed :</td>	  
							<%	if(vRetResult != null && vRetResult.size() > 0)
									strTemp = (String)vRetResult.elementAt(26);
								else
									strTemp =null; 
							%>
							<td width="77%">
							<input type="text" name="field_26" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
							onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="30"></td>
						</tr>	
						<tr>
							<td height="20" width="23%" valign="bottom" style="padding-left:80px;">Date</td>
							<%	if(vRetResult != null && vRetResult.size() > 0)
									strTemp = (String)vRetResult.elementAt(27);
								else
									strTemp =null; 	
							%>
							<td width="77%">
							<input name="field_27_date" type="text" size="12" maxlength="12" readonly="yes"
							value="<%=WI.getStrValue(strTemp)%>" 
							class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
							<a href="javascript:show_calendar('form_.field_27_date');" title="Click to select date" 
							onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
							<img src="../../../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
							</td>
						</tr>
						<!--<tr>
							<td height="20" width="23%" valign="bottom" style="padding-left:80px;">Department</td>
							<%	if(vRetResult != null && vRetResult.size() > 0)
									strTemp = (String)vRetResult.elementAt(28);	
								else
									strTemp =null; 			
							%>	
							<td>
							<select name="field_28" style="width:400px;">
							<option value="">N/A</option>
							<%=dbOP.loadCombo("d_index","d_name"," from department where IS_DEL=0 and IS_COLLEGE_DEPT=1 order by d_name asc", strTemp, false)%> 		
							</select>				
							</td>
						</tr>-->
					</table>
					</span>
					</td>
				</tr>		
				<tr>
					<td>&nbsp;</td>
					<%	if(vRetResult != null && vRetResult.size() > 0){
							strTemp = (String)vRetResult.elementAt(29);		
							if(WI.getStrValue(strTemp).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";		
						}else{
							strTemp = WI.fillTextValue("field_29");
							strErrMsg = "";	
						}	
					%>
					<td height="20" colspan="2">
					<%	if(strErrMsg.length() > 0)
							strStyle = "block";
						else
							strStyle = "";
					%>   	
					<input type="checkbox" onClick="showBranch('branch5');" name="field_29" id="folder5"  value="1" <%=strErrMsg%>>
					Module 2
					<span class="branch" id="branch5">
					<script>
					<%if(strStyle.length()  >0){%>
							showBranchOnLoad('branch5','<%=strStyle%>');
							<%strStyle = "";		
					  }%>
					</script>
					<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
						<tr>
							<td height="20" width="23%" valign="bottom" style="padding-left:80px;">Date</td>
							<%	if(vRetResult != null && vRetResult.size() > 0)
									strTemp = (String)vRetResult.elementAt(30);
								else
									strTemp =null; 	
							%>
							<td width="77%">
								<input name="field_30_date" type="text" size="12" maxlength="12" readonly="yes"
								value="<%=WI.getStrValue(strTemp)%>" 
								class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
								<a href="javascript:show_calendar('form_.field_30_date');" title="Click to select date" 
								onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
								<img src="../../../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
							</td>
						</tr>
						<!--<tr>
							<td height="20" width="23%" valign="bottom" style="padding-left:80px;">Department</td>
							<%	if(vRetResult != null && vRetResult.size() > 0)
									strTemp = (String)vRetResult.elementAt(31);
								else
									strTemp = null ; 			
							%>
							<td>
							<select name="field_31" style="width:400px;">
							<option value="">N/A</option>
							<%=dbOP.loadCombo("d_index","d_name"," from department where IS_DEL=0 and IS_COLLEGE_DEPT=1 order by d_name asc", strTemp, false)%> 		
							</select>				
							</td>
						</tr>-->
					</table>
					</span> 
					</td>
				</tr>
				<tr>
					<td width="9%" height="20">&nbsp;</td>
					<%	if(vRetResult != null && vRetResult.size() > 0){
						strTemp = (String)vRetResult.elementAt(32);		
						if(WI.getStrValue(strTemp).equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
						}else{
							strTemp = WI.fillTextValue("field_32");	
							strErrMsg = "";			
						}			
					%>
					<td height="20" colspan="2" >
					<input type="checkbox" name="field_32"  value="1" <%=strErrMsg%>>Job Interview Simulation</td>	 
				</tr>	
				<tr>
					<td width="9%" height="20">&nbsp;</td>
					<%	if(vRetResult != null && vRetResult.size() > 0){
							strTemp = (String)vRetResult.elementAt(33);		
							if(WI.getStrValue(strTemp).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						}else{
							strTemp = WI.fillTextValue("field_33");		
							strErrMsg = "";
						}			
					%>
					<td height="20" colspan="2">
					<input type="checkbox" name="field_33"  value="1" <%=strErrMsg%>>i-trabajo</td>	 
				</tr>	
				<tr>
					<td width="9%" height="20">&nbsp;</td>
					<%	if(vRetResult != null && vRetResult.size() > 0){
							strTemp = (String)vRetResult.elementAt(34);		
							if(WI.getStrValue(strTemp).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						}else{
							strTemp = WI.fillTextValue("field_34");		
							strErrMsg = "";
						}
					%>
					<td height="20" colspan="2">
					<input type="checkbox" name="field_34"  value="1" <%=strErrMsg%>>Directory of Graduates</td>	 
				</tr>
			</table>
			</span>		 
			</td>
		</tr>
		<tr>
			<td width="6%" height="20" >&nbsp;</td>
			<%	if(vRetResult != null && vRetResult.size() > 0){
					strTemp = (String)vRetResult.elementAt(35);		
					if(WI.getStrValue(strTemp).equals("1"))
						strErrMsg = "checked";
					else
						strErrMsg = "";
				}else{
					strTemp = WI.fillTextValue("field_35");		
					strErrMsg = "";
				}			
			%>
			<td height="20" colspan="2">
			<input type="checkbox" name="field_35"  value="1" <%=strErrMsg%>>Career Orientation</td>	 
		</tr>
	
		<tr>
			<td width="6%" height="20">&nbsp;</td>
			<%	if(vRetResult != null && vRetResult.size() > 0){
					strTemp = (String)vRetResult.elementAt(36);		
					if(WI.getStrValue(strTemp).equals("1"))
						strErrMsg = "checked";
					else
						strErrMsg = "";
				}else{
					strTemp = WI.fillTextValue("field_36");		
					strErrMsg="";
				}
			%>
			<td height="20" colspan="2">
			<%	if(strErrMsg.length() > 0)
					strStyle = "block";
				else
					strStyle = "";
			%>   	
			<input type="checkbox" onClick="showBranch('branch6');" id="folder6" name="field_36"  value="1" <%=strErrMsg%>>
			Information
			<span class="branch" id="branch6">
			<script>
			<%if(strStyle.length()  >0){%>
				showBranchOnLoad('branch6','<%=strStyle%>');
				<%strStyle = "";		
			  }%>
			</script>
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
				<tr>
					<td width="9%">&nbsp;</td>
					<%	if(vRetResult != null && vRetResult.size() > 0){
							strTemp = (String)vRetResult.elementAt(37);		
							if(WI.getStrValue(strTemp).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						}else{
							strTemp = WI.fillTextValue("field_37");	
							strErrMsg="";
						}			
					%>
					<td width="91%" height="20" colspan="2">	
					<%	if(strErrMsg.length() > 0)
							strStyle = "block";
						else
							strStyle = "";
					%>   		   
					<input type="checkbox" onClick="showBranch('branch7');" id="folder7" name="field_37"  value="1" 
					<%=strErrMsg%>>Learning Session<span class="branch" id="branch7">
					<script>
					<%if(strStyle.length()  >0){%>
						showBranchOnLoad('branch7','<%=strStyle%>');
						<%strStyle = "";		
					  }%>
					</script>
					<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
						<tr>
							<td width="23%" height="20" valign="bottom" style="padding-left:80px;">Data Needed :</td>	  
							<%  if(vRetResult != null && vRetResult.size() > 0)
									strTemp = (String)vRetResult.elementAt(38);
								else
									strTemp =null; 
							%>
							<td width="77%">
							<input type="text" name="field_38" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
							onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="30"></td>
						</tr>	
						<tr>
							<td height="20" width="23%" valign="bottom" style="padding-left:80px;">Date</td>
							<%	if(vRetResult != null && vRetResult.size() > 0)
									strTemp = (String)vRetResult.elementAt(39);
								else
									strTemp =null; 	
							%>
							<td width="77%">
							<input name="field_39_date" type="text" size="12" maxlength="12" readonly="yes"
							value="<%=WI.getStrValue(strTemp)%>" 
							class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
							<a href="javascript:show_calendar('form_.field_39_date');" title="Click to select date" 
							onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
							<img src="../../../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
							</td>
						</tr>
						<tr>
							<td width="23%" height="20" valign="bottom" style="padding-left:80px;">Title :</td>	  
							<%	if(vRetResult != null && vRetResult.size() > 0)
									strTemp = (String)vRetResult.elementAt(40);
								else
									strTemp =null; 
							%>
							<td width="77%">
							<input type="text" name="field_40" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
							onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="30"></td>
						</tr>				
					</table>
					</span>
					</td>
				</tr>				
				<tr>
					<td>&nbsp;</td>
					<%	if(vRetResult != null && vRetResult.size() > 0){
							strTemp = (String)vRetResult.elementAt(41);		
							if(WI.getStrValue(strTemp).equals("1"))
								strErrMsg = "checked";
							else
								strErrMsg = "";
						}else{
							strTemp = WI.fillTextValue("field_41");		
							strErrMsg="";			
						}
					%>
					<td height="20" colspan="2">			   
					<%
						if(strErrMsg.length() > 0)
							strStyle = "block";
						else
							strStyle = "";
					%>   		 
					<input type="checkbox" onClick="showBranch('branch8');" id="folder8" name="field_41"  value="1" 
					<%=strErrMsg%>>Fora<span class="branch" id="branch8">
					<script>
					<%if(strStyle.length()  >0){%>
						showBranchOnLoad('branch8','<%=strStyle%>');
						<%strStyle = "";		
					  }%>
					</script>
					<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
						<tr>
							<td height="20" width="23%" valign="bottom" style="padding-left:80px;">Date</td>
							<%	if(vRetResult != null && vRetResult.size() > 0)
									strTemp = (String)vRetResult.elementAt(42);
								else
									strTemp =null; 	
							%>
							<td width="77%">
							<input name="field_42_date" type="text" size="12" maxlength="12" readonly="yes"
							value="<%=WI.getStrValue(strTemp)%>" 
							class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
							<a href="javascript:show_calendar('form_.field_42_date');" title="Click to select date" 
							onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
							<img src="../../../../../images/calendar_new.gif" width="20" height="16" border="0"></a>	
							</td>
						</tr>
						<tr>
							<td width="23%" height="20" valign="bottom" style="padding-left:80px;">Title :</td>	  
							<%	if(vRetResult != null && vRetResult.size() > 0)
									strTemp = (String)vRetResult.elementAt(43);
								else
									strTemp =null; 
							%>
							<td width="77%">
							<input type="text" name="field_43" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
							onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="30">
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
			<%	if(vRetResult != null && vRetResult.size() > 0){
					strTemp = (String)vRetResult.elementAt(44);		
					if(WI.getStrValue(strTemp).equals("1"))
						strErrMsg = "checked";
					else
						strErrMsg = "";
				}else{
					strTemp = WI.fillTextValue("field_44");	
					strErrMsg="";				
				}			
			%>
			<td height="20" colspan="2">
			<input type="checkbox" name="field_44"  value="1" <%=strErrMsg%>>Peer Facilitating Program</td>	 
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
			<%if(vRetResult!=null && vRetResult.size()>0 && !bolIsEncoded){%>
				<input type="hidden" name="info_index" value="<%=(String)vRetResult.elementAt(0)%>">
				<a href="javascript:EditRecord('<%=(String)vRetResult.elementAt(0)%>');">
				<img src="../../../../../images/edit.gif" border="0"></a>
				<font size="1">click to edit entries</font>						
			<%}else{%>
				<a href="javascript:UpdateRecord();"><img src="../../../../../images/save.gif" border="0"></a>
				<font size="1">click to save entries</font>
			<%}%>
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
<input type="hidden" name="no_of_fields" value="50" >
<input type="hidden" name="page_action">
<input type="hidden" name="reload_page">
<input type="hidden" name="vDate" value="6,14,17,20,23,27,30,39,42">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>