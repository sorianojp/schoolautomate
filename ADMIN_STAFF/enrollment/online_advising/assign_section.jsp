<%@ page language="java" import="utility.*,enrollment.AdvisingExtn,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	
	if (strSchCode == null)
		strSchCode = "";

	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment - online advising configuration","assign_section.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
AdvisingExtn onlineAdvise = new AdvisingExtn();
Vector vStudentNotSet = null;//not set yet for online advising. 
Vector vStudentSet    = null;//set for online advising.. 

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(onlineAdvise.operateOnOnlineAdvisingAssignSection(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = onlineAdvise.getErrMsg();
	else	
		strErrMsg = "Operation successful.";
}

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg() {
	document.form_.print_pg.value = "1";
	this.SubmitOnce("form_");	
}
function ReloadPage()
{
	document.form_.searchStudent.value = "";
	document.form_.print_pg.value = "";
	this.SubmitOnce("form_");
}
function SelAll() {
	var iMaxCount = document.form_.max_disp_save.value;
	var bolIsChecked = document.form_.sel_all.checked;
	var vObj;
	for(i = 0; i < iMaxCount; ++i) {
		eval('vObj=document.form_.checkbox_'+i);
		if(!vObj)
			continue;
		if(bolIsChecked)
			vObj.checked = true;
		else	
			vObj.checked = false;
	}
}
function SelAllDel() {
	var iMaxCount = document.form_.max_disp_del.value;
	var bolIsChecked = document.form_.sel_all_del.checked;
	var vObj;
	for(i = 0; i < iMaxCount; ++i) {
		eval('vObj=document.form_._checkbox_'+i);
		if(!vObj)
			continue;
		if(bolIsChecked)
			vObj.checked = true;
		else	
			vObj.checked = false;
	}
}
function SelectBox(rowIndex) {
	eval('document.form_.checkbox_'+rowIndex+'.checked = true');
}
function CopyAll(strIndex) {
	var iMaxCount = document.form_.max_disp_save.value;
	var valToCopy;
	if(strIndex == '1') {
		valToCopy = document.form_.sub_section_0.value;
		document.form_.sub_section_0.focus();
	}
	else {
		valToCopy = document.form_.section_name_0.value;
		document.form_.section_name_0.focus();
	}
	if(valToCopy.length == 0) {
		alert("Please enter value for Top most field.");
		return;
	}
		
	var vObj;
	for(i = 0; i < iMaxCount; ++i) {
		if(strIndex == '1')
			eval('vObj=document.form_.sub_section_'+i);
		else
			eval('vObj=document.form_.section_name_'+i);

		if(!vObj)
			continue;
		vObj.value = valToCopy;
		
		eval('vObj=document.form_.checkbox_'+i);
		if(!vObj)
			continue;
		vObj.checked = true;
	}
}
function ClearAll(strIndex) {
	var iMaxCount = document.form_.max_disp_save.value;

	var vObj;
	for(i = 0; i < iMaxCount; ++i) {
		if(strIndex == '1')
			eval('vObj=document.form_.sub_section_'+i);
		else
			eval('vObj=document.form_.section_name_'+i);

		if(!vObj)
			continue;
		vObj.value = "";
	}
}
function ShowCuriculum(strStudIndex) {
	return;
	//does not work.. 
	var loadPg = "./show_sub_totake.jsp?stud_ref="+strStudIndex+"&sy_from="+document.form_.sy_from_advise.value+
	"&sem="+document.form_.semester_advise[document.form_.semester_advise.selectedIndex].value;
	var win=window.open(loadPg,"myfile",'dependent=yes,width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

}
</script>

<body>
<form action="./assign_section.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          Online Advising Configuation Page  ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="17%">SY-Term(enrolled)</td>
      <td width="80%">
<%
strTemp = WI.fillTextValue("sy_from_enrolled");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
if(strTemp == null) 
	strTemp = "";
%>	  <input name="sy_from_enrolled" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from_enrolled","sy_to_enrolled")' maxlength=4>
to
<%
if(strTemp.length() > 0)
	strTemp = Integer.toString(Integer.parseInt(strTemp) + 1);
%>
  <input name="sy_to_enrolled" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
&nbsp;&nbsp;
<select name="semester_enrolled">
  <option value="1">1st Sem</option>
  <%
strTemp = WI.fillTextValue("semester_enrolled");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp == null) 
	strTemp = "";
if(strTemp.equals("2"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
  <option value="2"<%=strErrMsg%>>2nd Sem</option>
<%
if(strTemp.equals("3"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
  <option value="3"<%=strErrMsg%>>3rd Sem</option>
<%
if(strTemp.equals("0"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
  <option value="0"<%=strErrMsg%>>Summer</option>
</select> 
<font size="1">-> Students are enrolled currently to this SY/Term</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>SY-Term(advising)</td>
      <td>
<%
String strSYFrom = WI.fillTextValue("sy_from_advise");String strSem = "1";
if(strSYFrom.length() == 0) { 
	strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	if(strTemp.equals("0"))
		strSYFrom = Integer.toString(Integer.parseInt(strSYFrom) + 1);
	else if(strTemp.equals("2"))
		strSem = "0";
	else if(strTemp.equals("1"))
		strSem = "2";
}
if(strSYFrom == null) 
	strSYFrom = "";
%>	  <input name="sy_from_advise" type="text" size="4" value="<%=strSYFrom%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from_advise","sy_to_advise")' maxlength=4>
to
<%
if(strSYFrom.length() > 0)
	strSYFrom = Integer.toString(Integer.parseInt(strSYFrom) + 1);
%>
  <input name="sy_to_advise" type="text" size="4" value="<%=strSYFrom%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
&nbsp;&nbsp;
<select name="semester_advise">
  <option value="1">1st Sem</option>
  <%
strTemp = WI.fillTextValue("semester_advise");
if(strTemp.length() == 0) 
	strTemp = strSem;
	
if(strTemp.equals("2"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
  <option value="2"<%=strErrMsg%>>2nd Sem</option>
<%
if(strTemp.equals("3"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
  <option value="3"<%=strErrMsg%>>3rd Sem</option>
<%
if(strTemp.equals("0"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>
  <option value="0"<%=strErrMsg%>>Summer</option>
</select> 
<font size="1">-> Students are  to be advised for this SY/Term</font></td>
    </tr>
    <tr>
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Year Level </td>
      <td><select name="year_level">
        <option value="">N/A</option>
        <%
strTemp = WI.fillTextValue("year_level");
if(strTemp.compareTo("1") ==0)
{%>
        <option value="1" selected>1st</option>
        <%}else{%>
        <option value="1">1st</option>
        <%}if(strTemp.compareTo("2") ==0){%>
        <option value="2" selected>2nd</option>
        <%}else{%>
        <option value="2">2nd</option>
        <%}if(strTemp.compareTo("3") ==0)
{%>
        <option value="3" selected>3rd</option>
        <%}else{%>
        <option value="3">3rd</option>
        <%}if(strTemp.compareTo("4") ==0)
{%>
        <option value="4" selected>4th</option>
        <%}else{%>
        <option value="4">4th</option>
        <%}if(strTemp.compareTo("5") ==0)
{%>
        <option value="5" selected>5th</option>
        <%}else{%>
        <option value="5">5th</option>
        <%}if(strTemp.compareTo("6") ==0)
{%>
        <option value="6" selected>6th</option>
        <%}else{%>
        <option value="6">6th</option>
        <%}%>
      </select>&nbsp;&nbsp;
	  Student ID : <input type="text" name="stud_id" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="24"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Course</td>
      <td><select name="course_index" style="font-size:10px;">
<%=dbOP.loadCombo("course_index","course_code+' :: '+course_name"," from course_offered where IS_DEL=0 and is_offered = 1 and degree_type = 0 order by course_name asc", request.getParameter("course_index"), false)%> 
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><font size="1" color="#0000FF">Section Name</font></td>
      <td style="font-size:9px; font-weight:bold; color:#0000FF"><input type="text" name="section_name" value="<%=WI.fillTextValue("section_name")%>" class="textbox"
	  	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="12"> &nbsp;<input type="checkbox" value="checked" name="exact_match" <%=WI.fillTextValue("exact_match")%>> Exact Match?</td>
    </tr>
    <tr> 
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td  width="5%" height="25">&nbsp;</td>
      <td width="95%">Sort by : 
<%
strTemp = WI.fillTextValue("sort_id");
if(strTemp.length() == 0 || strTemp.equals("0")) {
	strErrMsg = " checked";
	strTemp   = "";
}
else {
	strErrMsg = "";
	strTemp   = " checked";
}%>	  <input name="sort_id" type="radio" value="0"<%=strErrMsg%>>Last Name  (asc)
	  <input name="sort_id" type="radio" value="1"<%=strTemp%>>Student ID (asc)</td>
    </tr>
    
    <tr> 
      <td height="25">&nbsp;</td>
      <td><input type="submit" name="1" value="&nbsp;&nbsp;Search&nbsp;&nbsp;" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.print_pg.value='';"></td>
    </tr>
  </table>
<%
vStudentNotSet = onlineAdvise.operateOnOnlineAdvisingAssignSection(dbOP, request, 5);
if(vStudentNotSet == null)
	strErrMsg = onlineAdvise.getErrMsg();
	
if(vStudentNotSet != null && vStudentNotSet.size() > 0){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr> 
      <td height="25" colspan="2" bgcolor="#cccccc" align="center"><strong>Search Result - Not set for Advising </strong></td>
    </tr>
    <tr> 
      <td width="69%" ><b> Total Students : <%=vStudentNotSet.size()/3%></b></td>
      <td width="31%">&nbsp; </td>
    </tr>
  </table>

  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td width="10%" height="25" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Student ID</td>
      <td width="15%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Student Name</td>
      <td width="45%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Subject-Section list <a href="javascript:CopyAll('1')">(Copy all)</a> :: <a href="javascript:ClearAll('1')">(Clear)</a><br>
      (In format subject,section,subject,section) </td>
      <td width="25%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Section <a href="javascript:CopyAll('2')">(Copy all)</a> :: <a href="javascript:ClearAll('2')">(Clear)</a><br>
      (for all other subject) </td>
      <td width="5%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Select<br>
	  <input type="checkbox" name="sel_all" onClick="SelAll();"></td>
    </tr>
    
    <%int iRowCount = 0;
for(int i=0; i<vStudentNotSet.size(); i+=3, ++iRowCount){
%>
    <tr> 
      <td height="25" class="thinborder"><a href="javascript:ShowCuriculum('<%=vStudentNotSet.elementAt(i)%>')"><%=vStudentNotSet.elementAt(i + 1)%></a></td>
      <td class="thinborder"><%=vStudentNotSet.elementAt(i + 2)%></td>
      <td class="thinborder"><textarea name="sub_section_<%=iRowCount%>" cols="50" rows="3" class="textbox" style="font-size:9px;" onFocus="SelectBox('<%=iRowCount%>')"><%=WI.fillTextValue("sub_section_"+iRowCount)%></textarea></td>
      <td class="thinborder"><input type="text" name="section_name_<%=iRowCount%>" value="<%=WI.fillTextValue("section_name_"+iRowCount)%>" class="textbox"
	  	onFocus="SelectBox('<%=iRowCount%>');style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="18"></td>
      <td class="thinborder" align="center"><input type="checkbox" name="checkbox_<%=iRowCount%>" value="<%=vStudentNotSet.elementAt(i)%>"></td>
    </tr>
<%}%>
	<input type="hidden" name="max_disp_save" value="<%=iRowCount%>">
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
		<td align="center">
<input type="submit" name="1" value="&nbsp;&nbsp;Save Information&nbsp;&nbsp;" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='1';document.form_.print_pg.value='';">		
		</td>
	</tr>
  </table>
<%}//end of display. 
else{%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
		<td style="font-size:14px; color:#FF0000; font-weight:bold">Student list to set online advising information not found. <br>System Message : <%=WI.getStrValue(strErrMsg)%></td>
	</tr>
  </table>
<%}

vStudentSet = onlineAdvise.operateOnOnlineAdvisingAssignSection(dbOP, request, 4);
if(vStudentSet == null)
	strErrMsg = onlineAdvise.getErrMsg();
	
if(vStudentSet != null && vStudentSet.size() > 0){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="2" bgcolor="#cccccc" align="center"><strong>Search Result - Already set for online advising </strong></td>
    </tr>
    <tr> 
      <td width="69%" ><b> Total Students : <%=vStudentSet.size()/9%></b></td>
      <td width="31%">&nbsp; </td>
    </tr>
  </table>

  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td width="10%" height="25" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Student ID</td>
      <td width="15%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Student Name</td>
      <td width="40%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Subject</td>
      <td width="25%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Section</td>
      <td width="5%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Is Advised? </td>
      <td width="5%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Select<br>
	  <input type="checkbox" name="sel_all_del" onClick="SelAllDel();"></td>
    </tr>
    
    <%int iRowCount = 0;
for(int i=0; i<vStudentSet.size(); i+=9, ++iRowCount){
%>
    <tr> 
      <td height="25" class="thinborder"><a href="javascript:ShowCuriculum('<%=vStudentSet.elementAt(i +1)%>')"><%=vStudentSet.elementAt(i + 2)%></a></td>
      <td class="thinborder"><%=vStudentSet.elementAt(i + 3)%></td>
      <td class="thinborder"><%=WI.getStrValue(vStudentSet.elementAt(i + 5),"&nbsp;")%></td>
      <td class="thinborder"><%=vStudentSet.elementAt(i + 4)%></td>
      <td class="thinborder">&nbsp;<%if(vStudentSet.elementAt(i + 6).equals("1")){%>Yes<%}%></td>
      <td class="thinborder" align="center"><input type="checkbox" name="_checkbox_<%=iRowCount%>" value="<%=vStudentSet.elementAt(i)%>"></td>
    </tr>
<%}%>
	<input type="hidden" name="max_disp_del" value="<%=iRowCount%>">
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
		<td align="center">
<input type="submit" name="1" value="&nbsp;&nbsp;Delete Information&nbsp;&nbsp;" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='0';document.form_.print_pg.value='';">		
		</td>
	</tr>
  </table>
<%}//end of display. 
else{%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
		<td style="font-size:14px; color:#FF0000; font-weight:bold">Student list set for online advising not found. <br>System Message : <%=WI.getStrValue(strErrMsg)%></td>
	</tr>
  </table>
<%}%>




<input type="hidden" name="page_action">
<input type="hidden" name="print_pg">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>