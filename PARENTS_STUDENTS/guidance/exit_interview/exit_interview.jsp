<%@ page language="java" import="utility.*,java.util.Vector,enrollment.CourseRequirement,osaGuidance.GDExitInterview" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	
	String strUserId = (String)request.getSession(false).getAttribute("userId");
	String strAuthTypeIndex = (String)request.getSession(false).getAttribute("authTypeIndex");
	String strUserIndex = (String)request.getSession(false).getAttribute("userIndex");

	if((strUserId == null || strUserId.length() == 0) || !WI.getStrValue(strAuthTypeIndex).equals("4")){%>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		You are not authorized to view this page.</font></p>
	<%return;}%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Guidance Exit Interview</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
	div.thinborderBOTTOM{
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
	}
</style>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
/*function AjaxMapName() {
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
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+escape(strCompleteName);
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
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",
	'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function RefreshPage(){
	document.form_.reload_page.value="1";	
	document.form_.print_page.value ="";
	document.form_.submit();
}*/
function UpdateRecord(){
	document.form_.page_action.value = "1";
	document.form_.reload_page.value="1";		
	document.form_.print_page.value ="";
	document.form_.submit();
}
function EditRecord(strInfoIndex){		
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "2";
	document.form_.reload_page.value="1";	
	document.form_.print_page.value ="";
	document.form_.submit();
}
function PrintPg(strInfoIndex){
	document.form_.info_index.value = strInfoIndex;
	document.form_.print_page.value = "1";
	document.form_.submit();
}
</script>
</head>
<body bgcolor="#9FBFD0">
<%
	String strTemp = null;	
	String strErrMsg = null;
	
	/*if (WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./exit_interview_print.jsp" />
	    <%return;
	}*/
//add security here.
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
				"Admin/staff-Students Affairs-Guidance-Reports-Other(Guidance Services)","exit_interview.jsp");
	}catch(Exception exp){
		exp.printStackTrace();%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%return;
	}
//authenticate this user.
	

	//end of authenticaion code.	
Vector vRetResult  =null;
Vector vStudInfo  = null;
String strSYFrom = WI.fillTextValue("sy_from"); 
String strSYTo = WI.fillTextValue("sy_to"); 
String strSemester  = WI.fillTextValue("semester");

GDExitInterview gdExitInterview = new GDExitInterview();
enrollment.OfflineAdmission OA = new enrollment.OfflineAdmission();
gdExitInterview.setFieldNo(70);


strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(gdExitInterview.opearateGDExitInterview(dbOP, request, Integer.parseInt(strTemp),strUserIndex,strSYFrom,strSemester) == null)
		strErrMsg = gdExitInterview.getErrMsg();
	else{
		if(strTemp.equals("1"))
			strErrMsg = "Entry Succesfully Saved.";
		if(strTemp.equals("2"))
			strErrMsg = "Entry Succesfully Updated.";
	}
}
	
vStudInfo = OA.getStudentBasicInfo(dbOP,strUserId);
if (vStudInfo == null) 
	strErrMsg= OA.getErrMsg();	
else{
	strSYFrom = (String)vStudInfo.elementAt(10);
	strSYTo = (String)vStudInfo.elementAt(11);
	strSemester = (String)vStudInfo.elementAt(9);	
	
	strTemp = "select grad_cand_index from GRAD_CANDIDATE_LIST where is_valid =1 and is_del = 0 and STUD_INDEX = "+strUserIndex+
		" and sy_from = "+strSYFrom+" and semester="+strSemester;
	if(dbOP.getResultOfAQuery(strTemp, 0) != null){
		vRetResult = gdExitInterview.opearateGDExitInterview(dbOP, request, 4, strUserIndex, strSYFrom,strSemester);				
	}else{
		dbOP.cleanUP();
		strErrMsg = "Student is not yet a candidate for graduating student.";%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
<%	return;}
		
	
			
	
}
	
	
		
	
	
		
%>
<form action="./exit_interview.jsp" method="post" name="form_">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" id="myID1">
		<tr bgcolor="#A49A6A">
			<td width="100%" height="25" colspan="4" bgcolor="#47768F">
				<div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif">
				<strong>:::: GUIDANCE EXIT INTERVIEW ::::</strong></font></div>
			</td>
		</tr>
		<tr bgcolor="#FFFFFF">
			<td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
		</tr>
	</table>  
		
<!--	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr> 
			<td width="2%">&nbsp;</td>
			<td width="15%">ID Number</td>
			<td width="20%"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" 
			class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
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
			<td colspan="4">
			<a href="javascript:RefreshPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>	
		</tr>
	</table>-->
	
<% if(vStudInfo != null && vStudInfo.size() > 0 ){%>
<input type="hidden" name="stud_index" value="<%=strUserIndex%>">
<input type="hidden" name="sy_from" value="<%=strSYFrom%>">
<input type="hidden" name="sy_to" value="<%=strSYTo%>">
<input type="hidden" name="semester" value="<%=strSemester%>">
<table  width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
	<tr>
		<td width="6%" height="20" valign="bottom">Name:</td>
		<td width="36%" valign="bottom"><div style="border-bottom:solid 1px #000000;">
 <%=WebInterface.formatName((String)vStudInfo.elementAt(0), (String)vStudInfo.elementAt(1), (String)vStudInfo.elementAt(2), 4)%>
      </div></td>
		<td width="6%" valign="bottom" style="padding-left:20px;">Age:</td>
		
<% 

int iAge = CommonUtil.calculateAGE(ConversionTable.convertMMDDYYYYToDate(WI.getTodaysDate(1)),ConversionTable.convertMMDDYYYYToDate((String)vStudInfo.elementAt(19)));%>		
	  <td width="6%" valign="bottom"><div style="border-bottom:solid 1px #000000;">
	  <%=iAge%></div></td>
		<td width="9%" valign="bottom" style="padding-left:20px;">Gender:</td>
		<td width="6%" valign="bottom"><div style="border-bottom:solid 1px #000000;">
	  <%=(String)vStudInfo.elementAt(16)%></div></td>
	  <td width="8%" valign="bottom" style="padding-left:20px;">Date:</td>
	   <%	if(vRetResult != null && vRetResult.size() > 0)
				strTemp = (String)vRetResult.elementAt(1);
			else
				strTemp = WI.getTodaysDate(1);
	   %>
	  <td width="23%" valign="bottom" style="padding-right:20px;">
	  <div style="border-bottom:solid 1px #000000;">
	  <%=WI.getStrValue(strTemp)%>	  
	  </div>
	  </td>
	</tr>	
	<tr>
	   <td colspan="8" height="20" valign="bottom">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<tr>
					<td width="13%" height="20" valign="bottom">No. of years in UB:</td>
					  <%	
					  strTemp = "select distinct SY_FROM from STUD_CURRICULUM_HIST where IS_VALID = 1 "+
							" and USER_INDEX = "+strUserIndex;
					  java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
					  int iCount = 0;
					  while(rs.next())
					  	++iCount;
					  rs.close();
					  %>
				  	<td valign="bottom" colspan="3"><div class="thinborderBOTTOM" style="width:10%;"><%=iCount%></div></td>
					<td width="13%" valign="bottom" height="20" style="padding-left:20px;">Degree/Course:</td>
 				  <td width="56%" colspan="3" valign="bottom" style="padding-right:20px;">
				  <div style="border-bottom:solid 1px #000000;">
				    <%=(String)vStudInfo.elementAt(7)%>
					<%if(vStudInfo.elementAt(8) != null){%>
					/<%=(String)vStudInfo.elementAt(8)%>
					<%}%>
				  </div></td>
				</tr>
			</table>
	   </td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td height="25" colspan="3">&nbsp;</td>
	</tr>
	<tr>
		<td height="20" colspan="3"><strong>Part I. Personal Experience</strong></td>
	</tr>
	<tr>
		<td height="20" colspan="3">&nbsp;</td>
	</tr>
	<tr>
		<td width="3%" height="20">&nbsp;</td>
		<td colspan="2">1. What are your plans after graduation?</td>		
	</tr>
	<tr>
		<td colspan="2">&nbsp;</td>
		<td width="95%" height="20" valign="bottom">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<tr>
				 <%	strTemp = WI.fillTextValue("field_1");	
				 	if(vRetResult != null && vRetResult.size() > 0)
						strTemp = (String)vRetResult.elementAt(2);						
					if(WI.getStrValue(strTemp).equals("1"))
						strErrMsg = "checked";						
					else
						strErrMsg = "";
				 %>
					<td width="3%" valign="bottom" height="20">
			 	    <input type="checkbox" name="field_1" value="1" <%=strErrMsg%>></td>
					<td width="30%" valign="bottom">Proceed to Masteral/Doctoral/Law</td>
				 <%	strTemp = WI.fillTextValue("field_2");
				    if(vRetResult != null && vRetResult.size() > 0)
						strTemp = (String)vRetResult.elementAt(3);						
					if(WI.getStrValue(strTemp).equals("1"))
						strErrMsg = "checked";						
					else
						strErrMsg = "";					
				 %>
					<td width="3%" valign="bottom">
			  	    <input type="checkbox" name="field_2" value="1" <%=strErrMsg%>></td>
					<td width="64%" valign="bottom">Study another course</td>
				</tr>
				<tr>
				 <%	strTemp = WI.fillTextValue("field_3");
				  	if(vRetResult != null && vRetResult.size() > 0)
						strTemp = (String)vRetResult.elementAt(4);					
					if(WI.getStrValue(strTemp).equals("1"))
						strErrMsg = "checked";						
					else
						strErrMsg = "";
				%>
					<td valign="bottom" height="20">
					<input type="checkbox" name="field_3" value="1" <%=strErrMsg%>></td>
					<td valign="bottom">Look for a Job</td>
				 <%	strTemp = WI.fillTextValue("field_4");
				  	if(vRetResult != null && vRetResult.size() > 0)
						strTemp = (String)vRetResult.elementAt(5);						
					if(WI.getStrValue(strTemp).equals("1"))
						strErrMsg = "checked";						
					else
						strErrMsg = "";
					
				 %>
					<td valign="bottom">
					<input type="checkbox" name="field_4" value="1" <%=strErrMsg%> ></td>
					<td valign="bottom">Rest for a while</td>
				</tr>
				<tr>
				 <%	strTemp = WI.fillTextValue("field_5");
				 	if(vRetResult != null && vRetResult.size() > 0)
						strTemp = (String)vRetResult.elementAt(6);						
					if(WI.getStrValue(strTemp).equals("1"))
						strErrMsg = "checked";						
					else
						strErrMsg = "";					
				 %>
					<td valign="bottom" height="20">
					<input type="checkbox" name="field_5" value="1" <%=strErrMsg%>></td>
					<td valign="bottom">Travel</td>					
				 <%	strTemp = WI.fillTextValue("field_6");
				 	if(vRetResult != null && vRetResult.size() > 0)
						strTemp = (String)vRetResult.elementAt(7);						
					if(WI.getStrValue(strTemp).equals("1"))
						strErrMsg = "checked";						
					else
						strErrMsg = "";						
				 %>
					<td valign="bottom">
					<input type="checkbox" name="field_6" value="1"<%=strErrMsg%> ></td>
					<td valign="bottom">Get Married</td>
				</tr>
				<tr>
					<td colspan="4" height="20">&nbsp;</td>
				</tr>
				<tr>
				 <%	if(vRetResult != null && vRetResult.size() > 0)
						strTemp = (String)vRetResult.elementAt(8);
					else
						strTemp = null;							
				 %>
					<td colspan="4" height="20">Others please specify:
					<input type="text" name="field_7" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
					onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="style.backgroundColor='white';" size="40"></td>
				</tr>
			</table>
	  </td>
	</tr>
	<tr>
		<td height="20" colspan="3">&nbsp;</td>
	</tr>
	<tr>
		<td width="3%" height="20">&nbsp;</td>
		<td colspan="2">2. Have you enrolled in another course before taking up your present course? If yes, what course and what made you decide to shift?</td>		
	</tr>
	<tr>
		<td height="20">&nbsp;</td>
		<%	if(vRetResult != null && vRetResult.size() > 0)
				strTemp = (String)vRetResult.elementAt(9);
			else
				strTemp = null;							
		%>
	    <td height="20" colspan="2">
		<textarea name="field_8" cols="100" rows="4" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
		onBlur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp,"&nbsp;")%></textarea>
		</td>
	</tr>
	<tr>
		<td height="20" colspan="3">&nbsp;</td>
	</tr>
	<tr>
		<td width="3%" height="20">&nbsp;</td>
		<td colspan="2">3. What are the difficulties you encountered in your stay here at the university?</td>		
	</tr>
	<tr>
		<td height="20">&nbsp;</td>
		<%	if(vRetResult != null && vRetResult.size() > 0)
				strTemp = (String)vRetResult.elementAt(10);
			else
				strTemp = "";							
		%>
	    <td height="20" colspan="2">
		<textarea name="field_9" cols="100" rows="4" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
		onBlur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp,"&nbsp;")%></textarea>
		</td>
	</tr>
	<tr>
		<td height="20" colspan="3">&nbsp;</td>
	</tr>
	<tr>
		<td width="3%" height="20">&nbsp;</td>
		<td colspan="2">4. What caused the difficulty?</td>		
	</tr>
	<tr>
		<td height="20">&nbsp;</td>
		<%	if(vRetResult != null && vRetResult.size() > 0)
				strTemp = (String)vRetResult.elementAt(11);
			else
				strTemp = null;							
		%>
	    <td height="20" colspan="2">
		<textarea name="field_10" cols="100" rows="4" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
		onBlur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp)%></textarea>
		</td>
	</tr>
	<tr>
		<td height="20" colspan="3">&nbsp;</td>
	</tr>
	<tr>
		<td width="3%" height="20">&nbsp;</td>
		<td colspan="2">5. Who helped or assist you in overcoming them?</td>		
	</tr>
	<tr>
		<td height="20">&nbsp;</td>
		<%	if(vRetResult != null && vRetResult.size() > 0)
				strTemp = (String)vRetResult.elementAt(12);
			else
				strTemp = null;							
		%>
	    <td height="20" colspan="2">
		<textarea name="field_11" cols="100" rows="4" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
		onBlur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp)%></textarea>
		</td>
	</tr>
	<tr>
		<td height="20" colspan="3">&nbsp;</td>
	</tr>
	<tr>
		<td width="3%" height="20">&nbsp;</td>
		<td colspan="2">6. How did you overcome them?</td>		
	</tr>
	<tr>
		<td height="20">&nbsp;</td>
		<%	if(vRetResult != null && vRetResult.size() > 0)
				strTemp = (String)vRetResult.elementAt(13);
			else
				strTemp = null;							
		%>
	    <td height="20" colspan="2">
		<textarea name="field_12" cols="100" rows="4" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
		onBlur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp)%></textarea>
		</td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td height="25" colspan="3">&nbsp;</td>
	</tr>
	<tr>
		<td height="20" colspan="3"><strong>Part II. General Curriculum</strong></td>
	</tr>
	<tr>
		<td height="20" colspan="3">&nbsp;</td>
	</tr>
	<tr>
		<td width="3%" height="20">&nbsp;</td>
		<td colspan="2">1. Please rate your satisfaction with your present course in the following areas:</td>		
	</tr>
	<tr>
		<td height="25" colspan="3">&nbsp;</td>
	</tr>
	<tr>
		<td height="20">&nbsp;</td>
		<td colspan="2" valign="bottom">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:170px;" height="20">1- Needs Improvement</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:170px;" height="20">2- Moderately Satisfied</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:170px;" height="20">3- Satisfied</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:170px;" height="20">4- Very Satisfied</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:170px;" height="20">5- Outstanding</td>
				</tr>
			</table>	
		</td>	
	</tr>
	<tr>
		<td height="20" colspan="3">&nbsp;</td>
	</tr>
	<tr>
		<td height="20">&nbsp;</td>
		<td colspan="2">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<tr>
				  <td width="3%" height="20" valign="bottom" style="padding-left:20px;">&nbsp;</td>				  
				  <td valign="bottom">&nbsp;</td>
				  <td valign="bottom"align="center">1</td>
				  <td valign="bottom"align="center">2</td>
				  <td valign="bottom"align="center">3</td>
				  <td valign="bottom"align="center">4</td>
				  <td valign="bottom"align="center">5</td>
			      <td valign="bottom"align="center">&nbsp;</td>
				</tr>
				<tr>
					<td valign="bottom" style="padding-left:20px;" height="20">a. </td>
					<td width="53%" valign="bottom">Curriculum Design ( Courses in the Curriculum)</td>
					<% strTemp = WI.fillTextValue("field_13");
					   if(vRetResult != null && vRetResult.size() > 0)
							strTemp = WI.getStrValue((String)vRetResult.elementAt(14));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td width="5%" valign="bottom" align="center"><input type="radio" value="1" name="field_13" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
				 	<td width="5%" valign="bottom" align="center"><input type="radio" value="2" name="field_13" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
			  	  	<td width="5%" valign="bottom" align="center"><input type="radio" value="3" name="field_13" <%=strErrMsg%>></td>
				  	<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="5%" valign="bottom" align="center"><input type="radio" value="4" name="field_13" <%=strErrMsg%>></td>
				  	<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td width="5%" align="center" valign="bottom"><input type="radio" value="5" name="field_13" <%=strErrMsg%>></td>
				    <td width="19%" align="center" valign="bottom">&nbsp;</td>
				</tr>
				<tr>
					<td valign="bottom" style="padding-left:20px;" height="20">b.</td>
					<td valign="bottom"> Overall quality of instruction</td>
					<%	strTemp = WI.fillTextValue("field_14");
						if(vRetResult != null && vRetResult.size() > 0)
							strTemp = WI.getStrValue((String)vRetResult.elementAt(15));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td valign="bottom" align="center"><input type="radio" value="1" name="field_14" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="2" name="field_14" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="3" name="field_14" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="4" name="field_14" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" valign="bottom"><input type="radio" value="5" name="field_14" <%=strErrMsg%>></td>
				    <td align="center" valign="bottom">&nbsp;</td>
				</tr>
				<tr>
					<td valign="bottom" style="padding-left:20px;" height="20">c.</td>
					<td valign="bottom">  Relevance of course work to everyday life</td>
					<%	strTemp = WI.fillTextValue("field_15");
					    if(vRetResult != null && vRetResult.size() > 0)
							strTemp = WI.getStrValue((String)vRetResult.elementAt(16));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td valign="bottom" align="center"><input type="radio" value="1" name="field_15" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="2" name="field_15" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="3" name="field_15" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="4" name="field_15" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" valign="bottom"><input type="radio" value="5" name="field_15" <%=strErrMsg%>></td>
				    <td align="center" valign="bottom">&nbsp;</td>
				</tr>
				<tr>
					<td valign="bottom" style="padding-left:20px;" height="20">d.</td>
					<td valign="bottom"> Opportunity for Specialization</td>
					<%	strTemp = WI.fillTextValue("field_16");
					    if(vRetResult != null && vRetResult.size() > 0)
							strTemp = WI.getStrValue((String)vRetResult.elementAt(17));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td valign="bottom" align="center"><input type="radio" value="1" name="field_16" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="2" name="field_16" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="3" name="field_16" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="4" name="field_16" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" valign="bottom"><input type="radio" value="5" name="field_16" <%=strErrMsg%>></td>
				    <td align="center" valign="bottom">&nbsp;</td>
				</tr>
				<tr>
					<td valign="bottom" style="padding-left:20px;" height="20">e.</td>
					<td valign="bottom"> Laboratory Facilities and Equipement</td>
					<%	strTemp = WI.fillTextValue("field_17");
					    if(vRetResult != null && vRetResult.size() > 0)
							strTemp = WI.getStrValue((String)vRetResult.elementAt(18));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td valign="bottom" align="center"><input type="radio" value="1" name="field_17" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="2" name="field_17" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="3" name="field_17" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="4" name="field_17" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" valign="bottom"><input type="radio" value="5" name="field_17" <%=strErrMsg%>></td>
				    <td align="center" valign="bottom">&nbsp;</td>
				</tr>
				<tr>
					<td valign="bottom" style="padding-left:20px;" height="20">f.</td>
					<td valign="bottom"> Computer Facilities</td>
					<%	strTemp = WI.fillTextValue("field_18");
						if(vRetResult != null && vRetResult.size() > 0)
							strTemp = WI.getStrValue((String)vRetResult.elementAt(19));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td valign="bottom" align="center"><input type="radio" value="1" name="field_18" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="2" name="field_18" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="3" name="field_18" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="4" name="field_18" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" valign="bottom"><input type="radio" value="5" name="field_18" <%=strErrMsg%>></td>
				    <td align="center" valign="bottom">&nbsp;</td>
				</tr>
				<tr>
					<td valign="bottom" style="padding-left:20px;" height="20">g.</td>
					<td valign="bottom"> Tutoring and other academic assistance</td>
					<%	strTemp = WI.fillTextValue("field_19");
					    if(vRetResult != null && vRetResult.size() > 0)
							strTemp = WI.getStrValue((String)vRetResult.elementAt(20));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td valign="bottom" align="center"><input type="radio" value="1" name="field_19" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="2" name="field_19" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="3" name="field_19" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="4" name="field_19" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" valign="bottom"><input type="radio" value="5" name="field_19" <%=strErrMsg%>></td>
				    <td align="center" valign="bottom">&nbsp;</td>
				</tr>
				<tr>
					<td valign="bottom" style="padding-left:20px;" height="20">h.</td>
					<td valign="bottom"> Opportunities to participate in research </td>
					<%	strTemp = WI.fillTextValue("field_20");
					    if(vRetResult != null && vRetResult.size() > 0)
							strTemp = WI.getStrValue((String)vRetResult.elementAt(21));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td valign="bottom" align="center"><input type="radio" value="1" name="field_20" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="2" name="field_20" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="3" name="field_20" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="4" name="field_20" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" valign="bottom"><input type="radio" value="5" name="field_20" <%=strErrMsg%>></td>
				    <td align="center" valign="bottom">&nbsp;</td>
				</tr>
				<tr>
					<td valign="bottom" style="padding-left:20px;" height="20">i.</td>
					<td valign="bottom"> Opportunities for community service</td>
					<%	strTemp = WI.fillTextValue("field_21");
					    if(vRetResult != null && vRetResult.size() > 0)
							strTemp = WI.getStrValue((String)vRetResult.elementAt(22));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td valign="bottom" align="center"><input type="radio" value="1" name="field_21" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="2" name="field_21" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="3" name="field_21" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="4" name="field_21" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" valign="bottom"><input type="radio" value="5" name="field_21" <%=strErrMsg%>></td>
				    <td align="center" valign="bottom">&nbsp;</td>
				</tr>
				<tr>
					<td valign="bottom" style="padding-left:20px;" height="20">j.</td>
					<td valign="bottom"> Opportunities to develop leadership potentials</td>
					<%	strTemp = WI.fillTextValue("field_22");
					    if(vRetResult != null && vRetResult.size() > 0)
							strTemp = WI.getStrValue((String)vRetResult.elementAt(23));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td valign="bottom" align="center"><input type="radio" value="1" name="field_22" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="2" name="field_22" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="3" name="field_22" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="4" name="field_22" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" valign="bottom"><input type="radio" value="5" name="field_22" <%=strErrMsg%>></td>
				    <td align="center" valign="bottom">&nbsp;</td>
				</tr>
				<tr>
					<td valign="bottom" style="padding-left:20px;" height="20">k.</td>
					<td valign="bottom"> Sense of belongingness in the department</td>
					<%	strTemp = WI.fillTextValue("field_23");
					    if(vRetResult != null && vRetResult.size() > 0)
							strTemp = WI.getStrValue((String)vRetResult.elementAt(24));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td valign="bottom" align="center"><input type="radio" value="1" name="field_23" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="2" name="field_23" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="3" name="field_23" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="4" name="field_23" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" valign="bottom"><input type="radio" value="5" name="field_23" <%=strErrMsg%>></td>
				    <td align="center" valign="bottom">&nbsp;</td>
				</tr>
				<tr>
					<td valign="bottom" style="padding-left:20px;" height="20">l.</td>
					<td valign="bottom"> Sense of idendity being a UB student</td>
					<%	strTemp = WI.fillTextValue("field_24");
					    if(vRetResult != null && vRetResult.size() > 0)
							strTemp = WI.getStrValue((String)vRetResult.elementAt(25));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td valign="bottom" align="center"><input type="radio" value="1" name="field_24" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="2" name="field_24" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="3" name="field_24" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="4" name="field_24" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" valign="bottom"><input type="radio" value="5" name="field_24" <%=strErrMsg%>></td>
				    <td align="center" valign="bottom">&nbsp;</td>
				</tr>
				<tr>
					<td valign="bottom" style="padding-left:20px;" height="20">m.</td>
					<td valign="bottom"> Amount of contact with faculty</td>
					<%	strTemp = WI.fillTextValue("field_25");
					    if(vRetResult != null && vRetResult.size() > 0)
							strTemp = WI.getStrValue((String)vRetResult.elementAt(26));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td valign="bottom" align="center"><input type="radio" value="1" name="field_25" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="2" name="field_25" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="3" name="field_25" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="4" name="field_25" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" valign="bottom"><input type="radio" value="5" name="field_25" <%=strErrMsg%>></td>
				    <td align="center" valign="bottom">&nbsp;</td>
				</tr>
				<tr>
					<td valign="bottom" style="padding-left:20px;" height="20">n.</td>
					<td valign="bottom"> Interaction with other students</td>
					<%	strTemp = WI.fillTextValue("field_26");
					    if(vRetResult != null && vRetResult.size() > 0)
							strTemp = WI.getStrValue((String)vRetResult.elementAt(27));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td valign="bottom" align="center"><input type="radio" value="1" name="field_26" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="2" name="field_26" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="3" name="field_26" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="4" name="field_26" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" valign="bottom"><input type="radio" value="5" name="field_26" <%=strErrMsg%>></td>
				    <td align="center" valign="bottom">&nbsp;</td>
				</tr>				
			</table>	
		</td>	
	</tr>
	<tr>
		<td height="20" colspan="3">&nbsp;</td>
	</tr>
	<tr>
		<td width="3%" height="20">&nbsp;</td>
		<td colspan="2">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<tr>
					<td valign="bottom" height="20">
					2. Over - All impact of the General Curriculum</td>
					<%	strTemp = WI.fillTextValue("field_27");
						if(vRetResult != null && vRetResult.size() > 0)
							strTemp = WI.getStrValue((String)vRetResult.elementAt(28));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td width="5%" valign="bottom" align="center"><input type="radio" value="1" name="field_27" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
				 	<td width="5%" valign="bottom" align="center"><input type="radio" value="2" name="field_27" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
			  	  	<td width="5%" valign="bottom" align="center"><input type="radio" value="3" name="field_27" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
				  	<td width="5%" valign="bottom" align="center"><input type="radio" value="4" name="field_27" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
				  	<td width="5%" valign="bottom" align="center"><input type="radio" value="5" name="field_27" <%=strErrMsg%>></td>
				    <td width="19%" valign="bottom" align="center">&nbsp;</td>
				</tr>
			</table>
		</td>	
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td height="25" colspan="3">&nbsp;</td>
	</tr>
	<tr>
		<td height="20" colspan="3"><strong>Part III. Skills Acquired</strong></td>
	</tr>
	<tr>
		<td height="20" colspan="3">&nbsp;</td>
	</tr>
	<tr>
		<td width="3%" height="20">&nbsp;</td>
		<td colspan="2">1. Rate yourself in terms of the skills you are acquired in your stay in the University:</td>		
	</tr>
	<tr>
		<td height="25" colspan="3">&nbsp;</td>
	</tr>
	<tr>
		<td height="20">&nbsp;</td>
		<td colspan="2" valign="bottom">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:170px;" height="20">1- Needs Improvement</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:170px;" height="20">2- Moderately Satisfied</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:170px;" height="20">3- Satisfied</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:170px;" height="20">4- Very Satisfied</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:170px;" height="20">5- Outstanding</td>
				</tr>
			</table>	
		</td>	
	</tr>
	<tr>
		<td height="20" colspan="3">&nbsp;</td>
	</tr>
	<tr>
		<td height="20">&nbsp;</td>
		<td colspan="2">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<tr>
				  <td width="3%" height="20" valign="bottom" style="padding-left:20px;">&nbsp;</td>
				  <td valign="bottom">&nbsp;</td>
				  <td valign="bottom"align="center">1</td>
				  <td valign="bottom"align="center">2</td>
				  <td valign="bottom"align="center">3</td>
				  <td valign="bottom"align="center">4</td>
				  <td width="5%"align="center" valign="bottom">5</td>
			      <td width="19%" align="center" valign="bottom">&nbsp;</td>
				</tr>
				<tr>
					<td valign="bottom" style="padding-left:20px;" height="20">a.</td>
					<td valign="bottom"> Academic Preparation</td>
					<%	strTemp = WI.fillTextValue("field_28");
					    if(vRetResult != null && vRetResult.size() > 0)
							strTemp = WI.getStrValue((String)vRetResult.elementAt(29));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td width="5%" valign="bottom" align="center"><input type="radio" value="1" name="field_28" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
				 	<td width="5%" valign="bottom" align="center"><input type="radio" value="2" name="field_28" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
			  	  	<td width="5%" valign="bottom" align="center"><input type="radio" value="3" name="field_28" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
				  	<td width="5%" valign="bottom" align="center"><input type="radio" value="4" name="field_28" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
				  	<td valign="bottom" align="center"><input type="radio" value="5" name="field_28" <%=strErrMsg%>></td>
				    <td valign="bottom">&nbsp;</td>
				</tr>
				<tr>
					<td valign="bottom" style="padding-left:20px;" height="20">b.</td>
					<td valign="bottom"> Interpersonal Skills</td>
					<%	strTemp = WI.fillTextValue("field_29");
					    if(vRetResult != null && vRetResult.size() > 0)
							strTemp = WI.getStrValue((String)vRetResult.elementAt(30));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td valign="bottom" align="center"><input type="radio" value="1" name="field_29" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="2" name="field_29" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="3" name="field_29" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="4" name="field_29" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom"  align="center"><input type="radio" value="5" name="field_29" <%=strErrMsg%>></td>
				    <td valign="bottom">&nbsp;</td>
				</tr>
				<tr>
					<td valign="bottom" style="padding-left:20px;" height="20">c.</td>
					<td valign="bottom">  Ability to get along with people of different Races/cultures </td>
					<%	strTemp = WI.fillTextValue("field_30");
						if(vRetResult != null && vRetResult.size() > 0)
							strTemp = WI.getStrValue((String)vRetResult.elementAt(31));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td valign="bottom" align="center"><input type="radio" value="1" name="field_30" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="2" name="field_30" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="3" name="field_30" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="4" name="field_30" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="5" name="field_30" <%=strErrMsg%>></td>
				    <td valign="bottom">&nbsp;</td>
				</tr>
				<tr>
					<td valign="bottom" style="padding-left:20px;" height="20">d.</td>
					<td valign="bottom"> Religious beliefs and convictions</td>
					<%	strTemp = WI.fillTextValue("field_31");
						if(vRetResult != null && vRetResult.size() > 0)
							strTemp = WI.getStrValue((String)vRetResult.elementAt(32));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td valign="bottom" align="center"><input type="radio" value="1" name="field_31" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="2" name="field_31" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="3" name="field_31" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="4" name="field_31" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="5" name="field_31" <%=strErrMsg%>></td>
				    <td valign="bottom">&nbsp;</td>
				</tr>
				<tr>
					<td valign="bottom" style="padding-left:20px;" height="20">e.</td>
					<td valign="bottom"> Understanding of the problems facing our nation</td>
					<%	strTemp = WI.fillTextValue("field_32");
						if(vRetResult != null && vRetResult.size() > 0)
							strTemp = WI.getStrValue((String)vRetResult.elementAt(33));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td valign="bottom" align="center"><input type="radio" value="1" name="field_32" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="2" name="field_32" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="3" name="field_32" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="4" name="field_32" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="5" name="field_32" <%=strErrMsg%>></td>
				    <td valign="bottom">&nbsp;</td>
				</tr>
				<tr>
					<td valign="bottom" style="padding-left:20px;" height="20">f.</td>
					<td valign="bottom"> Understanding of global issues</td>
					<%	strTemp = WI.fillTextValue("field_33");
						if(vRetResult != null && vRetResult.size() > 0)
							strTemp = WI.getStrValue((String)vRetResult.elementAt(34));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td valign="bottom" align="center"><input type="radio" value="1" name="field_33" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="2" name="field_33" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="3" name="field_33" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="4" name="field_33" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="5" name="field_33" <%=strErrMsg%>></td>
				    <td valign="bottom">&nbsp;</td>
				</tr>
				<tr>
					<td valign="bottom" style="padding-left:20px;" height="20">g.</td>
					<td valign="bottom"> Mathematical skills</td>
					<%	strTemp = WI.fillTextValue("field_34");
						if(vRetResult != null && vRetResult.size() > 0)
							strTemp = WI.getStrValue((String)vRetResult.elementAt(35));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td valign="bottom" align="center"><input type="radio" value="1" name="field_34" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="2" name="field_34" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="3" name="field_34" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="4" name="field_34" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="5" name="field_34" <%=strErrMsg%>></td>
				    <td valign="bottom">&nbsp;</td>
				</tr>
				<tr>
					<td valign="bottom" style="padding-left:20px;" height="20">h.</td>
					<td valign="bottom"> Computer Skills </td>
					<%	strTemp = WI.fillTextValue("field_35");
						if(vRetResult != null && vRetResult.size() > 0)
							strTemp = WI.getStrValue((String)vRetResult.elementAt(36));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td valign="bottom" align="center"><input type="radio" value="1" name="field_35" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="2" name="field_35" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="3" name="field_35" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="4" name="field_35" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="5" name="field_35" <%=strErrMsg%>></td>
				    <td valign="bottom">&nbsp;</td>
				</tr>
				<tr>
					<td valign="bottom" style="padding-left:20px;" height="20">i.</td>
					<td valign="bottom"> Planning and Organizational Skills</td>
					<%	strTemp = WI.fillTextValue("field_36");
						if(vRetResult != null && vRetResult.size() > 0)
							strTemp = WI.getStrValue((String)vRetResult.elementAt(37));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td valign="bottom" align="center"><input type="radio" value="1" name="field_36" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="2" name="field_36" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="3" name="field_36" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="4" name="field_36" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="5" name="field_36" <%=strErrMsg%>></td>
				    <td valign="bottom">&nbsp;</td>
				</tr>
				<tr>
					<td valign="bottom" style="padding-left:20px;" height="20">j.</td>
					<td valign="bottom"> Oral and Communication Skills</td>
					<%	strTemp = WI.fillTextValue("field_37");
						if(vRetResult != null && vRetResult.size() > 0)
							strTemp = WI.getStrValue((String)vRetResult.elementAt(38));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td valign="bottom" align="center"><input type="radio" value="1" name="field_37" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="2" name="field_37" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="3" name="field_37" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="4" name="field_37" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="5" name="field_37" <%=strErrMsg%>></td>
				    <td valign="bottom">&nbsp;</td>
				</tr>
				<tr>
					<td valign="bottom" style="padding-left:20px;" height="20">k.</td>
					<td valign="bottom"> Decision - Making Skills</td>
					<%	strTemp = WI.fillTextValue("field_38");
						if(vRetResult != null && vRetResult.size() > 0)
							strTemp = WI.getStrValue((String)vRetResult.elementAt(39));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td valign="bottom" align="center"><input type="radio" value="1" name="field_38" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="2" name="field_38" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="3" name="field_38" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="4" name="field_38" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="5" name="field_38" <%=strErrMsg%>></td>
				    <td valign="bottom">&nbsp;</td>
				</tr>
				<tr>
					<td valign="bottom" style="padding-left:20px;" height="20">l.</td>
					<td valign="bottom"> Financial Management Skills</td>
					<%	strTemp = WI.fillTextValue("field_39");
						if(vRetResult != null && vRetResult.size() > 0)
							strTemp =WI.getStrValue( (String)vRetResult.elementAt(40));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td valign="bottom" align="center"><input type="radio" value="1" name="field_39" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="2" name="field_39" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="3" name="field_39" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="4" name="field_39" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="5" name="field_39" <%=strErrMsg%>></td>
				    <td valign="bottom">&nbsp;</td>
				</tr>
				<tr>
					<td valign="bottom" style="padding-left:20px;" height="20">m.</td>
					<td valign="bottom"> Critical thingking Skills</td>
					<%	strTemp = WI.fillTextValue("field_40");
						if(vRetResult != null && vRetResult.size() > 0)
							strTemp = WI.getStrValue((String)vRetResult.elementAt(41));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td valign="bottom" align="center"><input type="radio" value="1" name="field_40" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="2" name="field_40" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="3" name="field_40" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="4" name="field_40" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="5" name="field_40" <%=strErrMsg%>></td>
				    <td valign="bottom">&nbsp;</td>
				</tr>
				<tr>
					<td valign="bottom" style="padding-left:20px;" height="20">n.</td>
					<td valign="bottom"> Problem - Solving Skills</td>
					<%	strTemp = WI.fillTextValue("field_41");
						if(vRetResult != null && vRetResult.size() > 0)
							strTemp = WI.getStrValue((String)vRetResult.elementAt(42));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td valign="bottom" align="center"><input type="radio" value="1" name="field_41" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="2" name="field_41" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="3" name="field_41" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="4" name="field_41" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="5" name="field_41" <%=strErrMsg%>></td>
				    <td valign="bottom">&nbsp;</td>
				</tr>	
				<tr>
					<td valign="bottom" style="padding-left:20px;" height="20">o.</td>
					<td valign="bottom"> Conflict Resolution Skills </td>
					<%	strTemp = WI.fillTextValue("field_42");
						if(vRetResult != null && vRetResult.size() > 0)
							strTemp = WI.getStrValue((String)vRetResult.elementAt(43));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td valign="bottom" align="center"><input type="radio" value="1" name="field_42" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="2" name="field_42" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="3" name="field_42" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="4" name="field_42" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="5" name="field_42" <%=strErrMsg%>></td>
				    <td valign="bottom">&nbsp;</td>
				</tr>	
				<tr>
					<td valign="bottom" style="padding-left:20px;" height="20">p.</td>
					<td valign="bottom"> Teamwork and Teambuilding </td>
					<%	strTemp = WI.fillTextValue("field_43");
						if(vRetResult != null && vRetResult.size() > 0)
							strTemp = WI.getStrValue((String)vRetResult.elementAt(44));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td valign="bottom" align="center"><input type="radio" value="1" name="field_43" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="2" name="field_43" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="3" name="field_43" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="4" name="field_43" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="5" name="field_43" <%=strErrMsg%>></td>
				    <td width="0%" valign="bottom">&nbsp;</td>
				</tr>	
				<tr>
					<td valign="bottom" style="padding-left:20px;" height="20">q.</td>
					<td valign="bottom"> Ethics and Tolerance Skills </td>
					<%	strTemp = WI.fillTextValue("field_44");
						if(vRetResult != null && vRetResult.size() > 0)
							strTemp = WI.getStrValue((String)vRetResult.elementAt(45));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td valign="bottom" align="center"><input type="radio" value="1" name="field_44" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="2" name="field_44" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="3" name="field_44" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="4" name="field_44" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="5" name="field_44" <%=strErrMsg%>></td>
				    <td valign="bottom">&nbsp;</td>
				</tr>	
				<tr>
					<td valign="bottom" style="padding-left:20px;" height="20">r.</td>
					<td valign="bottom"> Personal Management Skills </td>
					<%	strTemp = WI.fillTextValue("field_45");
						if(vRetResult != null && vRetResult.size() > 0)
							strTemp = WI.getStrValue((String)vRetResult.elementAt(46));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td valign="bottom" align="center"><input type="radio" value="1" name="field_45" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="2" name="field_45" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="3" name="field_45" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="4" name="field_45" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%> 
					<td valign="bottom" align="center"><input type="radio" value="5" name="field_45" <%=strErrMsg%>></td>
				    <td valign="bottom">&nbsp;</td>
				</tr>	
				<tr>
					<td valign="bottom" style="padding-left:20px;" height="20">s.</td>
					<td valign="bottom"> Design and Planning Skills </td>
					<%	strTemp = WI.fillTextValue("field_46");
						if(vRetResult != null && vRetResult.size() > 0)
							strTemp = WI.getStrValue((String)vRetResult.elementAt(47));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td valign="bottom" align="center"><input type="radio" value="1" name="field_46" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="2" name="field_46" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="3" name="field_46" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="4" name="field_46" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="5" name="field_46" <%=strErrMsg%>></td>
				    <td valign="bottom">&nbsp;</td>
				</tr>	
				<tr>
					<td valign="bottom" style="padding-left:20px;" height="20">t.</td>
					<td valign="bottom"> Research and Investagation Skills </td>
					<%	strTemp = WI.fillTextValue("field_47");
						if(vRetResult != null && vRetResult.size() > 0)
							strTemp = WI.getStrValue((String)vRetResult.elementAt(48));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td valign="bottom" align="center"><input type="radio" value="1" name="field_47" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="2" name="field_47" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="3" name="field_47" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="4" name="field_47" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="5" name="field_47" <%=strErrMsg%>></td>
				    <td valign="bottom">&nbsp;</td>
				</tr>	
				<tr>
					<td valign="bottom" style="padding-left:20px;" height="20">u.</td>
					<td valign="bottom"> Listening Skills </td>
					<%	strTemp = WI.fillTextValue("field_48");
						if(vRetResult != null && vRetResult.size() > 0)
							strTemp = WI.getStrValue((String)vRetResult.elementAt(49));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td valign="bottom" align="center"><input type="radio" value="1" name="field_48" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="2" name="field_48" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="3" name="field_48" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="4" name="field_48" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="5" name="field_48" <%=strErrMsg%>></td>
				    <td valign="bottom">&nbsp;</td>
				</tr>	
				<tr>
					<td valign="bottom" style="padding-left:20px;" height="20">v.</td>
					<td valign="bottom"> Human Relations and Interpersonal Skills </td>
					<%	strTemp = WI.fillTextValue("field_49");
						if(vRetResult != null && vRetResult.size() > 0)
							strTemp = WI.getStrValue((String)vRetResult.elementAt(50));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td valign="bottom" align="center"><input type="radio" value="1" name="field_49" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="2" name="field_49" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="3" name="field_49" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="4" name="field_49" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="5" name="field_49" <%=strErrMsg%>></td>
				    <td valign="bottom">&nbsp;</td>
				</tr>	
				<tr>
					<td valign="bottom" style="padding-left:20px;" height="20">w.</td>
					<td valign="bottom"> Management and Administration Skills </td>
					<%	strTemp = WI.fillTextValue("field_50");
						if(vRetResult != null && vRetResult.size() > 0)
							strTemp = WI.getStrValue((String)vRetResult.elementAt(51));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td valign="bottom" align="center"><input type="radio" value="1" name="field_50" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="2" name="field_50" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="3" name="field_50" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="4" name="field_50" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="5" name="field_50" <%=strErrMsg%>></td>
				    <td valign="bottom">&nbsp;</td>
				</tr>	
				<tr>
					<td valign="bottom" style="padding-left:20px;" height="20">x.</td>
					<td valign="bottom"> Valuing Skills </td>
					<%	strTemp = WI.fillTextValue("field_51");
						if(vRetResult != null && vRetResult.size() > 0)
							strTemp = WI.getStrValue((String)vRetResult.elementAt(52));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td valign="bottom" align="center"><input type="radio" value="1" name="field_51" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="2" name="field_51" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="3" name="field_51" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="4" name="field_51" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="5" name="field_51" <%=strErrMsg%>></td>
				    <td valign="bottom">&nbsp;</td>
				</tr>	
				<tr>
					<td valign="bottom" style="padding-left:20px;" height="20">y.</td>
					<td valign="bottom"> Personal and Career Development Skills </td>
					<%	strTemp = WI.fillTextValue("field_52");
						if(vRetResult != null && vRetResult.size() > 0)
							strTemp = WI.getStrValue((String)vRetResult.elementAt(53));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td valign="bottom" align="center"><input type="radio" value="1" name="field_52" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="2" name="field_52" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="3" name="field_52" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="4" name="field_52" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="5" name="field_52" <%=strErrMsg%>></td>
				    <td valign="bottom">&nbsp;</td>
				</tr>									
			</table>	
		</td>	
	</tr>
	<tr>
		<td height="20" colspan="3">&nbsp;</td>
	</tr>
	<tr>
		<td width="3%" height="20">&nbsp;</td>
		<td colspan="2">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<tr>
					<td colspan="2" valign="bottom" height="20">
					2. Over - All Self - Evaluation</td>
					<%	strTemp = WI.fillTextValue("field_53");
						if(vRetResult != null && vRetResult.size() > 0)
							strTemp = WI.getStrValue((String)vRetResult.elementAt(54));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td width="5%" valign="bottom" align="center"><input type="radio" value="1" name="field_53" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
				 	<td width="5%" valign="bottom" align="center"><input type="radio" value="2" name="field_53" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
			  	  	<td width="5%" valign="bottom" align="center"><input type="radio" value="3" name="field_53" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
				  	<td width="5%" valign="bottom" align="center"><input type="radio" value="4" name="field_53" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
				  	<td width="5%" valign="bottom" align="center"><input type="radio" value="5" name="field_53" <%=strErrMsg%>></td>
				    <td width="19%" valign="bottom" align="center">&nbsp;</td>
				</tr>
			</table>
		</td>	
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td height="25" colspan="3">&nbsp;</td>
	</tr>
	<tr>
		<td height="20" colspan="3"><strong>Part IV. Administration, Faculty, and Student Services Staff</strong></td>
	</tr>
	<tr>
		<td height="20" colspan="3">&nbsp;</td>
	</tr>
	<tr>
		<td width="3%" height="20">&nbsp;</td>
		<td colspan="2">1. Rate the Adminstrators, Faculty Members, Staff and Student Service in your stay in the University:</td>		
	</tr>
	<tr>
		<td height="25" colspan="3">&nbsp;</td>
	</tr>
	<tr>
		<td height="20">&nbsp;</td>
		<td colspan="2" valign="bottom">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:170px;" height="20">1- Needs Improvement</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:170px;" height="20">2- Moderately Satisfied</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:170px;" height="20">3- Satisfied</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:170px;" height="20">4- Very Satisfied</td>
				</tr>
				<tr>
					<td colspan="2" valign="bottom" style="padding-left:170px;" height="20">5- Outstanding</td>
				</tr>
			</table>	
		</td>	
	</tr>
	<tr>
		<td height="20" colspan="2">&nbsp;</td>
	</tr>
	<tr>
		<td height="20">&nbsp;</td>
		<td colspan="2">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<tr>
				  <td width="3%" height="20" valign="bottom" style="padding-left:20px;">&nbsp;</td>
				  <td valign="bottom">&nbsp;</td>
				  <td valign="bottom"align="center">1</td>
				  <td valign="bottom"align="center">2</td>
				  <td valign="bottom"align="center">3</td>
				  <td valign="bottom"align="center">4</td>
				  <td valign="bottom"align="center">5</td>
			      <td valign="bottom"align="center">&nbsp;</td>
				</tr>
				<tr>
					<td valign="bottom" style="padding-left:20px;" height="20">1. </td>
					<td width="53%" valign="bottom">How is your relationship with your administrators?</td>
					<%	strTemp = WI.fillTextValue("field_54");
						if(vRetResult != null && vRetResult.size() > 0)
							strTemp = WI.getStrValue((String)vRetResult.elementAt(55));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td width="5%" valign="bottom" align="center"><input type="radio" value="1" name="field_54" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
				 	<td width="5%" valign="bottom" align="center"><input type="radio" value="2" name="field_54" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
			  	  	<td width="5%" valign="bottom" align="center"><input type="radio" value="3" name="field_54" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
				  	<td width="5%" valign="bottom" align="center"><input type="radio" value="4" name="field_54" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
				  	<td width="5%" align="center" valign="bottom"><input type="radio" value="5" name="field_54" <%=strErrMsg%>></td>
				    <td width="19%" align="center" valign="bottom">&nbsp;</td>
				</tr>
				<tr>
					<td valign="bottom" style="padding-left:20px;" height="20">2.</td>
					<td valign="bottom"> How is your relationship with your teachers?</td>
					<%	strTemp = WI.fillTextValue("field_55");
						if(vRetResult != null && vRetResult.size() > 0)
							strTemp = WI.getStrValue((String)vRetResult.elementAt(56));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td valign="bottom" align="center"><input type="radio" value="1" name="field_55" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="2" name="field_55" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="3" name="field_55" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="4" name="field_55" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" valign="bottom"><input type="radio" value="5" name="field_55" <%=strErrMsg%>></td>
				    <td align="center" valign="bottom">&nbsp;</td>
				</tr>
				<tr>
					<td valign="bottom" style="padding-left:20px;" height="20">3.</td>
					<td valign="bottom">  How is your relationship with the following areas?</td>
					<td valign="bottom" colspan="6">&nbsp;</td>
				</tr>
				<tr>
					<td valign="bottom" height="20">&nbsp;</td>
					<td valign="bottom" style="padding-left:40px;">Health Services</td>
					<%	strTemp = WI.fillTextValue("field_56");
						if(vRetResult != null && vRetResult.size() > 0)
							strTemp = WI.getStrValue((String)vRetResult.elementAt(57));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td valign="bottom" align="center"><input type="radio" value="1" name="field_56" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="2" name="field_56" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="3" name="field_56" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="4" name="field_56" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" valign="bottom"><input type="radio" value="5" name="field_56" <%=strErrMsg%>></td>
				    <td align="center" valign="bottom">&nbsp;</td>
				</tr>
				<tr>
					<td valign="bottom" height="20">&nbsp;</td>
					<td valign="bottom" style="padding-left:40px;">Guidance Center</td>
					<%	strTemp = WI.fillTextValue("field_57");
						if(vRetResult != null && vRetResult.size() > 0)
							strTemp = WI.getStrValue((String)vRetResult.elementAt(58));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td valign="bottom" align="center"><input type="radio" value="1" name="field_57" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="2" name="field_57" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="3" name="field_57" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="4" name="field_57" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" valign="bottom"><input type="radio" value="5" name="field_57" <%=strErrMsg%>></td>
				    <td align="center" valign="bottom">&nbsp;</td>
				</tr>	
				<tr>
					<td valign="bottom" height="20">&nbsp;</td>
					<td valign="bottom" style="padding-left:40px;">Student Affairs</td>
					<%	strTemp = WI.fillTextValue("field_58");
						if(vRetResult != null && vRetResult.size() > 0)
							strTemp = WI.getStrValue((String)vRetResult.elementAt(59));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td valign="bottom" align="center"><input type="radio" value="1" name="field_58" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="2" name="field_58" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="3" name="field_58" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="4" name="field_58" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" valign="bottom"><input type="radio" value="5" name="field_58" <%=strErrMsg%>></td>
				    <td align="center" valign="bottom">&nbsp;</td>
				</tr>	
				<tr>
					<td valign="bottom" height="20">&nbsp;</td>
					<td valign="bottom" style="padding-left:40px;">Library Services</td>
					<%	strTemp = WI.fillTextValue("field_59");
						if(vRetResult != null && vRetResult.size() > 0)
							strTemp = WI.getStrValue((String)vRetResult.elementAt(60));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td valign="bottom" align="center"><input type="radio" value="1" name="field_59" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="2" name="field_59" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="3" name="field_59" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="4" name="field_59" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" valign="bottom"><input type="radio" value="5" name="field_59" <%=strErrMsg%>></td>
				    <td align="center" valign="bottom">&nbsp;</td>
				</tr>	
				<tr>
					<td valign="bottom" height="20">&nbsp;</td>
					<td valign="bottom" style="padding-left:40px;">Registrar</td>
					<%	strTemp = WI.fillTextValue("field_60");
						if(vRetResult != null && vRetResult.size() > 0)
							strTemp = WI.getStrValue((String)vRetResult.elementAt(61));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td valign="bottom" align="center"><input type="radio" value="1" name="field_60" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="2" name="field_60" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="3" name="field_60" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="4" name="field_60" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" valign="bottom"><input type="radio" value="5" name="field_60" <%=strErrMsg%>></td>
				    <td align="center" valign="bottom">&nbsp;</td>
				</tr>	
				<tr>
					<td valign="bottom" height="20">&nbsp;</td>
					<td valign="bottom" style="padding-left:40px;">Treasurer</td>
					<%	strTemp = WI.fillTextValue("field_61");
						if(vRetResult != null && vRetResult.size() > 0)
							strTemp = WI.getStrValue((String)vRetResult.elementAt(62));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td valign="bottom" align="center"><input type="radio" value="1" name="field_61" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="2" name="field_61" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="3" name="field_61" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td valign="bottom" align="center"><input type="radio" value="4" name="field_61" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
					<td align="center" valign="bottom"><input type="radio" value="5" name="field_61" <%=strErrMsg%>></td>
				    <td align="center" valign="bottom">&nbsp;</td>
				</tr>			
				<tr>
					<td colspan="2" valign="bottom" height="20">Over - all rating</td>
					<%	strTemp = WI.fillTextValue("field_62");
						if(vRetResult != null && vRetResult.size() > 0)
							strTemp = WI.getStrValue((String)vRetResult.elementAt(63));		
						if(strTemp.equals("1"))
							strErrMsg = "checked";
						else
							strErrMsg = "";						
					%>
					<td valign="bottom" align="center"><input type="radio" value="1" name="field_62" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("2"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
				 	<td valign="bottom" align="center"><input type="radio" value="2" name="field_62" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("3"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
			  	  	<td valign="bottom" align="center"><input type="radio" value="3" name="field_62" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("4"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
				  	<td valign="bottom" align="center"><input type="radio" value="4" name="field_62" <%=strErrMsg%>></td>
					<%	if(strTemp.equals("5"))
							strErrMsg = "checked";
						else
							strErrMsg = "";
					%>
				  	<td align="center" valign="bottom"><input type="radio" value="5" name="field_62" <%=strErrMsg%>></td>
				    <td width="19%" align="center" valign="bottom">&nbsp;</td>
				</tr>			
			</table>	
		</td>	
	</tr>	
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td height="25" colspan="3">&nbsp;</td>
	</tr>
	<tr>
		<td height="20" colspan="3"><strong>Part V. General Considerations</strong></td>
	</tr>
	<tr>
		<td height="20" colspan="3">&nbsp;</td>
	</tr>
	<tr>
		<td width="3%" height="20">&nbsp;</td>
		<td colspan="2">1. What are some of the weakness of UB as an educational institution?</td>		
	</tr>
	<tr>
		<td height="20">&nbsp;</td>
		<%	if(vRetResult != null && vRetResult.size() > 0)
				strTemp = (String)vRetResult.elementAt(64);	
			else
				strErrMsg = null;						
		%>
		<td colspan="2"><textarea name="field_63" cols="100" rows="4" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
		onBlur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp)%></textarea></td>
	</tr>
	<tr>
		<td height="25" colspan="3">&nbsp;</td>
	</tr>
	<tr>
		<td width="3%" height="20">&nbsp;</td>
		<td colspan="2">2. What are some of the strengths of UB as an educational institution?</td>		
	</tr>
	<tr>
		<td height="20">&nbsp;</td>
		<%	if(vRetResult != null && vRetResult.size() > 0)
				strTemp = (String)vRetResult.elementAt(65);	
			else
				strErrMsg = null;						
		%>
		<td colspan="2"><textarea name="field_64" cols="100" rows="4" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
		onBlur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp)%></textarea></td>
	</tr>
	<tr>
		<td height="25" colspan="3">&nbsp;</td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<Td colspan="3">&nbsp;</Td></tr>
	<tr>
		<td height="25" colspan="5"><div align="center">
			<%if(vRetResult!=null){%>
					<a href="javascript:EditRecord('<%=(String)vRetResult.elementAt(0)%>');">
					<img src="../../../images/edit.gif" border="0"></a>
					<font size="1">click to edit entries</font>						
			  <%}else{%>
					<a href="javascript:UpdateRecord();"><img src="../../../images/save.gif" border="0"></a>
					<font size="1">click to save entries</font>
			  <%}%>
			 </div></td>
	</tr>
</table>
<%}//end of vStudInfo != null%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myID4">
	<tr>
		<td height="25">&nbsp;</td>
	</tr>
	<tr bgcolor="#B8CDD1">
		<td height="25" bgcolor="#A49A6A">&nbsp;</td>
	</tr>
</table>
<input type="hidden" name="no_of_fields" value="70">
<input type="hidden" name="print_page" >
<input type="hidden" name="page_action">
<input type="hidden" name="reload_page">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="stud_id" value="<%=strUserId%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>