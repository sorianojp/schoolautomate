<%@ page language="java" import="utility.*,java.util.Vector,ClassMgmt.CMSyllabusNew" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
	
	//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FACULTY/ACAD. ADMIN-CLASS MANAGEMENT"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FACULTY/ACAD. ADMIN"),"0"));
		}
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../faculty_acad/faculty_acad_bottom_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out.Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

	//end of authenticaion code.

	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Faculty/Acad. Admin-CLASS MANAGEMENT-Syllabus","syllabus_new.jsp");
	}
	catch(Exception exp) {
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"><%=strErrMsg%></p>
		<%
		return;
	}

CMSyllabusNew cmsNew   = new CMSyllabusNew();
Vector vSubInfo     = null;
Vector vGeneralInfo = null; Vector vFacultyInfo = null;

///
Vector vCourseCalendar = null;
Vector vCourseReq      = null;
Vector vGradingSystem  = null;
Vector vMethods        = null;
Vector vMaterial       = null;

Vector vTempInfo       = null;

strTemp = WI.fillTextValue("page_action");
vGeneralInfo = cmsNew.operateOnGC(dbOP, request, Integer.parseInt(WI.getStrValue(strTemp, "0")));
if(vGeneralInfo.size() > 0 && vGeneralInfo.elementAt(0) == null) {
	vGeneralInfo.removeElementAt(0);
	strErrMsg = cmsNew.getErrMsg();
}
String strFacultyIndex = (String)request.getSession(false).getAttribute("userIndex");

vFacultyInfo = cmsNew.operateOnID(dbOP, request, Integer.parseInt(WI.getStrValue(strTemp, "0")), 
				strFacultyIndex);
if(vFacultyInfo.size() > 0 && vFacultyInfo.elementAt(0) == null) {
	vFacultyInfo.removeElementAt(0);
	strErrMsg = cmsNew.getErrMsg();
}
String strSubIndex = WI.fillTextValue("sub_index");

////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////GENERIC OPERATIONS //////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
	int iPageAction   = Integer.parseInt(WI.getStrValue(strTemp,"4"));
	Vector vFields    = new Vector();
	Vector vFieldName = new Vector();
	Vector vFieldVal  = new Vector();
	Vector vFieldType = new Vector();
	
////////////////////////////////////////////////////course calendar /////////////////////////////////
		vFieldName.addElement("FACULTY_INDEX");		
		vFieldName.addElement("SUB_INDEX");		
		vFieldName.addElement("SY_FROM");		
		vFieldName.addElement("SEMESTER");		
		vFieldName.addElement("WEEK_NO");
		vFieldName.addElement("SYL_DATE");
		vFieldName.addElement("TOPIC_DESC");	
		vFieldName.addElement("READING_DUE");
		vFieldName.addElement("ADDL_INFO");		
		vFieldName.addElement("CREATE_DATE");
		vFieldName.addElement("CREATED_BY");

		vFieldVal.addElement(strFacultyIndex);		
		vFieldVal.addElement(strSubIndex);		
		vFieldVal.addElement(WI.fillTextValue("sy_from"));		
		vFieldVal.addElement(WI.fillTextValue("semester"));		
		vFieldVal.addElement(WI.getInsertValueForDB(WI.fillTextValue("week_no"), true, null));		
		vFieldVal.addElement(WI.getInsertValueForDB(WI.fillTextValue("syl_date"), true, null));
		vFieldVal.addElement(WI.getInsertValueForDB(WI.fillTextValue("topic_desc"), true, null));		
		vFieldVal.addElement(WI.getInsertValueForDB(WI.fillTextValue("reading_due"), true, null));
		vFieldVal.addElement(WI.getInsertValueForDB(WI.fillTextValue("addl_info"), true, null));		
		vFieldVal.addElement(WI.getInsertValueForDB(WI.getTodaysDate(), true, null));
		vFieldVal.addElement(strFacultyIndex);

		vFieldType.addElement("0");		
		vFieldType.addElement("0");		
		vFieldType.addElement("0");		
		vFieldType.addElement("0");		
		vFieldType.addElement("0");		
		vFieldType.addElement("1");
		vFieldType.addElement("0");		
		vFieldType.addElement("0");
		vFieldType.addElement("0");		
		vFieldType.addElement("1");
		vFieldType.addElement("0");

		vFields.addElement("11"); vFields.addElement("CM_SYL_CALENDAR");	
		vFields.addElement("CALENDAR_INDEX");
		vFields.addElement(vFieldName);vFields.addElement(vFieldVal);vFields.addElement(vFieldType);
		
		request.setAttribute("extra_con"," where sub_index = "+strSubIndex+" and faculty_index="+
			strFacultyIndex+" and sy_from="+WI.fillTextValue("sy_from")+" and semester="+
			WI.fillTextValue("semester")+" order by syl_date,week_no");
		
	if(iPageAction > 29 && iPageAction < 40) {
		iPageAction = iPageAction %30;
		if(iPageAction == 1 && WI.fillTextValue("week_no").length() == 0 && WI.fillTextValue("syl_date").length() == 0) {
			strErrMsg = "Enter either week number or date.";
		}
		else if(cmsNew.operateOnGenericEntry(dbOP, request, vFields, iPageAction) == null)
			strErrMsg = cmsNew.getErrMsg();
		else	
			strErrMsg = "Operation successful";
	}
	vCourseCalendar = cmsNew.operateOnGenericEntry(dbOP, request, vFields, 4);
///////////// requirement.. 
	vFields.clear(); vFieldName.clear(); vFieldVal.clear(); vFieldType.clear();
	vFieldName.addElement("FACULTY_INDEX"); vFieldName.addElement("SUB_INDEX");
	vFieldName.addElement("SY_FROM");		vFieldName.addElement("SEMESTER");
	vFieldName.addElement("REQUIREMENT");   vFieldName.addElement("PERCENTAGE");		
	
	vFieldVal.addElement(strFacultyIndex);	vFieldVal.addElement(strSubIndex);		
	vFieldVal.addElement(WI.fillTextValue("sy_from")); vFieldVal.addElement(WI.fillTextValue("semester"));		
	vFieldVal.addElement(WI.getInsertValueForDB(WI.fillTextValue("requirement"), true, null));		
	vFieldVal.addElement(WI.getInsertValueForDB(WI.fillTextValue("percentage"), true, null));

	vFieldType.addElement("0");		vFieldType.addElement("0");		vFieldType.addElement("0");		
	vFieldType.addElement("0");		vFieldType.addElement("0");		vFieldType.addElement("0");

		vFields.addElement("6"); vFields.addElement("CM_SYL_REQUIREMENT");	
		vFields.addElement("REQ_INDEX");
		vFields.addElement(vFieldName);vFields.addElement(vFieldVal);vFields.addElement(vFieldType);
		request.setAttribute("extra_con"," where sub_index = "+strSubIndex+" and faculty_index="+
			strFacultyIndex+" and sy_from="+WI.fillTextValue("sy_from")+" and semester="+
			WI.fillTextValue("semester"));
	if(iPageAction > 39 && iPageAction < 50) {
		iPageAction = iPageAction %40;
		if(iPageAction == 1 && WI.fillTextValue("requirement").length() == 0 ) {
			strErrMsg = "Enter requirement information.";
		}
		else if(cmsNew.operateOnGenericEntry(dbOP, request, vFields, iPageAction) == null)
			strErrMsg = cmsNew.getErrMsg();
		else	
			strErrMsg = "Operation successful";
	}
	vCourseReq = cmsNew.operateOnGenericEntry(dbOP, request, vFields, 4);

///////////// vGradingSystem.. 
	vFields.clear(); vFieldName.clear(); vFieldVal.clear(); vFieldType.clear();
	vFieldName.addElement("FACULTY_INDEX"); vFieldName.addElement("SUB_INDEX");
	vFieldName.addElement("SY_FROM");		vFieldName.addElement("SEMESTER");
	vFieldName.addElement("L_GRADE");       vFieldName.addElement("NUM_EQUIV");
	vFieldName.addElement("PERCENT_EQUIV");		

	vFieldVal.addElement(strFacultyIndex);	vFieldVal.addElement(strSubIndex);		
	vFieldVal.addElement(WI.fillTextValue("sy_from")); vFieldVal.addElement(WI.fillTextValue("semester"));		
	vFieldVal.addElement(WI.getInsertValueForDB(WI.fillTextValue("l_grade"), true, null));		
	vFieldVal.addElement(WI.getInsertValueForDB(WI.fillTextValue("num_equiv"), true, null));		
	vFieldVal.addElement(WI.getInsertValueForDB(WI.fillTextValue("percent_equiv"), true, null));		

	vFieldType.addElement("0");		vFieldType.addElement("0");		vFieldType.addElement("0");		
	vFieldType.addElement("0");		vFieldType.addElement("0");		vFieldType.addElement("0");
	vFieldType.addElement("0");

		vFields.addElement("7"); vFields.addElement("CM_SYL_GRADESYSTEM");	
		vFields.addElement("GS_INDEX");
		vFields.addElement(vFieldName);vFields.addElement(vFieldVal);vFields.addElement(vFieldType);
		request.setAttribute("extra_con"," where sub_index = "+strSubIndex+" and faculty_index="+
			strFacultyIndex+" and sy_from="+WI.fillTextValue("sy_from")+" and semester="+
			WI.fillTextValue("semester"));
	if(iPageAction > 49 && iPageAction < 60) {
		iPageAction = iPageAction %50;
		if(iPageAction == 1 && WI.fillTextValue("l_grade").length() == 0 ) {
			strErrMsg = "Enter Grading system information.";
		}
		else if(cmsNew.operateOnGenericEntry(dbOP, request, vFields, iPageAction) == null)
			strErrMsg = cmsNew.getErrMsg();
		else	
			strErrMsg = "Operation successful";
	}
	vGradingSystem = cmsNew.operateOnGenericEntry(dbOP, request, vFields, 4);

///////////// vMethods.. 
	vFields.clear(); vFieldName.clear(); vFieldVal.clear(); vFieldType.clear();
	vFieldName.addElement("FACULTY_INDEX"); vFieldName.addElement("SUB_INDEX");
	vFieldName.addElement("SY_FROM");		vFieldName.addElement("SEMESTER");
	vFieldName.addElement("METHODS");       vFieldName.addElement("STRATEGIES");

	vFieldVal.addElement(strFacultyIndex);	vFieldVal.addElement(strSubIndex);		
	vFieldVal.addElement(WI.fillTextValue("sy_from")); vFieldVal.addElement(WI.fillTextValue("semester"));		
	vFieldVal.addElement(WI.getInsertValueForDB(WI.fillTextValue("methods"), true, null));		
	vFieldVal.addElement(WI.getInsertValueForDB(WI.fillTextValue("strategies"), true, null));		

	vFieldType.addElement("0");		vFieldType.addElement("0");		vFieldType.addElement("0");		
	vFieldType.addElement("0");		vFieldType.addElement("0");		vFieldType.addElement("0");

		vFields.addElement("6"); vFields.addElement("CM_SYL_METHODS");	
		vFields.addElement("METHOD_INDEX");
		vFields.addElement(vFieldName);vFields.addElement(vFieldVal);vFields.addElement(vFieldType);
		request.setAttribute("extra_con"," where sub_index = "+strSubIndex+" and faculty_index="+
			strFacultyIndex+" and sy_from="+WI.fillTextValue("sy_from")+" and semester="+
			WI.fillTextValue("semester"));
	if(iPageAction > 59 && iPageAction < 70) {
		iPageAction = iPageAction %60;
		if(iPageAction == 1 && WI.fillTextValue("methods").length() == 0 ) {
			strErrMsg = "Enter Method information.";
		}
		else if(cmsNew.operateOnGenericEntry(dbOP, request, vFields, iPageAction) == null)
			strErrMsg = cmsNew.getErrMsg();
		else	
			strErrMsg = "Operation successful";
	}
	vMethods = cmsNew.operateOnGenericEntry(dbOP, request, vFields, 4);

///////////// vMaterial.. 
	vFields.clear(); vFieldName.clear(); vFieldVal.clear(); vFieldType.clear();
	vFieldName.addElement("FACULTY_INDEX"); vFieldName.addElement("SUB_INDEX");
	vFieldName.addElement("SY_FROM");		vFieldName.addElement("SEMESTER");
	vFieldName.addElement("MATERIAL");      vFieldName.addElement("REMARK");

	vFieldVal.addElement(strFacultyIndex);	vFieldVal.addElement(strSubIndex);		
	vFieldVal.addElement(WI.fillTextValue("sy_from")); vFieldVal.addElement(WI.fillTextValue("semester"));		
	vFieldVal.addElement(WI.getInsertValueForDB(WI.fillTextValue("material"), true, null));		
	vFieldVal.addElement(WI.getInsertValueForDB(WI.fillTextValue("remark"), true, null));		

	vFieldType.addElement("0");		vFieldType.addElement("0");		vFieldType.addElement("0");		
	vFieldType.addElement("0");		vFieldType.addElement("0");		vFieldType.addElement("0");

		vFields.addElement("6"); vFields.addElement("CM_SYL_MATERIAL");	
		vFields.addElement("MATERIAL_INDEX");
		vFields.addElement(vFieldName);vFields.addElement(vFieldVal);vFields.addElement(vFieldType);
		request.setAttribute("extra_con"," where sub_index = "+strSubIndex+" and faculty_index="+
			strFacultyIndex+" and sy_from="+WI.fillTextValue("sy_from")+" and semester="+
			WI.fillTextValue("semester"));
	if(iPageAction > 69 && iPageAction < 80) {
		iPageAction = iPageAction %70;
		if(iPageAction == 1 && WI.fillTextValue("material").length() == 0 ) {
			strErrMsg = "Please Enter Material information.";
		}
		else if(cmsNew.operateOnGenericEntry(dbOP, request, vFields, iPageAction) == null)
			strErrMsg = cmsNew.getErrMsg();
		else	
			strErrMsg = "Operation successful";
	}
	vMaterial = cmsNew.operateOnGenericEntry(dbOP, request, vFields, 4);

/**
Vector vCourseCalendar = null;
Vector vCourseReq      = null;
Vector vGradingSystem  = null;
Vector vMethods        = null;
Vector vMaterial       = null;
Vector vTextBooks      = null;
**/

if(strSubIndex.length() > 0) {
	vSubInfo = cmsNew.getSubInfo(dbOP,strSubIndex, WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"));
	if(vSubInfo == null) 
		strErrMsg = cmsNew.getErrMsg();
}


String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null) 
	strSchCode = "";


java.sql.ResultSet rs = null;%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="javascript">
function FocusID() {
	if(!document.form_.focus_field)
		return;
	var strFocusVal = document.form_.focus_field.value;
	if(strFocusVal.length == 0)
		return;
	eval('document.form_.'+strFocusVal+'.focus()');
}
function UpdateInformation(strReference) {
	var strSubIndex = document.form_.sub_index.value;
	var strSYFrom   = document.form_.sy_from.value;
	var strSem      = document.form_.semester[document.form_.semester.selectedIndex].value;
	if(strSubIndex.length == 0) {
		alert("please select a subject.");
		return;
	}
	if(strReference == 1) {
		var pgLoc = "./textbook_ref.jsp?sub_index="+strSubIndex+"&sy_from="+strSYFrom+
		"&semester="+strSem;
		var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
	else {
		var pgLoc = "./ind_lesson.jsp?sub_index="+strSubIndex+"&sy_from="+strSYFrom+
		"&semester="+strSem;
		var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}

}
</script>
<body onLoad="FocusID();">
<form name="form_" method="post" action="./syllabus_new.jsp" onSubmit="SubmitOnceButton(this);">  
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3" bgcolor="#6A99A2"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          SYLLABUS MAINTENANCE PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;
	  <font size="3" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="5%" height="25">&nbsp;</td>
      <td width="8%">SY/Term </td>
      <td width="87%">
<%
	strTemp = WI.fillTextValue("sy_from");
	if(strTemp.length() ==0) 
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp=" DisplaySYTo('form_','sy_from','sy_to')">
<%
	strTemp = WI.fillTextValue("sy_to");
	if(strTemp.length() ==0) 
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
-
<input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">
<select name="semester">
  <option value="0">Summer</option>
  <%
strTemp = WI.fillTextValue("semester");
	if(strTemp.length() ==0) 
		strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.equals("1")){%>
  <option value="1" selected>1st Sem</option>
  <%}else{%>
  <option value="1">1st Sem</option>
  <%}if(strTemp.equals("2")){%>
  <option value="2" selected>2nd Sem</option>
  <%}else{%>
  <option value="2">2nd Sem</option>
  <%}if(strTemp.equals("3") && !strSchCode.startsWith("CPU") ){%>
  <option value="3" selected>3rd Sem</option>
  <%}else if(!strSchCode.startsWith("CPU")){%>
  <option value="3">3rd Sem</option>
  <%}%>
</select>&nbsp;&nbsp;
<input type="submit" name="132" value="Reload Page" style="font-size:11px; height:22px;border: 1px solid #FF0000;"
	  onClick="document.form_.page_action.value='';"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="5%" height="25">&nbsp; </td>
      <td width="95%" height="25">Subject Code : <font size="1"> 
      (enter subject code to scroll the list)</font> &nbsp;&nbsp; <input type="submit" name="13" value="Reload Page" style="font-size:11px; height:22px;border: 1px solid #FF0000;"
	  onClick="document.form_.page_action.value='';"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp; </td>
      <td><select name="sub_index" title="SELECT A  SUBJECT"
	  	style="font-size:11px;font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;" onChange="ReloadPage();">
          <option value=""> .. select a subject .. </option>
          <%=dbOP.loadCombo("sub_index","sub_code +'&nbsp;&nbsp;&nbsp;('+sub_name+')' as s_code"," from subject where is_del=0 order by s_code",WI.fillTextValue("sub_index"), false)%> 
        </select>
        <font size="1">
        <input type="text" name="scroll_sub" size="16" style="font-size:9px" 
	  onKeyUp="AutoScrollListSubject('scroll_sub','sub_index',true,'form_');"
	  class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
	   onBlur="style.backgroundColor='#FFFFFF'" >
        </font></td>
    </tr>
<%
if(vSubInfo != null) {%>
     <tr> 
      <td height="25">&nbsp;</td>
      <td><table width="99%" border="0" cellspacing="0" cellpadding="0" bgcolor="#CCCCCC" class="thinborder">
          <tr> 
            <td width="13%" height="25" class="thinborder"><strong><font size="1">SCHOOL YEAR</font></strong></td>
            <td width="12%" class="thinborder"><strong><font size="1">TERM</font></strong></td>
            <td width="31%" class="thinborder"><strong><font size="1">INSTRUCTOR</font></strong></td>
            <td width="44%" class="thinborder"><strong><font size="1">POSITION/ COLLEGE</font></strong></td>
          </tr>
          <tr> 
            <td height="25" class="thinborder">&nbsp;</td>
            <td class="thinborder">&nbsp;</td>
            <td class="thinborder">&nbsp;</td>
            <td class="thinborder">&nbsp;</td>
          </tr>
        </table>
        <br>
        NOTE: show on the table the list of existing syllabus under the selected 
        subject. Make the Instructor name clickable. When they click the instructor 
        name , then load the syllabus of that instructor.</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><div align="right"><a href="javascript:PrintPg();"><img src="../../../images/copy.gif" border=0></a><font size="1">click 
          to COPY SYLLABUS</font>&nbsp;&nbsp;&nbsp;&nbsp;<font size="1"><a href="syllabus_new_print.htm" target="_blank"><img src="../../../images/print.gif" border="0"></a></font><font size="1">click 
          to PRINT SYLLABUS</font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="1" cellspacing="0" class="thinborderALL">
    <tr bgcolor="#FFCC99"> 
      <td height="25" colspan="2" class="thinborderBOTTOM"><strong><font color="#0000FF">&nbsp;&nbsp;1. GENERAL COURSE INFORMATION</font></strong></td>
    </tr>
    <tr> 
      <td width="23%" height="25" class="thinborderRIGHT">Course Number :</td>
      <td width="72%" class="thinborderNONE"><%=vSubInfo.remove(0)%></td>
    </tr>
    <tr> 
      <td height="25" class="thinborderRIGHT">Course Title :</td>
      <td class="thinborderNONE"><%=vSubInfo.remove(0)%></td>
    </tr>
    <tr> 
      <td height="25" class="thinborderRIGHT">No. of Teaching Hours : </td>
<%
strTemp = (String)vSubInfo.remove(1);
%>      <td class="thinborderNONE"> <%=strTemp%> hours a week</td>
    </tr>
    <tr> 
      <td height="25" class="thinborderRIGHT">Unit Credit : </td>
      <td class="thinborderNONE"><%=vSubInfo.remove(0)%> units </td>
    </tr>
    <tr> 
      <td height="25" class="thinborderRIGHT">Total Hours :</td>
      <td class="thinborderNONE"><%=Integer.parseInt(strTemp) * 18%></td>
    </tr>
    <tr> 
      <td height="25" class="thinborderRIGHT">Time Allotment :</td>
      <td class="thinborderNONE">
<%
if(vGeneralInfo.size() > 0)
	strTemp = (String)vGeneralInfo.elementAt(2);
else	
	strTemp = "";
%>
	  	<input name="time_allot" type="text" size="8" maxlength="8" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='#FFFFFF'" value="<%=strTemp%>">
	  	(Optional)</td>
    </tr>
    <tr> 
      <td height="25" class="thinborderRIGHT">Prerequisites :</td>
      <td class="thinborderNONE">
	  <%strTemp = "";
	  for(int i =0; i < vSubInfo.size(); i += 2) {
	  	if(strTemp.length() == 0)
			strTemp = WI.getStrValue(vSubInfo.elementAt(i))+" "+WI.getStrValue(vSubInfo.elementAt(i + 1));
		else
			strTemp = strTemp +", "+ WI.getStrValue(vSubInfo.elementAt(i))+" "+WI.getStrValue(vSubInfo.elementAt(i + 1));
	  }%>
	  <%=strTemp%>
	  </td>
    </tr>
    <tr>
      <td height="25" class="thinborderBOTTOMRIGHT" valign="top"><br>Course Description </td>
      <td class="thinborderBOTTOM">
<%
if(vGeneralInfo.size() > 0)
	strTemp = (String)vGeneralInfo.elementAt(0);
else	
	strTemp = "";
%>
	  <textarea name="course_desc" cols="75" rows="4" style="font-size:10px" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='#FFFFFF'"><%=strTemp%></textarea>
	  </td>
    </tr>
    <tr> 
      <td height="10" valign="bottom">Course Objectives *(Required)</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="2" valign="top" >
<%
if(vGeneralInfo.size() > 0)
	strTemp = (String)vGeneralInfo.elementAt(0);
else	
	strTemp = "";
%>
	  <textarea name="course_obj" cols="75" rows="4" style="font-size:10px" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='#FFFFFF'"><%=strTemp%></textarea>
	  &nbsp;&nbsp;<input type="submit" name="1322" value="Update Information" style="font-size:11px; height:22px;border: 1px solid #FF0000;"
	  onClick="document.form_.page_action.value='1';document.form_.focus_field.value='course_obj'">
  	  </td>
    </tr>
<%}//only if vSubInfo not null.%>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="1" cellspacing="0">
  <tr> 
      <td height="15" colspan="2">&nbsp;</td>
    </tr>
  </table>
<%
if(vFacultyInfo != null && vFacultyInfo.size() > 0) {%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
    <tr bgcolor="#FFCC99"> 
      <td height="25" colspan="2" class="thinborderBOTTOM"><strong><font color="#0000FF">&nbsp;&nbsp;2. INSTRUCTOR DETAILS</font></strong></td>
    </tr>
    <tr>
      <td height="25" class="thinborderRIGHT">Faculty ID : </td>
      <td>&nbsp;<%=vFacultyInfo.remove(0)%></td>
    </tr>
    <tr> 
      <td width="23%" height="25" class="thinborderRIGHT">Name :</td>
      <td width="72%">&nbsp;<%=vFacultyInfo.remove(0)%></td>
    </tr>
    <tr> 
      <td height="25" class="thinborderRIGHT">Position / College:</td>
<%
strTemp = (String)vFacultyInfo.remove(0);
if(strTemp == null)
	strTemp = (String)vFacultyInfo.remove(0);
else	
	vFacultyInfo.removeElementAt(0);
strTemp = (String)vFacultyInfo.remove(0)+" / "+strTemp;
%>
      <td>&nbsp;<%=strTemp%></td>
    </tr>
    <tr> 
      <td height="25" class="thinborderRIGHT">Email Address : </td>
      <td style="font-size:9px;"> 
	  <input name="email_id" type="text" size="54" maxlength="64" class="textbox" 
	  	onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='#FFFFFF'"
		 value="<%=WI.getStrValue(vFacultyInfo.remove(3))%>">
        (Optional)</td>
    </tr>
    <tr> 
      <td height="25" class="thinborderRIGHT">Office Phone No. :</td>
      <td style="font-size:9px;"><input name="office_phone" type="text" size="54" maxlength="64" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='#FFFFFF'"
		 value="<%=WI.getStrValue(vFacultyInfo.remove(0))%>">
        (Optional)</td>
    </tr>
    <tr> 
      <td height="25" class="thinborderRIGHT">Office Room Nos. :</td>
      <td style="font-size:9px;"><input name="office_room" type="text" size="54" maxlength="64" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='#FFFFFF'"
		 value="<%=WI.getStrValue(vFacultyInfo.remove(0))%>">
        (Optional)</td>
    </tr>
    <tr> 
      <td height="25" class="thinborderRIGHT">Counseling Hours :</td>
      <td style="font-size:9px;"><input name="counseling_hr" type="text" size="54" maxlength="64" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='#FFFFFF'"
		 value="<%=WI.getStrValue(vFacultyInfo.remove(0))%>">
        (Optional)</td>
    </tr>
    <tr> 
      <td height="46" colspan="2" class="thinborderTOP" align="center"><input type="submit" name="13222" value="Update Information" style="font-size:11px; height:22px;border: 1px solid #FF0000;"
	  onClick="document.form_.page_action.value='21';document.form_.focus_field.value='counseling_hr'"></td>
    </tr>
  </table>
<%}//end of faculty info printing.. %>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="1" cellspacing="0">
  <tr> 
      <td height="15" colspan="2">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="1" cellspacing="0" class="thinborderALL">
  <tr bgcolor="#FFCC99"> 
      <td height="25" colspan="6" class="thinborderBOTTOM"><strong><font color="#0000FF">&nbsp;&nbsp;3. COURSE CALENDAR (Optional)</font></strong></td>
    </tr>
    <tr> 
      <td width="5%" height="25"><div align="center"><strong><font size="1">WEEK</font></strong></div></td>
      <td width="18%"><div align="center"><strong><font size="1">DATE</font></strong></div></td>
      <td width="24%"><div align="center"><strong><font size="1">TOPIC</font></strong></div></td>
      <td width="24%"><div align="center"><strong><font size="1">READING DUE</font></strong></div></td>
      <td width="24%"><div align="center"><strong><font size="1">ADDITIONAL INFO</font></strong></div></td>
      <td width="5%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">
        <input name="week_no" type="text" size="2" maxlength="2" class="textbox" style="font-size:10px;" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='#FFFFFF'" value="<%=WI.fillTextValue("week_no")%>">
      </td>
      <td><input name="syl_date" type="text" class="textbox" id="date_attendance"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  value="<%=WI.fillTextValue("syl_date")%>" size="11" maxlength="11" 
	   style="font-size:9px">
        <a href="javascript:show_calendar('form_.syl_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0" width="18"></a></td>
      <td height="25">
	  <textarea name="topic_desc" cols="25" rows="3" style="font-size:10px" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='#FFFFFF'"><%=WI.fillTextValue("topic_desc")%></textarea></td>
      <td><textarea name="reading_due" cols="25" rows="3" style="font-size:10px" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='#FFFFFF'"><%=WI.fillTextValue("reading_due")%></textarea></td>
      <td><textarea name="addl_info" cols="25" rows="3" style="font-size:10px" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='#FFFFFF'"><%=WI.fillTextValue("addl_info")%></textarea></td>
      <td>
        <input type="submit" name="132222" value=" Add " style="font-size:11px; height:22px;border: 1px solid #FF0000;"
	  onClick="document.form_.page_action.value='31';document.form_.focus_field.value='week_no'">
      </td>
    </tr>
    <tr> 
      <td height="10" colspan="6"><hr size="1" color="#0B0000"></td>
    </tr>
<%if(vCourseCalendar != null){
for(int i = 0; i < vCourseCalendar.size(); i += 12){%>
    <tr> 
      <td height="25" style="font-size:9px"><%=vCourseCalendar.elementAt(i + 4)%></td>
      <td style="font-size:9px"><%=vCourseCalendar.elementAt(i + 5)%></td>
      <td style="font-size:9px"><%=vCourseCalendar.elementAt(i + 6)%></td>
      <td style="font-size:9px"><%=vCourseCalendar.elementAt(i + 7)%></td>
      <td style="font-size:9px"><%=vCourseCalendar.elementAt(i + 8)%></td>
      <td>
        <input type="submit" name="1322222" value=" Delete " style="font-size:11px; height:22px;border: 1px solid #FF0000;"
	  onClick="document.form_.page_action.value='30';document.form_.focus_field.value='week_no';document.form_.info_index.value=<%=vCourseCalendar.elementAt(i + 11)%>">
      </td>
    </tr>
<%}//for loop.
}//if vCourseCalendar not null. %>
    <tr> 
      <td height="25" colspan="6">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="1" cellspacing="0">
  <tr> 
      <td height="15" colspan="2">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="1" cellspacing="0" class="thinborderALL">
  <tr bgcolor="#FFCC99"> 
      <td height="25" colspan="3" class="thinborderBOTTOM"><strong><font color="#0000FF">&nbsp;&nbsp;4. COURSE REQUIREMENTS</font></strong></td>
    </tr>
    <tr> 
      <td width="61%" height="25" style="font-size:9px; font-weight:bold">REQUIREMENTS/EVALUATION</td>
      <td width="29%" style="font-size:9px; font-weight:bold">PERCENTAGE</td>
      <td width="10%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"><textarea name="requirement" cols="50" rows="3" style="font-size:10px" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='#FFFFFF'"><%=WI.fillTextValue("requirement")%></textarea>
	  </td>
      <td><textarea name="percentage" cols="25" rows="3" style="font-size:10px" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='#FFFFFF'"><%=WI.fillTextValue("percentage")%></textarea></td>
      <td><input type="submit" name="1322223" value=" Add " style="font-size:11px; height:22px;border: 1px solid #FF0000;"
	  onClick="document.form_.page_action.value='41';document.form_.focus_field.value='requirement'"></td>
    </tr>
    <tr> 
      <td colspan="3"><hr size="1" color="#0B0000"></td>
    </tr>
<%if(vCourseReq != null){
for(int i = 0; i < vCourseReq.size(); i += 7){%>
    <tr> 
      <td height="25" style="font-size:9px"><%=vCourseReq.elementAt(i + 4)%></td>
      <td style="font-size:9px"><%=vCourseReq.elementAt(i + 5)%></td>
      <td><input type="submit" name="13222222" value=" Delete " style="font-size:11px; height:22px;border: 1px solid #FF0000;"
	  onClick="document.form_.page_action.value='40';document.form_.focus_field.value='requirement';document.form_.info_index.value=<%=vCourseReq.elementAt(i + 6)%>"></td>
    </tr>
<%}
}%>
    <tr> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="1" cellspacing="0">
  <tr> 
      <td height="15" colspan="2">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="1" cellspacing="0" class="thinborderALL">
  <tr bgcolor="#FFCC99"> 
      <td height="25" colspan="4" class="thinborderBOTTOM"><strong><font color="#0000FF">&nbsp;&nbsp;5. GRADING SYSTEM</font></strong></td>
    </tr>
    <tr> 
      <td width="13%" style="font-size:9px; font-weight:bold">LETTER GRADE</td>
      <td width="22%" height="25" style="font-size:9px; font-weight:bold">NUMERICAL EQUIVALENT</td>
      <td width="55%" style="font-size:9px; font-weight:bold">PERCENTAGES EQUIVALENT</td>
      <td width="10%">&nbsp;</td>
    </tr>
    <tr> 
      <td><input name="l_grade" type="text" size="8" maxlength="12" class="textbox" 
	  	onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='#FFFFFF'"
		 value="<%=WI.fillTextValue("l_grade")%>"></td>
      <td height="25"><input name="num_equiv" type="text" size="12" maxlength="12" class="textbox" 
	  	onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='#FFFFFF'"
		 value="<%=WI.fillTextValue("num_equiv")%>"></td>
      <td><input name="percent_equiv" type="text" size="24" maxlength="24" class="textbox" 
	  	onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='#FFFFFF'"
		 value="<%=WI.fillTextValue("percent_equiv")%>"></td>
      <td><input type="submit" name="13222232" value=" Add " style="font-size:11px; height:22px;border: 1px solid #FF0000;"
	  onClick="document.form_.page_action.value='51';document.form_.focus_field.value='l_grade'"></td>
    </tr>
    <tr> 
      <td colspan="4"><hr size="1" color="#0B0000"></td>
    </tr>
<%if(vGradingSystem != null){
for(int i = 0; i < vGradingSystem.size(); i += 8){%>
    <tr> 
      <td style="font-size:9px"><%=vGradingSystem.elementAt(i + 4)%></td>
      <td height="25" style="font-size:9px"><%=vGradingSystem.elementAt(i + 5)%></td>
      <td style="font-size:9px"><%=vGradingSystem.elementAt(i + 6)%></td>
      <td><input type="submit" name="132222222" value=" Delete " style="font-size:11px; height:22px;border: 1px solid #FF0000;"
	  onClick="document.form_.page_action.value='50';document.form_.focus_field.value='l_grade';document.form_.info_index.value=<%=vGradingSystem.elementAt(i + 7)%>"></td>
    </tr>
<%}
}%>    <tr> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="1" cellspacing="0">
  <tr> 
      <td height="15" colspan="2">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="1" cellspacing="0" class="thinborderALL">
  <tr bgcolor="#FFCC99"> 
      <td height="25" colspan="3" class="thinborderBOTTOM"><strong><font color="#0000FF">&nbsp;&nbsp;6. METHODS AND 
        STRATEGIES</font></strong></td>
    </tr>
    <tr> 
      <td width="45%" style="font-size:9px; font-weight:bold">METHODS</td>
      <td width="45%" height="25" style="font-size:9px; font-weight:bold">STRATEGIES</td>
      <td width="10%">&nbsp;</td>
    </tr>
    <tr> 
      <td><textarea name="methods" cols="50" rows="3" style="font-size:10px" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='#FFFFFF'"><%=WI.fillTextValue("methods")%></textarea></td>
      <td height="25"><textarea name="strategies" cols="50" rows="3" style="font-size:10px" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='#FFFFFF'"><%=WI.fillTextValue("strategies")%></textarea>	  </td>
      <td><input type="submit" name="132222322" value=" Add " style="font-size:11px; height:22px;border: 1px solid #FF0000;"
	  onClick="document.form_.page_action.value='61';document.form_.focus_field.value='methods'"></td>
    </tr>
    <tr> 
      <td colspan="3"><hr size="1" color="#0B0000"></td>
    </tr>
<%if(vMethods != null){
for(int i = 0; i < vMethods.size(); i += 7){%>
    <tr> 
      <td style="font-size:9px;"><%=vMethods.elementAt(i + 4)%></td>
      <td height="25" style="font-size:9px;"><%=vMethods.elementAt(i + 4)%></td>
      <td><input type="submit" name="1322222222" value=" Delete " style="font-size:11px; height:22px;border: 1px solid #FF0000;"
	  onClick="document.form_.page_action.value='60';document.form_.focus_field.value='methods';document.form_.info_index.value=<%=vMethods.elementAt(i + 6)%>"></td>
    </tr>
<%}
}%>    <tr> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="1" cellspacing="0">
  <tr> 
      <td height="15" colspan="2">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="1" cellspacing="0" class="thinborderALL">
  <tr bgcolor="#FFCC99"> 
      <td height="25" colspan="3" class="thinborderBOTTOM"><strong><font color="#0000FF">&nbsp;&nbsp;7. MATERIALS NEEDED</font></strong></td>
    </tr>
    <tr> 
      <td width="45%" style="font-size:9px; font-weight:bold">MATERIALS</td>
      <td width="45%" height="25" style="font-size:9px; font-weight:bold">REMARKS</td>
      <td width="10%" style="font-size:9px; font-weight:bold">&nbsp;</td>
    </tr>
    <tr> 
      <td>
	  <textarea name="material" cols="50" rows="3" style="font-size:10px" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='#FFFFFF'"><%=WI.fillTextValue("material")%></textarea>		</td>
      <td height="25">
	  <textarea name="remark" cols="50" rows="3" style="font-size:10px" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='#FFFFFF'"><%=WI.fillTextValue("remark")%></textarea>	  </td>
      <td><input type="submit" name="1322223222" value=" Add " style="font-size:11px; height:22px;border: 1px solid #FF0000;"
	  onClick="document.form_.page_action.value='71';document.form_.focus_field.value='material'"></td>
    </tr>
    <tr> 
      <td colspan="3"><hr size="1" color="#0B0000"></td>
    </tr>
<%if(vMaterial != null){
for(int i = 0; i < vMaterial.size(); i += 7){%>
    <tr> 
      <td style="font-size:9px;"><%=vMaterial.elementAt(i + 4)%></td>
      <td height="25" style="font-size:9px;"><%=vMaterial.elementAt(i + 5)%></td>
      <td><input type="submit" name="13222222222" value=" Delete " style="font-size:11px; height:22px;border: 1px solid #FF0000;"
	  onClick="document.form_.page_action.value='70';document.form_.focus_field.value='material';document.form_.info_index.value=<%=vMaterial.elementAt(i + 6)%>"></td>
    </tr>
<%}
}%>    <tr> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="1" cellspacing="0">
  <tr> 
      <td height="15" colspan="2">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="1" cellspacing="0" class="thinborder">
    <tr bgcolor="#FFCC99">
      <td height="25" colspan="4" class="thinborder"><div align="center"><strong><font color="#0000FF">::TEXTBOOK 
        AND REFERENCES ::</font></strong></div></td>
    </tr>
<%
vTempInfo = cmsNew.operateOnTextBook(dbOP, request, 4);
if(vTempInfo != null){%>
    <tr>
      <td height="25" colspan="4" class="thinborder"><strong>TEXTBOOK :</strong>
          <%
strTemp = "";
for(int i = 0; i < vTempInfo.size() ; i += 5) {
	if(vTempInfo.elementAt(i + 4).equals("0"))
		continue;
	if(strTemp.length() > 0) 
		strTemp = strTemp + ",";
	strTemp = strTemp + vTempInfo.elementAt(i + 1);

vTempInfo.removeElementAt(i);vTempInfo.removeElementAt(i);vTempInfo.removeElementAt(i);
vTempInfo.removeElementAt(i);vTempInfo.removeElementAt(i);
i -= 5;
}
if(strTemp.length() == 0) 
	strTemp = "Not set.";%>
        <%=strTemp%> </td>
    </tr>
    <tr>
      <td height="25" colspan="4" class="thinborder">REFERENCES</td>
    </tr>
    <%
for(int i =0; i < vTempInfo.size(); i += 5) {%>
    <tr>
      <td width="5%" class="thinborder"><%=i/5 + 1%>.</td>
      <td width="45%" height="25" class="thinborder"><%=vTempInfo.elementAt(i + 1)%></td>
      <td width="25%" class="thinborder"><%=vTempInfo.elementAt(i + 2)%></td>
      <td width="25%" height="25" class="thinborder"><%=vTempInfo.elementAt(i + 3)%></td>
    </tr>
    <%}
}//if vTempInfo is not null%>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="1" cellspacing="0">
  <tr> 
      <td height="15" colspan="2" class="thinborderBOTTOMLEFTRIGHT" align="center">
	  <a href="javascript:UpdateInformation(1);"><img src="../../../images/update.gif" border="0"></a></td>
    </tr>
  <tr> 
      <td height="15" colspan="2">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="1" cellspacing="0">
  <tr bgcolor="#FFCC99"> 
      <td height="25" colspan="8" class="thinborderALL"><strong><font color="#0000FF">&nbsp;&nbsp;9. INDIVIDUAL LESSON</font></strong></td>
    </tr>
<%
vTempInfo = cmsNew.operateOnIndividualLesson(dbOP, request, 4);
if(vTempInfo != null){%>
    <tr> 
      <td width="11%"><div align="center"><font size="1"><strong>PART NO. / LESSON NAME </strong></font></div></td>
      <td width="10%"><div align="center"><strong><font size="1">UNIT NO./UNIT NAME</font></strong></div></td>
      <td width="12%"><div align="center"><font size="1"><strong>LEARNING OBJECTIVE</strong></font></div></td>
      <td width="16%" height="25"><div align="center"><font size="1"><strong>CONTENT/TOPIC</strong></font></div></td>
      <td width="14%"><div align="center"><font size="1"><strong>TEACHING STRATEGY</strong></font></div></td>
      <td width="20%"><div align="center"><font size="1"><strong>EVALUATION</strong></font></div></td>
      <td width="8%"><div align="center"><font size="1"><strong>TIMEFRAME <br>Hours) </strong></font></div></td>
      <td width="9%"><div align="center"><font size="1"><strong>REFERENCES</strong></font></div></td>
    </tr>
<%
boolean bolShow = true;
for(int i = 0 ; i < vTempInfo.size(); i += 11){
if(i > 0 && vTempInfo.elementAt(i + 1).equals(strTemp))
	bolShow = false;
else {	
	bolShow = true;
	strTemp = (String)vTempInfo.elementAt(i + 1);
}
%>
    <tr> 
      <td style="font-size:9px;">&nbsp;
	  <%if(bolShow){%><%=vTempInfo.elementAt(i + 1)%>.<%=vTempInfo.elementAt(i + 2)%><%}%></td>
      <td style="font-size:9px;"><%=WI.getStrValue((String)vTempInfo.elementAt(i + 3),"",".","")%><%=WI.getStrValue(vTempInfo.elementAt(i + 4))%></td>
      <td style="font-size:9px;"><%=WI.getStrValue(vTempInfo.elementAt(i + 5))%></td>
      <td style="font-size:9px;"><%=WI.getStrValue(vTempInfo.elementAt(i + 6))%></td>
      <td height="25" style="font-size:9px;"><%=WI.getStrValue(vTempInfo.elementAt(i + 7))%></td>
      <td style="font-size:9px;"><%=WI.getStrValue(vTempInfo.elementAt(i + 1))%></td>
      <td style="font-size:9px;"><%=WI.getStrValue(vTempInfo.elementAt(i + 1))%></td>
      <td style="font-size:9px;"><%=WI.getStrValue(vTempInfo.elementAt(i + 1))%></td>
    </tr>
<%}//end of for loop.
}//end of vTempInfo%>
    <tr> 
      <td height="42" colspan="8" class="thinborderTOP"><div align="center"><font size="1"><a href="javascript:UpdateInformation(2);"><img src="../../../images/update.gif" border="0"></a>click to UPDATE entries</font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="1" cellspacing="0">
  <tr> 
      <td height="15" colspan="2">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="1" cellspacing="0" class="thinborder">
    <tr bgcolor="#FFCC99"> 
      <td height="25" colspan="3" class="thinborder"><strong><font color="#0000FF">&nbsp;&nbsp;10. SUMMARY OF 
        LESSON</font></strong></td>
    </tr>
    <tr> 
      <td width="44%" height="25" class="thinborder"><div align="center"><font size="1"><strong>PART NO. / LESSON NAME </strong></font></div></td>
      <td width="44%" class="thinborder"><div align="center"><strong><font size="1">UNIT NO./UNIT NAME</font></strong></div></td>
      <td width="12%" class="thinborder"><div align="center"><font size="1"><strong>TIMEFRAME <br>(Hours) </strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" class="thinborder"><font size="1">I - ORIENTATION</font></td>
      <td class="thinborder"><font size="1">&nbsp;</font></td>
      <td class="thinborder"><div align="center"><font size="1">2</font></div></td>
    </tr>
    <tr> 
      <td height="25"><font size="1">II - REVIEW OF THE ACCOUNTING PROCESS</font></td>
      <td><font size="1">&nbsp;</font></td>
      <td><div align="center"><font size="1">4</font></div></td>
    </tr>
    <tr> 
      <td height="25"><font size="1">III - PARTNERSHIP</font></td>
      <td height="25"><font size="1">I - Introduction to Partnership</font></td>
      <td height="25"><div align="center"><font size="1">2</font></div></td>
    </tr>
    <tr> 
      <td height="25"><font size="1">&nbsp;</font></td>
      <td><font size="1">II - Partnership Formation</font></td>
      <td><div align="center"><font size="1"><font size="1">12</font></font></div></td>
    </tr>
    <tr> 
      <td height="25"><font size="1">&nbsp;</font></td>
      <td><font size="1">III - Partnership Operation</font></td>
      <td><div align="center"><font size="1">10</font></div></td>
    </tr>
    <tr> 
      <td height="25"><font size="1">&nbsp;IV - CORPORATION</font></td>
      <td><font size="1">I - Introduction to Corporation</font></td>
      <td><div align="center"><font size="1">3</font></div></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="26" colspan="2"><div align="center"><font size="1">&nbsp;</font><font size="1">&nbsp;TOTAL 
          HOURS </font></div></td>
      <td><div align="center"><font size="1"><u> 108&nbsp;</u> </font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="94%" height="44" valign="bottom"><div align="center"><font size="1"><a href="syllabus_new_print.htm" target="_blank"><img src="../../../images/print.gif" border="0"></a>click 
          to PRINT Syllabus</font></div></td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" bgcolor="#6A99A2">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="info_index">
<input type="hidden" name="page_action">
<input type="hidden" name="focus_field" value="<%=WI.fillTextValue("focus_field")%>">

<!-- add in pages with subject scroll -->
<%=dbOP.constructAutoScrollHiddenField()%>

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>