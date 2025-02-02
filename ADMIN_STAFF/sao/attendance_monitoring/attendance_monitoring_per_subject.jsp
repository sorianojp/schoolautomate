<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

String strEmpIndex = (String)request.getSession(false).getAttribute("userIndex");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
table#classgrid {
	font-family: verdana,arial,sans-serif;
	font-size:7pt;
	color:#333333;
	border: 1px solid #666666;
	border-collapse: collapse;
}
table#classgrid td {
	font-size:7pt;
	border: 1px solid #666666;
	background-color: #ffffff;
}


 /*this is what we want the div to look like*/
  div.processing{
    display:block;

    /*set the div in the bottom right corner*/
    position:absolute;
    right:0;
	top:0;
    width:350px;
	height:200;/** it expands on its own.. **/
    
    /*give it some background and border
    background:#007fb7;*/
	background:#FFCC99;
    border:1px solid #ddd;
  }


</style>

</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">

function HideLayer(strDiv) {			
	document.getElementById(strDiv).style.visibility = 'hidden';
	document.form_.show_claimed_cc.checked = false;
}

function ShowLayer(strDiv) {	
	if(document.form_.show_claimed_cc.checked)	
		document.getElementById(strDiv).style.visibility = 'visible';
	else
		document.getElementById(strDiv).style.visibility = 'hidden';
}
function PrintPg()
{
	document.bgColor = "#FFFFFF";

	document.getElementById("idNumber1").deleteRow(0);
	document.getElementById("idNumber1").deleteRow(0);
	document.getElementById("idNumber1").deleteRow(0);
	document.getElementById("idNumber1").deleteRow(0);	
	document.getElementById("idNumber1").deleteRow(0);
	
	document.getElementById("idNumber2").deleteRow(0);
	document.getElementById("idNumber2").deleteRow(0);
	document.getElementById("idNumber2").deleteRow(0);	
	document.getElementById("idNumber2").deleteRow(0);
	document.getElementById("idNumber2").deleteRow(0);
	
	
	document.getElementById("idNumber3").deleteRow(0);
	document.getElementById("idNumber3").deleteRow(0);	
	document.getElementById("idNumber3").deleteRow(0);
	
	document.getElementById("idNumber4").deleteRow(0);
	document.getElementById("idNumber4").deleteRow(0);

	
	
	document.getElementById("idNumber6").deleteRow(0);
	
	

	window.print();
}
function ReloadPage()
{		
	if(document.form_.subject)
		document.form_.sub_code_.value = document.form_.subject[document.form_.subject.selectedIndex].text;
	document.form_.submit();
}
function ShowCList()
{	
	document.form_.showCList.value="1";
	ReloadPage();
}

function PageAction(strAction){	
		
	document.form_.page_action.value = strAction;
	this.ShowCList();


}
</script>

<body onLoad="HideLayer('processing2');">
<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector"%>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strErrMsg = null;
	String strTemp = null;
	String strDegType = null;//0-> uG,1->doctoral,2->college of medicine.
	String strDegreeType = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Faculty/Acad. Admin-Class Management-Attendance","attendance_monitoring_per_subject.jsp");		
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
														"Enrollment","REPORTS",request.getRemoteAddr(),
														null);

if(iAccessLevel == 0)
iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Faculty/Acad. Admin","CLASS MANAGEMENT",request.getRemoteAddr(), 
														"attendance_monitoring_per_subject.jsp");
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
Vector vRetResult = null;
Vector vSecList = null;
Vector vSubList = null;
Vector vSecDetail = null;
Vector vClassList = null;


enrollment.AttendanceMonitoringCDD attendanceCDD = new enrollment.AttendanceMonitoringCDD();
ReportEnrollment reportEnrl= new ReportEnrollment();
String strSubSecIndex = null;


boolean bolIsAllowedToEncode = attendanceCDD.isAllowedToEncode(dbOP, strEmpIndex, WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"), WI.fillTextValue("offering_sem"));
String strEncodeErrMsg = attendanceCDD.getErrMsg();


strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(attendanceCDD.operateOnAttendanceMonitoringCDD(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = attendanceCDD.getErrMsg();
	else{
		if(strTemp.equals("0"))
			strErrMsg = "Entry Successfully Deleted.";
		if(strTemp.equals("1"))
			strErrMsg = "Entry Successfully Saved.";
		if(strTemp.equals("2"))
			strErrMsg = "Entry Successfully Updated.";
	}
}

if (WI.fillTextValue("sub_sec_index").length() == 0 ){
	if(WI.fillTextValue("section_name").length() > 0 && WI.fillTextValue("subject").length() > 0) {
		strSubSecIndex =
			dbOP.mapOneToOther("E_SUB_SECTION join faculty_load " +
					 " on (faculty_load.sub_sec_index = e_sub_section.sub_sec_index) ",
					"section","'"+WI.fillTextValue("section_name")+"'"," e_sub_section.sub_sec_index",
					" and e_sub_section.sub_index = "+WI.fillTextValue("subject")+
					" and faculty_load.is_valid = 1 and e_sub_section.is_valid =1 and e_sub_section.offering_sy_from = "+
					WI.fillTextValue("sy_from")+ " and e_sub_section.offering_sy_to = "+
					WI.fillTextValue("sy_to")+ " and e_sub_section.offering_sem="+
					WI.fillTextValue("offering_sem")+" and is_lec=0");
	}
}
else
	strSubSecIndex = WI.fillTextValue("sub_sec_index");

if(strSubSecIndex != null && strSubSecIndex.length() > 0) {//get here subject section detail.
	vSecDetail = reportEnrl.getSubSecSchDetail(dbOP,strSubSecIndex);
	if(vSecDetail == null)
		strErrMsg = reportEnrl.getErrMsg();
	//vStudListWithDropSub = gsExtn.getStudListWithSubStatChanged(dbOP, strSubSecIndex);
}

Vector vIDList = new Vector();
if(vSecDetail != null && vSecDetail.size() > 0 && WI.fillTextValue("showCList").length() > 0)
{
	
	strTemp = "select id_number, fname, mname, lname from user_table join enrl_final_cur_list as efcl on (efcl.user_index = user_table.user_index) "+
		" where efcl.is_valid =1 and is_temp_stud = 0 "+
		" and sub_Sec_index = "+strSubSecIndex+
		" and sy_from = "+WI.fillTextValue("sy_from")+
		" and current_semester = "+WI.fillTextValue("offering_sem")+
		" order by lname, fname, mname";
	 java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
	 while(rs.next()){
		 vIDList.addElement(rs.getString(1));
		 strTemp = WebInterface.formatName(rs.getString(2),rs.getString(3),rs.getString(4),4);
		 vIDList.addElement(strTemp);
	 }rs.close();
	
}

String strEnrollIndex = null;
if(WI.fillTextValue("stud_id").length() > 0 && strSubSecIndex != null && strSubSecIndex.length()  >0){
	strTemp = "select  enroll_index from user_table join enrl_final_cur_list as efcl on (efcl.user_index = user_table.user_index) "+
		" where efcl.is_valid =1 and is_temp_stud = 0 "+
		" and id_number = '"+WI.fillTextValue("stud_id")+
		"' and sub_Sec_index = "+strSubSecIndex+
		" and sy_from = "+WI.fillTextValue("sy_from")+
		" and current_semester = "+WI.fillTextValue("offering_sem");
	strEnrollIndex = dbOP.getResultOfAQuery(strTemp, 0);
}


Vector vStudDtls = attendanceCDD.operateOnAttendanceMonitoringCDD(dbOP, request, 5);
	
vRetResult = attendanceCDD.operateOnAttendanceMonitoringCDD(dbOP, request, 4);
//if(vRetResult == null)
//	strErrMsg = attendanceCDD.getErrMsg();

String strEmployeeID = (String)request.getSession(false).getAttribute("userId");
String strEmployeeIndex = dbOP.mapUIDToUIndex(strEmployeeID);
%>
<form name="form_" method="post" action="attendance_monitoring_per_subject.jsp">
	
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0" id="idNumber1">
    <tr bgcolor="#A49A6A" >
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          REPORTS - ATTENDANCE SHEET PAGE ::::        
          </strong></font></div></td>
    </tr>
  

<input type="hidden" name="section" value="<%=WI.getStrValue(strSubSecIndex)%>">
<input type="hidden" name="prevent_fwd" value="<%=WI.fillTextValue("prevent_fwd")%>">
<input type="hidden" name="show_delete">
<input type="hidden" name="show_save">
    <tr>
      <td height="25" colspan="6">&nbsp;&nbsp;&nbsp;<strong><font size="3" color="#FF0000">
	  <%=WI.getStrValue(strErrMsg,"MESSAGE: ","","")%></font></strong></td>
    </tr>

    <tr>
      <td height="25" colspan="6">&nbsp;&nbsp;&nbsp; 

	  <strong><font color="blue">NOTE: Subject/Sections appear are the sections handled by the logged in faculty Employee ID: <%=strEmployeeID%></font></strong>	  </td>
    </tr>
    <tr>
      <td width="1%" height="25" rowspan="4" >&nbsp;</td>
      <td width="22%" valign="bottom" >Term</td>
      <td width="27%" valign="bottom" >School Year</td>
      <td colspan="2" >&nbsp; </td>
      <td width="8%" >&nbsp;</td>
    </tr>
<%
String strTerm = WI.fillTextValue("offering_sem");
%>
    <tr>
      <td valign="bottom" >
	  <select name="offering_sem" onChange="ReloadPage();">
	  
          <option value="1">1st Sem</option>
          <%
if(strTerm.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
<%}else{%>
          <option value="2">2nd Sem</option>
<%}if(strTerm.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
<%}else{%>
          <option value="3">3rd Sem</option>
<%}if(strTerm.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
<%}else{%>
          <option value="0">Summer</option>
<%}%>
        </select></td>
      <td valign="bottom" >
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        -
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  readonly="yes">      </td>
      <td colspan="2" >
	  	<a href="javascript:ShowCList();"><img src="../../../images/form_proceed.gif" border="0"></a>	  
		
	 
		</td>
      <td width="8%" >&nbsp;</td>
    </tr>
</table>
  

<%
if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_to").length() >0){
%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" id="idNumber2">
    <tr>
      <td width="1%"></td>
      <td width="39%" height="25" valign="bottom" >Section Handled</td>
      <td valign="bottom" >Instructor (Name of logged in user)</td>
    </tr>
    <tr>
      <td></td>
      <td height="25" >
        <%
strTemp = " from e_sub_section join FACULTY_LOAD on (FACULTY_LOAD.sub_sec_index = e_sub_section.sub_sec_index)  where "+
			"faculty_load.is_valid = 1 and e_sub_section.is_valid = 1 and e_sub_section.OFFERING_SY_FROM ="+
			WI.fillTextValue("sy_from")+" and e_sub_section.OFFERING_SEM = "+WI.fillTextValue("offering_sem")+" and faculty_load.user_index = "+
			strEmployeeIndex;
%>
        <select name="section_name" onChange="ReloadPage();">
          <option value="">Select a section</option>
          <%=dbOP.loadCombo("distinct section","section",strTemp, request.getParameter("section_name"), false)%>
        </select> </td>
      <td height="25" > <strong>
        <%if(vSecDetail != null){%>
        <%=WI.getStrValue(vSecDetail.elementAt(0))%>
        <%}%>
        </strong> </td>
    </tr>
    <tr>
      <td width="1%"></td>
      <td height="25">Subject Handled</td>
      <td>Subject Title </td>
    </tr>
    <tr>
      <td width="1%"></td>
      <td height="25" >
        <%
strTemp = " from faculty_load join e_sub_section on (faculty_load.sub_sec_index = e_sub_section.sub_sec_index) "+
			"join subject on (e_sub_section.sub_index = subject.sub_index) where faculty_load.user_index = "+
			strEmployeeIndex+" and e_sub_section.section = '"+WI.fillTextValue("section_name")+
			"' and faculty_load.is_valid = 1 and e_sub_section.offering_sy_from = "+
			WI.fillTextValue("sy_from")+" and e_sub_section.offering_sy_to = "+WI.fillTextValue("sy_to")+
			" and e_sub_section.offering_sem="+WI.fillTextValue("offering_sem");
			
//System.out.println(strTemp);%>
        <select name="subject" onChange="ShowCList();" >
          <option value="">Select a subject</option>
          <%=dbOP.loadCombo("distinct subject.sub_index","sub_code",strTemp, request.getParameter("subject"), false)%>
        </select></td>
      <td> <strong>
        <%
if(WI.fillTextValue("subject").length() > 0) {
	strTemp = dbOP.mapOneToOther("SUBJECT","SUB_INDEX",request.getParameter("subject"),"sub_name"," and is_del=0");
%>
      <%=WI.getStrValue(strTemp)%></strong></td>
      <%}%>
    </tr>
    
  </table>
<%
}

if(vSecDetail != null){%>
  <table width="100%" border="0" cellspacing="1" cellpadding="1" bgcolor="#FFFFFF" id="idNumber3">
    <tr>
      <td width="15%">&nbsp;</td>
      <td width="24%" bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>ROOM
          NUMBER</strong></font></div></td>
      <td width="20%" bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>LOCATION</strong></font></div></td>
      <td width="26%" bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>SCHEDULE</strong></font></div></td>
      <td width="15%">&nbsp;</td>
    </tr>
    <%for(int i = 1; i<vSecDetail.size(); i+=3){%>
    <tr>
      <td>&nbsp;</td>
      <td align="center"><%=(String)vSecDetail.elementAt(i)%></td>
      <td align="center"><%=(String)vSecDetail.elementAt(i+1)%></td>
      <td align="center"><%=(String)vSecDetail.elementAt(i+2)%></td>
      <td>&nbsp;</td>
    </tr>
    <%}%>
    <tr>
      <td>&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>

  
  </table>
<%}

if(vIDList != null && vIDList.size() > 0){
%>
  
<table width="100%" border="0" cellspacing="1" cellpadding="1" bgcolor="#FFFFFF">
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="17%">Student ID</td>
		<td>
		<select name="stud_id" onChange="ShowCList()" style="width:400px;">
		<option value="">Please Select Student ID</option>
			<%
			strTemp = WI.fillTextValue("stud_id");
			for(int i = 0; i < vIDList.size(); i+=2){
			if(strTemp.equals((String)vIDList.elementAt(i)))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%>
			<option value="<%=vIDList.elementAt(i)%>" <%=strErrMsg%>><%=vIDList.elementAt(i+1)%><%=WI.getStrValue((String)vIDList.elementAt(i)," (",")","")%></option>			
			<%}%>
		</select>
		</td>
	</tr>
</table>
<%
if(vStudDtls != null && vStudDtls.size() > 0){
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr >
      <td height="25" colspan="5"><hr size="1">      </td>
    </tr>
	
	<tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="17%" height="25">Student Name </td>
      <td height="25"><strong><%=(String)vStudDtls.elementAt(1)%></strong></td>
    </tr>	
	<tr>
		<td height="25">&nbsp;</td>
		<td>Subject Hours  </td>
	
	
		<td>
			<select name="no_of_absences">
		<%
		strTemp = WI.fillTextValue("no_of_absences");
		if(strTemp.equals("24"))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		%><option value="24" <%=strErrMsg%>>108-hour (max 24hrs absences)</option>
		<%
		if(strTemp.equals("20"))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		%><option value="20" <%=strErrMsg%>>90-hour (max 20hrs absences)</option>
				
		<%
		if(strTemp.equals("12"))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		%><option value="12" <%=strErrMsg%>>54-hour (max 12 hrs absences)</option>
				
		<%
		if(strTemp.equals("8"))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		%><option value="8" <%=strErrMsg%>>36-hour (max 8 hrs absences) </option>
			</select>
		</td>
	</tr>
	
	<tr>
      <td height="25">&nbsp;</td>
      <td height="25">Day of Absent  </td>
      <td height="25">
	  		<input name="day_absent" type="text" size="10" maxlength="10" readonly="yes" class="textbox" 
				value="<%=WI.fillTextValue("day_absent")%>" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
			<a href="javascript:show_calendar('form_.day_absent');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" border="0"></a>
	  </td> 
    </tr>
	
	
	<tr> 
      <td height="25">&nbsp;</td>
      <td>Reason </td>
	  <%
	  strTemp = WI.fillTextValue("reason");	  
	  %>
      <td colspan="2">
	  	<textarea name="reason" cols="48" rows="3" class="textbox" 
			id="reason" onFocus="style.backgroundColor='#D3EBFF'" 
			onBlur="style.backgroundColor='white'" ><%=strTemp%></textarea></td>
    </tr>
	
	<tr><td colspan="4">&nbsp;</td></tr>
	<tr>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td colspan="2">
		<%if(bolIsAllowedToEncode){%>
		<a href="javascript:PageAction('1','','');">
		<img src="../../../images/save.gif" border="0"></a>
		<font size="1">Click to save</font>
		<%}%> <%=WI.getStrValue(strEncodeErrMsg)%>
		</td>
	</tr>
	
	
	<tr><td colspan="4">&nbsp;</td></tr>
  </table>
  
  <%

if (vRetResult!= null && vRetResult.size()>0){%>
	<!--<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr><td align="right" height="25">
	<a href="javascript:PrintLetter('<%=(String)vStudDtls.elementAt(0)%>')">
	<img src="../../../images/print.gif" border="0"></a>
	<font size="1">Click to print letter</font>
	</td></tr>
	</table>
-->
	<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
		<tr>
			<td class="thinborder" height="25" align="" width="15%"><strong>Subect Code</strong></td>
			<td class="thinborder" align="" width="27%"><strong>Subect Name</strong></td>
			<td class="thinborder" align="center" width="13%"><strong>Date Absent</strong></td>
			<td class="thinborder" align="center" width="13%"><strong>No of Hours</strong></td>
			<td width="32%" align="" class="thinborder"><strong>Reason</strong></td>
		</tr>
		
		<%
		
		String strColor = null;
		String strCurCode = null;
		String strPrevCode = "";
//		String[] astrMin = {"","","","","","30 mins","","","","","","","","",""};
		String[] astrMin = new String[30];
		astrMin[5] = "30 mins";
		
		String[] astrHrAbsent = null;
		String strHrAbsent = null;
		int iCount = 0;
		for(int i = 0; i < vRetResult.size(); i+=8){
			strCurCode = WI.getStrValue((String)vRetResult.elementAt(i+3));			
			
			strHrAbsent = (String)vRetResult.elementAt(i+7);
			if( strHrAbsent != null && strHrAbsent.length() > 0){
				iCount = 0;
				astrHrAbsent = new String[strHrAbsent.length()];
				while(strHrAbsent.indexOf(".") > -1) {
					astrHrAbsent[iCount] = strHrAbsent.substring(0, strHrAbsent.indexOf("."));
					strHrAbsent = strHrAbsent.substring(strHrAbsent.indexOf(".")+1);
					++iCount;
				}
				
				if(strHrAbsent.length() > 0)
					astrHrAbsent[iCount] = strHrAbsent;
					
				if(astrHrAbsent != null && astrHrAbsent.length >= 2){
					strHrAbsent = null;
					if(astrHrAbsent[0] != null && astrHrAbsent[0].length() > 0)
						strHrAbsent = astrHrAbsent[0]+" Hr(s)";
					if(astrHrAbsent[1] != null && astrHrAbsent[1].length() > 0)
						strHrAbsent += WI.getStrValue(astrMin[Integer.parseInt(astrHrAbsent[1])]," ","","");
				}
			}
			
			strColor = "#FFFFFF";
			/*if(strColor == null)
				strColor = "#999999";
			else{
				if(strColor.equals("#999999") && !strPrevCode.equals(strCurCode))
					
				else{
					if(strColor.equals("#FFFFFF") && strPrevCode.equals(strCurCode))
						strColor = "#FFFFFF";
					else
						strColor = "#999999";				
				}
					
			}*/
		%>
		
		<tr>
			<td bgcolor="<%=strColor%>" class="thinborder" height="25"><%=strCurCode%></td>
			<td bgcolor="<%=strColor%>" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+4))%></td>
			<td bgcolor="<%=strColor%>" class="thinborder" align="center"><%=vRetResult.elementAt(i+5)%></td>
			<td bgcolor="<%=strColor%>" class="thinborder" align="center"><%=WI.getStrValue(strHrAbsent,"&nbsp;")%></td>
			<td bgcolor="<%=strColor%>" class="thinborder" align=""><%=WI.getStrValue((String)vRetResult.elementAt(i+6),"&nbsp;")%></td>
		</tr>
		
		<%
			strPrevCode = strCurCode;
		}%>
	</table>

<%}//end vRetResult not null%>

  
  

<%}
}%>

<input type="hidden" name="is_firsttime" value="0" >
<input type="hidden" name="subject_name" >
<input type="hidden" name="section_name" >
<input type="hidden" name="course_name" >
<input type="hidden" name="showCList" value="" >
<input type="hidden" name="page_action" />
<input type="hidden" name="sub_code_" value="<%=WI.fillTextValue("sub_code_")%>" >
<input type="hidden" name="enroll_index" value="<%=WI.getStrValue(strEnrollIndex)%>">
<input type="hidden" name="faculty_encoding" value="1">
<%=dbOP.constructAutoScrollHiddenField()%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
