<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
	
boolean bolIsSWU = strSchCode.startsWith("SWU");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/treelinkcss.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax2.js"></script>
<script language="JavaScript">

function PrintClassList(strSubIndex, strSubSecIndex){	
	if(strSubIndex.length == 0){
		alert("Subject information reference not found.");
		return;
	}
	
	if(strSubSecIndex.length == 0){
		alert("Section information reference not found.");
		return;
	}
	
	var strSYFrom = document.form_.sy_from.value;
	var strSemester = document.form_.semester.value;
	var strCIndex = document.form_.c_index_sel.value;
	var strDIndex = document.form_.d_index_sel.value;
	
	
		
	var loadPg = "../../enrollment/reports/class_list_cit_print.jsp?sy_from="+strSYFrom+
		"&semester="+strSemester+
		"&rows_per_pg=50"+
		"&c_index="+strCIndex+
		"&d_index="+strDIndex+
		"&sub_index="+strSubIndex+
		"&section="+strSubSecIndex;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=850,height=900,top=0,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

/**function loadDept() {
	var objCOA=document.getElementById("load_dept");
	var objCollegeInput = document.form_.c_index_sel[document.form_.c_index_sel.selectedIndex].value;
	
	if(objCollegeInput == 0)
		objCollegeInput = " -1 ";
	
	this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	
	this.InitXmlHttpObjectMultiple(objCOA,document.getElementById("load_section"), null);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	///if blur, i must find one result only,, if there is no result foud
	//var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+"&sel_name=d_index_sel&all=1";	
	
	
	var objSchoolYear = document.form_.sy_from.value;
	var objOfferingSem = document.form_.semester.value;
	var objCIndex = document.form_.c_index_sel[document.form_.c_index_sel.selectedIndex].value;
	var objDIndex = "";
	
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=5005&col_ref="+objCollegeInput+"&sel_name=d_index_sel&all=1"+"&onchange=loadSection"+
		"&sel_name_section=section_name&sy_from="+objSchoolYear+"&offering_sem="+objOfferingSem+
		"&c_index_sel_section="+objCIndex+"&d_index_sel_section="+objDIndex;
		

	this.processRequest(strURL);
}
*/

function DisplayAll(){

	document.form_.search_.value = "1";

	document.form_.submit();
}

function ToggleForceCloseOpen(strSubSecRef, strIsDC) {
		var obj = document.getElementById(strSubSecRef);		
		if(!obj)
			return;

		this.InitXmlHttpObject(obj, 2);//I want to get value in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=124&sub_sec_ref="+strSubSecRef;
		this.processRequest(strURL);
}

function loadSection() {

	var objCOA=document.getElementById("load_section");
	var objSchoolYear = document.form_.sy_from.value;
	var objOfferingSem = document.form_.semester.value;
	var objCIndex = document.form_.c_index_sel[document.form_.c_index_sel.selectedIndex].value;
	var objDIndex = document.form_.d_index_sel[document.form_.d_index_sel.selectedIndex].value;

	this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=128"+
		"&sel_name_section=section_name&sy_from="+objSchoolYear+"&offering_sem="+objOfferingSem+
		"&c_index_sel_section="+objCIndex+"&d_index_sel_section="+objDIndex;	
	this.processRequest(strURL);
}


function checkAllSaveItems() {
	var maxDisp = document.form_.item_count.value;
	var bolIsSelAll = document.form_.selAllSaveItems.checked;
	for(var i =1; i< maxDisp; ++i)
		eval('document.form_.save_'+i+'.checked='+bolIsSelAll);
}

function ForceClose(strType){
	document.form_.force_close_open.value = strType;
	this.DisplayAll();
}

function FacultySched(strSubSecIndex, strLableID){
	if(strSubSecIndex == null || strSubSecIndex.length == 0){
		alert("Subject information reference is missing.");
		return;
	}
	
	var strCIndex = "0";	
	var strDIndex = "0";	
		
	var strCollegeName = "ALL";	
	var loadPg = "cp/redirect_form.jsp?sub_sec_index="+strSubSecIndex+
		"&c_c_index="+strCIndex+
		"&d_index="+strDIndex+"&college_name="+strCollegeName+"&faculty_lbl_id="+strLableID;
	var win=window.open(loadPg,"FacultySched",'dependent=yes,width=1100,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

}

function LoadFacultyName(lblID, val)
{
	document.getElementById(lblID).innerHTML = val;
}


</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-Class program per subject","class_program_persection.jsp");
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
														"Enrollment","CLASS PROGRAM-PER SECTION",request.getRemoteAddr(),
														"class_program_persection.jsp");
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
enrollment.SubjectSection SS = new enrollment.SubjectSection();
Vector vRetResult = null;


String strSYFrom   = WI.fillTextValue("sy_from");
String strSYTo     = WI.fillTextValue("sy_to");
String strSemester = WI.fillTextValue("semester");

Vector vSubSecInfo = null; int iIndexOf = 0;

if(WI.fillTextValue("force_close_open").length() > 0){
	if(SS.operateOnSectionForceClose(dbOP, request, 1) == null)
		strErrMsg = SS.getErrMsg();
}

if(WI.fillTextValue("search_").length() > 0){
	vRetResult = SS.operateOnSectionForceClose(dbOP, request, 4);
	if(vRetResult == null)
		strErrMsg = SS.getErrMsg();
	else {
		Vector vTemp = new Vector();
		vTemp.addElement(strSYFrom);
		vTemp.addElement(strSemester);
		
		vSubSecInfo = SS.getScheduleMWFALL(dbOP, request, vTemp, true);
	}
}
if(vSubSecInfo == null)
	vSubSecInfo = new Vector();
	
%>

<form name="form_" action="./class_program_persection.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25"><div align="center"><font color="#FFFFFF"><strong>:::: 
          CLASS PROGRAM - PER SECTION ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="3%">&nbsp;</td>
      <td colspan="4" height="25"><strong><font size="3"><%=WI.getStrValue(strErrMsg,"")%></font></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="4" valign="bottom">School year : 
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");

strSYFrom = strTemp;%> <input name="sy_from" type="text" class="textbox" id="sy_from"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")' value="<%=strTemp%>" size="4" maxlength="4">
        to 

 <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");

strSYTo = strTemp;
%>
 <input name="sy_to" type="text" class="textbox" id="sy_to"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="4" maxlength="4"
	  readonly="yes">
 &nbsp;&nbsp;&nbsp; &nbsp;Term :
 <select name="semester">
          <option value="1">1st</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");

strSemester = strTemp;

if(strTemp.compareTo("2") ==0)
{%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.compareTo("3") ==0)
{%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.compareTo("0") ==0)
{%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
      </select> </td>
    </tr>
	
	<tr>
      <td height="25">&nbsp;</td>
      <td>Offering College: </td>
	  <td colspan="3">
	  <select name="c_index_sel" onChange="document.form_.submit();">
	  <option value="">Select College</option>
	  <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", WI.fillTextValue("c_index_sel"), false)%>
	  </select>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Offering Department: </td>
	  <%
	  strTemp = WI.fillTextValue("c_index_sel");
	  if(strTemp.length() > 0)
	  	strTemp = " and c_index = "+strTemp;
	  else
	  	strTemp = " and c_index <> 0";
		
	  %>
	  
	  <td colspan="3">
<label id="load_dept">
	  <select name="d_index_sel" onChange="loadSection();">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 "+ strTemp +
		  " order by d_name asc",WI.fillTextValue("d_index_sel"), false)%>
        </select>
</label>	  </td>
    </tr>
   
    
	
	<tr>
			<td height="25">&nbsp;</td>
			<td width="22%">Section</td>
			<td colspan="3">
				<%					
					String strCon = "";		
					
					String strCIndex = WI.fillTextValue("c_index_sel");
					if(strCIndex.length() > 0)
						strCon += " and offered_by_college = "+strCIndex;
						
					String strDIndex = WI.fillTextValue("d_index_sel");
					if(strDIndex.length() > 0)
						strCon += " and offered_by_dept = "+strDIndex;
					
					
					  
					
					strTemp = 
						" from e_sub_section where is_valid = 1 "+						
						" and offering_sy_from = "+strSYFrom+
						" and offering_sem = "+strSemester + strCon+						
						" order by e_sub_section.section ";
				%>
				<label id="load_section">
				<select name="section_name">
					<option value="">Select a section</option>
					<%=dbOP.loadCombo("distinct e_sub_section.section","e_sub_section.section",strTemp, WI.fillTextValue("section_name"), false)%>
				</select>
				</label></td>
	</tr>
	<tr> 
      <td colspan="5" height="10"></td>
    </tr>
	<tr> 
	<td></td>
	<%
	strTemp = WI.fillTextValue("view_all_reserved");
	if(strTemp.equals("1"))
		strTemp = "checked";
	else
		strTemp = "";
	%>
      <td height="19">
	  	<input type="checkbox" name="view_all_reserved" value="1" <%=strTemp%> onClick="DisplayAll();"> Show Reserved 
	  </td>
      <td>
	  	<input type="checkbox" name="show_sched_room" value="checked" <%=WI.fillTextValue("show_sched_room")%>> Include Schedule and Room
	  </td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
	</tr>
	<tr>
		<td colspan="2">&nbsp;</td>
		<td valign="bottom" colspan="3"><a href="javascript: DisplayAll()"><img src="../../../images/form_proceed.gif"border="0"></a></td>
	</tr>
	
    <tr><td colspan="5" height="10"></td>
    </tr>
  </table>
<% if (vRetResult != null && vRetResult.size() > 0) {%>

<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
	<tr style="font-weight:bold">
		<td width="10%" height="25" class="thinborder"><strong>Subject Code</strong></td>		
		<td width="5%" class="thinborder"><strong>Section</strong></td>		
		<td class="thinborder"><strong>Description</strong></td>
		<td width="15%" class="thinborder" align="center">Time</td>
		<td width="10%" class="thinborder" align="center">Room</td>
		<%if(bolIsSWU){%>
		<td width="15%" class="thinborder" align="center">Faculty</td>
		<td width="4%" class="thinborder" align="center">For<br>Dissolve</td>
		<%}%>
		<td width="5%" class="thinborder" align="center"><strong># Enrolled</strong></td>
		<td width="5%" class="thinborder" align="center"><strong>Status</strong></td>
		<td width="5%" align="center" class="thinborder"><strong>Select<br />
		</strong>
	  <input type="checkbox" name="selAllSaveItems" value="0" onClick="checkAllSaveItems();"></td>
	</tr>
	
	<%
	int iCount = 1;
	String strTime = null;
	String strRoom = null;
	String strFaculty = null; Vector vTemp = null; String strIsLab = null;
	int iLabelCount = 1;
	for(int i =0; i < vRetResult.size(); i+=7, iCount++){
		iIndexOf = vSubSecInfo.indexOf(vRetResult.elementAt(i));
		strTime = null;
		strRoom = null;
		strFaculty = null;

		if(iIndexOf > -1) {
			vTemp = (Vector)vSubSecInfo.elementAt(iIndexOf + 2);
			if(vSubSecInfo.elementAt(iIndexOf + 1).equals("1"))
				strIsLab = " (LAB)";
			else	
				strIsLab = "";
			while(vTemp.size() > 0) {
				if(strTime != null) {
					strTime = strTime + "<br>";
					strRoom = strRoom + "<br>";
				}
				strTime = WI.getStrValue(strTime) + (String)vTemp.remove(0)+strIsLab;
				strRoom = WI.getStrValue(strRoom) + (String)vTemp.remove(0);
				strIsLab = "";
			}
			vTemp = (Vector)vSubSecInfo.elementAt(iIndexOf + 3);
			while(vTemp.size() > 0) {
				if(strFaculty != null)
					strFaculty = strFaculty + "<br>";
				
				strFaculty = WI.getStrValue(strFaculty) + (String)vTemp.remove(0);
			}
			vSubSecInfo.remove(iIndexOf);vSubSecInfo.remove(iIndexOf);vSubSecInfo.remove(iIndexOf);vSubSecInfo.remove(iIndexOf);
		}
	
	%>	
	<tr>
		<td class="thinborder" height="25" style="font-size:9px;"><%=(String)vRetResult.elementAt(i+2)%></td>
		<input type="hidden" name="sub_sec_index_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>" >		
		<td class="thinborder" style="font-size:9px;"><%=(String)vRetResult.elementAt(i+6)%></td>		
		<td class="thinborder" style="font-size:9px;"><%=(String)vRetResult.elementAt(i+3)%></td>
		<td class="thinborder" style="font-size:9px;"><%=WI.getStrValue(strTime, "&nbsp;")%></td>
		<td class="thinborder" style="font-size:9px;"><%=WI.getStrValue(strRoom, "&nbsp;")%></td>
		
		<%if(bolIsSWU){%>
		<td class="thinborder" style="font-size:9px;">
		
		<a href="javascript:FacultySched('<%=vRetResult.elementAt(i)%>', 'lbl_faculty_name<%=iLabelCount%>')">
			  	<label id="lbl_faculty_name<%=iLabelCount++%>"><%=WI.getStrValue(strFaculty, "__________")%></label></a>		
		</td>
		<%
		strTemp = WI.getStrValue(vRetResult.elementAt(i + 4),"0");
		if(strTemp.equals("0"))
			strTemp = "&nbsp;";
		else
			strTemp = "For Dissolve";
		%>
		<td class="thinborder" align="center" <%if(iAccessLevel > 1){%>onDblClick="ToggleForceCloseOpen('<%=vRetResult.elementAt(i)%>')"<%}%>>
			<label id="<%=vRetResult.elementAt(i)%>" style="font-weight:bold; font-size:9px; color:#FF0000"><%=strTemp%></label></td>
		<%}%>
		
		<td class="thinborder" align="center" 
		 	<%if(bolIsSWU){%>onClick="PrintClassList('<%=vRetResult.elementAt(i + 1)%>','<%=vRetResult.elementAt(i)%>')"<%}%>
			style="font-size:9px;"><%=(String)vRetResult.elementAt(i+5)%></td>
		<%
		strTemp = (String)vRetResult.elementAt(i+4);
		if(strTemp.equals("1"))
			strTemp = "R";
		else
			strTemp = "&nbsp;";
		%>
		<td class="thinborder" align="center" style="font-size:9px;"><%=strTemp%></td>
		<td class="thinborder" align="center" style="font-size:9px;">				
				<input type="checkbox" name="save_<%=iCount%>" value="1" tabindex="-1" <%=strErrMsg%>></td>
	</tr>
	<%}%>
	<input type="hidden" name="item_count" value="<%=iCount%>" >
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
	<tr><td align="center">
	<%if(WI.fillTextValue("view_all_reserved").length() == 0){%>		
			<a href="javascript:ForceClose('1');">
				<input type="button" name="add" value="Reserve Subject"
								style="font-size:11px; height:28px;border: 1px solid #FF0000;" /></a>
			<font size="1">Click to reserve subject</font>
	
	
				&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; 		&nbsp; &nbsp; &nbsp; &nbsp; 
	<%}%>
	<a href="javascript:ForceClose('0');">
		<input type="button" name="add_" value="Open Subject(For Enrollment)"
						style="font-size:11px; height:28px;border: 1px solid #FF0000;" /></a>
		<font size="1">Click to update reserve subject</font>
	
	</td></tr>
</table>

<%} // if (vRetResult != null && vRetResult.size() > 0)%>



<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
<tr><td height="25">&nbsp;</td></tr>
<tr bgcolor="#A49A6A"><td height="25" >&nbsp;</td></tr>
</table>

<input type="hidden" name="force_close_open" >
<input type="hidden" name="search_" >
<!-- add in pages with subject scroll -->
<%=dbOP.constructAutoScrollHiddenField()%>

</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
