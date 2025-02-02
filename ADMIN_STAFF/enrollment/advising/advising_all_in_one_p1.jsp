<%@ page language="java" import="utility.*,enrollment.Advising,java.util.Vector " buffer="16kb" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	
	boolean bolIsOnlineAdvising = false;
	String strAuthTypeIndex = (String)request.getSession(false).getAttribute("authTypeIndex");
	if(strAuthTypeIndex == null)
		strAuthTypeIndex = "0";
	else if(strAuthTypeIndex.equals("0") && WI.fillTextValue("online_advising").length() > 0) 
		bolIsOnlineAdvising = true;

	String strStudID = WI.fillTextValue("stud_id");
	if(bolIsOnlineAdvising)
		strStudID = (String)request.getSession(false).getAttribute("tempId");

		
	//System.out.println("bolIsOnlineAdvising: "+bolIsOnlineAdvising );
	//System.out.println("strStudID: "+strStudID);



	boolean bolIsLoggedIn = false;
	if(request.getSession(false).getAttribute("userIndex") != null)
		bolIsLoggedIn = true;
	else if(bolIsOnlineAdvising && strStudID != null)
		bolIsLoggedIn = true;

%>
<%if(!bolIsLoggedIn) {%>
	<p style="font-weight:bold; font-size:14px; font-family:Verdana, Arial, Helvetica, sans-serif">You are already logged out. Please login again.</p>
<%return;}

	String strErrMsg = null;
	String strTemp   = null;
	
	String strSQLQuery = null;
	
	String strSYFrom = WI.fillTextValue("sy_from");
	String strSYTo   = WI.fillTextValue("sy_to");
	String strTerm   = WI.fillTextValue("semester");
	if(strSYFrom.length() == 0) {
		strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
		strSYTo   = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
		strTerm   = (String)request.getSession(false).getAttribute("cur_sem");
	}
	
	String strSchCode       = (String)request.getSession(false).getAttribute("school_code");
	String strFacultyDIndex = (String)request.getSession(false).getAttribute("info_faculty_basic.d_index");
	String strFacultyCIndex = (String)request.getSession(false).getAttribute("info_faculty_basic.c_index");

	if(strFacultyDIndex == null)
		strFacultyDIndex = "0";
	
	if(strFacultyCIndex == null && strAuthTypeIndex.equals("5")) {%>
		<p style="font-size:14px; font-family:Verdana, Arial, Helvetica, sans-serif; font-weight:bold; color:#FF0000"> Advisor's College is empty. Please Contact System administrator to update College/Department Information in HR Records.</p>
	<%return;
	}
	
	
	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = 2;
	if(!bolIsOnlineAdvising)
		iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Enrollment","ADVISING & SCHEDULING",request.getRemoteAddr(),
															"advising_all_in_one_p1.jsp");
	//System.out.println("iAccessLevel: "+iAccessLevel);
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
	 
	java.sql.ResultSet rs = null; String strCourseIndex = null; String strMajorIndex = null; String strApplCatg = null; boolean bolIsTempStud = false;
	String strStudIndex = null; String strAlreadyRegistered = "0"; String strYrLevelRegistered = null;///use this yr level if already registered.

	///I have to check if enrollment is still open
	enrollment.SetParameter sParam = new enrollment.SetParameter();
	boolean bolIsAllowedToAdvise = true;//if not yet locked.. 
	
	
	/** 
	*	this block is moved to Next so that system will consider exceptions as well
	
	if(strTerm != null && strSYFrom != null) {//check first time only.
		if(sParam.isLockedGeneric(dbOP, strSYFrom, strTerm, "1", null, "0")) {
			bolIsAllowedToAdvise = false;
			strErrMsg = "Enrollment already closed";
		}
	}**/

if(strSchCode.startsWith("DLSHSI")) {//tracking is for lasalle only.. 
	request.getSession(false).setAttribute("start_time_long",String.valueOf(new java.util.Date().getTime()));
	//System.out.println(request.getSession(false).getAttribute("start_time_long"));
}	
	if(strStudID.length() > 0 && strSYFrom.length() > 0 && strTerm.length() > 0 && bolIsAllowedToAdvise) {
		strStudIndex = dbOP.mapUIDToUIndex(strStudID);
		if(dbOP.strBarcodeID != null)
			strStudID = dbOP.strBarcodeID;
		//check if hs grad.. 
		strSQLQuery = "select course_index from stud_curriculum_hist join semester_sequence on (semester_sequence.semester_val = semester) "+
						" where is_valid = 1 and user_index = "+strStudIndex+" order by sy_from desc, sem_order desc";
		strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
		if(strSQLQuery != null && strSQLQuery.equals("0")) {
			strErrMsg = "Enrollment Information not found. Please check Student ID.";
			strStudIndex = null;
		}

			//do not allow basic student here. 
			
			/**
			if(strStudIndex != null) {
				strSQLQuery = "select application_index from new_application where temp_id = '"+strStudID+"' and old_stud_id = '"+strStudID+"' and is_valid = 1";
				strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
				if(strSQLQuery != null)
					strStudIndex = null;
			}**/

		if(strStudIndex == null) {//student may be temporary student.. 
			strSQLQuery = "select application_index,course_index,appl_catg from new_application "+
							"join appl_form_schedule on (appl_form_schedule.appl_sch_index = new_application.appl_sch_index) "+
							"where schyr_from = "+strSYFrom+" and semester = "+strTerm+" and temp_id = '"+strStudID+"' and new_application.is_valid = 1";
			rs = dbOP.executeQuery(strSQLQuery);
			if(rs.next()) {
				bolIsTempStud      = true;
				strCourseIndex     = rs.getString(2);
				strApplCatg = rs.getString(3);
				strStudIndex = rs.getString(1);				
			}//System.out.println(strSQLQuery);
			rs.close();
			if(strCourseIndex == null)
				strErrMsg = "Student ID not found. Please go to Registration process first before advising.";
		}
		else {
			strSQLQuery = "select course_index, appl_catg, major_index, year_level from na_old_stud where user_index = "+strStudIndex+" and is_valid = 1 and sy_from = "+strSYFrom+
						" and semester = "+strTerm;
			rs = dbOP.executeQuery(strSQLQuery);//System.out.println("strSQLQuery : "+strSQLQuery);
			if(rs.next()) {
				strCourseIndex     = rs.getString(1);
				strApplCatg = rs.getString(2);	
				strAlreadyRegistered = "1";	
				strMajorIndex = rs.getString(3);	
				strYrLevelRegistered = rs.getString(4);
			}
			rs.close();//System.out.println("strAlreadyRegistered : "+strAlreadyRegistered);System.out.println("sy_from : "+strSYFrom);
			if(strCourseIndex == null) {
				strSQLQuery = "select course_index, major_index from stud_curriculum_hist "+
								"join semester_sequence on (stud_curriculum_hist.semester = semester_val) "+
								" where user_index = "+strStudIndex+" and stud_curriculum_hist.is_valid = 1 order by sy_from desc, sem_order desc";
				rs = dbOP.executeQuery(strSQLQuery);
				if(rs.next()) {
					strCourseIndex  = rs.getString(1);
					strApplCatg 	= "Old";	
					strMajorIndex = rs.getString(2);			
				}
				rs.close();
			if(strCourseIndex == null)
				strErrMsg = "Old student ID does not have any enrollment reference. Please go to system admin.";
			}
		}
		
		if(strCourseIndex != null) {
			String strCollegeIndex = null;
			String strDeptIndex    = null;
			String strCourseName   = null;
			
			strSQLQuery = "select c_index, d_index,course_name from course_offered where course_index = "+strCourseIndex;
			rs = dbOP.executeQuery(strSQLQuery);
			strSQLQuery = null;
			if(rs.next()) {
				strCollegeIndex = rs.getString(1);
				strDeptIndex    = rs.getString(2);
				strCourseName   = rs.getString(3);
				if(strDeptIndex == null)
					strDeptIndex = "0";
			}
			rs.close();
			
			//if not faculty, do not consider college/dept condition.
			if(!strAuthTypeIndex.equals("5")) {
				if(strFacultyCIndex == null)
					strFacultyCIndex = "0";
					
				strDeptIndex    = strFacultyDIndex;
				strCollegeIndex = strFacultyCIndex;
			}
			//System.out.println(strFacultyCIndex);
			//System.out.println(strCollegeIndex);
			
			if(!WI.getStrValue(strFacultyCIndex).equals(strCollegeIndex))
					strErrMsg = "Faculty does not belong to the college offering this course : "+strCourseName;
			else if(!strFacultyDIndex.equals("0") && !strDeptIndex.equals("0") && !strFacultyDIndex.equals(strDeptIndex))		
					strErrMsg = "Your Department and offering department does not match. Please contact system administrator to modify your college/department infomration.";
		}
	}

boolean bolIsETO = new enrollment.SetParameter().bolIsETO(dbOP, (String)request.getSession(false).getAttribute("userIndex"));
boolean bolAllowAdvising = true;

boolean bolIsReadviseBlocked = false;
if(!strSchCode.startsWith("CIT")) {
	strSQLQuery = "select prop_val from read_property_file where prop_name = 'ALLOW_READVISE'";
	strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
	if(strSQLQuery != null && strSQLQuery.equals("0"))
		bolIsReadviseBlocked = true;
}


//System.out.println(strStudIndex);
if(!bolIsETO && (strSchCode.startsWith("CIT") || bolIsReadviseBlocked)) {//now open for all :: locking.
	if(strStudIndex != null) {
		strSQLQuery = "select count(*) from enrl_final_cur_list where is_valid = 1 and user_index = "+strStudIndex+" and sy_from = "+strSYFrom+
			" and current_semester = "+strTerm+" and is_printed_1 = 1 ";
		if(bolIsTempStud)
			strSQLQuery += " and is_temp_stud = 1";
		else	
			strSQLQuery += " and is_temp_stud = 0"; 			
		strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);

		if(strSQLQuery != null && !strSQLQuery.equals("0")) {
			strSQLQuery = "select ALLOW_INDEX from CIT_ALLOW_SECOND_ADVISING where stud_index = "+strStudIndex+" and is_valid = 1 and sy_from = "+strSYFrom+
				" and sem = "+strTerm+" and is_used = 0";
			if(bolIsTempStud)
				strSQLQuery += " and is_temp_stud = 1";
			else	
				strSQLQuery += " and is_temp_stud = 0";
			strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
			if(strSQLQuery == null) {
				strErrMsg = "Re-advising is not allowed.";
				bolAllowAdvising = false;
			}
		}	
	}
}

	/** 
	*	this block is moved to Next so that system will consider exceptions as well
	*   Check if system locked advising and if student having exception
	**/	
		if(strStudIndex != null && strTerm != null && strSYFrom != null) {//check first time only.
			strTemp = "0";
			if(bolIsTempStud)
				strTemp = "1";
			///System.out.println(strSYFrom);
			//System.out.println(strTerm);
			//System.out.println(strStudIndex);
			//System.out.println(strTemp);
			if(sParam.isLockedGeneric(dbOP, strSYFrom, strTerm, "1", strStudIndex, strTemp, strCourseIndex)) {
				bolIsAllowedToAdvise = false;
				strErrMsg = "Enrollment already closed";
				strStudIndex = null;
			}
			
			///temp student for NEU, are blocked unless opened by registrar.
			if(strSchCode.startsWith("NEU") && bolIsTempStud) {
				java.util.Vector vOnlineAdv = new enrollment.NAApplicationForm().checkOnlineAdvsingStat(dbOP, strStudIndex);
				if(vOnlineAdv != null && ((String)vOnlineAdv.elementAt(0)).equals("2")) {
					//do nothing
				}
				else {
					bolIsAllowedToAdvise = false;
					strErrMsg = "Advising is not allowed.";
					strStudIndex = null;
				}

			} 			
		}



if(strStudIndex != null) {
//also check blocking of advising.
	boolean bolShowAdviseList = true;
	if(!bolIsTempStud) {
		bolShowAdviseList = sParam.allowAdvising(dbOP, strStudIndex, 0d, strSYFrom, strTerm);
		if(!bolShowAdviseList)
			strErrMsg = sParam.getErrMsg();	
	}
	
//apply auto block for CIT for returnees and transferees (1 sem prior).
	if(false && strSYFrom.equals("2014") && !strTerm.equals("1")) {
		//do nothing.. 
	}
	else {
		if(!bolIsTempStud && !sParam.autoLockStudent(dbOP, strStudIndex, strSYFrom, strTerm, strSchCode)) {
			strErrMsg = sParam.getErrMsg();
			bolAllowAdvising = false;
		}
	}

//check if blocked by departments.. 
//if(bolAllowAdvising) {
	//get here if blocked by depts.. 
	if(!bolIsTempStud && sParam.isStudLockedByDept(dbOP, strStudIndex, strSYFrom, strTerm)) {
	//System.out.println("I am here..");
		if(strErrMsg != null) {
			strErrMsg += "<br><br>"+sParam.getErrMsg();
		}
		else 
			strErrMsg = sParam.getErrMsg();
		bolAllowAdvising = false;
	}
	
//}
}
String strVMASectionList = null;
if(strSchCode.startsWith("SPC")) 
	strVMASectionList = dbOP.loadCombo("distinct e_sub_section.section","e_sub_section.section"," from e_sub_section where is_valid = 1 order by e_sub_section.section asc", WI.fillTextValue("section_name_"), false);
else if(strSchCode.startsWith("VMA")) 
	strVMASectionList = dbOP.loadCombo("vma_section.section_name","vma_section.section_name"," from vma_section order by vma_section.section_name asc", WI.fillTextValue("section_name_"), false);

if(strStudIndex != null && strErrMsg == null && strCourseIndex != null && bolAllowAdvising) {
	String strWindowWidth = WI.fillTextValue("win_width");
	
	
	if(bolIsTempStud) {//forward to advising.. 
		
		if(WI.fillTextValue("section_name_").length() > 0) {
			strErrMsg = "update new_application set section_name_ = '"+WI.fillTextValue("section_name_")+"' where application_index = "+strStudIndex;
			dbOP.executeUpdateWithTrans(strErrMsg, null, null, false);
		}
		//System.out.println("I am here.");
		
		if(strApplCatg.toLowerCase().startsWith("new"))
			strErrMsg = "./advising_new.jsp?is_forwarded=1&temp_id="+strStudID+"&sy_from="+strSYFrom+"&sy_to="+strSYTo+"&semester="+strTerm+
			"&showList=1&win_width="+strWindowWidth+"&online_advising="+WI.fillTextValue("online_advising");
		else
			strErrMsg = "./advising_transferee.jsp?is_forwarded=1&stud_id="+strStudID+"&sy_from="+strSYFrom+"&sy_to="+strSYTo+"&semester="+strTerm+"&showList=1&pgDisp="+
			strApplCatg.toUpperCase()+"&win_width="+strWindowWidth+"&online_advising="+WI.fillTextValue("online_advising");//System.out.println(strErrMsg);
		//strErrMsg = response.encodeRedirectURL(strErrMsg);
		dbOP.cleanUP();
		%>
			<jsp:forward page="<%=strErrMsg%>"/>
		<%
	}
	else {
	dbOP.cleanUP();

			//System.out.println("strAlreadyRegistered2 : "+strAlreadyRegistered);
			strErrMsg = "./advising_all_in_one_p2.jsp?stud_status=Old&pullStudInfo=1&reloadPage=1&stud_id="+strStudID+"&sy_from="+
							strSYFrom+"&sy_to="+strSYTo+"&semester="+strTerm+"&already_registered="+strAlreadyRegistered+"&stud_stat="+strApplCatg+
							"&win_width="+strWindowWidth;
			if(strAlreadyRegistered.equals("1") && strYrLevelRegistered != null)
				strErrMsg += "&year_level="+strYrLevelRegistered;
			//System.out.println(strErrMsg);
		if( (strSchCode.startsWith("UC") || strSchCode.startsWith("FATIMA")) && strAlreadyRegistered.equals("0"))
			strErrMsg = "Please go to Admission.";
		else{%>
			<jsp:forward page="<%=strErrMsg%>"/>
		<%}
	}

}	

dbOP.cleanUP();

String strDefaultTerm = (String)request.getSession(false).getAttribute("cur_sem");
if(strDefaultTerm == null)
	strDefaultTerm = "";
%>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Advising Old Students</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function OpenSearch() {
<%
	strTemp ="&sy_from=" + strSYFrom + "&sy_to=" + strSYTo + "&semester=" + strTerm;
%>
	var pgLoc = "../../../search/srch_stud_enrolled.jsp?opner_info=form_.stud_id&is_advised=1<%=strTemp%>";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function focusID() {
	if(!document.form_.stud_id)
		return;
	document.form_.stud_id.focus();
}
function ReloadPage() {
	document.form_.submit();
}
function AjaxMapName(strRef) {
		var strSearchCon = "&search_temp=2";
		
		var strCompleteName = document.form_.stud_id.value;
		if(strCompleteName.length  < 3) 
			return;
		
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2"+strSearchCon+"&name_format=5&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
		//document.getElementById("coa_info").innerHTML=this.strPrevEntry+this.bolReturnStrEmpty
}
function UpdateID(strID, strUserIndex) {
	//do nothing.
	document.form_.stud_id.value = strID;
	document.getElementById("coa_info").innerHTML = "";
	//document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}


function alertSize() {
	<%
	if(WI.fillTextValue("win_width").length() > 0){%>
		return;
	<%}%>
  var myWidth = 0, myHeight = 0;
  if( typeof( window.innerWidth ) == 'number' ) {
    //Non-IE
    myWidth = window.innerWidth;
    myHeight = window.innerHeight;
  } else if( document.documentElement && ( document.documentElement.clientWidth || document.documentElement.clientHeight ) ) {
    //IE 6+ in 'standards compliant mode'
    myWidth = document.documentElement.clientWidth;
    myHeight = document.documentElement.clientHeight;
  } 
  else if( document.body && ( document.body.clientWidth || document.body.clientHeight ) ) {
    //IE 4 compatible
    myWidth = document.body.clientWidth;
    myHeight = document.body.clientHeight;
  }
  //window.alert( 'Width = ' + myWidth );
  //window.alert( 'Height = ' + myHeight );
  	document.form_.win_width.value = myWidth - 35;
	//alert(document.form_.win_width.value);
}

function updateSYIfDefaultIsSummer() {
	<%
	if(!strDefaultTerm.equals("0")){%>
		return;
	<%}%>
	//increment sy if term changed from summer to regular sem.
	if(document.form_.semester.selectedIndex == 1) {
		document.form_.sy_from.value = "<%=Integer.parseInt(strSYFrom) + 1%>";
		document.form_.sy_to.value = "<%=Integer.parseInt(strSYTo) + 1%>";
	}

}
function AddRecord()
{
	if(document.form_.section_name_) {
		if(document.form_.section_name_.selectedIndex == 0) {
			alert("Please select a section of student.");
			return;
		}
	}
	document.form_.submit();
}

function GoToBatchAdvising() {
	location = "./advising_batch_spc.jsp";
}
</script>
<%
//add security here.




/**

// additional setting to force stop / or allow advising.. 
// setting is in System Admin -> Set param -> Enrollment advising setting.
double dOutstanding      = 0d;

//check if student is having outstanding balance.
if(vStudInfo != null && vStudInfo.size() > 0) {
	enrollment.FAFeeOperation fOperation = new enrollment.FAFeeOperation();
	fOperation.checkIsEnrolling(dbOP,(String)vStudInfo.elementAt(0), WI.fillTextValue("sy_from"),
								WI.fillTextValue("sy_to"), WI.fillTextValue("semester"));
	dOutstanding= fOperation.calOutStandingOfPrevYearSemEnrolling(dbOP, (String)vStudInfo.elementAt(0));

	enrollment.SetParameter sParam = new enrollment.SetParameter();
	bolShowAdviseList = sParam.allowAdvising(dbOP, (String)vStudInfo.elementAt(0), dOutstanding, 
											WI.fillTextValue("sy_from"), WI.fillTextValue("semester"));
	if(!bolShowAdviseList)
		strErrMsg = sParam.getErrMsg();
//	System.out.println(bolShowAdviseList);
}

if(strErrMsg == null)
	strErrMsg = "";

**/


boolean bolAutoSubmit = true;
//if(strSchCode.startsWith("VMA") || strSchCode.startsWith("SPC"))
	bolAutoSubmit = false;
if(strSchCode.startsWith("CIT"))
	bolAutoSubmit = true;


%>

<body bgcolor="#D2AE72" onLoad="focusID();alertSize();">
<form name="form_" action="./advising_all_in_one_p1.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="8" bgcolor="#A49A6A" align="center"><strong> <font color="#FFFFFF">
        :::: ADVISING PAGE :::: </font></strong></td>
    </tr>
    <tr>
      <td height="25" colspan="8" style="font-weight:bold; font-size:14px; color:#FF0000">&nbsp;&nbsp; <%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
<%if(bolIsAllowedToAdvise) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr valign="top"> 
      <td width="1%" height="25">&nbsp;</td>
      <td width="20%" height="25">Enter Student ID </td>
      <td width="17%" height="25"> <input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp="AjaxMapName('1');">      </td>
      <td width="4%" height="25">
	  	<a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0" ></a>	  </td>
      <td width="22%"><a href="javascript:AddRecord();"><img src="../../../images/form_proceed.gif" border="0"></a> 
&nbsp;	  </td>
	  <td>
      <label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label>	  </td>
    </tr>
    <tr> 
      <td width="1%" height="24">&nbsp;</td>
      <td width="20%" height="24">School Year/Term </td>
      <td height="24" colspan="3"> 
	  <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strSYFrom%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        - 
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strSYTo%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> &nbsp;&nbsp;&nbsp;&nbsp; <select name="semester" onChange="<%if(bolAutoSubmit){%>updateSYIfDefaultIsSummer(); ReloadPage();<%}%>">
		<%=CommonUtil.constructTermList(dbOP, request, strTerm)%>

<!--
          <option value="0">Summer</option>
          <%
strTemp = strTerm;
if(strTemp.equals("1")){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.equals("2")){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}
		  if (!strSchCode.startsWith("CPU")){
			  if(strTemp.equals("3")){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}
          }%>
-->
        </select>      </td>
      <td height="24" style="font-weight:bold; font-size:14px;" align="right">
<%if(strSchCode.startsWith("SPC") || strSchCode.startsWith("DLSHSI")){%>
	  <a href="javascript:GoToBatchAdvising();">Go to Batch Advising</a>
<%}%>
	  </td>
    </tr>
<%if(strSchCode.startsWith("VMA") || strSchCode.startsWith("SPC")){%>
    <tr>
      <td height="24">&nbsp;</td>
      <td height="24" style="font-size:13px; font-weight:bold; color:#0000FF">
		Set Section of Student</td>
      <td height="24" colspan="4">
	  <select name="section_name_">
			<option value=""></option>
          <%=strVMASectionList%>
		</select> 
	  <font size="1">(Optional to set, Leave it blanck to retain same section set during registration)</font>	  </td>
<%}%>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="8" style="font-size:14px; font-weight:bold; color:#FF0000">&nbsp;&nbsp;&nbsp;&nbsp; 
	  <%if(!bolAllowAdvising) {%>
	  	Advising is not allowed. Please contact System admin
	  <%}%>
	  
	  </td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="8" bgcolor="#A49A6A" align="center">&nbsp;&nbsp;&nbsp;&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="win_width" value="<%=WI.fillTextValue("win_width")%>">
<input type="hidden" name="online_advising" value="<%=WI.fillTextValue("online_advising")%>">
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
