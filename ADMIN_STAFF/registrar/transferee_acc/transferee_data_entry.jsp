<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Transferee Info Management</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
.px50 {
	width:700px;
}

.branch{
	display: none;
	margin-left: 0 px;
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
.nav {
     /**color: #000000;**/
     /**background-color: #FFFFFF;**/
	 font-weight:normal;
	 
}
.nav-highlight {
     /**color: #0000FF;**/
     /**background-color: #FAFCDD;**/
     background-color:#BCDEDB;
}

-->

</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function HideLayer(strDiv) {			
	document.getElementById(strDiv).style.visibility = 'hidden';
	document.form_.show_excluded_sub.checked = false;
}
function navRollOver(obj, state) {
  document.getElementById(obj).className = (state == 'on') ? 'nav-highlight' : 'nav';
}

function showBranch(branch){
	if (document.getElementById(branch) == null) 
		return;

	var objBranch = document.getElementById(branch).style;
	
	
	
	if(document.studdata_entry.is_internship.checked) 
		objBranch.display="block";
	else
		objBranch.display="none";
}

function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=studdata_entry.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ViewResidency() {
	if(document.studdata_entry.stud_id.value.length == 0) {
		alert("Please enter Student ID to view Residency.");
		return;
	}
	location = "../residency/residency_status.jsp?stud_id="+
	escape(document.studdata_entry.stud_id.value);

}
function ReloadPage()
{
	document.studdata_entry.page_action.value = "";
	document.studdata_entry.fake_focus.value = "1";
	document.studdata_entry.submit();
}
function AddRecord()
{
	document.studdata_entry.page_action.value = 1;
	document.studdata_entry.remarkName.value = document.studdata_entry.remark_index[document.studdata_entry.remark_index.selectedIndex].text;

	document.studdata_entry.submit();
}
function DeleteRecord(strTargetIndex)
{
	document.studdata_entry.page_action.value = 0;

	document.studdata_entry.info_index.value = strTargetIndex;
	document.studdata_entry.submit();
}
function EditRecord(strTargetIndex)
{
	var pgLoc = "./transferee_alter_entry.jsp?info_index="+strTargetIndex+"&stud_id="+document.studdata_entry.stud_id.value+"&student_type="+document.studdata_entry.student_type.value;
	var win=window.open(pgLoc,"EditWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

}
function UpdateSchoolList()
{
	//pop up here.
	var pgLoc = "../sub_creditation/schools_accredited.jsp?parent_wnd=studdata_entry";
	var win=window.open(pgLoc,"EditWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

}
function LoadInfo(strSYFrom, strSYTo, strSemester, strYr, strTermType, strSchI) {
	document.studdata_entry.page_action.value  = '';
	document.studdata_entry.info_index.value   = '';
	document.studdata_entry.starts_with2.value = '';

	document.studdata_entry.sy_from.value     = strSYFrom;
	document.studdata_entry.sy_to.value       = strSYTo;
	document.studdata_entry.semester[document.studdata_entry.semester.selectedIndex].value       = strSemester;
	document.studdata_entry.year_level[document.studdata_entry.year_level.selectedIndex].value   = strYr;
	document.studdata_entry.term_type[document.studdata_entry.term_type.selectedIndex].value     = strTermType;
	document.studdata_entry.prev_school[document.studdata_entry.prev_school.selectedIndex].value = strSchI;

	document.studdata_entry.submit();
}

//// - all about ajax.. 
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.studdata_entry.stud_id.value;
		if(strCompleteName.length < 3) {
			document.getElementById("coa_info").innerHTML = "";
			return;
		}
		
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");
			
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
	/** do not do anything **/
	document.studdata_entry.stud_id.value = strID;
	document.studdata_entry.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.studdata_entry.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}
function focusID() {
	
	if(document.studdata_entry.credit_earned)
		document.studdata_entry.credit_earned.focus();
	else
		document.studdata_entry.stud_id.focus();
	
}
</script>

<body bgcolor="#D2AE72" onLoad="focusID()">
<%@ page language="java" import="utility.*,enrollment.GradeSystemTransferee,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	Vector vTemp = null;
	int i=0; int j=0;

	float fCredit = 0;
	String strDegreeType = null;
	String[] strCurInfo = null;


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-TRANSFEREE INFO MAINTENANCE","transferee_data_entry.jsp");
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
														"Registrar Management","TRANSFEREE INFO MAINTENANCE",request.getRemoteAddr(),
														"transferee_data_entry.jsp");
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
boolean bolIsSuccessful = false;

GradeSystemTransferee GSTransferee = new GradeSystemTransferee();
vTemp = GSTransferee.getTransfereeStudInfo(dbOP, request.getParameter("stud_id"));
if(vTemp == null)
	strErrMsg = GSTransferee.getErrMsg();
else//
{
	strDegreeType = dbOP.mapOneToOther("COURSE_OFFERED","course_index",(String)vTemp.elementAt(4),"DEGREE_TYPE",null);
	if(strDegreeType == null)
		strErrMsg = "Error in getting course degree type.";
	else if(WI.fillTextValue("page_action").length() > 0)
	{
	  if(GSTransferee.operateOnTransfereeGrade(dbOP,request,Integer.parseInt(request.getParameter("page_action"))) != null) {
	  	strErrMsg = "Operation successful.";
		bolIsSuccessful = true;
	  }
	  else
	  	strErrMsg = GSTransferee.getErrMsg();
	}
}

Vector vTransEncoded = new Vector();

String[] astrConvertYear ={"N/A","1st Year","2nd Year","3rd Year","4th Year","5th Year","6th Year","7th Year"};
String[] astrConvertSem = {"Summer","1st ","2nd ","3rd ","4th "};
if(vTemp != null && vTemp.size() > 0 && WI.fillTextValue("equiv_code").length() > 0 && 
	!WI.fillTextValue("equiv_code").equals("0")){// I have to get the curriculum detail infromation.
	strCurInfo = GSTransferee.getCurIndex(dbOP,request.getParameter("equiv_code"),(String)vTemp.elementAt(4),(String)vTemp.elementAt(5),
                              (String)vTemp.elementAt(6),(String)vTemp.elementAt(7),strDegreeType);
	if(strCurInfo == null)
		strErrMsg = GSTransferee.getErrMsg();
}
if(vTemp != null && vTemp.size() > 0) {
	String strSQLQuery = "select distinct sy_from, sy_to, semester, year, term_type, g_sheet_final_trans.sch_accr_index, term_name, sch_code, sem_order from g_sheet_final_trans "+
					" join semester_sequence on (semester_val = semester) "+
					" join G_SHEET_FINAL_TRANS_TERM on (G_SHEET_FINAL_TRANS_TERM.term_type_ref = term_type) "+
					" join SCH_ACCREDITED on (SCH_ACCREDITED.sch_accr_index = g_sheet_final_trans.SCH_ACCR_INDEX) "+
					" where user_index = "+vTemp.elementAt(12)+" and is_valid = 1 order by sy_from, sem_order"; 
	java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		vTransEncoded.addElement(rs.getString(1));//[0] sy_from
		vTransEncoded.addElement(rs.getString(2));//[1] sy_to
		vTransEncoded.addElement(rs.getString(3));//[2] semester
		vTransEncoded.addElement(rs.getString(4));//[3] year
		vTransEncoded.addElement(rs.getString(5));//[4] term_type
		vTransEncoded.addElement(rs.getString(6));//[5] sch_accr_index
		vTransEncoded.addElement(rs.getString(7));//[6] term_name
		vTransEncoded.addElement(rs.getString(8));//[7] sch_code
	}
	rs.close();
}

%>


<form action="./transferee_data_entry.jsp" method="post" name="studdata_entry">
<%if(vTransEncoded != null && vTransEncoded.size() > 0){%>
	<!-- show subjects excluded in TOR -->
	<div id="processing2" class="processing">
	<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% class="thinborderALL" bgcolor="#9999CC" valign="top">
		<tr>
			<td valign="top" align="right" style="color:#FF0000"><a href="javascript:HideLayer('processing2')"><font style="color:#FFFF00; font-weight:bold">Close Window X</font></a></td></tr>	
	  <tr>
		<td valign="top" align="center"><b>LIST OF SY-TERM ENCODED</b></td>
	  </tr>
	  <tr>
		  <td valign="top">
			<table width="100%" cellpadding="0" cellspacing="0" border="0" class="thinborder">
				<tr bgcolor="#CCCCCC" style="font-weight:bold">
					<td class="thinborder" height="20" width="30%" style="font-size:9px;">SY-Term</td>
					<td class="thinborder" width="50%" style="font-size:9px;">Sch Code</td>
				    <td class="thinborder" style="font-size:9px;">Term Type</td>
				</tr>
				<%
				for(i = 0; i < vTransEncoded.size(); i += 8){			
				%>
				<tr onDblClick="LoadInfo('<%=vTransEncoded.elementAt(i)%>','<%=vTransEncoded.elementAt(i + 1)%>','<%=vTransEncoded.elementAt(i + 2)%>','<%=vTransEncoded.elementAt(i + 3)%>','<%=vTransEncoded.elementAt(i + 4)%>','<%=vTransEncoded.elementAt(i + 5)%>')"
				class="nav" id="msg<%=i%>" onMouseOver="navRollOver('msg<%=i%>', 'on')" onMouseOut="navRollOver('msg<%=i%>', 'off')">
					<td class="thinborder" height="18"><%=vTransEncoded.elementAt(i)%>-<%=vTransEncoded.elementAt(i + 2)%></td>
					<td class="thinborder"><%=vTransEncoded.elementAt(i+7)%></td>
				    <td class="thinborder"><%=vTransEncoded.elementAt(i+6)%></td>
				</tr>
				<%}%>
			</table>
		  </td>
	  </tr>	
	</table>
	</div>
<%}//show only for EAC%>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF"><strong>::::
          TRANSFEREE INFORMATION MANAGEMENT :::: </strong> <br>
          (Encoding of transferee transcript of record data from previous
          school)</font></div></td>
    </tr>
  </table>
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
		<td width="2%" height="25" colspan="4">&nbsp;</td>
      <td width="98%"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td width="2%" height="25">&nbsp;</td>
      <td width="13%">Student ID</td>
      <td width="13%"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');"></td>
      <td width="11%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
      <td width="11%"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
      <td width="50%"><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label></td>
    <tr >
      <td  colspan="6" height="25" align="center"> <a href="javascript:ViewResidency();"><img src="../../../images/view.gif" border="0"></a>
        Click to view Residency.</td>
    </tr>
    <tr >
      <td  colspan="6" height="25"><hr size="1"></td>
    </tr>
  </table>
<%
if(vTemp != null && vTemp.size() > 0)
{%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25">&nbsp;</td>
      <td>Student name : <strong><%=(String)vTemp.elementAt(1)%></strong></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td>Previous school : <strong><%=WI.getStrValue(vTemp.elementAt(15),"Not Set")%> </strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Previous course/Major :<strong> <%=WI.getStrValue(vTemp.elementAt(13),"Not Set")%>
<%
if(vTemp.elementAt(14) != null){%>
	<%=(String)vTemp.elementAt(14)%>
<%}%>
	</strong></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td  colspan="4" height="25"><hr size="1"></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="2">New Course / Major: <strong><%=(String)vTemp.elementAt(2)%>
	  <%
	  if(vTemp.elementAt(3) != null){%>
	  /<%=(String)vTemp.elementAt(3)%>
	  <%}%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="39%">Curriculum year : <strong><%=(String)vTemp.elementAt(6)%>
        - <%=(String)vTemp.elementAt(7)%></strong></td>
      <td width="59%">Year level upon entry : <strong><%=astrConvertYear[Integer.parseInt(WI.getStrValue(vTemp.elementAt(10),"0"))]%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Term : <strong><%=astrConvertSem[Integer.parseInt((String)vTemp.elementAt(11))]%></strong></td>
      <td>School Year : <strong><%=(String)vTemp.elementAt(8)%></strong> to <strong><%=(String)vTemp.elementAt(9)%></strong></td>
    </tr>
    <tr>
      <td colspan="3" height="25"><hr size="1"></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" >
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">Previous School: <input type="text" name="starts_with2" value="<%=WI.fillTextValue("starts_with2")%>" size="25" class="textbox"
		  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		   style="font-size:12px" onKeyUp = "AutoScrollList('studdata_entry.starts_with2','studdata_entry.prev_school',true);">&nbsp;&nbsp;<a href="javascript:UpdateSchoolList();"><img src="../../../images/update.gif" border="0"></a><font size="1">click to update  school list</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2"><select name="prev_school">
<%=dbOP.loadCombo("SCH_ACCR_INDEX","SCH_NAME"," from SCH_ACCREDITED where IS_DEL=0 " + 
" and SCH_NAME not like '%elem%' and SCH_NAME not like '%high s%' order by SCH_NAME",WI.fillTextValue("prev_school"),false)%>
        </select></td>
    </tr>
<%
if(strDegreeType != null && strDegreeType.equals("3")){%>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="14%">Prep/Proper</td>
      <td width="84%"><select name="prep_prop_stat">
          <option value="1">Preparatory</option>
          <%
strTemp = WI.fillTextValue("prep_prop_stat");
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>Proper</option>
          <%}else{%>
          <option value="2">Proper</option>
          <%}%>
        </select> </td>
    </tr>
<%}//end of displaying prep proper.%>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="14%">School Year </td>
      <td width="84%"> <input name="sy_from" type="text" size="4" value="<%=WI.fillTextValue("sy_from")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("studdata_entry","sy_from","sy_to")'>
        to
        <input name="sy_to" type="text" size="4" value="<%=WI.fillTextValue("sy_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </td>
    </tr>
  </table>
 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Term Type</td>
      <td height="25" colspan="2">
	  <select name="term_type">
<%=dbOP.loadCombo("TERM_TYPE_REF","TERM_NAME"," from G_SHEET_FINAL_TRANS_TERM where IS_INVALID=0 order by TERM_TYPE_REF",WI.fillTextValue("term_type"),false)%>
	  </select>
<!--
	  <select name="term_type" onChange="">
          <option value="1">SEMESTER</option>
          <%
			strTemp = WI.fillTextValue("term_type");
			if(strTemp.equals("2")){%>
          <option value="2" selected>TRIMESTER</option>
          <%}else{%>
          <option value="2">TRIMESTER</option>
          <%}if(strTemp.equals("3")){%>
          <option value="3" selected>ANNUAL</option>
          <%}else{%>
          <option value="3">ANNUAL</option>
          <%}if(strTemp.equals("4")){%>
          <option value="4" selected>QUARTER</option>
          <%}else{%>
          <option value="4">QUARTER</option>
          <%}%>

        </select> --></td>
    </tr>

    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="14%" height="25"> <%
if(strDegreeType != null && strDegreeType.compareTo("4") !=0 && strDegreeType.compareTo("1") !=0){%>
        Year 
        <select name="year_level">
          <option value="1">1st</option>
          <%
strTemp = WI.fillTextValue("year_level");
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
        </select> <%}//end of displaying year level%> </td>
      <td width="18%" height="25"> Term 
        <select name="semester" onChange="ReloadPage();">
          <option value="1">1st </option>
          <%
			strTemp = WI.fillTextValue("semester");
		  if(strTemp.equals("2")){%>
          <option value="2" selected>2nd </option>
          <%}else{%>
          <option value="2">2nd </option>
          <%}if(strTemp.equals("3")){%>
          <option value="3" selected>3rd </option>
          <%}else{%>
          <option value="3">3rd </option>
          <%}if(strTemp.equals("4")){%>
          <option value="4" selected>4th</option>
          <%}else{%>
          <option value="4">4th</option>
          <%}if(strTemp.equals("0")){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select> </td>
      <td> <font size="1"> 
        <%if(WI.fillTextValue("is_internship").compareTo("1") == 0)
			strTemp = "checked";
		  else 
		  	strTemp = "";
		  %>
       <input name="is_internship" type="checkbox" value="1" <%=strTemp%> 
	   	onClick="showBranch('branch1')">
        (check if INTERNSHIP/CLERKSHIP/CADETSHIP subject)</font></td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td height="18" colspan="3">
<span class="branch" id="branch1">
	  <table width="100%" border="0" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" 
 	style="border:solid #FF0000 2px 2px 2px 2px ">
        <tr>
          <td height="25" colspan="3">Inclusive date of internship/clerkship :
            <input name="internship_date_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("internship_date_fr")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
              <a href="javascript:show_calendar('studdata_entry.internship_date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>&nbsp;&nbsp;&nbsp;to 
            &nbsp;&nbsp;
              <input name="internship_date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("internship_date_to")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
              <a href="javascript:show_calendar('studdata_entry.internship_date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>&nbsp;</td>
        </tr>
        <tr>
          <td height="25" colspan="3">Place taken :
            <input name="internship_place" type="text" size="60" maxlength="128" value="<%=WI.fillTextValue("internship_place")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
        </tr>
        <tr>
          <td height="25" colspan="3">Duration :
            <input name="internship_dur" type="text" size="5" value="<%=WI.fillTextValue("internship_dur")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
              <select name="internship_dur_unit">
                <option value="0">Hours</option>
                <%
strTemp = WI.fillTextValue("internship_dur_unit");
if(strTemp.compareTo("1") ==0){%>
                <option value="1" selected>Weeks</option>
                <%}else{%>
                <option value="1">Weeks</option>
                <%}if(strTemp.compareTo("2") ==0){%>
                <option value="2" selected>Months</option>
                <%}else{%>
                <option value="2">Months</option>
                <%}%>
            </select></td>
        </tr>
      </table>
</span> 	  
	  
	  </td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="9" ><hr size="1"></td>
    </tr>
    <tr>
      <td width="2%" height="25" >&nbsp;</td>
      <td width="28%"  height="25" ><div align="left"><font size="1"><strong><br>
          SUBJECT CODE</strong></font></div></td>
      <td width="35%" ><font size="1"><strong>SUBJECT TITLE</strong></font></td>
      <td width="7%" ><div align="left"><font size="1"><strong>CREDITS EARNED</strong></font></div></td>
      <td width="7%" align="center"><font size="1"><strong>UNITS</strong></font></td>
      <td width="7%" ><div align="left"><font size="1"><strong>FINAL GRADE</strong></font></div></td>
      <td width="7%" ><font size="1"><strong>REMARKS</strong></font></td>
      <td width="7%" ><font size="1"><strong>ACCRE<br>
      CREDIT</strong></font></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td  height="25" ><select name="subject" onChange="ReloadPage();">
          <option value="0">Enter another sub/code</option>
          <%=dbOP.loadCombo("sub_index","sub_code"," from subject where is_del=0 order by sub_code asc",request.getParameter("subject"),false)%>
        </select></td>
      <td >
        <%
strTemp = dbOP.mapOneToOther("SUBJECT","sub_index",request.getParameter("subject"),"SUB_NAME",null);
%>
        <%=WI.getStrValue(strTemp)%></td>
      <td >
<%
strTemp = WI.fillTextValue("credit_earned");
if(bolIsSuccessful)
	strTemp = "";
%>
	  <input name="credit_earned" type="text" size="4" class="textbox" value="<%=strTemp%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" tabindex="3"></td>
      <td ><select name="unit">
          <option >Unit</option>
          <%
strTemp = WI.fillTextValue("unit");
if(strTemp.compareTo("Hour") ==0){%>
          <option selected>Hour</option>
          <%}else{%>
          <option>Hour</option>
          <%}if(strTemp.compareTo("Month") ==0){%>
          <option selected>Month</option>
          <%}else{%>
          <option>Month</option>
          <%}if(strTemp.compareTo("Weeks") ==0){%>
          <option selected>Weeks</option>
          <%}else{%>
          <option>Weeks</option>
          <%}%>
        </select></td>
      <td >
<%
strTemp = WI.fillTextValue("grade");
if(bolIsSuccessful)
	strTemp = "";
%>
	  <input name="grade" type="text" size="5" maxlength="12" class="textbox" value="<%=strTemp%>"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" tabindex="4"></td>
      <td >
<%
strTemp = WI.fillTextValue("remark_index");
if(bolIsSuccessful)
	strTemp = "";
%>
	  <select name="remark_index" tabindex="5">
          <%=dbOP.loadCombo("remark_index", "remark"," from REMARK_STATUS where is_del=0",strTemp, false)%>
        </select></td>
      <td >
<%
strTemp = WI.fillTextValue("accredited_credit");
if(bolIsSuccessful)
	strTemp = "";
%>
	  <input name="accredited_credit" type="text" size="4" class="textbox" value="<%=strTemp%>" tabindex="6"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <%
if(request.getParameter("subject") == null || request.getParameter("subject").compareTo("0") ==0){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>
<%
strTemp = WI.fillTextValue("sub_code");
if(bolIsSuccessful)
	strTemp = "";
%>
	  <input type="text" name="sub_code" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" tabindex="1"> 
        <font size="1">(enter code)</font></td>
      <td >
<%
strTemp = WI.fillTextValue("sub_name");
if(bolIsSuccessful)
	strTemp = "";
%>
	  <input type="text" name="sub_name" size="45" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" tabindex="2"> 
        <font size="1">(enter name)</font></td>
    </tr>
    <%}//end of displaying if subject does not exist
%>
    <tr> 
      <td>&nbsp;</td>
      <td  height="25" colspan="2" ><font color="#0000FF" size="1" ><strong>EQUIV. 
        SUBJECT CODEE ::: SUBJECT TITLE (only if subject is passed) </strong>&nbsp; </font>
		<input type="text" name="scroll_sub" size="16" style="font-size:9px" onBlur="ReloadPage()"
	  onKeyUp="AutoScrollListSubject('scroll_sub','equiv_code',true,'studdata_entry');">
		
	  </td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td  height="25" colspan="2" ><select name="equiv_code" class="px50" style="font-size:11px" onChange="ReloadPage();" tabindex="7">
          <option value="">Select a subject</option>
          <%=dbOP.loadCombo("SUB_INDEX","SUB_CODE +'&nbsp;&nbsp;&nbsp;('+sub_name+')'"," from SUBJECT where IS_DEL=0 order by sub_code asc",WI.getStrValue(WI.fillTextValue("equiv_code"),"0"),false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25" width="2%">&nbsp;</td>
      <td width="34%"> </td>
      <td width="64%"> <%
//if(strCurInfo != null)
{%> <a href="javascript:AddRecord();" tabindex="8"><img src="../../../images/add.gif" border="0"></a><font size="1">click 
      to add</font> <%}%> </td>
    </tr>
  </table>
<%
//get here transferee grade sheet information.
strErrMsg = null;
vTemp = null;
if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_to").length() > 0)
{
	vTemp = GSTransferee.operateOnTransfereeGrade(dbOP,request,4);
	if(vTemp == null)
		strErrMsg = GSTransferee.getErrMsg();
}
if(vTemp != null && vTemp.size() > 0)
{%>


  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="8" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>TOR 
          ENTRIES FROM PREV. SCHOOL FOR AY <%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%>, TERM 
		  <% if (WI.fillTextValue("term_type").equals("2")){ // trimester
		  		strTemp = astrConvertSem[Integer.parseInt(request.getParameter("semester"))] + 
					"(TRIMESTER) ";
			}else if(WI.fillTextValue("term_type").equals("3")){ // annual
		  		strTemp = "(ANNUAL)";
		    }else if (WI.fillTextValue("term_type").equals("4")){
		  		strTemp = astrConvertSem[Integer.parseInt(request.getParameter("semester"))] + 
						" QUARTER";
			}else if (WI.fillTextValue("term_type").equals("1") ||
					WI.fillTextValue("term_type").equals("0"))
				strTemp = astrConvertSem[Integer.parseInt(request.getParameter("semester"))] + 
					" Sem";
			else {//this is manually created.. 
				strTemp = "select term_Name from G_SHEET_FINAL_TRANS_TERM where TERM_TYPE_REF = "+WI.fillTextValue("term_type");
				strTemp = dbOP.getResultOfAQuery(strTemp, 0);
			}		
				%>
			<%=strTemp%>
          </strong></font></div></td>
    </tr>
    <tr>
      <td width="15%"  height="25" class="thinborder" ><font size="1"><strong>&nbsp;&nbsp;SUBJECT
        CODE</strong></font></td>
      <td width="26%" class="thinborder" ><font size="1"><strong>SUBJECT TITLE</strong></font></td>
      <td width="16%" class="thinborder" ><strong><font color="#0000FF" size="1" >EQUIV. SUBJECT
        CODE</font></strong></td>
      <td width="7%" class="thinborder" ><div align="left"><font size="1"><strong>CREDITS EARNED</strong></font></div></td>
      <td width="6%" class="thinborder" ><div align="left"><font size="1"><strong>FINAL GRADE</strong></font></div></td>
      <td width="8%" class="thinborder" ><font size="1"><strong>REMARKS</strong></font></td>
      <td width="6%" class="thinborder" ><font size="1"><strong>ACCR CREDIT</strong></font></td>
      <td width="14%" class="thinborder" >&nbsp;</td>
    </tr>
    <%
	for(i=0; i< vTemp.size(); ++i)
	{
	/*System.out.println(vTemp.elementAt(i));
	System.out.println(vTemp.elementAt(i+1));
	System.out.println(vTemp.elementAt(i+2));
	System.out.println(vTemp.elementAt(i+3));
	System.out.println(vTemp.elementAt(i+4));
	System.out.println(vTemp.elementAt(i+5));
	System.out.println(vTemp.elementAt(i+6));
	*/
	if(vTemp.elementAt(i) != null){%>
    <tr>
      <td height="25" colspan="8" class="thinborder">&nbsp;&nbsp;School Name: <strong><%=(String)vTemp.elementAt(i)%></strong></td>
    </tr>
	<%}%>
    <tr>
      <td height="25" class="thinborder">&nbsp;<%=WI.getStrValue(vTemp.elementAt(i+2),"&nbsp;")%></td>
      <td class="thinborder">&nbsp;<%=(String)vTemp.elementAt(i+3)%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(vTemp.elementAt(i+8),"&nbsp;")%></td>
      <td class="thinborder">&nbsp;<%=(String)vTemp.elementAt(i+4)%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(vTemp.elementAt(i+6),"&nbsp;")%></td>
      <td class="thinborder">&nbsp;<%=(String)vTemp.elementAt(i+7)%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(vTemp.elementAt(i+10),"&nbsp;")%></td>
      <td class="thinborder"> 
      <a href='javascript:EditRecord("<%=(String)vTemp.elementAt(i+1)%>");'><img src="../../../images/edit.gif" border="0"></a>
      <a href='javascript:DeleteRecord("<%=(String)vTemp.elementAt(i+1)%>");'><img src="../../../images/delete.gif" border="0"></a></td>
    </tr>
      <%i = i+10;
	}%>
  </table>
 <%
 }//if vTemp !=null - student is having grade created already.

}////if transferee info exists - vTemp != null; - biggest loop == only if the Proceed for Student id is exists
%>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
<%
if(strErrMsg != null){%>
    <tr>
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;<%=strErrMsg%></td>
    </tr>
<%}%>
	<tr>
      <td height="25">
	  <input type="input" name="set_focus" size="1" maxlength="1" readonly
 	style="background-color: #ffffff;border-style: inset;border-color: #ffffff; border-width: 0px"></td>
    </tr>
    <tr>
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->
  <%
strTemp = request.getParameter("info_index");
if(strTemp == null) strTemp = "0";
%>
<input type="hidden" name="info_index" value="<%=strTemp%>">
<input type="hidden" name="page_action">
<input type="hidden" name="degree_type" value="<%=strDegreeType%>">
<%
if(strCurInfo != null){%>
<input type="hidden" name="cur_index" value="<%=strCurInfo[0]%>">
<%}%>
<input type="hidden" name="remarkName">
<input type="hidden" name="student_type" value="Transferee">

<%
if(WI.fillTextValue("fake_focus").compareTo("1") ==0){%>
<script language="JavaScript">
document.studdata_entry.set_focus.focus();
</script>
<%}%>
<input type="hidden" name="fake_focus" value="<%=WI.fillTextValue("fake_focus")%>">

<!-- add in pages with subject scroll -->

<script language="javascript">
	showBranch('branch1');
</script>
<!-- add in pages with subject scroll -->
<%=dbOP.constructAutoScrollHiddenField()%>

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
