<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.page_action.value = "";
	document.form_.submit();
}
function PageAction(strInfoIndex,strPageAction)
{
	document.form_.page_action.value = strPageAction;
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
function PrepareToEdit(strInfoIndex)
{
	document.form_.page_action.value = "";
	document.form_.info_index.value = strInfoIndex;
	document.form_.prepareToEdit.value = "1";
	document.form_.submit();
}
function EditRecord()
{
	document.form_.page_action.value = "2";
	document.form_.submit();
}
function CancelRecord()
{
	location = "./change_stud_critical_info_yrlevel.jsp?stud_id="+document.form_.stud_id.value;
}
function OpenSearch(strIDInfo) {
	var pgLoc = "../../search/srch_stud.jsp?opner_info=form_.stud_id";
		
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
//// - all about ajax.. 
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.form_.stud_id.value;
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
		var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.form_.stud_id.value = strID;
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}
</script>

<body bgcolor="#D2AE72" onLoad="document.form_.stud_id.focus()">
<%@ page language="java" import="utility.*,student.ChangeCriticalInfo,enrollment.SubjectSection,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	Vector vStudInfo = new Vector();
	
	String strTemp = null;
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code")); 
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission-Student Info Mgmt","change_stud_critical_info_move_enrollment.jsp");
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
CommonUtil comUtil = new CommonUtil();//only super user.
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"dfddfd","dfdfd",request.getRemoteAddr(),
														null);
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
String[] astrConvertToSem={"SU","FS","SS","TS"};
String[] astrConvertToYr = {"","1st Yr","2nd Yr","3rd Yr","4th Yr","5th Yr","6th Yr","7th Yr"};

boolean bolShowMoveStud = true;


//get student Information.. 
String strSQLQuery = null;
java.sql.ResultSet rs = null;

int iPaymentMade = 0;
int iTotalEnrolled = 0;

if(WI.fillTextValue("stud_id").length() > 0) {
	strSQLQuery = "select user_table.user_index, fname, mname, lname from user_Table where id_number = "+
				WI.getInsertValueForDB(WI.fillTextValue("stud_id"), true, null)+" and is_valid = 1 and auth_type_index = 4";
	rs = dbOP.executeQuery(strSQLQuery);
	if(rs.next()) {
		vStudInfo.addElement(rs.getString(1));//[0] user_index
		vStudInfo.addElement(WI.formatName(rs.getString(2),rs.getString(3),rs.getString(4),4));//[1] name
	}
	rs.close();
	if(vStudInfo.size() == 0) {
		strErrMsg = "Student Id not found.";
	}
	else {
		strSQLQuery = "select course_offered.course_code, major.course_code, sy_from, sy_to, semester,year_level,user_status.STATUS,IS_RETURNEE,cur_hist_index from STUD_CURRICULUM_HIST "+
					"join SEMESTER_SEQUENCE on (semester_val = semester) "+
					"join COURSE_OFFERED on (course_offered.course_index = STUD_CURRICULUM_HIST.course_index) "+
					"left join major on (major.major_index = STUD_CURRICULUM_HIST.major_index) "+
					"join user_status on (user_status.status_index = STUD_CURRICULUM_HIST.status_index) "+
					"where user_index = "+vStudInfo.elementAt(0)+" and stud_curriculum_hist.is_valid = 1 order by sy_from desc, sem_order desc";
		rs = dbOP.executeQuery(strSQLQuery);
		if(rs.next()) {
			vStudInfo.addElement(rs.getString(1));//[2] course_code
			vStudInfo.addElement(rs.getString(2));//[3] major.course_code
			vStudInfo.addElement(rs.getString(3));//[4] sy_from
			vStudInfo.addElement(rs.getString(4));//[5] sy_to
			vStudInfo.addElement(rs.getString(5));//[6] semester
			vStudInfo.addElement(rs.getString(6));//[7] Year_level
			vStudInfo.addElement(rs.getString(7));//[8] STATUS
			vStudInfo.addElement(rs.getString(8));//[9] IS_RETURNEE
			vStudInfo.addElement(rs.getString(9));//[10] stud_curriculum_hist
		}
		rs.close();
		
		strSQLQuery = "select count(*) from fa_stud_payment where user_index = "+vStudInfo.elementAt(0)+" and is_valid = 1 and is_stud_temp = 0 and sy_from = "+
						vStudInfo.elementAt(4)+" and semester = "+vStudInfo.elementAt(6);
		rs = dbOP.executeQuery(strSQLQuery);
		rs.next();
		iPaymentMade = rs.getInt(1);
		rs.close();		
		
		//move here if move is clicked.
		if(WI.fillTextValue("page_action").equals("1")) {
			if(!WI.fillTextValue("stud_id").equals(WI.fillTextValue("stud_id_old"))) {
				strErrMsg = "Faild to Update. Student ID does not match with displayed data. Please click MOVE ENROLLMENT again.";
			}
			else {
				strSQLQuery = "select cur_hist_index from stud_Curriuclum_hist where user_index = "+vStudInfo.elementAt(0)+
								" and stud_curriculum_hist.is_valid = 1 and sy_from = "+WI.fillTextValue("sy_from_move")+" and semester = "+WI.fillTextValue("sem_move");
				strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
				if(strSQLQuery != null) {
					strErrMsg = "Failed to Proceed. Student already has enrollment information for sy-term student is moving enrollment.";
				}
				else {
					boolean bolUpdatePmtMethod = false; 
					String strIDRangeRef = null;
					String strIDRangeSY = null;
					
					int iRowUpdated = 0;
					strSQLQuery = "select pmtmethod_index from stud_Curriuclum_hist where user_index = "+vStudInfo.elementAt(0)+
								" and is_valid = 1 and sy_from = "+WI.fillTextValue("sy_from_move")+" and semester = "+WI.fillTextValue("sem_move");
					if(dbOP.getResultOfAQuery(strSQLQuery , 0) == null) 
						bolUpdatePmtMethod = true;
						
					dbOP.forceAutoCommitToFalse();
					strErrMsg = "Failed at step - 1/5";
					strSQLQuery = "update fa_stud_payment set sy_from = "+WI.fillTextValue("sy_from_move")+
									", sy_to = "+Integer.toString(Integer.parseInt(WI.fillTextValue("sy_from_move")) + 1)+", semester = "+
									WI.fillTextValue("sem_move")+" where user_index = "+vStudInfo.elementAt(0)+
									" and is_stud_temp = 0 and stud_curriculum_hist.is_valid = 1 and sy_from = "+WI.fillTextValue("sy_from_enrolled")+" and semester = "+WI.fillTextValue("sem_enrolled");
					iRowUpdated = dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
					
					if(iRowUpdated > -1) { 
						strSQLQuery = "update fa_stud_payable set sy_from = "+WI.fillTextValue("sy_from_move")+
										", sy_to = "+Integer.toString(Integer.parseInt(WI.fillTextValue("sy_from_move")) + 1)+", semester = "+
										WI.fillTextValue("sem_move")+" where user_index = "+vStudInfo.elementAt(0)+
										" and is_valid = 1 and sy_from = "+WI.fillTextValue("sy_from_enrolled")+" and semester = "+WI.fillTextValue("sem_enrolled");
						iRowUpdated = dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
						strErrMsg = "Failed at step - 2/5";
					}
					if(iRowUpdated > -1) { 
						if(bolUpdatePmtMethod)
							strSQLQuery = "update fa_stud_pmtmethod set sy_from = "+WI.fillTextValue("sy_from_move")+
											", sy_to = "+Integer.toString(Integer.parseInt(WI.fillTextValue("sy_from_move")) + 1)+", semester = "+
											WI.fillTextValue("sem_move")+" where user_index = "+vStudInfo.elementAt(0)+
											" and is_stud_temp = 0 and is_valid = 1 and sy_from = "+WI.fillTextValue("sy_from_enrolled")+" and semester = "+WI.fillTextValue("sem_enrolled");
						else
							strSQLQuery = "update fa_stud_pmtmethod set is_valid = 0 where user_index = "+vStudInfo.elementAt(0)+
											" and is_stud_temp = 0 and is_valid = 1 and sy_from = "+WI.fillTextValue("sy_from_enrolled")+" and semester = "+WI.fillTextValue("sem_enrolled");
						iRowUpdated = dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
						strErrMsg = "Failed at step - 3/5";
					}
					if(iRowUpdated > -1) { 
						strSQLQuery = "update ENRL_FINAL_CUR_LIST set is_valid = 0, is_del = 1, LAST_MOD_BY = "+(String)request.getSession(false).getAttribute("userIndex")+
										", LAST_MOD_DATE = '"+WI.getTodaysDate()+"' where user_index = "+vStudInfo.elementAt(0)+
										" and IS_TEMP_STUD = 0 and is_valid = 1 and sy_from = "+WI.fillTextValue("sy_from_enrolled")+" and current_semester = "+WI.fillTextValue("sem_enrolled");
						
						iRowUpdated = dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
						strErrMsg = "Failed at step - 4/5";
					}
					if(iRowUpdated > -1) { 
						strSQLQuery = "update stud_curriculum_hist set is_valid = 0 where user_index = "+vStudInfo.elementAt(0)+
										" is_valid = 1 and sy_from = "+WI.fillTextValue("sy_from_enrolled")+" and semester = "+WI.fillTextValue("sem_enrolled");
						iRowUpdated = dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
						strErrMsg = "Failed at step - 5/5";
					}
					if(iRowUpdated > -1) {
						dbOP.commitOP();
						strErrMsg = "Payment already moved. To Enroll student, pls do admission, advising and validate ID.";
					}
					else	
						dbOP.rollbackOP();
					dbOP.forceAutoCommitToTrue();
				}
				
			}
		}		
		
	}
	
}

dbOP.cleanUP();

String strSYFromMoveTo = null;
String strSYToMoveTo = null;
String strSemesterMoveTo = null;
%>
<form action="./change_stud_critical_info_move_enrollment.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          Move Student Enrollment ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" width="2%"></td>
	  <td width="98%" > <strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr valign="top"> 
      <td height="25" width="2%">&nbsp;</td>
      <td width="13%" >Student ID :</td>
      <td width="23%" ><input type="text" name="stud_id" size="18" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');">      </td>
      <td width="8%" height="25"><!--<a href="javascript:OpenSearch()">Search ID</a>&nbsp;-->
	  <input type="image" src="../../images/form_proceed.gif"></td>
      <td width="54%"><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label></td>
    </tr>
    <tr> 
      <td colspan="5"><hr size="1"></td>
    </tr>
  </table>
<%
if(vStudInfo != null && vStudInfo.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="15%" >Name: </td>
      <td colspan="3" ><%=(String)vStudInfo.elementAt(1)%></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td >Enrollment Status:</td>
      <td width="41%"><%=(String)vStudInfo.elementAt(8)%>
	  <%if(((String)vStudInfo.elementAt(1)).equals("1")) {%>
		- Returnee
	  <%}%>	  </td>
      <td colspan="2">Year Level: <%=WI.getStrValue((String)vStudInfo.elementAt(7), "N/A")%></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td >Course/Major: </td>
      <td><%=(String)vStudInfo.elementAt(2)%> 
        <%if(vStudInfo.elementAt(3) != null){%>
        - <%=(String)vStudInfo.elementAt(3)%> 
        <%}%>        </td>
      <td colspan="2" style="font-weight:bold; font-size:18px;">Enrolled: <%=astrConvertToSem[Integer.parseInt((String)vStudInfo.elementAt(6))]%>, <%=(String)vStudInfo.elementAt(4)%>-<%=((String)vStudInfo.elementAt(5)).substring(2)%></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2" ><strong><u>Other Enrollment Information:</u></strong></td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td >Total Payment Made: </td>
      <td><%=iPaymentMade%></td>
      <td width="10%">&nbsp;</td>
      <td width="32%">&nbsp;</td>
    </tr>
    
    <tr> 
      <td colspan="5"><hr size="1"></td>
    </tr>
<%
if(((String)vStudInfo.elementAt(6)).equals("0")) {
	strSemesterMoveTo = "1";
	strSYFromMoveTo   = Integer.toString(Integer.parseInt((String)vStudInfo.elementAt(4)) + 1);
	strSYToMoveTo = Integer.toString(Integer.parseInt(strSYFromMoveTo) + 1);
}
else if(((String)vStudInfo.elementAt(6)).equals("1")) {
	strSemesterMoveTo = "0";
	strSYFromMoveTo   = Integer.toString(Integer.parseInt((String)vStudInfo.elementAt(4)) - 1);
	strSYToMoveTo = Integer.toString(Integer.parseInt(strSYFromMoveTo) + 1);
}
else {
	strErrMsg = "Only Summer/First Sem enrollment allowed to move.";
}
if(strSYFromMoveTo == null) {%>    
	<tr> 
      <td colspan="5" style="font-size:18px; font-weight:bold"><%=strErrMsg%></td>
    </tr>
<%}else{%>
	<tr> 
      <td colspan="5" style="font-size:18px; font-weight:bold">Move Enrollment To: <%=astrConvertToSem[Integer.parseInt(strSemesterMoveTo)]%>, <%=strSYFromMoveTo%>-<%=(strSYToMoveTo).substring(2)%></td>
    </tr>
	<tr>
	  <td colspan="5" align="center">
		<input type="button" name="_" value=" <<< Move Enrollment >>> " onClick="document.form_.page_action.value='1';document.form_.submit()" style="font-size:11px; height:25px; width:200px; border: 1px solid #FF0000;">
	    <input type="hidden" name="sy_from_enrolled" value="<%=vStudInfo.elementAt(4)%>">
	    <input type="hidden" name="sem_enrolled" value="<%=vStudInfo.elementAt(6)%>">
	    <input type="hidden" name="sy_from_move" value="<%=strSYFromMoveTo%>">
	    <input type="hidden" name="sem_move" value="<%=strSemesterMoveTo%>">
	  </td>
    </tr>

<%}%>
  </table>
<%}//only if student information is not null. 
%> 

<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action" value="">
<input type="hidden" name="stud_id_old" value="<%=WI.fillTextValue("stud_id")%>">
</form>
</body>
</html>
