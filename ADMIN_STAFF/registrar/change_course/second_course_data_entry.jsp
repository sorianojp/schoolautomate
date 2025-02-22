<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.branch{
	display: none;
	margin-left: 0 px;
}
</style>


</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">

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
function ReloadPage()
{
	document.studdata_entry.page_action.value = "";
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
function UpdateSchoolList()
{
	//pop up here.
	var pgLoc = "../sub_creditation/schools_accredited.jsp?parent_wnd=studdata_entry";
	var win=window.open(pgLoc,"EditWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
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
function EditRecord(strTargetIndex)
{
	var pgLoc = "../transferee_acc/transferee_alter_entry.jsp?info_index="+strTargetIndex+"&stud_id="+document.studdata_entry.stud_id.value+"&student_type="+document.studdata_entry.student_type.value;
	var win=window.open(pgLoc,"EditWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

}
</script>

<body bgcolor="#D2AE72">
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

GradeSystemTransferee GSTransferee = new GradeSystemTransferee();
vTemp = GSTransferee.getSecondCourseStudInfo(dbOP, request.getParameter("stud_id"));
if(vTemp == null)
	strErrMsg = GSTransferee.getErrMsg();
else//
{
	strDegreeType = dbOP.mapOneToOther("COURSE_OFFERED","course_index",(String)vTemp.elementAt(4),"DEGREE_TYPE",null);
	if(strDegreeType == null)
		strErrMsg = "Error in getting course degree type.";
	else if(WI.fillTextValue("page_action").length() > 0)
	{
	  if(GSTransferee.operateOnTransfereeGrade(dbOP,request,
	  								Integer.parseInt(request.getParameter("page_action"))) != null)
	  	strErrMsg = "Operation successful.";
	  else
	  	strErrMsg = GSTransferee.getErrMsg();
	}
}

String[] astrConvertYear ={"N/A","1st Year","2nd Year","3rd Year","4th Year","5th Year","6th Year","7th Year"};
String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};
if(vTemp != null && vTemp.size() > 0 && WI.fillTextValue("equiv_code").length() > 0 && 
		WI.fillTextValue("equiv_code").compareTo("0") != 0){// I have to get the curriculum detail infromation.
	strCurInfo = GSTransferee.getCurIndex(dbOP,request.getParameter("equiv_code"),(String)vTemp.elementAt(4),(String)vTemp.elementAt(5),
                              (String)vTemp.elementAt(6),(String)vTemp.elementAt(7),strDegreeType);
	if(strCurInfo == null)
		strErrMsg = GSTransferee.getErrMsg();
}

%>


<form action="./second_course_data_entry.jsp" method="post" name="studdata_entry">
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" align="center"><font color="#FFFFFF"><strong>::::
          SECOND COURSE INFORMATION MANAGEMENT :::: </strong> </font></td>
    </tr>
    <tr >
		<td width="2%" height="25">&nbsp;</td>
      <td width="98%"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr > 
      <td width="2%" height="25">&nbsp;</td>
      <td width="13%">Student ID</td>
      <td width="19%"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="5%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
      <td width="61%"><font size="1"> 
        <input name="image" type="image" onClick="ReloadPage();" src="../../../images/form_proceed.gif">
      </font></td>
    <tr >
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><a href="javascript:ViewResidency();"><img src="../../../images/view.gif" border="0"></a> 
        Click to view Residency.</td>
    <tr > 
      <td  colspan="5" height="25"><hr size="1"></td>
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
if(strDegreeType != null && strDegreeType.compareTo("3") ==0){%>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="14%">Select Prep/Proper</td>
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
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
      </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%
//if(false) -- 
{%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Term Type</td>
      <td height="25" colspan="2"><select name="term_type">
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

        </select> </td>
    </tr>
<%}%>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="14%" height="25">
        <%
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
        </select>
        <%}//end of displaying year level%>      </td>
      <td width="18%" height="25"> Term
        <select name="semester" onChange="ReloadPage();">
          <option value="1">1st Sem</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd </option>
          <%}else{%>
          <option value="2">2nd </option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd </option>
          <%}else{%>
          <option value="3">3rd </option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select> </td>
      <td> <font size="1">
        <%if(WI.fillTextValue("is_internship").compareTo("1") == 0)
			strTemp ="checked";
		  else
		  	strTemp = "";
		%>
      <input name="is_internship" type="checkbox" value="1" <%=strTemp%> onClick="showBranch('branch1')">
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
      <td height="12" colspan="9" ><hr size="1"></td>
    </tr>
    <tr>
      <td width="2%" height="25" >&nbsp;</td>
      <td width="28%"  height="25" ><div align="left"><font size="1"><strong><br>
          SUBJECT CODE</strong></font></div></td>
      <td width="35%" ><font size="1"><strong>SUBJECT TITLE</strong></font></td>
      <td width="7%" ><div align="left"><font size="1"><strong>CREDITS EARNED</strong></font></div></td>
      <td width="7%" align="center"><font size="1"><strong>UNITS</strong></font></td>
      <td width="7%" ><div align="left"><font size="1"><strong>FINAL GRADES</strong></font></div></td>
      <td width="7%" ><font size="1"><strong>REMARKS</strong></font></td>
      <td width="7%" ><font size="1"><strong>ACCR<br>
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
      <td ><input name="credit_earned" type="text" size="4" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
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
      <td ><input name="grade" type="text" size="4" maxlength="5" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td ><select name="remark_index">
          <%=dbOP.loadCombo("remark_index", "remark"," from REMARK_STATUS where is_del=0",request.getParameter("remark_index"), false)%>
        </select></td>
      <td ><input name="accredited_credit" type="text" size="4" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
   <%
if(request.getParameter("subject") == null || request.getParameter("subject").compareTo("0") ==0){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td><input type="text" name="sub_code" value="<%=WI.fillTextValue("sub_code")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <font size="1">(enter code)</font></td>
      <td ><input type="text" name="sub_name" size="45" value="<%=WI.fillTextValue("sub_name")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <font size="1">(enter name)</font></td>
    </tr>
    <%}//end of displaying if subject does not exist
%>
    <tr>
      <td>&nbsp;</td>
      <td  height="25" ><font color="#0000FF" size="1" ><strong>EQUIV. SUBJECT
        CODE</strong></font></td>
      <td ><font color="#0000FF" size="1" ><strong>EQUIV. SUBJECT TITLE</strong></font></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td  height="25" ><select name="equiv_code" onChange="ReloadPage();">
	  <option value="">Select a subject</option>
          <%=dbOP.loadCombo("SUB_INDEX","SUB_CODE"," from SUBJECT where IS_DEL=0 order by sub_code asc",WI.getStrValue(WI.fillTextValue("equiv_code"),"0"),false)%>
        </select></td>
      <td>
        <%
strTemp = dbOP.mapOneToOther("SUBJECT","sub_index",request.getParameter("equiv_code"),"SUB_NAME",null);
%>
        <%=WI.getStrValue(strTemp)%></td>
    </tr>
    <tr>
      <td height="25" width="2%">&nbsp;</td>
      <td width="33%">&nbsp;</td>
      <td width="65%">
<%
//if(strCurInfo != null)
{%>
	  <a href="javascript:AddRecord();"><img src="../../../images/add.gif" border="0"></a><font size="1">click
          to add</font>
<%}%>	  </td>
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
          ENTRIES FROM PREV. SCHOOL FOR AY <%=request.getParameter("sy_from")%>
          - <%=request.getParameter("sy_to")%>, TERM 		 
		   <% if (WI.fillTextValue("term_type").equals("2")){ // trimester
		  		strTemp = astrConvertSem[Integer.parseInt(request.getParameter("semester"))] + 
					"(TRIMESTER) ";
			}else if(WI.fillTextValue("term_type").equals("3")){ // annual
		  		strTemp = "(ANNUAL)";
		    }else strTemp = astrConvertSem[Integer.parseInt(request.getParameter("semester"))];%>
			<%=strTemp%>
		  </strong></font></div></td>
    </tr>
    <tr>
      <td width="15%"  height="25" class="thinborder" ><font size="1"><strong>&nbsp;SUBJECT CODE</strong></font></td>
      <td width="25%" class="thinborder" ><font size="1"><strong>SUBJECT TITLE</strong></font></td>
      <td width="15%" class="thinborder" ><strong><font color="#0000FF" size="1" >EQUIV. SUBJECT
        CODE</font></strong></td>
      <td width="7%" class="thinborder" ><div align="left"><font size="1"><strong>CREDITS EARNED</strong></font></div></td>
      <td width="6%" class="thinborder" ><div align="left"><font size="1"><strong>FINAL GRADES</strong></font></div></td>
      <td width="10%" class="thinborder" ><font size="1"><strong>REMARKS</strong></font></td>
      <td width="5%" class="thinborder" ><font size="1"><strong>ACCR<br>
      CREDIT</strong></font></td>
      <td width="15%" class="thinborder" >&nbsp;</td>
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
      <td height="25" colspan="8" class="thinborder">&nbsp;School Name: <strong><%=(String)vTemp.elementAt(i)%></strong></td>
    </tr>
	<%}%>
    <tr>
      <td height="25" class="thinborder">&nbsp;<%=(String)vTemp.elementAt(i+2)%></td>
      <td class="thinborder">&nbsp;<%=(String)vTemp.elementAt(i+3)%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(vTemp.elementAt(i+8),"&nbsp;")%></td>
      <td class="thinborder">&nbsp;<%=(String)vTemp.elementAt(i+4)%></td>
      <td class="thinborder">&nbsp;<%=(String)vTemp.elementAt(i+6)%></td>
      <td class="thinborder">&nbsp;<%=(String)vTemp.elementAt(i+7)%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(vTemp.elementAt(i+10),"&nbsp;")%></td>
      <td class="thinborder"> 
      <a href='javascript:EditRecord("<%=(String)vTemp.elementAt(i+1)%>");'><img src="../../../images/edit.gif" border="0"></a>
	  <a href='javascript:DeleteRecord("<%=(String)vTemp.elementAt(i+1)%>");'><img src="../../../images/delete.gif" width="55" height="28" border="0"></a></td>
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
      <td height="25">&nbsp;</td>
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
<input type="hidden" name="student_type" value="Second Course">

<script language="javascript">
	showBranch('branch1');
</script>

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
