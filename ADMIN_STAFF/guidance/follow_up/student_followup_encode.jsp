<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript">
function PageAction(strAction, strInfoIndex) {
	if(strAction == "0") {
		if(!confirm("Do you want to delete information?"))
			return;
	}
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	if(strAction.length == 0) { 
		document.form_.preparedToEdit.value = "";
		document.form_.info_index.value = "";
	}
}
function PreparedToEdit(strInfoIndex) {
//	alert("I am here.");
	document.form_.preparedToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
}
function StudSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
var AjaxCalledPos;
function AjaxMapName(strPos) {
		AjaxCalledPos = strPos;
		
		var strCompleteName;
		if(strPos == "1")
			strCompleteName = document.form_.stud_id.value;
		else	
			strCompleteName = document.form_.emp_id.value;
			
		if(strCompleteName.length == 0)
			return;
		
		var objCOAInput;
		if(strPos == "1")
			objCOAInput = document.getElementById("coa_info");
		else	
			objCOAInput = document.getElementById("coa_info2");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);
		if(strPos == "2")
			strURL += "&is_faculty=1";
		//if(document.form_.account_type[1].checked) //faculty
		//	strURL += "&is_faculty=1";
		//alert(strURL);
		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	if(AjaxCalledPos == "2"){
		document.form_.emp_id.value = strID;
		return;
	}
	document.form_.stud_id.value = strID;
	document.form_.stud_id.focus();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	if(AjaxCalledPos == "1")
		document.getElementById("coa_info").innerHTML = strName;
	else	
		document.getElementById("coa_info2").innerHTML = strName;
}

</script>
<body bgcolor="#663300">
<%@ page language="java" import="utility.*,osaGuidance.GDStudReferralFollowUp,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);

	String strTemp   = null;
	String strErrMsg = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Administration","student_followup_encode.jsp");
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
														"Guidance & Counseling","student followup",request.getRemoteAddr(),
														"student_followup_encode.jsp");
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


GDStudReferralFollowUp cmsNew = new GDStudReferralFollowUp();
Vector vRetResult = null;
Vector vEditInfo  = null;

boolean bolShowOrig = true; boolean bolFatalErr = false;

boolean bolIsBasic = WI.fillTextValue("is_basic").equals("1");		

String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"), "0");
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(cmsNew.operateOnFollowUp(dbOP, request, Integer.parseInt(strTemp)) == null) {
		strErrMsg   = cmsNew.getErrMsg();
		bolShowOrig = false;
	}
	else {
		strPreparedToEdit = "0";
		strErrMsg = "Operation successful.";
	}
}
String strStudID     = WI.fillTextValue("stud_id");
Vector vStudInfo     = new Vector();
if(strStudID.length() > 0) {
	vRetResult = cmsNew.operateOnFollowUp(dbOP, request, 4);
	if(vRetResult == null) {
		if(strErrMsg == null)
			strErrMsg = cmsNew.getErrMsg();
	}
}

String strSYFrom = WI.fillTextValue("sy_from");
String strSem    = WI.fillTextValue("semester");

String strFollowUpReason = null;
String strSQLQuery       = null;

if(strPreparedToEdit.equals("1"))
	vEditInfo = cmsNew.operateOnFollowUp(dbOP, request, 3);
else if(strSYFrom.length() > 0) {
	vEditInfo = cmsNew.operateOnFollowUp(dbOP, request, 5);
	if(vEditInfo != null && vEditInfo.size() > 0) 
		strPreparedToEdit = "1";
}

if(strSYFrom.length() > 0 && strStudID.length() > 0) {
	String strDegreeType = null;
	java.sql.ResultSet rs = null;
	String strStudIndex = null; String strCurHistIndex = null;
	rs = dbOP.executeQuery("select fname, mname, lname, user_index from user_table where id_number = '"+
		strStudID+"'");
	if(rs.next()) {
		vStudInfo.addElement(WebInterface.formatName(rs.getString(1), rs.getString(2), rs.getString(3), 4));
		strStudIndex = rs.getString(4);
	}
	rs.close();
	
	if(strStudIndex == null) {
		bolFatalErr = true;
		strErrMsg = "Student information not found.";
	}
	else {
		//get student infomration for that sy/sem.
		if(bolIsBasic) 
			strSQLQuery = " left ";
		else	
			strSQLQuery = "";
		strSQLQuery = "select course_offered.course_code,major_name, year_level,"+
			"course_offered.degree_type, cur_hist_index from stud_curriculum_hist "+
			strSQLQuery + "join course_offered on (course_offered.course_index = stud_curriculum_hist.course_index) "+
			"left join major on (major.major_index = stud_curriculum_hist.major_index) "+
			" where stud_curriculum_hist.is_valid = 1 and sy_from = "+strSYFrom+" and semester="+
			strSem+" and stud_curriculum_hist.user_index = "+strStudIndex;
		rs = dbOP.executeQuery(strSQLQuery);
		if(rs.next()) {
			if(bolIsBasic) {
				vStudInfo.addElement(dbOP.getBasicEducationLevel(rs.getInt(3)));
				strDegreeType = "0";
			}
			else {
				if(rs.getString(2) != null) 
					vStudInfo.addElement(rs.getString(1) +" :: "+rs.getString(2));
				else
					vStudInfo.addElement(rs.getString(1));
				vStudInfo.addElement(rs.getString(3));	
				strDegreeType   = rs.getString(4);
			}
			strCurHistIndex = rs.getString(5);
		}
		rs.close();
		if(vStudInfo.size() == 1) {
			bolFatalErr = true;
			strErrMsg = "Student enrollment information not found for the SY/Term entered.";
		}
	}
	
	//now get Reason.. 
	if(vEditInfo == null && !bolFatalErr) {
		//get all inc and failed grade.. 
		if(strDegreeType.equals("1")) {//masteral - 
			strSQLQuery = 	"select sub_code,remark from g_sheet_final "+
							"join cculum_masters on (cculum_masters.cur_index = g_sheet_final.cur_index) "+
							"join subject on (subject.sub_index = cculum_masters.sub_index) "+
							"join remark_status on (remark_status.remark_index = g_sheet_final.remark_index) "+
							" where g_sheet_final.is_valid = 1 and g_sheet_final.cur_hist_index="+
							strCurHistIndex+" and (remark like 'inc%' or remark like 'fail%') order by sub_code";
		}
		else if(strDegreeType.equals("2")) {//medicine
			strSQLQuery = 	"select sub_code,remark from g_sheet_final "+
							"join cculum_medicine on (cculum_medicine.cur_index = g_sheet_final.cur_index) "+
							"join subject on (subject.sub_index = cculum_medicine.main_sub_index) "+
							"join remark_status on (remark_status.remark_index = g_sheet_final.remark_index) "+
							" where g_sheet_final.is_valid = 1 and g_sheet_final.cur_hist_index="+
							strCurHistIndex+" and (remark like 'inc%' or remark like 'fail%') order by sub_code";
		}
		else {//u.g
			strSQLQuery = 	"select sub_code,remark from g_sheet_final "+
							"join curriculum on (curriculum.cur_index = g_sheet_final.cur_index) "+
							"join subject on (subject.sub_index = curriculum.sub_index) "+
							"join remark_status on (remark_status.remark_index = g_sheet_final.remark_index) "+
							" where g_sheet_final.is_valid = 1 and g_sheet_final.cur_hist_index="+
							strCurHistIndex+" and (remark like 'inc%' or remark like 'fail%') order by sub_code";
		}//System.out.println(strSQLQuery);
		rs = dbOP.executeQuery(strSQLQuery);
		while(rs.next()) {
			if(strFollowUpReason == null)
				strFollowUpReason = rs.getString(1)+ " :: "+rs.getString(2);
			else	
				strFollowUpReason += "\r\n"+rs.getString(1)+ " :: "+rs.getString(2);
		}
	
	}
}

String strFacultyName = "";

if(strStudID.length() == 0 || WI.fillTextValue("sy_from").length() == 0) 
	bolFatalErr = true;

%>
<form action="./student_followup_encode.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="1" bgcolor="#FFFFFF">
    <tr>
     <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          STUDENT FOLLOW UP PAGE ::::</strong></font></div></td>
    </tr>
    <tr >
      <td height="25" style="font-size:14px; color:#FF0000; font-weight:bold">&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td>SY-Term</td>
      <td>
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
	  readonly="yes"> 
- 
<select name="semester" onChange="ReloadPage();">
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
%>
	<%=dbOP.loadSemester(bolIsBasic, strTemp, request)%>	
</select></td>
    </tr>
    <tr> 
      <td width="5%" height="25">&nbsp;</td>
      <td width="16%">Student ID</td>
      <td width="79%"><input type="image" src="../../../images/blank.gif" border="0">
        <input name="stud_id" type="text"  value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
			onKeyUp="AjaxMapName('1');">
		
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		
		
		<input type="submit" name="Submit2" value=" Reload Information " style="font-size:11px; height:22px;border: 1px solid #FF0000;"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="1" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
      <td valign="top"> Student Name</td>
      <td width="79%" height="25"><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"><%if(vStudInfo != null && vStudInfo.size() > 0){%><%=vStudInfo.elementAt(0)%><%}%></label></td>
    </tr>
    <tr> 
      <td  width="5%"height="25">&nbsp;</td>
      <td width="16%" height="25">Course</td>
      <td height="25"><strong>
        <%if(vStudInfo != null && vStudInfo.size() > 1){%>
      <label id="stud_info1"><%=vStudInfo.elementAt(1)%><%}%></label></strong></td>
    </tr>
    
<%if(!bolFatalErr) {//always edit.. %>
    <tr> 
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">Reason(s) for Follow up:</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2" style="font-size:9px; color:#0000FF">
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(10);
else	
	strTemp = WI.fillTextValue("follow_reason");

if(strTemp == null || strTemp.length() == 0) 
	strTemp = strFollowUpReason;
	
%>
	  <textarea name="follow_reason" cols="90" rows="6" style="font-size:10px" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='#FFFFFF'"><%=WI.getStrValue(strTemp)%></textarea></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Follow up Date </td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(3);
else	
	strTemp = WI.fillTextValue("followup_date");
%>
        <input name="followup_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.followup_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Strategy</td>
      <td><select name="strategy_i">
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(3);
else	
	strTemp = WI.fillTextValue("strategy_i");
%>
        <%=dbOP.loadCombo("STRATEGY_INDEX","STRATEGY"," from GD_FOLLOWUP_STRATEGY order by STRATEGY asc", strTemp, false)%>
      </select>
        <a href='javascript:viewList("GD_FOLLOWUP_STRATEGY","STRATEGY_INDEX","STRATEGY","STRATEGY NAME",
	"GD_FOLLOWUP","STRATEGY_I", " and GD_FOLLOWUP.IS_VALID=1","","strategy_i")'><img src="../../../images/update.gif" border="0"></a><font size="1">click 
      to UPDATE list </font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td valign="top"><br>Student's Remark </td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(8);
else	
	strTemp = WI.fillTextValue("stud_remark");
%>
	  <textarea name="stud_remark" cols="90" rows="4" style="font-size:10px" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='#FFFFFF'"><%=WI.getStrValue(strTemp)%></textarea></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td valign="top"><br>Counselor's Remark </td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0)
	strTemp = (String)vEditInfo.elementAt(9);
else	
	strTemp = WI.fillTextValue("c_remark");
%>
	  <textarea name="c_remark" cols="90" rows="4" style="font-size:10px" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='#FFFFFF'"><%=WI.getStrValue(strTemp)%></textarea></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2" align="center"><%if(iAccessLevel > 1) {
	if(strPreparedToEdit.equals("0")){%>
        <input type="submit" name="Submit1" value=" Save Info " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('1','');">
&nbsp;&nbsp;&nbsp;&nbsp;
<%}else{%>
<input type="submit" name="EditInfo" value=" Edit Info " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('2','');">
&nbsp;&nbsp;&nbsp;&nbsp;
<%}
}%>
<input type="submit" name="Cancel" value=" Cancel " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('','');document.form_.follow_reason.value='';document.form_.stud_remark.value='';document.form_.c_remark.value='';"></td>
    </tr>
<%}//end of sy_from/semester not null... %>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0" class="thinborder">
    <tr bgcolor="#FFCC99"> 
      <td height="25" colspan="7" class="thinborder">
	  <div align="center"><strong><font color="#0000FF">:: LIST OF REFERRALS :: </font></strong></div></td>
    </tr>
    <tr> 
      <td width="10%" height="25" class="thinborder" style="font-size:9px; font-weight:bold;" align="center">SY/Term</td>
      <td width="20%" class="thinborder" style="font-size:9px; font-weight:bold;" align="center">Reasons </td>
      <td width="20%" class="thinborder" style="font-size:9px; font-weight:bold;" align="center">Follow up Date </td>
      <td width="20%" class="thinborder" style="font-size:9px; font-weight:bold;" align="center">Strategy</td>
      <td width="20%" class="thinborder" style="font-size:9px; font-weight:bold;" align="center">Counselor's Remark </td>
      <td width="5%" class="thinborder" style="font-size:9px; font-weight:bold;" align="center">&nbsp;</td>
      <td width="5%" class="thinborder" style="font-size:9px; font-weight:bold;" align="center">&nbsp;</td>
    </tr>
<%for(int i = 0; i < vRetResult.size(); i += 14){%>
    <tr> 
      <td height="25" class="thinborder" style="font-size:9px;"><%=vRetResult.elementAt(i + 1)%> : <%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder" style="font-size:9px;"><%=ConversionTable.replaceString((String)vRetResult.elementAt(i + 10), "\r\n", "<br>")%></td>
      <td class="thinborder" style="font-size:9px;"><%=vRetResult.elementAt(i + 3)%></td>
      <td class="thinborder" style="font-size:9px;"><%=vRetResult.elementAt(i + 13)%></td>
      <td class="thinborder" style="font-size:9px"><%=WI.getStrValue(vRetResult.elementAt(i + 9), "&nbsp;")%></td>
      <td class="thinborder" style="font-size:9px;">
        <%if(iAccessLevel > 1){%>
        <input type="button" name="122" value=" Edit " style="font-size:11px; height:20px;border: 1px solid #FF0000;"
		 onClick="PreparedToEdit('<%=vRetResult.elementAt(i)%>');document.form_.submit();">
        <%}else{%>&nbsp;<%}%>      </td>
      <td class="thinborder" style="font-size:9px;">
        <%if(iAccessLevel ==2 ){%>
        <input type="button" name="123" value="Delete" style="font-size:11px; height:20px;border: 1px solid #FF0000;"
		 onClick="PageAction('0','<%=vRetResult.elementAt(i)%>');">
        <%}else{%>&nbsp;<%}%>      </td>
    </tr>
<%}%>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td width="94%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<%
strTemp = WI.fillTextValue("info_index");
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(0);
%>
<input type="hidden" name="info_index" value="<%=strTemp%>">
<input type="hidden" name="preparedToEdit" value="<%=strPreparedToEdit%>">
<input type="hidden" name="page_action" value="">
<input type="hidden" name="is_basic" value="<%=WI.fillTextValue("is_basic")%>">

</form>
</body>
</html>

<%
dbOP.cleanUP();
%>