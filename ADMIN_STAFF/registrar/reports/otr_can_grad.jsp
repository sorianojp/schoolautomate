<%
	
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	String strInfo5   = (String)request.getSession(false).getAttribute("info5");
	if(strSchCode == null) {%>
	<p style="font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif; color:#FF0000; font-size:20px;">You are already loggedout. Please login again.</p>
	<%return;}
	

	%>
	
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function UpdateEntranceData() {
	if(document.form_.stud_id.value.length ==0) {
		alert("Please enter Student ID.");
		return;
	}
	var pgLoc = "../entrance_data/entrance_data.jsp?stud_id="+document.form_.stud_id.value+
		"&parent_wnd=form_";
	var win=window.open(pgLoc,"EditWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function FocusID() {
	document.form_.stud_id.focus();
}
function RemovePrintPg() {
	document.form_.add_record.value = "";
	document.form_.print_pg.value = "";
	
	this.getTFSelected();
	document.form_.submit();
}
function PrintAllPages(strPrintStat) {
	//ensure safe reload of page and call Printing of TOR.. 
	document.form_.add_record.value = "";
	document.form_.print_pg.value = "1";
	document.form_.print_.value = '1';
	if(strPrintStat)
		document.form_.print_.value = strPrintStat;
	//alert(document.form_.print_.value);
	this.getTFSelected();
	document.form_.print_all_pages.value='1';
	//alert(document.form_.print_.value);
	document.form_.submit();
}
/**
function PrintAllPages() {
	//ensure safe reload of page and call Printing of TOR.. 
	document.form_.add_record.value = "";
	document.form_.print_pg.value = "1";
	document.form_.print_.value = '1';
	
	document.form_.print_all_pages.value='1';
	document.form_.submit();
}
**/

function PrintPg(strRowStartFr,strRowCount,strLastPage,strPageNumber,strMaxRowsToDisp, strPrintStatus) {
	document.form_.add_record.value = "";

	document.form_.print_pg.value = "1";

	document.form_.row_start_fr.value = strRowStartFr;
	document.form_.row_count.value = strRowCount;
	document.form_.last_page.value = strLastPage;

	document.form_.page_number.value = strPageNumber;
	document.form_.max_page_to_disp.value = strMaxRowsToDisp;
	document.form_.print_.value = strPrintStatus;
	
	this.getTFSelected();
	document.form_.submit();
}
function AddRecord() {
	document.form_.add_record.value = "1";
	document.form_.print_pg.value = "";
	document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.submit();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function MapSG() {
	var pgLoc = "./otr_can_grad_map.jsp";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ExcludeSubForm9() {
	if(document.form_.stud_id.value.length ==0) {
		alert("Please enter Student ID.");
		return;
	}
	var pgLoc = "./otr_can_grad_exclude.jsp?stud_id="+escape(document.form_.stud_id.value);
	var win=window.open(pgLoc,"PrintWindow",'width=1000,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function UpdateAdditionalInfo() {
	if(document.form_.stud_id.value.length ==0) {
		alert("Please enter Student ID.");
		return;
	}
	var pgLoc = "../../admission/stud_personal_info_page2.jsp?stud_id="+document.form_.stud_id.value+
		"&parent_wnd=form_";
	var win=window.open(pgLoc,"EditWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
/*** this ajax is called for required downpayment update **/
function ajaxUpdate(objField, strRef) {
	//if there is no change, just return here..
	var strNewVal = ""; 
	if(strRef == '3') {
		if(objField.checked)
			strNewVal = '1';
	}
	else
		strNewVal = objField.value;

	var strParam = "new_val="+escape(strNewVal)+"&field_ref="+strRef+"&stud_ref="+document.form_.stud_ref.value;
	var objCOAInput = document.getElementById("coa_info"+strRef);
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get value in this.retObj
  	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=120&"+strParam;
	
	this.processRequest(strURL);
}

//all about ajax.
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.form_.stud_id.value;
		if(strCompleteName.length < 2)
			return;
		
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

function toggleTF() {
	var iMaxTFList = document.form_.tf_list.value;
	if(iMaxTFList.length == 0) 
		return;
	var objChkBox; 
	var bolIsChecked = document.form_.sel_all_tf.checked;
	
	for(var i = 0; i < iMaxTFList; ++i) {
		eval('objChkBox = document.form_.tf_info'+i);
		if(!objChkBox)
			continue;
		objChkBox.checked = bolIsChecked
	}
}
function getTFSelected() {
	document.form_.tf_sel_list.value  = "-1";//do not process.. 
	if(!document.form_.tf_list)
		return;
//	document.form_.tf_sel_list.value = "0";
	
	var strTFSelected = "";
	var iMaxTFList = document.form_.tf_list.value;
	if(iMaxTFList.length == 0) 
		return;
	var objChkBox; var iChecked = 0;
	for(var i = 0; i < iMaxTFList; ++i) {
		eval('objChkBox = document.form_.tf_info'+i);
		if(!objChkBox)
			continue;
		//document.form_.tf_sel_list.value = "0";
		if(!objChkBox.checked)
			continue;
			
		if(strTFSelected == "")
			strTFSelected = objChkBox.value;
		else	
			strTFSelected +=","+ objChkBox.value;
		++iChecked;
	}
	
	if(iChecked == iMaxTFList) {//all checked 
		document.form_.tf_sel_list.value = "-1";
		return;
	}

	//if(strTFSelected.length > 0)
	document.form_.tf_sel_list.value = strTFSelected;
	//alert(document.form_.tf_sel_list.value);
}function ReloadNeeded() {
	var obj = document.getElementById("reload_page_tf");
	if(!obj)
		return;
	if(obj.innerHTML == '')
		obj.innerHTML = "Please click Refresh if you make any change.";

}


</script>

<body bgcolor="#D2AE72" onLoad="FocusID();">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);

	String strOTRExtn = null;
	if(strSchCode != null) 
		strOTRExtn = strSchCode.substring(0,strSchCode.indexOf("_"));
	if(strOTRExtn != null && strOTRExtn.compareTo("VMUF") != 0 && WI.fillTextValue("show_chedformat").length() == 0) //System.out.println(strOTRExtn);
		strOTRExtn = "./otr_can_grad_print_ui.jsp";
	else	
		strOTRExtn = "./otr_can_grad_print.jsp";
	
	if(strSchCode.startsWith("WNU"))
		strOTRExtn = "./otr_can_grad_print_wnu.jsp";
	if(strSchCode.startsWith("UC"))
		strOTRExtn = "./otr_can_grad_print_uc.jsp";
	if(strSchCode.startsWith("VMUF"))
		strOTRExtn = "./otr_can_grad_print.jsp";
	if(strSchCode.startsWith("CSAB"))
		strOTRExtn = "./otr_can_grad_print_csa.jsp";
	if(strSchCode.startsWith("VMA"))
		strOTRExtn = "./otr_can_grad_print_vma.jsp";
	if(strSchCode.startsWith("CDD"))
		strOTRExtn = "./otr_can_grad_print_cdd.jsp";
	if(strSchCode.startsWith("UPH") && strInfo5 == null)
		strOTRExtn = "./otr_can_grad_print_uph.jsp";

if(request.getParameter("print_pg") != null && request.getParameter("print_pg").compareTo("1") ==0){%>
	<jsp:forward page="<%=strOTRExtn%>"/>
<%return;}

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strDeanName = null;//I have to find.
	String strDegreeType = null;

	Vector vCourseHist = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-REPORTS-candidate for grad - form 18","rec_can_grad.jsp");
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
														"Registrar Management","REPORTS",request.getRemoteAddr(),
														"rec_can_grad.jsp");
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

String strEntranceDataOtherUC = null;
String strEntranceData        = null;
int iIndexOf = 0;

///// extra condition for the selected courses
boolean viewAll = true;
int iMaxCourseDisplay = Integer.parseInt(WI.getStrValue(WI.fillTextValue("max_course_disp"),"0"));
String[] strTok = null; Vector vCourseSelected = new Vector();
String strExtraCon = " and (";

for (int k = 0; k < iMaxCourseDisplay; k++){
	if (WI.fillTextValue("checkbox"+k).length() == 0 )
		continue;
	
	viewAll = false;
	strTok = (WI.fillTextValue("checkbox"+k)).split(",");
	
	if (strTok != null){
		if (strExtraCon.length() > 7) 
			strExtraCon += " or ";
	
		strExtraCon += " (stud_curriculum_hist.course_index = " + strTok[0];
		vCourseSelected.addElement(strTok[0]);
		
		if (!strTok[1].equals("null"))
			strExtraCon +=  
				" and stud_curriculum_hist.major_index = " + strTok[1];
		strExtraCon += ")";
	}	
}

strExtraCon += ")";

if (viewAll || strExtraCon.length() < 10){
	strExtraCon = null;
}
/////////////end of extra Con.

enrollment.OfflineAdmission offlineAdm = new enrollment.OfflineAdmission();
enrollment.EntranceNGraduationData eData = new enrollment.EntranceNGraduationData();
enrollment.ReportRegistrar repRegistrar  = new enrollment.ReportRegistrar();
student.StudentInfo studInfo = new student.StudentInfo();
enrollment.GradeSystemExtn GSExtn = new enrollment.GradeSystemExtn();
Vector vApprenticeInfo  = new Vector();
Vector vStudInfo = null;
Vector vEntranceData = null;
Vector vAdditionalInfo = null;
String strUserIndex = null;//student index

int iPageCount = 0;
boolean bolNewStudentID  = !WI.fillTextValue("curr_stud_id").equals(WI.fillTextValue("stud_id"));

String strSQLQuery = null;

Vector vRetResult = null;//this is otr detail info, i have to break it to pages,

if(!bolNewStudentID && !WI.fillTextValue("tf_sel_list").equals("-1")) {
	if(WI.fillTextValue("tf_sel_list").length() == 0) 
		repRegistrar.strTFList = "0";
	else	
		repRegistrar.strTFList = WI.fillTextValue("tf_sel_list");
	
}

if(WI.fillTextValue("stud_id").length() > 0){
	vStudInfo = offlineAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"));
	if(vStudInfo == null)
		strErrMsg = offlineAdm.getErrMsg();
	else {
		strUserIndex = (String)vStudInfo.elementAt(12);

		strDegreeType = (String)vStudInfo.elementAt(15);
		strDeanName = dbOP.mapOneToOther("course_offered join college on (college.c_index = course_offered.c_index)",
						"course_index",(String)vStudInfo.elementAt(5),"DEAN_NAME",null);

		vAdditionalInfo = studInfo.getStudInfoOTRCanForGradForm17(dbOP,
				(String)vStudInfo.elementAt(12));
		if(vAdditionalInfo == null || vAdditionalInfo.size() ==0)
			strErrMsg = studInfo.getErrMsg();
		vEntranceData = eData.operateOnEntranceData(dbOP, request,4);
		if(vEntranceData == null)
			strErrMsg = eData.getErrMsg()+". <a href='javascript:UpdateEntranceData()'> Click to Go to Entrance Data</a>";
		
		if (strSchCode.startsWith("VMUF") || strSchCode.startsWith("WNU") || strSchCode.startsWith("UB") || strSchCode.startsWith("UC")) {
			vCourseHist = GSExtn.retrieveCourseHistory(dbOP, request.getParameter("stud_id"));
			if (vCourseHist == null)
				strErrMsg = GSExtn.getErrMsg();
		}
		
		//get requirement complied.
		enrollment.CourseRequirement cRequirement = new enrollment.CourseRequirement();
		Vector vFirstEnrl = cRequirement.getFirstEnrollment(dbOP,request.getParameter("stud_id"),
													WI.getStrValue((String)vStudInfo.elementAt(7)),
													(String)vStudInfo.elementAt(8));
		Vector vCompliedRequirement = null;
		if (vFirstEnrl != null) {
			if(strSchCode.startsWith("UC"))
				vFirstEnrl = cRequirement.getStudentPendingCompliedList(dbOP,(String)vStudInfo.elementAt(12),
											(String)vFirstEnrl.elementAt(0),(String)vFirstEnrl.elementAt(1),
											(String)vFirstEnrl.elementAt(2),false,false,true,false);
			else
				vFirstEnrl = cRequirement.getStudentPendingCompliedList(dbOP,(String)vStudInfo.elementAt(12),
											(String)vFirstEnrl.elementAt(0),(String)vFirstEnrl.elementAt(1),
											(String)vFirstEnrl.elementAt(2),false,false,true,true);
										
			if(vFirstEnrl == null) {
				if(strErrMsg == null)
					strErrMsg = cRequirement.getErrMsg();
			}
			else
				vCompliedRequirement = (Vector)vFirstEnrl.elementAt(1); 
		}	
		if(vCompliedRequirement == null)
			vCompliedRequirement = new Vector();	
		
					//I have to get any other requirement submitted. 
		strSQLQuery = "select req_sub_index,requirement from NA_REQ_SUBMITTED "+
								"join NA_ADMISSION_REQ on (NA_ADMISSION_REQ.req_index = na_req_submitted.req_index) "+
								"where NA_REQ_SUBMITTED.is_valid = 1 and stud_index = "+
								strUserIndex+" and is_temp_stud = 0 and NA_REQ_SUBMITTED.is_other_data_uc = 1"; 
		java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
		while(rs.next()) {
			iIndexOf = vCompliedRequirement.indexOf(rs.getString(1));
			if(iIndexOf > -1) {
				vCompliedRequirement.remove(iIndexOf);vCompliedRequirement.remove(iIndexOf);vCompliedRequirement.remove(iIndexOf);
			}
			if(strEntranceDataOtherUC == null)
				strEntranceDataOtherUC = rs.getString(2);
			else	
				strEntranceDataOtherUC += ","+rs.getString(2);
		}
		rs.close();
		if (vCompliedRequirement != null && vCompliedRequirement.size() > 0) {
		
			for (int i = 0; i < vCompliedRequirement.size(); i+= 3) {
				if (i == 0) 
					strEntranceData = (String)vCompliedRequirement.elementAt(i+1);
				else 
					strEntranceData += "," + (String)vCompliedRequirement.elementAt(i+1);
			}
		}

		
		
		
	}
	if(strErrMsg == null) {//get the grad detail.
		//vRetResult = repRegistrar.getOTROfCanForGrad(dbOP, WI.fillTextValue("stud_id"), strDegreeType);
		vRetResult = repRegistrar.getOTROfCanForGrad(dbOP, WI.fillTextValue("stud_id"), strDegreeType,false,strExtraCon);
		
		if(vRetResult == null)
			strErrMsg = repRegistrar.getErrMsg();
		else{
			enrollment.ReportRegistrarExtn rprtReg = new enrollment.ReportRegistrarExtn();
			if(strSchCode.startsWith("WNU"))
				vApprenticeInfo = rprtReg.operateOnApprenticeInfoWNU(dbOP, request, 4, (String)vStudInfo.elementAt(12), true);
			if(vApprenticeInfo == null)
				vApprenticeInfo = new Vector();
		}
	}
}

//save encoded information if save is clicked.
java.sql.ResultSet rs  = null;
Vector vForm17Info = null;
if(WI.fillTextValue("add_record").compareTo("1") == 0){
	if(repRegistrar.operateOnForm17Form18EncodedInfo(dbOP, request,1,true) == null)
		strErrMsg = repRegistrar.getErrMsg();
}
vForm17Info = repRegistrar.operateOnForm17Form18EncodedInfo(dbOP, request,2,true);
if(vForm17Info != null && vForm17Info.size() ==0)
	vForm17Info = null;


String strPrintValueCSV = "";//this stores all print values passed in javascript PrintPg method call.. csv values are
//row_start_fr,row_count,row_count,last_page,page_number,max_page_to_disp,
int iExcluded = 0;
if(strUserIndex != null) {
	strSQLQuery = "select count(*) from SUBJECT_EXCLUDE_FORM19 where stud_index = "+strUserIndex+" and is_valid = 1";
	strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
	if(strSQLQuery != null)
		iExcluded = Integer.parseInt(strSQLQuery);
}
%>
<form action="./otr_can_grad.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          OTR OF CANDIDATE FOR GRADUATION PAGE ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="5">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td align="right">
	  	<a href="javascript:MapSG();"><b>Map Subject Group to CHED Format</b></a>&nbsp;&nbsp;	  </td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="13%">Student ID </td>
      <td width="26%"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');">      </td>
      <td width="5%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td width="54%"><a href="javascript:RemovePrintPg();"><img src="../../../images/form_proceed.gif" onClick="RemovePrintPg();" border="0"></a>
	  <label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF; position:absolute; width:350;"></label>
	  </td>
    </tr>
    
    <tr>
      <td height="25" colspan="5"><hr size="1"></td>
    </tr>
  </table>
<%
if(vStudInfo != null && vStudInfo.size() > 0 && vAdditionalInfo != null && vAdditionalInfo.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3">NCEE :
        <input name="ncee" type="text" size="4" value="<%=WI.fillTextValue("ncee")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;GSA
        <input name="gsa" type="text" size="4" value="<%=WI.fillTextValue("gsa")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Percentile Rank
        <input name="percentile" type="text" size="4" value="<%=WI.fillTextValue("percentile")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="31%" align="right">
	  	<a href="javascript:ExcludeSubForm9();"><b>Exclude Subjects in Form9 (Excluded: <%=iExcluded%>)</b></a>&nbsp;&nbsp;
	  
	  
	  </td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="14%">Last name :</td>
      <td width="39%"><%=((String)vStudInfo.elementAt(2)).toUpperCase()%></td>
      <td width="14%">Gender : </td>
      <td><%=WI.getStrValue(vAdditionalInfo.elementAt(0))%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>First Name :</td>
      <td><%=((String)vStudInfo.elementAt(0)).toUpperCase()%></td>
      <td>Date of Birth :</td>
      <td><%=WI.getStrValue(vAdditionalInfo.elementAt(1))%></td>
    </tr>
    <tr>
      <td height="24"><font size="2">&nbsp;</font></td>
      <td><font size="2">Middle Name :</font></td>
      <td><%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%></td>
      <td>Place of Birth : </td>
      <td><%=WI.getStrValue(vAdditionalInfo.elementAt(2))%></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Address :</td>
      <td colspan="3"><%=WI.getStrValue((String)vAdditionalInfo.elementAt(3))%>
	  <%=WI.getStrValue((String)vAdditionalInfo.elementAt(4),",","","")%>
	  <%=WI.getStrValue((String)vAdditionalInfo.elementAt(5),",","","")%>
	  <%=WI.getStrValue((String)vAdditionalInfo.elementAt(7),"-","","")%>
	  <%=WI.getStrValue((String)vAdditionalInfo.elementAt(6),",","","")%>	  </td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3">
	  <a href="javascript:UpdateAdditionalInfo();"><img src="../../../images/update.gif" border="0"></a>
		<font color="#0000FF" size="1">Click to update Student Information </font>
	  </td>
    </tr>
    <tr>
      <td height="25" colspan="5"><hr size="1"></td>
    </tr>
  </table>
<%//if vStudInfo is not null
if(vEntranceData != null && vEntranceData.size() > 0){//System.out.println(vEntranceData);
String[] astrConvertToDocType = {"Form 137-A","Transcript of Record","C.E.A No."};
%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="4"> Educational Data 
	  <a href="javascript:UpdateEntranceData();"><img src="../../../images/update.gif" border="0"></a> <font color="#0000FF" size="1">Click to Entrance Data </font>	  </td>
      <td width="27%">School Year</td>
    </tr>
    <tr> 
<!--
      <td height="25">&nbsp;</td>
      <td width="4%">&nbsp;</td>
      <td width="14%">Primary</td>
      <td colspan="2"><%=WI.getStrValue(vEntranceData.elementAt(14))%></td>
      <td><%=WI.getStrValue(vEntranceData.elementAt(17)) +" - "+
	  	WI.getStrValue(vEntranceData.elementAt(18))%></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>Intermediate</td>
      <td colspan="2"><%=WI.getStrValue(vEntranceData.elementAt(16))%></td>
      <td><%=WI.getStrValue(vEntranceData.elementAt(19)) +" - "+
	  WI.getStrValue(vEntranceData.elementAt(20))%></td>
    </tr>
-->
      <td height="25">&nbsp;</td>
      <td width="4%">&nbsp;</td>
      <td width="14%">Elementary</td>
      <td colspan="2"><%=WI.getStrValue((String)vEntranceData.elementAt(14),(String)vEntranceData.elementAt(3))%></td>
      <td><%=WI.getStrValue(vEntranceData.elementAt(19)) +" - "+
	  	WI.getStrValue(vEntranceData.elementAt(20))%></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>Secondary</td>
      <td colspan="2"><%=WI.getStrValue(vEntranceData.elementAt(5))%></td>
      <td><%=WI.getStrValue(vEntranceData.elementAt(21)) +" - "+
	  WI.getStrValue(vEntranceData.elementAt(22))%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>EL Number </td>
      <td colspan="2"><input type="text" class="textbox" name="el_no" onFocus="style.backgroundColor='#D3EBFF'" 
	  onBlur="ajaxUpdate(document.form_.el_no, '1');style.backgroundColor='white'"
		value="<%=WI.getStrValue(vEntranceData.elementAt(29))%>">
		
		<label id="coa_info1" style="font-size:9px; font-weight:bold; color:#FF0000"></label>		</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3">Contact Person Occupation: 
        <input type="text" class="textbox" name="con_addr_rel" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="ajaxUpdate(document.form_.con_addr_rel, '2');style.backgroundColor='white'"
		value="<%=WI.getStrValue(vEntranceData.elementAt(28))%>">
		<label id="coa_info2" style="font-size:9px; font-weight:bold; color:#FF0000"></label>		</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3" style="font-size:11px; font-weight:bold; color:#0000FF">
<%
strTemp  = (String)vEntranceData.elementAt(30);
if(strTemp != null && strTemp.equals("1"))
	strTemp = " checked";
else	
	strTemp = "";
%>
	  <input type="checkbox" name="remove_nstp_opt" value="1" <%=strTemp%> onChange="ajaxUpdate(document.form_.remove_nstp_opt, '3');"> Remove ROTC/LTS/CWTS
	  <label id="coa_info3" style="font-size:9px; font-weight:bold; color:#FF0000"></label>	  </td>
      <td>&nbsp;</td>
    </tr>
<% if (strSchCode.startsWith("UC")) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3">Entrance Data :</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="4"><input name="entrance_data" type="text" class="textbox" value="<%=WI.getStrValue(strEntranceData)%>" size="76"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3">Entrance Data (Other Data) :</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="4"><input name="adm_cre1" type="text" class="textbox" value="<%=WI.getStrValue(strEntranceDataOtherUC)%>" size="76"></td>
    </tr>
<%}else{%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="5">Admission Credentials :</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">1. ) <input type="text" class="textbox" value="<%=astrConvertToDocType[Integer.parseInt((String)vEntranceData.elementAt(8))]%>" name="adm_cre1"></td>
      <td colspan="2">2.) <input type="text" class="textbox" name="adm_cre2"></td>
    </tr>
<%}%>
    <tr> 
      <td height="27" colspan="6"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="27">&nbsp;</td>
      <td colspan="3">Report prepared by :</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="27">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="4"> 1. ) 
        <%
if(vForm17Info != null)
	strTemp = (String)vForm17Info.elementAt(1);
else
	strTemp = WI.fillTextValue("prep_by1");
%> <input name="prep_by1" type="text" class="textbox"
	  	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		value="<%=WI.getStrValue(strTemp)%>" size="64"> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="4">2. ) 
        <%
if(vForm17Info != null)
	strTemp = (String)vForm17Info.elementAt(2);
else
	strTemp = WI.fillTextValue("prep_by2");
%> <input name="prep_by2" type="text" class="textbox"
	  	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		value="<%=WI.getStrValue(strTemp)%>" size="64"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3">Report checked by :</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="4">1. ) 
        <%
if(vForm17Info != null)
	strTemp = (String)vForm17Info.elementAt(3);
else
	strTemp = WI.fillTextValue("check_by1");
%> <input name="check_by1" type="text" class="textbox"
	  	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		value="<%=WI.getStrValue(strTemp)%>" size="64"> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="4">2. ) 
        <%
if(vForm17Info != null)
	strTemp = (String)vForm17Info.elementAt(4);
else
	strTemp = WI.fillTextValue("check_by2");
%> <input name="check_by2" type="text" class="textbox"
	  	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		value="<%=WI.getStrValue(strTemp)%>" size="64"> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="5">Accounting Division</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="4"> <%
if(vForm17Info != null)
	strTemp = (String)vForm17Info.elementAt(6);
else
	strTemp = WI.fillTextValue("accounting_division");
%> <input name="accounting_division" type="text" class="textbox"
	  	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		value="<%=WI.getStrValue(strTemp)%>" size="64"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="5">Registrar's Name </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="4"> <%
if(vForm17Info != null)
	strTemp = (String)vForm17Info.elementAt(0);
else
	strTemp = WI.fillTextValue("registrar_name");
%> <input name="registrar_name" type="text" size="64" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="5">Dean's Name</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="4"> <input name="dean_name" type="text" size="64" value="<%=WI.getStrValue(strDeanName)%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="5">Credit Equivalent Notes</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="4"> <%
if(vForm17Info != null)
	strTemp = (String)vForm17Info.elementAt(5);
else
	strTemp = WI.fillTextValue("notes");
%> <textarea name="notes" cols="50" rows="2" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
	  onblur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp)%></textarea></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="5">Date of Enrollment </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="4">
<%
		strTemp = WI.fillTextValue("date_enrolled");
	if (strTemp.length() == 0 ) {
		strTemp = (String)vStudInfo.elementAt(17);
		if (strTemp != null && strTemp.length() > 0){
			strTemp = WI.formatDate(strTemp,11);
		}
		else	
			strTemp = "";
	}
%>
	  <input name="date_enrolled" type="text" size="24" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="5">Expected Date of Graduation </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"> <input name="date_grad" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_grad")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.date_grad');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
      <td colspan="2">&nbsp;
	  <%if(strSchCode.startsWith("CDD")){%>
	  	Highest Educ'l Attainment: 
	  	<select name="highest_edu">
<%
strTemp = WI.fillTextValue("highest_edu");
if(strTemp.equals("High School Level"))
	strErrMsg = "selected";
else	
	strErrMsg = "";
%>		
		<option value="High School Level"<%=strErrMsg%>>High School Level</option>
<%
if(strTemp.equals("College Level"))
	strErrMsg = "selected";
else	
	strErrMsg = "";
%>		
		<option value="College Level"<%=strErrMsg%>>College Level</option>
<%
if(strTemp.equals("Graduate Level"))
	strErrMsg = "selected";
else	
	strErrMsg = "";
%>		
		<option value="Graduate Level"<%=strErrMsg%>>Graduate Level</option>
		</select>
	  
	  <%}%>	  </td>
    </tr>
<% if (vCourseHist != null) {
	int iCheckBoxCtr = 0;
%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="4">
<%
if(strSchCode.startsWith("VMUF") || strSchCode.startsWith("WNU") || strSchCode.startsWith("UB") || strSchCode.startsWith("UC")){%>
		<table width="91%" border="0" cellspacing="0" cellpadding="0"
	  	style=" border: solid #0000FF 1px 1px 1px 1px;">
        <tr>
          <td width="45%">&nbsp;Select Courses to be shown</td>
          <td width="55%"><a href="javascript:RemovePrintPg()"><img src="../../../images/refresh.gif" width="71" height="23" border="1"></a> 
		  	<font size="1">click to recompute pages</font></td>
        </tr>
	<% 	Vector vTemp = null;
		int k = 0; 
		for (int j = 1; j < vCourseHist.size(); j++) {
  		  vTemp = (Vector)vCourseHist.elementAt(j);
		  if (vTemp == null) continue;
			for (k = 0; k<vTemp.size(); k += 5, iCheckBoxCtr++) {
	%> 	
        <tr>
          <td colspan="2">
		  &nbsp;&nbsp;&nbsp;&nbsp;
		  <% 
			if (WI.fillTextValue("checkbox"+iCheckBoxCtr).length()>0){
					strTemp = "checked";
			}else{
					strTemp = "";
			}
		  	
			if (bolNewStudentID)  // force check..
				strTemp = "checked";
			
		  %>
		  
		  	<input type="checkbox" name="checkbox<%=iCheckBoxCtr%>" 
					value="<%=(String)vTemp.elementAt(k+1) + 
								WI.getStrValue((String)vTemp.elementAt(k+2),",","",",null")%>" <%=strTemp%>>
			<%=(String)vTemp.elementAt(k+3) + 
				WI.getStrValue((String)vTemp.elementAt(k+4)," (",")","")%>		  </td>
        </tr>
	<% 		} 
	  	}
	%><input type="hidden" name="max_course_disp" value="<%=iCheckBoxCtr%>">
	
	<%
	//I have to now check if student has transferee info.. if so, i have to give option to include transferee info.. 
	
	strTemp = "select distinct sy_from, semester,sem_order from g_sheet_final_trans "+
					"join semester_sequence on (semester_val = semester) where user_index = "+strUserIndex+
					" and is_valid = 1 order by sy_from, sem_order";
	vTemp = new Vector();
if(strSchCode.startsWith("AUF") || strSchCode.startsWith("WNU") || strSchCode.startsWith("VMUF")){
	rs = dbOP.executeQuery(strTemp);
	while(rs.next()) {
		vTemp.addElement(rs.getString(1));
		vTemp.addElement(rs.getString(2));
	}
	rs.close();
}
	if(vTemp.size() > 0) {
		if(WI.fillTextValue("sel_all_tf").length() > 0) 
			strTemp = " checked";
		else	
			strTemp = "";
		%>
        <tr>
          <td colspan="2" style="font-size:9px; font-weight:bold">
		  <input type="checkbox" name="sel_all_tf" onClick="toggleTF();ReloadNeeded()" <%=strTemp%>>
		  <u>Include Transferee Information.</u>
		  <font style="font-weight:bold; font-size:14px; color:#FF0000">
		  <label id="reload_page_tf"></label>
		  </font>		  </td>
        </tr>
	<%
	iCheckBoxCtr = 0;
	while(vTemp.size() > 0) {
	if(WI.fillTextValue("tf_info"+iCheckBoxCtr).length() > 0 || bolNewStudentID)
		strTemp = " checked";
	else	
		strTemp = "";
	%>
        <tr>
          <td colspan="2">&nbsp; 
		  <input type="checkbox" name="tf_info<%=iCheckBoxCtr%>" value="<%=(String)vTemp.elementAt(0)+"-"+(String)vTemp.elementAt(1)%>" <%=strTemp%> onClick="ReloadNeeded()">
		  <%=vTemp.elementAt(0)%> - <%=vTemp.elementAt(1)%></td>
        </tr>
		
	<%vTemp.remove(0); vTemp.remove(0);++iCheckBoxCtr;}%>
	
	<input type="hidden" name="tf_list" value="<%=iCheckBoxCtr%>">
	
	<%}//end of if tf info exists..%>
      </table>
<%}%>	  </td>
    </tr>
<%}%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">
	  <%if(strSchCode.startsWith("VMUF") && false){%>
		<input type="checkbox" name="show_chedformat" value="checked" <%=WI.fillTextValue("show_chedformat")%>>
		Show Ched Format
	  <%}%>	  </td>
      <td colspan="2"><a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
        Click to save/edit encoded Information</td>
    </tr>
    <%
if(vRetResult != null && vRetResult.size() > 0){

/**I need to add this so this can be viewed as part of all subjects */
for(int i = 0 ; i < vRetResult.size(); i += 11){
	strTemp = WI.getStrValue((String)vRetResult.elementAt(i + 6))+WI.getStrValue((String)vRetResult.elementAt(i + 7));
	iIndexOf = vApprenticeInfo.indexOf(strTemp);
	if(iIndexOf > -1){	
		int iii = i + 11;
		vRetResult.insertElementAt(vRetResult.elementAt(i), iii);
		vRetResult.insertElementAt(vRetResult.elementAt(i+1), iii+1);
		vRetResult.insertElementAt(vRetResult.elementAt(i+2), iii+2);
		vRetResult.insertElementAt(vRetResult.elementAt(i+3), iii+3);
		vRetResult.insertElementAt(vRetResult.elementAt(i+4), iii+4);
		vRetResult.insertElementAt(vRetResult.elementAt(i+5), iii+5);
		vRetResult.insertElementAt("Apprenticeship:", iii+6);
		vRetResult.insertElementAt(vApprenticeInfo.elementAt(iIndexOf + 5), iii+7);
		vRetResult.insertElementAt(vApprenticeInfo.elementAt(iIndexOf + 7), iii+8);
		vRetResult.insertElementAt("&nbsp;", iii+9);
		vRetResult.insertElementAt("INC", iii+10);
		
		vRetResult.insertElementAt(vRetResult.elementAt(i), iii);
		vRetResult.insertElementAt(vRetResult.elementAt(i+1), iii+1);
		vRetResult.insertElementAt(vRetResult.elementAt(i+2), iii+2);
		vRetResult.insertElementAt(vRetResult.elementAt(i+3), iii+3);
		vRetResult.insertElementAt(vRetResult.elementAt(i+4), iii+4);
		vRetResult.insertElementAt(vRetResult.elementAt(i+5), iii+5);
		vRetResult.insertElementAt("Apprenticeship:", iii+6);
		strTemp = (String)vApprenticeInfo.elementAt(iIndexOf + 5);
		strTemp += "<br>"+ WI.getStrValue((String)vApprenticeInfo.elementAt(iIndexOf + 8),"From: ","","")+
			WI.getStrValue((String)vApprenticeInfo.elementAt(iIndexOf + 9),"- ","","");
		strTemp += "<br>"+ WI.getStrValue((String)vApprenticeInfo.elementAt(iIndexOf + 10),"Gross Tonnage: ","","");
		strTemp += "<br>"+ WI.getStrValue((String)vApprenticeInfo.elementAt(iIndexOf + 11),"Registry Number: ","","");

		vRetResult.insertElementAt(strTemp, iii+7);
		vRetResult.insertElementAt(vApprenticeInfo.elementAt(iIndexOf + 6), iii+8);
		vRetResult.insertElementAt("&nbsp;", iii+9);
		vRetResult.insertElementAt("INC", iii+10);
		
		vApprenticeInfo.remove(iIndexOf);vApprenticeInfo.remove(iIndexOf);vApprenticeInfo.remove(iIndexOf);vApprenticeInfo.remove(iIndexOf);
		vApprenticeInfo.remove(iIndexOf);vApprenticeInfo.remove(iIndexOf);vApprenticeInfo.remove(iIndexOf);vApprenticeInfo.remove(iIndexOf);
		vApprenticeInfo.remove(iIndexOf);vApprenticeInfo.remove(iIndexOf);vApprenticeInfo.remove(iIndexOf);vApprenticeInfo.remove(iIndexOf);
	}
}








//decide here page number.
//if (strSchCode != null && strSchCode.startsWith("UI")){
	// remove subjects which are not credited
//	for (int k = 0; k  <vRetResult.size(); k+=11){
//		if (vRetResult.elementAt(k+10) == null){
//			vRetResult.removeElementAt(k);vRetResult.removeElementAt(k);vRetResult.removeElementAt(k);
//			vRetResult.removeElementAt(k);vRetResult.removeElementAt(k);vRetResult.removeElementAt(k);
//			vRetResult.removeElementAt(k);vRetResult.removeElementAt(k);vRetResult.removeElementAt(k);
//			vRetResult.removeElementAt(k);vRetResult.removeElementAt(k);
//			k-=11;
			
//		}
//	}
//}

int iTemp = vRetResult.size() / 11;
//System.out.println(iPageCount);
//System.out.println(iRowsPerPage);
iPageCount = 1;
int iRowsPerPage = 25;
int iFirstPageRowCount = 25;
int iLastPageRowCount = 15;
int iMaxRowToDisplay = 0;
if(strSchCode.startsWith("WNU")) {
	iRowsPerPage = 46;
	iFirstPageRowCount = 35;
	iLastPageRowCount = 25;
}
else if(strSchCode.startsWith("VMUF")) {
	iRowsPerPage = 40;
	iFirstPageRowCount = 40;
	iLastPageRowCount = 40;
/**
	iRowsPerPage = 25;
	iFirstPageRowCount = 25;
	iLastPageRowCount = 15;
**/
}
else if(strSchCode.startsWith("UC")) {
	iRowsPerPage = 65;
	iFirstPageRowCount = 48;
	iLastPageRowCount = 48;
}
else {
	iRowsPerPage = 40;
	iFirstPageRowCount = 25;
	iLastPageRowCount = 25;
}

iTemp -= iFirstPageRowCount;
if(iTemp > 0) {
	iTemp -= iLastPageRowCount;
	++iPageCount;
}
else if(strSchCode.startsWith("UC")) {//I have to check if first page have enough space to handle footer.
	iTemp = iTemp +  iFirstPageRowCount;
	if(iTemp > 25)
		++iPageCount;
	iTemp = 0;
}
iPageCount += iTemp / iRowsPerPage;
if(iTemp % iRowsPerPage > 0)
	++iPageCount;


	
if (iPageCount <=0)
	iPageCount = 1;

int[] iRowsToShow = new int[iPageCount];
int[] iRowStartFrom = new int[iPageCount];
//if there are two pages, i have to findout the page counts here. only if the count is less than 30
iTemp = vRetResult.size() / 11;
//iTemp = 56;
/**
for(int i = 0 ; i < iPageCount; ++i){
	iRowsToShow[i] = iRowsPerPage;
	iRowStartFrom[i] = iRowsPerPage * i;
	iTemp -= 25;
	if(iTemp < 0) {
		iTemp += 25;
		iTemp -= 15;//may be this is last page.
		if(iTemp <=0){
			iTemp += 15;
			iRowsToShow[i] = iTemp;//end page.
		}
		else {//not last page.
			iTemp += 15;
			iRowsToShow[i] = iTemp - 5;
			iRowsToShow[i + 1] = 5;
			//
			iRowStartFrom[i + 1] = iRowsPerPage * i + iTemp - 5;
		}
		break;
	}
}
**/
for(int i = 0 ; i < iPageCount; ++i){
	if(i == 0) {
		iRowsToShow[i] = iFirstPageRowCount;
		iRowStartFrom[i] = 0;
		iTemp -= iFirstPageRowCount; 
		if(iTemp <= 0) {
			iRowsToShow[i] = iTemp + iFirstPageRowCount;
			break;
		}
		//I have to now get the last page information.
		continue;
	}
	if(i == (iPageCount - 1))//last page.
		iRowsToShow[i] = iLastPageRowCount;
	else	
		iRowsToShow[i] = iRowsPerPage;
		
	iRowStartFrom[i] = iFirstPageRowCount + iRowsPerPage * (i-1);

	iTemp -= iRowsPerPage;
	if(iTemp <= 0 && i != (iPageCount - 1) ) {//one page prior to last page is big enough to get all row, but can't take the last rows of last page.
		iTemp += iRowsPerPage;
		iRowsToShow[i] = iTemp;//just show 5 lines 
		//insert for last page.
		iRowStartFrom[i + 1] = vRetResult.size() / 11 ;
		iRowsToShow[i + 1] = 0;

/**
		iTemp += iRowsPerPage;
		iRowsToShow[i] = iTemp - 5;//just show 5 lines 
		//insert for last page.
		iRowStartFrom[i + 1] = vRetResult.size() / 11 - 5;
		iRowsToShow[i + 1] = 5;
**/
		break;
	} 
}

//System.out.println(iRowStartFrom[0]+" ,, "+iRowStartFrom[1]+" ,, "+iRowStartFrom[2]);

%>
    <!--    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="4"> <a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>
        <font size="1">Click to print report all information in one page , or
        select page # below to print individual page.</font></td>
    </tr>-->
    <%
int iLastPage = 0;
for(int i = 1; i <= iPageCount; ++i){
	if(i == iPageCount) {
		if(i == 1) 
			iMaxRowToDisplay = iFirstPageRowCount;
		else	
			iMaxRowToDisplay = iLastPageRowCount;
	
		strTemp = "Print Last Page";
		iLastPage = 1;
	}
	else {
		if(i == 1) 
			iMaxRowToDisplay = iFirstPageRowCount;
		else	
			iMaxRowToDisplay = iRowsPerPage; 
		strTemp = "Print Page "+i;
	}

if(strPrintValueCSV.length() > 0) 
	strPrintValueCSV = strPrintValueCSV+",";
	
strPrintValueCSV +=	Integer.toString(iRowStartFrom[i - 1]) + ","+//row_start_fr
					Integer.toString(iRowsToShow[i - 1])   + ","+//row_count
					Integer.toString(iLastPage)            + ","+//last_page
					Integer.toString(i)                    + ","+//page_number
					Integer.toString(iMaxRowToDisplay);//max_page_to_disp

//Print page(start pt, no of rows, is last page.
%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="4"> <table width="100%">
          <tr> 
            <td width="30%"> <b><font size="3"> <a href='javascript:PrintPg("<%=iRowStartFrom[i - 1]%>","<%=iRowsToShow[i - 1]%>","<%=iLastPage%>","<%=i%>",<%=iMaxRowToDisplay%>,"1");'> 
              <%=strTemp%></a></font></td>
            <td width="70%"> <a href='javascript:PrintPg("<%=iRowStartFrom[i - 1]%>","<%=iRowsToShow[i - 1]%>","<%=iLastPage%>","<%=i%>",<%=iMaxRowToDisplay%>,"0");'> 
              <font size="3"> <strong>[ VIEW ]</strong></font> </a> </td>
          </tr>
        </table></td>
    </tr>
    <%}%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">
  <%if(strSchCode.startsWith("WNU") || strSchCode.startsWith("UC")){%>
			<a href="javascript:PrintAllPages();">Print All Pages</a>
  <%}if(strSchCode.startsWith("UC")){%>  
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  <a href="javascript:PrintAllPages('0');">View All Pages</a>
  <%}%>  </td>

	  </td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <%}%>
  </table>
<%}//only if vEntrance Data info is not null
}//only if vStud info is not null and vStud Info.size () > 0
%>

  <table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>
	<input type="hidden" name="curr_stud_id" value="<%=WI.fillTextValue("stud_id")%>">

<input type="hidden" name="row_start_fr">
<input type="hidden" name="row_count">
<input type="hidden" name="last_page">

<input type="hidden" name="add_record">
<input type="hidden" name="print_pg">

<input type="hidden" name="page_number">
<input type="hidden" name="total_page" value="<%=iPageCount%>">
<input type="hidden" name="max_page_to_disp">
<input type="hidden" name="print_">

	<input type="hidden" name="print_value_csv" value="<%=strPrintValueCSV%>">
	<input type="hidden" name="print_all_pages" value="">

<%if(vStudInfo != null && vStudInfo.elementAt(12) != null) {%>
	<input type="hidden" name="stud_ref" value="<%=(String)vStudInfo.elementAt(12)%>">
<%}%>
<%if(bolNewStudentID) {%>
	<input type="hidden" name="tf_sel_list" value="">
<%}else{%>
	<input type="hidden" name="tf_sel_list" value="<%=WI.fillTextValue("tf_sel_list")%>">
<%}%>	

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
