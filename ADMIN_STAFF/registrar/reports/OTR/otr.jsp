<%
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	//strSchCode = "WNU_BOHOL";
	if(strSchCode == null) {%>
		<p style="font-size:14px; color:#FF0000; font-family:Verdana, Arial, Helvetica, sans-serif;"> Failed to proceed. You are already logged out. Please login again.</p>

<%return;}%> 
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	boolean bolIsEACCOG = (WI.fillTextValue("is_eac_cog").length() > 0);
	boolean bolIsSWUGPA = (WI.fillTextValue("is_swu_gpa").length() > 0);
	
	if(bolIsSWUGPA)
		bolIsEACCOG = true;
		
	String strDegreeType = null;
	java.sql.ResultSet rs  = null;
	String strImgFileExt = null;
	String strRootPath  = null;
	
	boolean bolIsVMA = strSchCode.startsWith("VMA");
	
	///if AUF, convert it to UI.
	//strSchCode = "WNU_BACALOD";
	//strSchCode = "VMUF_CB";
	String strOTRExtn = null;
	if(strSchCode != null) 
		strOTRExtn = strSchCode.substring(0,strSchCode.indexOf("_"));
if(strOTRExtn != null) {//System.out.println(strOTRExtn);
	if(strSchCode.startsWith("UPH")){
		strTemp = (String)request.getSession(false).getAttribute("info5");//dbOP.getResultOfAQuery("select info5 from sys_info", 0);
		if(strTemp != null && strTemp.equals("jonelta"))
			strOTRExtn = "UPHS";
		else	
			strOTRExtn = "UPHSD";	
	}

	if (WI.fillTextValue("honor_point").length() > 0) 
		strOTRExtn = "otr_print_"+strOTRExtn+"_honor.jsp";
	else {
		strOTRExtn = "otr_print_"+strOTRExtn+".jsp";
		if(WI.fillTextValue("print_old").length() == 0 && strSchCode.startsWith("CGH"))
			strOTRExtn = "otr_print_CGH_new.jsp";
	}
	
	if (WI.fillTextValue("show_spr").equals("1"))
		strOTRExtn = "otr_print_"+strSchCode.substring(0,strSchCode.indexOf("_"))+"_spr.jsp";
	if (WI.fillTextValue("is_eac_cog").length() > 0)
		strOTRExtn = "certificate_of_grade_EAC.jsp";	
	if (WI.fillTextValue("is_swu_gpa").length() > 0)
		strOTRExtn = "otr_print_SWU_gpa.jsp";	
		
if(request.getParameter("print_pg") != null 
		&& request.getParameter("print_pg").compareTo("1") ==0){
		//System.out.println("strOTRExtn "+strOTRExtn);
		//strOTRExtn = "otr_print_UL.jsp";
		%>
	<jsp:forward page="<%=strOTRExtn%>"/>
<%return;}
}


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-REPORTS-OTR - form 9","otr.jsp");
		if(request.getSession(false).getAttribute("info5") == null) {
			strTemp = (String)request.getSession(false).getAttribute("info5");
			if(strTemp == null)
				strTemp = "";
			request.getSession(false).setAttribute("info5", strTemp);
		}
		
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");
		strRootPath = readPropFile.getImageFileExtn("installDir");
		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
		
		if(strRootPath == null || strRootPath.trim().length() ==0)
		{
			strErrMsg = "Installation directory path is not set.  " +
						 " Please check the property file for installDir KEY.";
			dbOP.cleanUP();
			throw new Exception();
		}
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
														"otr.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

Vector vStudInfo = null; String strUserIndex = null;//student index.
Vector vAdditionalInfo = null;
Vector vEntranceData = null;
Vector vGraduationData = null;
Vector vRetResult  = null;
Vector vApprenticeInfo  = new Vector();
int iIndexOf = 0;
Vector vCompliedRequirement  = null;
Vector vCourseHist = null;
int iPageCount = 0;
int iTemp = 0;
boolean bolNewStudentID  = !WI.fillTextValue("curr_stud_id").equals(WI.fillTextValue("stud_id"));
boolean bolAllowOTRPrinting = true;
String strPrintErrMsg = null;
String strCourseIndex = null;

String strEntranceDataOtherUC = null;


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
//System.out.println(strExtraCon);
String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};

String strEntranceStatus = "New";

enrollment.ReportRegistrar repRegistrar  = new enrollment.ReportRegistrar();
if(strSchCode.startsWith("DBTC") || strSchCode.startsWith("PIT")) 
	repRegistrar.strTFList="0";


enrollment.OfflineAdmission offlineAdm = new enrollment.OfflineAdmission();
enrollment.EntranceNGraduationData entranceGradData = new enrollment.EntranceNGraduationData();
enrollment.CourseRequirement cRequirement = new enrollment.CourseRequirement();
enrollment.GradeSystemExtn GSExtn = new enrollment.GradeSystemExtn();

//enrollment.ReportRegistrarExtn RPExtn = new enrollment.ReportRegistrarExtn();

Vector vTORLineNumber = null;//pre-set line number for a user if already printed before.

/////////// 

if(!bolNewStudentID && !WI.fillTextValue("tf_sel_list").equals("-1")) {
	if(WI.fillTextValue("tf_sel_list").length() == 0) 
		repRegistrar.strTFList = "0";
	else	
		repRegistrar.strTFList = WI.fillTextValue("tf_sel_list");
	
}
//if(strSchCode.startsWith("PIT"))
	//repRegistrar.strTFList = "0";
	
//System.out.println(repRegistrar.strTFList);

double dOutStandingBalance = 0d;

if(WI.fillTextValue("stud_id").length() > 0) {
	vStudInfo = offlineAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"));
	//System.out.println("vStudInfo "+vStudInfo);
	if(vStudInfo == null || vStudInfo.size() ==0)
		strErrMsg = offlineAdm.getErrMsg();
	else {
		strUserIndex = (String)vStudInfo.elementAt(12);
		
		/*if(false && strSchCode.startsWith("UB")){
			bolAllowOTRPrinting = RPExtn.isAllowOTRPrinting(dbOP, request, strUserIndex, false);
			if(!bolAllowOTRPrinting){
				strPrintErrMsg = RPExtn.getErrMsg();
				if(strPrintErrMsg == null)
					strPrintErrMsg = "Student OTR is not open for printing.";
			}
		}*/
		
		student.StudentInfo studInfo = new student.StudentInfo();
		vAdditionalInfo = studInfo.getStudInfoOTRCanForGradForm17(dbOP,strUserIndex);
		//System.out.println("vAdditionalInfo "+vAdditionalInfo);
		if( (vAdditionalInfo == null || vAdditionalInfo.size() ==0)  && !strSchCode.startsWith("SPC")) 
			strErrMsg = studInfo.getErrMsg();
			
		if(strSchCode.startsWith("SPC") && vAdditionalInfo == null)
			vAdditionalInfo = new Vector();
			
			
		if (strSchCode.startsWith("FATIMA")|| strSchCode.startsWith("UI") || strSchCode.startsWith("AUF") || strSchCode.startsWith("WNU") || strSchCode.startsWith("DBTC") || 
			strSchCode.startsWith("VMUF")  || strSchCode.startsWith("EAC") || true) {
			vCourseHist = GSExtn.retrieveCourseHistory(dbOP, request.getParameter("stud_id"));
			//System.out.println("vCourseHist "+vCourseHist);
			if (vCourseHist == null)
				strErrMsg = GSExtn.getErrMsg();
		}
	}	
}

//check field TOR_PMT_REQUIRED if set to 1, then balance must be 0
boolean bolBlockPrinting = false;
if(strSchCode.startsWith("FATIMA")) {
	if(strUserIndex != null) {
		enrollment.FAFeeOperation fOperation = new enrollment.FAFeeOperation();
		dOutStandingBalance= fOperation.calOutStandingOfPrevYearSem(dbOP, strUserIndex, true, true);
	}
}
else if(strUserIndex != null){
	String strSQLQuery = "select prop_val from read_Property_file where proP_name = 'TOR_PMT_REQUIRED'";
	strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
	if(WI.getStrValue(strSQLQuery).equals("1")) {
		//may be unhold already.. get current sy-term.. 
		//if printed, can't print/process anymore, even though the exception date is still valid.
		strSQLQuery = "select EXCEPTION_INDEX,is_locked from OTR_PRINT_EXCEPTION where is_valid = 1 and valid_until >='"+WI.getTodaysDate()+"' and PRINTED_BY_ is null and user_index = "+strUserIndex;
		rs = dbOP.executeQuery(strSQLQuery);
		String strExceptionIndex = null;
		if(rs.next()) {
			strExceptionIndex = rs.getString(1);
			if(rs.getInt(2) == 0)
				strSQLQuery = "update OTR_PRINT_EXCEPTION set is_locked = 1 where exception_index = "+strExceptionIndex;
			else	
				strSQLQuery = null;
		}
		rs.close();
		if(strExceptionIndex != null) {
			if(strSQLQuery != null)
				dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
		}
		if(strExceptionIndex == null) {
			enrollment.FAFeeOperation fOperation = new enrollment.FAFeeOperation();
			dOutStandingBalance= fOperation.calOutStandingOfPrevYearSem(dbOP, strUserIndex, true, true);
			if(dOutStandingBalance > 1d) 
				bolBlockPrinting = true;
			//System.out.println(dOutStandingBalance);
		}
		
	} 

}

/** save here tor encoded information.. **/
if(WI.fillTextValue("add_record").equals("1")){
	if(repRegistrar.operateOnForm17Form18EncodedInfo(dbOP, request,1,true) == null)  
		strErrMsg = repRegistrar.getErrMsg();
	if(!entranceGradData.updateOTREncodedInfo(dbOP, request, strUserIndex))
		strErrMsg = entranceGradData.getErrMsg();
}	
else if(WI.fillTextValue("add_record").equals("2")) {
	//update entrance data.
	strTemp = WI.fillTextValue("entrance_data");
	if(strTemp.length() > 0) {
		strTemp = "select stud_index from entrance_data where stud_index = "+strUserIndex;
		strTemp = dbOP.getResultOfAQuery(strTemp, 0);
		if(strTemp == null) {//insert
			strTemp = "insert into entrance_data (stud_index, entrance_data_1, doc_type, elem_sch_index, encoded_by, create_date) values ("+strUserIndex+", "+
						WI.getInsertValueForDB(WI.fillTextValue("entrance_data"), true, null)+", 0,0, "+(String)request.getSession(false).getAttribute("userIndex")+",'"+WI.getTodaysDate()+"')";
		}else{
			strTemp = "update entrance_data set entrance_data_1 = "+WI.getInsertValueForDB(WI.fillTextValue("entrance_data"), true, null) +
						" where stud_index = "+strUserIndex;
		}
		//System.out.println(strTemp);
		dbOP.executeUpdateWithTrans(strTemp, null, null, false);
	}

}





//request.getSession(false).setAttribute("other_requirement",null);

//System.out.println("I am here.");
if(vStudInfo != null && vStudInfo.size() > 0) {
	vEntranceData = entranceGradData.operateOnEntranceData(dbOP,request,4);
	//System.out.println("vEntranceData "+vEntranceData);
	vGraduationData = entranceGradData.operateOnGraduationData(dbOP,request,4);
	//System.out.println("vGraduationData "+vGraduationData);
	//allow even nothing is entered.
	if((vEntranceData == null || vGraduationData == null) && (strErrMsg ==null) && !bolIsEACCOG && !strSchCode.startsWith("SPC"))
		strErrMsg = entranceGradData.getErrMsg();
		
	if(strSchCode.startsWith("SPC")){
		if(vEntranceData == null)
			vEntranceData = new Vector();
		if(vGraduationData == null)
			vGraduationData = new Vector();
	}

	//System.out.println("request.getParameter('stud_id') "+request.getParameter("stud_id"));
	//System.out.println("(String)vStudInfo.elementAt(7)"+(String)vStudInfo.elementAt(7));
	//System.out.println("(String)vStudInfo.elementAt(8)"+(String)vStudInfo.elementAt(8));
	
	Vector vFirstEnrl = cRequirement.getFirstEnrollment(dbOP,request.getParameter("stud_id"),
														WI.getStrValue((String)vStudInfo.elementAt(7)),
														(String)vStudInfo.elementAt(8));
	//System.out.println("vFirstEnrl "+vFirstEnrl);
		if (vFirstEnrl != null) {
			if(strSchCode.startsWith("UC"))
				vRetResult = cRequirement.getStudentPendingCompliedList(dbOP,(String)vStudInfo.elementAt(12),
											(String)vFirstEnrl.elementAt(0),(String)vFirstEnrl.elementAt(1),
											(String)vFirstEnrl.elementAt(2),false,false,true,false);
			else
				vRetResult = cRequirement.getStudentPendingCompliedList(dbOP,(String)vStudInfo.elementAt(12),
											(String)vFirstEnrl.elementAt(0),(String)vFirstEnrl.elementAt(1),
											(String)vFirstEnrl.elementAt(2),false,false,true,true);
										
			if(vRetResult == null) {
				if(strErrMsg == null)
					strErrMsg = cRequirement.getErrMsg();
			}
			else
				vCompliedRequirement = (Vector)vRetResult.elementAt(1); 
				
			
			strEntranceStatus = (String)vFirstEnrl.elementAt(3);
			
			//I have to get any other requirement submitted. 
			String strSQLQuery = "select req_sub_index,requirement from NA_REQ_SUBMITTED "+
          							"join NA_ADMISSION_REQ on (NA_ADMISSION_REQ.req_index = na_req_submitted.req_index) "+
          							"where NA_REQ_SUBMITTED.is_del = 0 and NA_REQ_SUBMITTED.is_valid = 1 and stud_index = "+
          							strUserIndex+" and is_temp_stud = 0 and NA_REQ_SUBMITTED.sy_from = "+
          							vFirstEnrl.elementAt(0)+" and NA_REQ_SUBMITTED.is_other_data_uc = 1 and NA_REQ_SUBMITTED.semester = "+vFirstEnrl.elementAt(2); 
			rs = dbOP.executeQuery(strSQLQuery);
			strSQLQuery = null; iIndexOf = 0;
			if(vCompliedRequirement == null) vCompliedRequirement = new Vector();
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
			//System.out.println(strEntranceDataOtherUC);
			//request.getSession(false).setAttribute("other_requirement",strSQLQuery);
			
	  }else{
	   strErrMsg = cRequirement.getErrMsg();	
	   //System.out.println("strErrMsg "+strErrMsg);
	   }
		
}
///check if student is on hold. 
boolean bolIsStudOnHold = false;
if(vStudInfo != null && vStudInfo.size() > 0) {
	strTemp = new enrollment.SetParameter().bolStudentIsOnHold(dbOP, strUserIndex); 
	if(strTemp != null) {
		bolIsStudOnHold = true;
		strErrMsg = "<font style='color:red;font-size:18px;font-weight:bold'>"+strTemp+"</font>";
	}

}
if(bolBlockPrinting)
	bolIsStudOnHold = bolBlockPrinting;



//save encoded information if save is clicked. 
Vector vForm17Info = null;
vForm17Info = repRegistrar.operateOnForm17Form18EncodedInfo(dbOP, request,2,true);
//System.out.println("vForm17Info "+vForm17Info);
if(vForm17Info != null && vForm17Info.size() ==0)
	vForm17Info = null;
String[] astrConvertToDocType = {"Form 137-A","Transcript of Record","C.E.A No."};
if(strSchCode.startsWith("SPC"))
	astrConvertToDocType[0] = "Form 138";

if(vStudInfo != null) {//get the grad detail. 
	strDegreeType = (String)vStudInfo.elementAt(15);
	
	//I have to find correct degree type here if courses are selected.. 
	if(vCourseSelected.size() > 0) {
		strTemp = "select degree_type from course_offered where course_index in ("+CommonUtil.convertVectorToCSV(vCourseSelected)+")";//System.out.println();
		rs = dbOP.executeQuery(strTemp);
		while(rs.next()) {
			strTemp = rs.getString(1);
			if(strTemp.equals("1")) {
				strDegreeType = "1";
				break;
			}
			if(strTemp.equals("2")) {
				strDegreeType = "2";
				break;
			}
			strDegreeType = "0";//problem if course type is prep. type.. it doubles..  updated on March 20, 2013
			
			//strDegreeType = strTemp;
		}
		strTemp = "select course_index from stud_curriculum_hist "+
			" join semester_sequence ON (semester_val = semester)"+
			//" Join course_offered on (course_offered.course_index = stud_curriculum_hist.course_index) "+
			" where user_index = "+strUserIndex+
			" and stud_curriculum_hist.is_valid = 1 and stud_curriculum_hist.course_index in ("+
			CommonUtil.convertVectorToCSV(vCourseSelected)+") order by sy_from desc, sem_order desc";
		rs = dbOP.executeQuery(strTemp);
		if(rs.next())
			strCourseIndex = rs.getString(1);
			
		rs.close();		
	}
	else
		strCourseIndex = (String)vStudInfo.elementAt(5);
		
	if(!bolIsStudOnHold){
		//System.out.println(strExtraCon);
		
		///apply condition here to remove the credit subject.
		repRegistrar.setGetCreditSubject(0);
		
		vRetResult = repRegistrar.getOTROfCanForGrad(dbOP, WI.fillTextValue("stud_id"), strDegreeType,false,strExtraCon);
		//System.out.println("vRetResult "+vRetResult);
		if(vRetResult == null) 
			strErrMsg = repRegistrar.getErrMsg();
		else {//remove the credited subject to be shown.
		
			enrollment.ReportRegistrarExtn rprtReg = new enrollment.ReportRegistrarExtn();
			vApprenticeInfo = null;//rprtReg.operateOnApprenticeInfoWNU(dbOP, request, 4, (String)vStudInfo.elementAt(12), true);
			if(vApprenticeInfo == null)
				vApprenticeInfo = new Vector();
		
			if(strSchCode.startsWith("CGH")) {
				for(int i = 0; i < vRetResult.size(); i += 11) {
					if(vRetResult.elementAt(i + 1) != null)
						break;
					vRetResult.remove(i);vRetResult.remove(i);vRetResult.remove(i);vRetResult.remove(i);
					vRetResult.remove(i);vRetResult.remove(i);vRetResult.remove(i);vRetResult.remove(i);
					vRetResult.remove(i);vRetResult.remove(i);vRetResult.remove(i);
					i -= 11;
				}
			}	
			Vector vExcludeList = null;//repRegistrar.operateOnExcludedSubjectTOR(dbOP, request, 4);
			if(vExcludeList == null)
				vExcludeList = new Vector();

			for(int i = 0 ; i < vRetResult.size(); i += 11){
				if(vRetResult.elementAt(i + 6) != null && vExcludeList.indexOf(vRetResult.elementAt(i + 6)) > -1) {
					vRetResult.remove(i);	vRetResult.remove(i);	vRetResult.remove(i);	vRetResult.remove(i);
					vRetResult.remove(i);	vRetResult.remove(i);	vRetResult.remove(i);	vRetResult.remove(i);
					vRetResult.remove(i);	vRetResult.remove(i);	vRetResult.remove(i);
					
					i = i - 11;		
				}
			}

			
			
					
		}
	}
}

if (!entranceGradData.updateGraduationData(dbOP)){
	strErrMsg = entranceGradData.getErrMsg();
}

//System.out.println(strExtraCon);



String strPrintValueCSV = "";//this stores all print values passed in javascript PrintPg method call.. csv values are
//row_start_fr,row_count,row_count,last_page,page_number,max_page_to_disp,
%>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Transcript of Record</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">

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
<script language="javascript" src ="../../../../Ajax/ajax.js" ></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
function UploadFile()
{
	if(document.form_.stud_id.value.length == 0){
		alert("Please provide student id.");
		return;
	}
	
	var sT = "./upload_id_step2.jsp?stud_id="+escape(document.form_.stud_id.value)+
		"&img_ext="+escape(document.form_.img_ext.value)+		
		"&hr_emp=/otr";
	var win=window.open(sT,"UploadFile",'dependent=yes,width=700,height=200,top=200,left=100,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
	
}
function ManageExcludeList() {
	location = "./exclude_subject_tor.jsp";
}
function HideLayer(strDiv) {			
	document.getElementById(strDiv).style.visibility = 'hidden';
	document.form_.show_excluded_sub.checked = false;
}
function UpdateEntranceData() {
	if(document.form_.stud_id.value.length ==0) {
		alert("Please enter Student ID.");
		return;
	}
	var pgLoc = "../../entrance_data/entrance_data.jsp?stud_id="+document.form_.stud_id.value+
		"&parent_wnd=form_&new_id_entered="+document.form_.stud_id.value;
	var win=window.open(pgLoc,"EditWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function UpdateGraduationData() {
	if(document.form_.stud_id.value.length ==0) {
		alert("Please enter Student ID.");
		return;
	}
	var pgLoc = "../../entrance_data/graduation_data.jsp?stud_id="+document.form_.stud_id.value+
		"&parent_wnd=form_";
	var win=window.open(pgLoc,"EditWindow",'width=950,height=700,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function UpdateAdditionalInfo() {
	if(document.form_.stud_id.value.length ==0) {
		alert("Please enter Student ID.");
		return;
	}
	var pgLoc = "../../../admission/stud_personal_info_page2.jsp?stud_id="+document.form_.stud_id.value+
		"&parent_wnd=form_";
	var win=window.open(pgLoc,"EditWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function FocusID() {
	document.form_.stud_id.focus();
}
function OpenSearch() {
	var pgLoc = "../../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function RemovePrintPg() {
	document.form_.add_record.value = "";
	document.form_.print_pg.value = "";
	
	this.getTFSelected();	
	document.form_.submit();
}

function PrintAllPages(strPrintValue) {
//used in EAC COG
	var strPrintPerSY = "";
	var strPrintPerSYSem = "";	
	if(document.form_.print_per_school_year_from){
		strPrintPerSY = document.form_.print_per_school_year_from.value;//used in EAC COG
		strPrintPerSYSem = document.form_.print_per_school_year_semester.value;//used in EAC COG
	}	
	if(strPrintPerSY.length > 0 && strPrintPerSY.length != 4){
		alert("Invalid School Year format. Please try again.");
		return;
	}	
	if(strPrintPerSYSem.length > 0 && ( strPrintPerSY.length == 0 || (strPrintPerSY.length > 0 && strPrintPerSY.length != 4) ) ){
		alert("Please provide school year.");
		return;
	}
//end of EAC COG

	//ensure safe reload of page and call Printing of TOR.. 
	document.form_.add_record.value = "";
	document.form_.print_pg.value = "1";
	document.form_.print_.value = strPrintValue;
	
	this.getTFSelected();
	document.form_.print_all_pages.value='1';
	document.form_.submit();
}

function PrintPg(strRowStartFr,strRowCount,strLastPage, strPrintStatus,strPageNumber,strMaxRowsToDisp) {
	document.form_.print_all_pages.value='';
	document.form_.add_record.value = "";

	document.form_.print_pg.value = "1";
	
	document.form_.row_start_fr.value = strRowStartFr;
	document.form_.row_count.value = strRowCount;
	document.form_.last_page.value = strLastPage;
	
	document.form_.print_.value = strPrintStatus;
	document.form_.page_number.value = strPageNumber;
		
	document.form_.max_page_to_disp.value = strMaxRowsToDisp;	
	
	this.getTFSelected();
	document.form_.submit();
}
function AddRecord(strAddVal) {
	document.form_.add_record.value = strAddVal;
	document.form_.print_pg.value = "";
	document.form_.hide_save.src = "../../../../images/blank.gif";

	this.SubmitOnce("form_");
}
function ShowAddlColumn(iIndex) {

	if(iIndex == 1) {
		if(document.form_.show_rle.checked) 
			document.form_.show_leclab.checked = false;
	}else {
		if(document.form_.show_leclab.checked) 
			document.form_.show_rle.checked = false;	
	}
	
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
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
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

//Ajax Operation here. for wnu - updating end of tor remark.. 
function updateEndOfTORRemark(objField, fieldNo) {
	this.InitXmlHttpObject(objField, 1);//I want to get value in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=206&stud_index="+document.form_.stud_i.value+
	"&endof_tor_remark="+encodeURIComponent(objField.value);
	if(fieldNo == '-1')
		strURL += "&filed=CAREGIVER_DURATION";
	else if(fieldNo == '1')
		strURL += "&filed=END_OF_TOR_REMARK";
	else if(fieldNo == '3')
		strURL += "&filed=TOR_ADD_TRAINING";
	else	
		strURL += "&filed=END_OF_TOR_REMARK2";
	//alert(strURL);
	//return;
	this.processRequest(strURL);
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
}
function ReloadNeeded() {
	var obj = document.getElementById("reload_page_tf");
	if(!obj)
		return;
	if(obj.innerHTML == '')
		obj.innerHTML = "Please click Refresh if you make any change.";

}

function ajaxUpdateRow(strRowNo, objRow) {

		var strRowVal = objRow.value;
		if(strRowVal.length == 0)
			return;
		
		//alert(strRowVal);
		//alert(strRowNo);
		

		this.InitXmlHttpObject(objRow, 1);//I want to get value in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=214&stud_ref="+
			document.form_.stud_i.value+"&row_no="+strRowNo+
			"&row_val="+objRow.value+"&is_tor=1";
			
		this.processRequest(strURL);

}
/*** this ajax is called for required downpayment update **/
function ajaxUpdate(objField, strRef) {
	//if there is no change, just return here..
	var strNewVal = ""; 
	if(strRef == '3' || strRef == '4') {
		if(objField.checked)
			strNewVal = '1';
	}
	else
		strNewVal = objField.value;

	var strParam = "new_val="+escape(strNewVal)+"&field_ref="+strRef+"&stud_ref=<%=strUserIndex%>";
	var objCOAInput = document.getElementById("coa_info"+strRef);
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get value in this.retObj
  	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=120&"+strParam;
	
	this.processRequest(strURL);
}
function UpdateRecogNo(){
	var pgLoc = "./otr_gr_no.jsp?course_index="+<%=strCourseIndex%>;
	var win=window.open(pgLoc,"UpdateRecogNo",'width=800,height=400,top=0,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function EncodeNumberOfDaysMPC() {
	var pgLoc = "./school_days_present_mpc.jsp?stud_id="+document.form_.stud_id.value;
	var win=window.open(pgLoc,"UpdateRecogNo",'width=800,height=400,top=0,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function EncodeApprentice() {
	var pgLoc = "./encode_apprentice_info.jsp?stud_id="+document.form_.stud_id.value;
	var win=window.open(pgLoc,"UpdateRecogNo",'width=800,height=400,top=0,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function AllowOTRPrinting(){
	var pgLoc = "./allow_otr_printing.jsp?stud_id="+document.form_.stud_id.value;
	var win=window.open(pgLoc,"UpdateRecogNo",'width=800,height=400,top=0,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

</script>

<body bgcolor="#D2AE72" onLoad="FocusID();">
<form action="./otr.jsp" method="post" name="form_">
<%if(strSchCode.startsWith("EAC") || strSchCode.startsWith("CDD") || strSchCode.startsWith("UL")){%>
	<!-- show subjects excluded in TOR -->
	<div id="processing2" class="processing">
	<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% class="thinborderALL" bgcolor="#9999CC" valign="top">
		<tr>
			<td valign="top" align="right" style="color:#FF0000"><a href="javascript:HideLayer('processing2')"><font style="color:#FFFF00; font-weight:bold">Close Window X</font></a></td></tr>	
	<%
	Vector vListExcluded = repRegistrar.operateOnExcludedSubjectTOR(dbOP, request, 4);
	if(vListExcluded == null || vListExcluded.size() == 0){%>
		<tr valign="top">
			<td><strong>TOR subject exclude list is empty.</strong></td>
		</tr>
	<%
	}  	  
	if(vListExcluded != null && vListExcluded.size() > 0){
	%>
	  <tr>
		<td valign="top" align="center"><b>LIST OF EXCLUDED SUBJECT</b></td>
	  </tr>
	  <tr>
		  <td valign="top">
			<table width="100%" cellpadding="0" cellspacing="0" border="0" class="thinborder">
				<tr bgcolor="#CCCCCC" style="font-weight:bold">
					<td class="thinborder" height="22" width="30%">Subj Code</td>
					<td class="thinborder">Subject Name </td>
				</tr>
				<%
				for(int i = 0; i < vListExcluded.size(); i += 3){			
				%>
				<tr>
					<td class="thinborder" height="22" width="30%"><%=vListExcluded.elementAt(i+1)%></td>
					<td class="thinborder"><%=vListExcluded.elementAt(i+2)%></td>
				</tr>
				<%}%>
			</table>
		  </td>
	  </tr>
	<%}%>
	<tr><td colspan="2" height="25" align="right">
		<input type="button" name="add" value="Manage Exclude List" onClick="javascript:ManageExcludeList();"
			style="font-size:11px; height:20px;border: 1px solid #FF0000;" /></td>
	</tr>
	</table>
	</div>
<%}//show only for EAC%>


  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
	<%
	if(WI.fillTextValue("is_eac_cog").length() > 0)
		strTemp = "CERTIFICATE OF GRADES PAGE";
	else if(WI.fillTextValue("is_swu_gpa").length() > 0)
		strTemp = "GRADES POINT AVERAGE PAGE";
	else if(WI.fillTextValue("honor_point").compareTo("1") == 0 )
		strTemp = "HONOR STUDENT PAGE";
	else
		strTemp = "OFFICIAL TRANSCRIPT OF RECORD";
	%>
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: <%=strTemp%> ::::</strong></font></div></td>
    </tr>
  </table>
<%
if(WI.getStrValue(strErrMsg).length() == 0 && WI.getStrValue(strPrintErrMsg).length() > 0)
	strErrMsg = strPrintErrMsg;
%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="5">&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
<%
if(strUserIndex != null)
	strTemp = new utility.MessageSystem().getSystemMsg(dbOP, strUserIndex, 10);
else	
	strTemp = null;
if(strTemp != null){%>
    <tr>
      <td height="25" colspan="5">
	  <table width="100%" cellpadding="0" cellspacing="0">
		<tr>
		  <td width="2%" height="25">&nbsp;</td>
		  <td width="96%" style="font-size:15px; color:#FFFF00; background-color:#7777aa" class="thinborderALL"><%=strTemp%></td>
		  <td width="2%">&nbsp;</td>
		</tr>
	  </table>	  </td>
    </tr>
<%}%>
    <tr valign="top">
      <td height="25">&nbsp;</td>
      <td colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;
	  <%if(dOutStandingBalance > 1d) {
		  	if(strSchCode.startsWith("WNU"))
  				strTemp = "Advisory: Please Settle Accounts in Finance Office";
			else	
			  strTemp = CommonUtil.formatFloat(dOutStandingBalance,true);
		%>
	  	<font size="4" color="red"><strong>OLD ACCOUNT : <%=strTemp%></strong></font>
	  <%}%>	  </td>
    </tr>
<%if(strSchCode.startsWith("MARINER")) {%>
    <tr valign="top">
      <td height="25">&nbsp;</td>
      <td colspan="3"><a href="javascript:EncodeNumberOfDaysMPC();">Encode Number Days Present per SY-Term</a></td>
      <td>&nbsp;</td>
    </tr>
<%}%>

<%if(strSchCode.startsWith("WNU")) {%>
    <tr valign="top">
      <td height="25">&nbsp;</td>
      <td colspan="3"><a href="javascript:EncodeApprentice();">Encode Apprentice Information</a></td>
      <td>&nbsp;</td>
    </tr>
<%}%>

    <tr valign="top"> 
      <td width="5%" height="25">&nbsp;</td>
      <td width="12%">Student ID </td>
      <td width="23%"><input name="stud_id" type="text" class="textbox"  
	  	onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		value="<%=WI.fillTextValue("stud_id")%>" onKeyUp="AjaxMapName('1');"></td>
      <td width="9%"><a href="javascript:RemovePrintPg();"><img src="../../../../images/form_proceed.gif" border="0"></a><a href="javascript:OpenSearch();"></a></td>
      <td width="51%"><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label></td>
    </tr>
<%if(strSchCode.startsWith("CGH")) {%>
    <tr valign="top">
      <td height="25">&nbsp;</td>
      <td colspan="3">
	  <input type="checkbox" name="print_old" value="checked" <%=WI.fillTextValue("print_old")%>> Print OLD Format	  </td>
      <td>&nbsp;</td>
    </tr>
<%}if(strSchCode.startsWith("WNU") && vEntranceData != null && vEntranceData.size() > 0) {%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="4" style="font-size:11px; font-weight:bold; color:#0000FF">
<%
strTemp  = (String)vEntranceData.elementAt(30);
if(strTemp != null && strTemp.equals("1"))
	strTemp = " checked";
else	
	strTemp = "";
%>
	  <input type="checkbox" name="remove_nstp_opt" value="1" <%=strTemp%> onChange="ajaxUpdate(document.form_.remove_nstp_opt, '3');"> Remove ROTC/LTS/CWTS
	  <label id="coa_info3" style="font-size:9px; font-weight:bold; color:#FF0000"></label>
	  
<%
strTemp  = (String)vEntranceData.elementAt(31);
if(strTemp != null && strTemp.equals("1"))
	strTemp = " checked";
else	
	strTemp = "";
%>
	  <input type="checkbox" name="remove_major_tor" value="1" <%=strTemp%> onChange="ajaxUpdate(document.form_.remove_major_tor, '4');"> Remove Major
	  <label id="coa_info4" style="font-size:9px; font-weight:bold; color:#FF0000"></label>	  </td>
    </tr>
<%}%>
<%if(strSchCode.startsWith("CSA") && vEntranceData != null && vEntranceData.size() > 0) {%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="4" style="font-size:11px; font-weight:bold; color:#0000FF">
<%
strTemp  = (String)vEntranceData.elementAt(30);
if(strTemp != null && strTemp.equals("1"))
	strTemp = " checked";
else	
	strTemp = "";
%>
	  <input type="checkbox" name="remove_nstp_opt" value="1" <%=strTemp%> onChange="ajaxUpdate(document.form_.remove_nstp_opt, '3');"> Remove ROTC/LTS/CWTS
	  <label id="coa_info3" style="font-size:9px; font-weight:bold; color:#FF0000"></label>	  </td>
    </tr>
<%}%>
<%if(strSchCode.startsWith("UC")) {%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="4" style="font-size:11px; font-weight:bold; color:#0000FF">
	  <input type="checkbox" name="show_parenthesis" value="checked" <%=WI.fillTextValue("show_parenthesis")%> > Show Parenthesis	  </td>
    </tr>
<%}%>
<%if(strSchCode.startsWith("AUF") || strSchCode.startsWith("MARINER")) {%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="4"><input name="show_spr" type="checkbox" id="show_spr" value="1">
        Show only Student Permanent Record</td>
    </tr>
<%}%>
<%if(strSchCode.startsWith("CDD")) {%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="4"><input name="show_pic" type="checkbox" value="checked" <%=WI.fillTextValue("show_pic")%>> Show picture of student
		&nbsp;&nbsp;&nbsp;&nbsp;
		<input type="checkbox" name="remove_major_tor" value="checked" <%=WI.fillTextValue("remove_major_tor")%>> Remove Major
		
		&nbsp;&nbsp;&nbsp;&nbsp;
		Entrance Status: <input type="textbox" name="entrance_stat" value="<%=WI.getStrValue(strEntranceStatus).toUpperCase()%>">		</td>
    </tr>
<%}%>
<%if(strSchCode.startsWith("UC")) {%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="4"><input name="show_pic" type="checkbox" value="checked" <%=WI.fillTextValue("show_pic")%>> Show picture of student</td>
    </tr>
<%
if(vForm17Info != null)
	strTemp = (String)vForm17Info.elementAt(6);
else	
	strTemp = WI.fillTextValue("accounting_division");
%>
<tr> 
      <td height="25">&nbsp;</td>
      <td colspan="4">Append to Name(Awards/Others): <input type="textbox" name="accounting_division" value="<%=WI.getStrValue(strTemp)%>" size="64"></td>
    </tr>
<%}%>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="100%" height="25" colspan="5"><hr size="1"></td>
    </tr>
  </table>
<% if(vStudInfo != null && vStudInfo.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="7%" height="25">&nbsp;</td>
      <td colspan="3">Name : <strong><%=((String)vStudInfo.elementAt(2)).toUpperCase()%>,<%=((String)vStudInfo.elementAt(0)).toUpperCase()%> <%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%></strong></td>
      <td width="28%" rowspan="7" valign="top">
	  <%
		strTemp = WI.fillTextValue("stud_id").toUpperCase();		
		if (strTemp.length() > 0) {
			strErrMsg = strRootPath+"upload_img/otr/"+strTemp+"."+strImgFileExt;
			java.io.File file = new java.io.File(strErrMsg);
			strErrMsg = "../../../../upload_img/otr/"+strTemp+"."+strImgFileExt;
			if(!file.exists()){
				strErrMsg = strRootPath+"upload_img/"+strTemp+"."+strImgFileExt;
				file = new java.io.File(strErrMsg);
				strErrMsg = "../../../../upload_img/"+strTemp+"."+strImgFileExt;
			}
			
			if(file.exists()) {
				//strTemp = "../../../../upload_img/"+strTemp+"."+strImgFileExt;
				strTemp = "<img src=\""+strErrMsg+"\" width='150' name='stud_image' height='150'>";
			}
			else {
				strTemp = "<img src='../../../../images/blank.gif' name='stud_image' width='150' height='150' border='1'>";
			}
		}
%>

	 <%if(bolIsVMA){%><%=strTemp%><%}%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3">Address :
<% 

	strTemp = WI.fillTextValue("address");
	if (bolNewStudentID)
		strTemp = ""; // reset because it will still prev student data
	
	if (strTemp.length() == 0 && vAdditionalInfo != null && vAdditionalInfo.size() > 0){
		strTemp = WI.getStrValue((String)vAdditionalInfo.elementAt(3)) +
				WI.getStrValue((String)vAdditionalInfo.elementAt(4),", ","","") + 
				WI.getStrValue((String)vAdditionalInfo.elementAt(5),", ","",""); 
				//WI.getStrValue((String)vAdditionalInfo.elementAt(7),"-","","") + 
				//WI.getStrValue((String)vAdditionalInfo.elementAt(6),", ","","");
	}
			
%>	  	  
      <input name="address" type="text" class="textbox" value="<%=strTemp%>" size="48"></td>	  
    </tr>
<% if (strSchCode.startsWith("UDMC")) {

	strTemp = WI.fillTextValue("address2");
	if (bolNewStudentID)
		strTemp = ""; // reset because it will still prev student data
%> 
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3">Address	:  
		<input name="address2" type="text" class="textbox" size="48" 
							value="<%=strTemp%>"></td>
    </tr>
<%}
if(!bolIsEACCOG){
%> 
    <tr> 
      <td height="22">&nbsp;</td>
      <td>&nbsp;</td>
      <td><div align="right"><a href="javascript:UpdateEntranceData();"><img src="../../../../images/update.gif" border="0"></a></div></td>
      <td colspan="1"><font color="#0000FF" size="1">Click to update Entrance Data</font>      </td>
    </tr>
    <tr> 
      <td height="22">&nbsp;</td>
      <td colspan="3">Entrance Data : <strong> 
<%
strTemp = WI.fillTextValue("entrance_data");
if(strTemp.length() == 0) {
	strTemp = "select entrance_data_1 from entrance_data where stud_index = "+strUserIndex;
	strTemp = dbOP.getResultOfAQuery(strTemp, 0);
	if(strTemp == null)
		strTemp = "";
}
if(strTemp.length() == 0) {
	if (vCompliedRequirement != null && vCompliedRequirement.size() > 0) {
	
		for (int i = 0; i < vCompliedRequirement.size(); i+= 3) {
			if (i == 0) 
				strTemp = (String)vCompliedRequirement.elementAt(i+1);
			else 
				strTemp += "," + (String)vCompliedRequirement.elementAt(i+1);
		}
	}
}


//if(strTemp.length() == 0 && vEntranceData != null && vEntranceData.size() > 0)
//	strTemp = astrConvertToDocType[Integer.parseInt((String)vEntranceData.elementAt(8))];
%>
		<input name="entrance_data" type="text" class="textbox" value="<%=strTemp%>" size="75">
        </strong> 
		<%if(strSchCode.startsWith("SPC")){%>
			<a href="javascript:AddRecord('2')">Update</a>
		<%}%>
		</td>
    </tr>
<% if (strSchCode.startsWith("UC")) {
%>
    <tr>
      <td height="22">&nbsp;</td>
      <td colspan="3">Entrance Date (Other Data): <input name="entrance_data_other_uc" type="text" class="textbox" value="<%=WI.getStrValue(strEntranceDataOtherUC)%>" size="66"></td>
    </tr>
<%}%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td width="16%">Elementary ......</td>
      <td colspan="1"> <%
if(vEntranceData != null && vEntranceData.size() > 0)
	strTemp = (String)vEntranceData.elementAt(3);
else	
	strTemp = "";
%> <strong><%=strTemp%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>Secondary &nbsp;......</td>
      <td colspan="1"> 
<% if(vEntranceData != null && vEntranceData.size() > 0)
	strTemp = (String)vEntranceData.elementAt(5);
else	
	strTemp = "";
%> <strong><%=strTemp%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="5%">&nbsp; </td>
      <td>College ............</td>
      <td> <%
if(vEntranceData != null && vEntranceData.size() > 0)
	strTemp = WI.getStrValue(vEntranceData.elementAt(7));
else	
	strTemp = "&nbsp;";
%> <strong><%=strTemp%></strong></td>
      <td><%if(bolIsVMA){%><a href="javascript:UploadFile();"><strong>Upload Image</strong></a><%}%></td>
    </tr>
<%}%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="4">Course : <strong><%=(String)vStudInfo.elementAt(7)%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="4">Title/Degree :<strong> 
	  	<% 	strTemp = WI.fillTextValue("title_degree");
			if (strTemp.length() == 0 || bolNewStudentID) 
			 	strTemp =(String)vStudInfo.elementAt(7);
			if (strSchCode.startsWith("UI")) {
		%>
			<input name="title_degree" type="text" class="textbox"
					value="<%=strTemp%>" size="25">
		<%}else{%> 		
			<%=strTemp%>
		 <%}%> 		
		</strong>	  </td>
    </tr>
<%if(!bolIsEACCOG){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><div align="right"><a href="javascript:UpdateGraduationData();"><img src="../../../../images/update.gif" border="0"></a></div></td>
      <td colspan="2"><font color="#0000FF" size="1">Click to update Graduation Data</font>      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2"> Special Order No. </td>
      <td colspan="2"> <%
if(vGraduationData != null && vGraduationData.size()!=0)
	strTemp = WI.getStrValue(vGraduationData.elementAt(6));
else	
	strTemp = "";
%> <strong><%=strTemp%></strong></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td colspan="2">Date Issued </td>
      <td colspan="2"> <%
if(vGraduationData != null && vGraduationData.size()!=0){
	if (vGraduationData.elementAt(7) != null)
		strTemp = (String)vGraduationData.elementAt(7);
	else
		strTemp = "&nbsp;";
}else{
	strTemp = "&nbsp;";
}
%> <strong><%=strTemp%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">Date of Graduation</td>
      <td colspan="2">
        <%
if(vGraduationData != null && vGraduationData.size()!=0)
	strTemp = (String)vGraduationData.elementAt(8);
else	
	strTemp = "&nbsp;";
%>
        <strong><%=strTemp%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">Date of Dismissal</td>
      <td colspan="2">
<%		
if(vGraduationData != null && vGraduationData.size()!=0)
	strTemp = WI.getStrValue((String)vGraduationData.elementAt(14));
else	
	strTemp = "&nbsp;";
%>
        <strong><%=strTemp%></strong> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">Date Prepared </td>
      <td colspan="2"><%
strTemp = WI.fillTextValue("date_prepared");
if(strTemp.length() ==0)
	strTemp = WI.getTodaysDate(1);
%>
        <input name="date_prepared" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_prepared');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td align="right"><a href="javascript:UpdateAdditionalInfo();"><img src="../../../../images/update.gif" border="0"></a></td>
      <td colspan="2"><font color="#0000FF" size="1">Click to update Student Information </font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>Sex : </td>
<%
	if (vAdditionalInfo != null && vAdditionalInfo.size() > 0) 
		strTemp =  (String)vAdditionalInfo.elementAt(0);
	else
		strTemp = "&nbsp;";
%>
      <td colspan="2"><strong><%=strTemp%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>Date of Birth : </td>
<%
	if (vAdditionalInfo != null && vAdditionalInfo.size() > 0) 
		strTemp =  (String)vAdditionalInfo.elementAt(1);
	else
		strTemp = "&nbsp;";
%>
      <td colspan="2"><strong><%=strTemp%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>Place of Birth : </td>
<%
	if (vAdditionalInfo != null && vAdditionalInfo.size() > 0) 
		strTemp =  (String)vAdditionalInfo.elementAt(2);
	else
		strTemp = "&nbsp;";
%>
      <td colspan="2"><strong><%=strTemp%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="5"><hr size="1"></td>
    </tr>
  </table>
<%  if( (vEntranceData != null && vAdditionalInfo != null) || bolIsEACCOG  || strSchCode.startsWith("SPC")){
//--removed because student not graduating shud be able to get OTR. && vGraduationData != null%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
<%
if(!bolIsEACCOG){
if(strSchCode.startsWith("VMUF")){%>
    <tr>
      <td height="27">&nbsp;</td>
      <td colspan="2">Special Order Number Label : 
	  <select name="ched_sp_no">
	  <option value="CHED Special Order No.">CHED Special Order No.</option>
	  <%
	  strTemp = WI.fillTextValue("ched_sp_no");
	  if(strTemp.equals("ROG No.")) {%>
	  	<option value="ROG No." selected>ROG No.</option>
	  <%}else{%>
	  	<option value="ROG No.">ROG No.</option>
	  <%} if (strTemp.equals("TESDA Special Order No.")){%>
	  	<option value="TESDA Special Order No." selected>TESDA Special Order No.</option>
	  <%}else{%>
	  	<option value="TESDA Special Order No.">TESDA Special Order No.</option>
	  <%}%>	
	  </select></td>
    </tr>
<%}


if(strSchCode.startsWith("PHILCST")){%>
    <tr>
      <td height="27">&nbsp;</td>
      <td colspan="2">Special Order Remarks : 
	  		<input name="special_order_remark" type="text" class="textbox"
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				value="<%=WI.getStrValue(WI.fillTextValue("special_order_remark"))%>" size="30">	  </td>
    </tr>
<%}%>

    <tr> 
      <td height="27" width="2%">&nbsp;</td>
      <td colspan="2">Report prepared by :</td>
    </tr>
    <tr> 
      <td height="27">&nbsp;</td>
      <td width="3%">&nbsp;</td>
      <td width="95%"> 1. ) 
        <%
if(vForm17Info != null)
	strTemp = (String)vForm17Info.elementAt(1);
else	
	strTemp = WI.fillTextValue("prep_by1");
%> <input name="prep_by1" type="text" class="textbox"
	  	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		value="<%=WI.getStrValue(strTemp)%>" size="64"> </td>
    </tr>
	
<% if (strSchCode.startsWith("UDMC")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">Assistant Comptroller </td>
    </tr>
<%}%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>2. ) 
<%
if(vForm17Info != null)
	strTemp = (String)vForm17Info.elementAt(2);
else	
	strTemp = WI.fillTextValue("prep_by2");
%>

<input name="prep_by2" type="text" class="textbox"
	  	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		value="<%=WI.getStrValue(strTemp)%>" size="64"></td>
    </tr>

    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">Report checked by :</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>1. ) 
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
      <td colspan="2">Report approved by :</td>
    </tr>
	
    <tr> 	
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>1. ) 
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
      <td colspan="2">University Registrar's Name </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td> 
<%
if(vForm17Info != null)
	strTemp = (String)vForm17Info.elementAt(0);
else	
	strTemp = WI.fillTextValue("registrar_name");
%> <input name="registrar_name" type="text" size="64" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
    </tr>
<%if(strSchCode.startsWith("CSA")){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">Assistant Registrar's Name (In case Assistant Registrar is signing TOR)</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td> 
	 <input name="assistant_registrar" type="text" size="64" value="<%=WI.fillTextValue("assistant_registrar")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">Purpose: &nbsp;&nbsp;&nbsp; 
	    <input name="purpose_csa" type="text" size="64" value="<%=WI.fillTextValue("purpose_csa")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">T/R Sent to: 
        <input name="tr_sent_to_csa" type="text" size="64" value="<%=WI.fillTextValue("tr_sent_to_csa")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	  </td>
    </tr>
<%}//end of showing caregiver duration for auf %>

<%if(strSchCode.startsWith("DBTC")){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2"><u>"COPY TO" INFORMATION</u> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>
<%
if(vEntranceData != null && vEntranceData.size() > 0)
	strTemp = (String)vEntranceData.elementAt(42);
else
	strTemp = WI.fillTextValue("copy_to1");

%>	
  <select name="copy_to1">
	<option value=""></option>
	    <%=dbOP.loadCombo("SCH_ACCREDITED.SCH_NAME","SCH_ACCREDITED.SCH_NAME"," from SCH_ACCREDITED where IS_DEL=0 order by SCH_NAME",strTemp,false)%> 
	</select>
<!--
	  <input name="copy_to1" type="text" size="64" value="<%=WI.fillTextValue("copy_to1")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
-->	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>
<%
if(vEntranceData != null && vEntranceData.size() > 0)
	strTemp = (String)vEntranceData.elementAt(43);
else
	strTemp = WI.fillTextValue("copy_to2");

%>	
	  <input name="copy_to2" type="text" size="64" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>
<%
if(vEntranceData != null && vEntranceData.size() > 0)
	strTemp = (String)vEntranceData.elementAt(44);
else
	strTemp = WI.fillTextValue("copy_to3");

%>	
	  <input name="copy_to3" type="text" size="64" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">Parent/Guardian: </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>
<%
if(vEntranceData != null && vEntranceData.size() > 0)
	strTemp = (String)vEntranceData.elementAt(45);
else
	strTemp = WI.fillTextValue("dbtc_parent_guardian");

if(strTemp == null || strTemp.length() == 0 && vAdditionalInfo != null && vAdditionalInfo.size() > 0 && vAdditionalInfo.elementAt(8) != null)
	strTemp = (String)vAdditionalInfo.elementAt(8);

%>	
	  <input name="dbtc_parent_guardian" type="text" size="64" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>

<%}
}%>

<%
String strCGDuration      	 = null;
String strEndOfTORRemark2 	 = null;
String strAdditionalTraining = null;
strTemp = "select END_OF_TOR_REMARK,end_of_tor_remark2,CAREGIVER_DURATION,TOR_ADD_TRAINING from ENTRANCE_DATA where stud_index = "+strUserIndex;
rs = dbOP.executeQuery(strTemp);
if(rs.next())  {
	strTemp = rs.getString(1);
	strEndOfTORRemark2 = rs.getString(2);
	strCGDuration = rs.getString(3);
	strAdditionalTraining = rs.getString(4);
}
else {
	strTemp = null;
}
rs.close();

if(strSchCode.startsWith("VMA") && strTemp == null && vGraduationData != null &&  vGraduationData.size() > 0){

	String strCourseCode = (String)vStudInfo.elementAt(24);
	String strMajorCode  = null;
	if(vStudInfo.size() > 25)
		strMajorCode = (String)vStudInfo.elementAt(25);
	else if(vStudInfo.elementAt(8) != null) {
		strMajorCode = "select course_code from major where course_index="+vStudInfo.elementAt(5)+
		" and major_index="+vStudInfo.elementAt(6)+" and is_del=0";
		strMajorCode = dbOP.getResultOfAQuery(strMajorCode,0);		
	}
	
	/*if(bolIsCareGiver)
		strTemp = "GRADUATED WITH THE SIX-MONTH CARE GIVER";
	else*/
		strTemp = "GRADUATED WITH THE DEGREE, " +((String)vStudInfo.elementAt(7)).toUpperCase();						
	 
	 if(strMajorCode != null) {
		strTemp += ", MAJOR IN "+((String)vStudInfo.elementAt(8)).toUpperCase();
		strCourseCode = strCourseCode + " "+strMajorCode;
	 }
	
	 strTemp += WI.getStrValue(strCourseCode," (",") ","");
	//System.out.println(strTemp);	
	 if ((String)vGraduationData.elementAt(8) != null)
		strTemp += " AS OF " +WI.formatDate((String)vGraduationData.elementAt(8),6).toUpperCase();
	
		
	 if(vGraduationData.elementAt(6) != null)
		strTemp +=	" AS PER " +vGraduationData.elementAt(6);
	 if (vGraduationData.elementAt(6) != null && vGraduationData.elementAt(7) != null) {
		/*if(bolIsCareGiver)
			strTemp +=  " DATED " ;
		else*/	
			strTemp +=  " DATED: " ;
		strTemp +=WI.formatDate((String)vGraduationData.elementAt(7),6).toUpperCase() + ".";
	 }
	 else	
		strTemp += ".";
		
	 if(vGraduationData.elementAt(16) != null)
		strTemp = strTemp + " "+((String)vGraduationData.elementAt(16)).toUpperCase();

}

if(strSchCode.startsWith("WNU") || strSchCode.startsWith("AUF") || strSchCode.startsWith("FATIMA") || 
strSchCode.startsWith("UL") || strSchCode.startsWith("CDD") || strSchCode.startsWith("UB") || strSchCode.startsWith("VMA")){

if(strSchCode.startsWith("VMA")){
%>
<tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2" valign="top">Enter Student Trainings(if any). For multiple trainings use &lt;br&gt; to separate line. 
	  	If certificate is available use <strong> remarks</strong> keyword. Please 
        refer example below<br>
		BASIC SAFETY COURSE  /DECK WATCHKEEPING remarks w/ certificate&lt;br&gt;BASIC SAFETY TRAINING remarks with certificate<br>
		--&gt; this will look like<br>
		BASIC SAFETY COURSE  /DECK WATCHKEEPING &nbsp; &nbsp; &nbsp; &nbsp; w/ certificate<br>
		BASIC SAFETY TRAINING &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp; &nbsp; &nbsp;
			 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; w/ certificate		</td> 
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>
	  <textarea name="additional_training" size="64" class="textbox" cols="90" rows="6"
		  onFocus="style.backgroundColor='#D3EBFF'" 
		  onBlur="updateEndOfTORRemark(document.form_.additional_training, '3');style.backgroundColor='white'"><%=WI.getStrValue(strAdditionalTraining)%></textarea></td>
    </tr>
<%}%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">Enter Remarks for end of TOR. Consult System admin for format of encoding.</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>
	  <textarea name="endof_tor_remark" size="64" class="textbox" cols="90" rows="6"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="updateEndOfTORRemark(document.form_.endof_tor_remark, '1');style.backgroundColor='white'"><%=WI.getStrValue(strTemp)%></textarea></td>
    </tr>

<%if(strSchCode.startsWith("AUF")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">Caregiver Duration (if applicable): 
	  <input name="caregiver_dur" type="text" size="64" value="<%=WI.getStrValue(strCGDuration)%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="updateEndOfTORRemark(document.form_.caregiver_dur, '-1');style.backgroundColor='white'">	  </td>
    </tr>
<%}//end of showing caregiver duration for auf %>

<%}


if(WI.fillTextValue("honor_point").compareTo("1") == 0) {//only if honor student.%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><strong> 
        <%
strTemp = WI.fillTextValue("consider_mterm");
if(strTemp.compareTo("1") == 0)
	strTemp = " selected";
else	
	strTemp = "";
%>
        <input type="checkbox" name="consider_mterm" value="1" <%=strTemp%>>
        <font color="#0066CC">Compute Midterm grade if Final grade is not encoded 
        (optional)</font></strong><br>
        <br>
        <br>
        <br></td>
    </tr>
<%} 

if (WI.fillTextValue("honor_point").length() == 0) {
if(!bolIsEACCOG){
%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" width="2%">&nbsp;</td>
      <td colspan="2">REMARK (if any). To separate line add &lt;br&gt; tag to 
        the end. To make the line bold write within &lt;b&gt;&lt;/b&gt; tag. Please 
        refer example below<br> &lt;b&gt;GRANTED HONORABLE DISMISSAL ....&lt;/b&gt; 
        &lt;br&gt;&lt;b&gt;Copy for... &lt;/b&gt;&lt;br&gt; Name of the school 
        &lt;br&gt; Address1 of the school &lt;br&gt;Address2 of the school &lt;br&gt;Address3 
        of the school<br>
        --&gt; this will look like<br> <strong>GRANTED HONORABLE DISMISSAL .... 
        <br>
        Copy for... <br>
        </strong>Name of the school <br>
        Address1 of the school<br>
        Address2 of the school<br>
        Address3 of the school</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td valign="top"> <textarea name="addl_remark" size="64" class="textbox" cols="90" rows="6"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="updateEndOfTORRemark(document.form_.addl_remark, '2');style.backgroundColor='white'"><%=WI.getStrValue(strEndOfTORRemark2)%></textarea>      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td align="center"><a href="javascript:AddRecord('1');"><img src="../../../../images/save.gif" border="0" name="hide_save"></a> 
        Click to save/edit encoded Information</td>
    </tr>
    <%if(strSchCode.startsWith("CGH")){%>
    <tr> 
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>
	  Date of Completion: 
      <input type="text" name="date_of_completion" value="<%=WI.fillTextValue("date_of_completion")%>"></td>
    </tr>
    <%}if(strSchCode.startsWith("UL")){%>
    <tr> 
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>
	  Designation of Registrar : <input type="text" name="registrar_desig" value="<%=WI.fillTextValue("registrar_desig")%>"> 
	  &nbsp;&nbsp;
	  Name: <input type="text" name="registrar_desig_name" value="<%=WI.fillTextValue("registrar_desig_name")%>">	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>
	  Designation of VP : <input type="text" name="vp_desig" value="<%=WI.fillTextValue("vp_desig")%>">
	  &nbsp;&nbsp;
	  Name: <input type="text" name="vp_desig_name" value="<%=WI.fillTextValue("vp_desig_name")%>">	  </td>
    </tr>
    <%}if(strSchCode.startsWith("UI")){%>
    <tr> 
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>Designation of Registrar : <input type="text" name="registrar_desig" value="<%=WI.getStrValue(WI.fillTextValue("registrar_desig"),"University Registrar")%>"> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>NCEE : 
        <input name="ncee" type="text" size="4" value="<%=WI.fillTextValue("ncee")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;GSA 
        <input name="gsa" type="text" size="4" value="<%=WI.fillTextValue("gsa")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Percentile Rank 
        <input name="percentile" type="text" size="4" value="<%=WI.fillTextValue("percentile")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>Number of Weeks : 
        <input name="weeks" type="text" size="4" maxlength="4" class="textbox" value="<%=WI.fillTextValue("weeks")%>" onFocus="style.backgroundColor='#D3EBFF'" 
		onKeyUp = "AllowOnlyInteger('form_','weeks')" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td> <%
if(request.getParameter("show_rel") == null && request.getParameter("show_leclab") == null) 
	strTemp = " checked";
else if(WI.fillTextValue("show_rel").compareTo("1") == 0 )
	strTemp = " checked";
else	
	strTemp = "";
%> <input type="checkbox" name="show_rle" value="1" onClick="ShowAddlColumn(1);"<%=strTemp%>> 
        <strong>Show RLE hrs 
        <%
if(strTemp.length() > 0) 
	strTemp = "";
else if(WI.fillTextValue("show_leclab").length() > 0)
	strTemp = " checked";
else	
	strTemp = "";
%>
        <input type="checkbox" name="show_leclab" value="1" onClick="ShowAddlColumn(2);"<%=strTemp%>>
        Show Lec/Lab Hour</strong> <font size="1">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(NOTE: 
        RLE hours will be shown only if applicable.)</font></td>
    </tr>
    <%} // end  if(strSchCode.startsWith("UI")) show RLE
	
	if(strSchCode.startsWith("AUF")){%>
	<!--
	<tr>
		<td>&nbsp; </td>
		<td>&nbsp; </td>
		<td>AUF - CAT: 
		<% strTemp = WI.fillTextValue("AUF_CAT");%>
		<input name="AUF_CAT" type="text" size="4" value="<%=strTemp%>" class="textbox"
		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;NSAT 
		<% strTemp = WI.fillTextValue("NSAT");%>
		<input name="NSAT" type="text" size="4" value="<%=WI.fillTextValue("NSAT")%>" class="textbox"
		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      
		</td>
	</tr>
	-->
	<tr>
		<td>&nbsp; </td>
		<td>&nbsp; </td>
	  <td>GWA: 
		<% strTemp = WI.fillTextValue("AUF_CAT");%>
		<input name="gwa" type="text" size="4" value="<%=strTemp%>" class="textbox"
		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>
	
<% } // end if(strSchCode.startsWith("AUF") 
}//if(WI.fillTextValue("is_eac_cog").length() == 0)
%>

<%if(strSchCode.startsWith("CDD")){%>
<tr>
	<td>&nbsp;</td>
	<td>&nbsp;</td>
	<td valign="top">
		<table width="91%" border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td width="20%">CHED RECOGNITION NO.</td>
				<td width="20%">
					<select name="ched_recognition_no" style="width:200px;">		
						<%=dbOP.loadCombo("OTR_GR_CDD.GR_NO", "OTR_GR_CDD.GR_NO", " from OTR_GR_CDD where course_index = "+strCourseIndex+" order by DATE_ISSUED desc", WI.fillTextValue("ched_recognition_no"), false)%>		
					</select>				</td>
				
				<%
				strTemp = "select gr_no from otr_gr_cdd where course_index = "+strCourseIndex;
				rs = dbOP.executeQuery(strTemp);
				strTemp = null;
				while(rs.next()){
					if(strTemp == null)
						strTemp = rs.getString(1);
					else
						strTemp += ", " + rs.getString(1);
				}rs.close();
				
				%>
				
				<input type="hidden" name="ched_recognition_no_" value="<%=WI.getStrValue(strTemp)%>" >
				
				<td>&nbsp; &nbsp; &nbsp; &nbsp; 
					<a href="javascript:UpdateRecogNo();"><img src="../../../../images/update.gif" border="0"></a>				</td>
			</tr>
		</table>	</td>
</tr>
<%}%>

<% if (vCourseHist != null) {
	int iCheckBoxCtr = 0;
%>
<tr>
<td>&nbsp; </td>
<td>&nbsp; </td>
      <td>
	  <table width="91%" border="0" cellspacing="0" cellpadding="0"
	  	style=" border: solid #0000FF 1px 1px 1px 1px;">
        <tr>
          <td width="45%">&nbsp;Select Courses to be shown</td>
          <td width="55%">
		  <%if(!strSchCode.startsWith("UB")){%>
		  <a href="javascript:RemovePrintPg()"><img src="../../../../images/refresh.gif" width="71" height="23" border="1"></a> 
		  	<font size="1">click to recompute pages</font><%}%></td>
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
			if ( (WI.fillTextValue("rows_per_page").length() == 0 && !bolIsEACCOG)
				|| WI.fillTextValue("checkbox"+iCheckBoxCtr).length()>0){
					strTemp = "checked";
			}else{
					strTemp = "";
			}
		  	
			if (bolNewStudentID && !bolIsEACCOG)  // force check..
				strTemp = "checked";
				
			if(bolIsEACCOG){
				strErrMsg = "radio";
				iCheckBoxCtr = 1;
			}else
				strErrMsg = "checkbox";
			
		  %>
		  
		  	<input type="<%=strErrMsg%>" name="checkbox<%=iCheckBoxCtr%>" 
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
      </table>	  </td>
</tr>
<%} 
/**
strTemp = null; 
boolean bolShowAllTF = true;
int iMaxTFList = Integer.parseInt(WI.getStrValue(WI.fillTextValue(""), "0"));
for(int i = 0 ; i < iMaxTFList; ++i) {
	if(WI.fillTextValue("tf_info"+i).length() == 0)  {
		bolShowAllTF = false;
		continue;
	}
	if(strTemp == null)
		strTemp = WI.fillTextValue("");
	else	
		strTemp = strTemp + ", "+ WI.fillTextValue("");	
}
**/


} //end check for honor point

//System.out.println(vRetResult);

if(vRetResult != null && vRetResult.size() > 2){

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
iTemp = vRetResult.size() / 11;
iPageCount = 1;
//int iRowsPerPage = 30;  --> default static
int iRowsPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("rows_per_page"),"0"));

//int iFirstPageCount = 20; //less lines in first page. -->default static, updated to variable
int iFirstPageCount = Integer.parseInt(WI.getStrValue(WI.fillTextValue("rows_1st_page"),"0"));

if (bolNewStudentID){
	iRowsPerPage = 0;
	iFirstPageCount = 0;
}

int iMaxRowToDisplay=0;//this is the max page count to display - if it is first page, val = iFirstPageCount, else iRowPerPage.

if (iRowsPerPage == 0) {

	if(strSchCode != null && strSchCode.startsWith("UI")){
			iRowsPerPage = 42;
	
		if (WI.fillTextValue("honor_point").length() == 0) // used by UI 
			iFirstPageCount = 30;
		else	
			iFirstPageCount = 40;
	}
	if(strSchCode != null && strSchCode.startsWith("PHILCST")) {
		iRowsPerPage =40;
		iFirstPageCount = 40;
	}
	if(strSchCode != null && strSchCode.startsWith("VMUF")) {
		iRowsPerPage = 40;
		iFirstPageCount = 41;
	}
	if(strSchCode != null && strSchCode.startsWith("LNU")) {
		iRowsPerPage = 35;
		iFirstPageCount = 29;
	}

	if(strSchCode != null && (strSchCode.startsWith("AUF") || strSchCode.startsWith("UL")) ){
		iRowsPerPage = 25;
		iFirstPageCount = 23;
	}

	if(strSchCode != null && strSchCode.startsWith("CLDH")){
		iRowsPerPage = 30;
		iFirstPageCount = 30;
	}

	if(strSchCode != null && (strSchCode.startsWith("UDMC") || strSchCode.startsWith("CSAB")) ){
		iRowsPerPage = 25;
		iFirstPageCount = 30;
	}
	
	if (strSchCode != null && strSchCode.startsWith("CGH")) {
		iRowsPerPage =43;
		iFirstPageCount = 46;
	}
	if (strSchCode != null && strSchCode.startsWith("WNU")) {
		iRowsPerPage =36;
		iFirstPageCount = 26;
	}
	if (strSchCode != null && strSchCode.startsWith("DBTC")) {
		iRowsPerPage =35;
		iFirstPageCount = 35;
	}
	if (strSchCode != null && strSchCode.startsWith("FATIMA")) {
		iRowsPerPage = 43;
		iFirstPageCount = 46;
	}
	if (strSchCode != null && strSchCode.startsWith("UPH")) {
		iRowsPerPage = 42;
		iFirstPageCount = 42;
	}
	if (strSchCode != null && strSchCode.startsWith("UC")) {
		iRowsPerPage = 38;
		iFirstPageCount = 38;
	}
	if (strSchCode != null && strSchCode.startsWith("WUP")) {
		iRowsPerPage = 40;
		iFirstPageCount = 42;
	}
	if (strSchCode != null && strSchCode.startsWith("VMA")) {
		iRowsPerPage = 35;
		iFirstPageCount = 25;
	}
	if(iRowsPerPage == 0) {//foreced.
		iRowsPerPage =30;
		iFirstPageCount = 30;
	}

}
//System.out.println(strSchCode);
//System.out.println(iRowsPerPage);
//I have to find how many pages here.. 
boolean bolComputePerPage = false;
if(WI.fillTextValue("rows_per_pg_1").length() > 0) {
	bolComputePerPage = true;
	iFirstPageCount = Integer.parseInt(WI.fillTextValue("rows_per_pg_1"));
	iTemp -= iFirstPageCount;
	while(iTemp > 0) {
		++iPageCount;
		iTemp = iTemp - Integer.parseInt(WI.getStrValue(WI.fillTextValue("rows_per_pg_"+iPageCount),Integer.toString(iRowsPerPage)));
	}
	//System.out.println("iPageCount : "+iPageCount);	
}
else {
	iTemp -= iFirstPageCount;
	if(iTemp > 0) {
		iPageCount += iTemp / iRowsPerPage;
		if(iTemp % iRowsPerPage > 0)
			++iPageCount;
	}
}

int[] iRowsToShow = new int[iPageCount];
int[] iRowStartFrom = new int[iPageCount];
//if there are two pages, i have to findout the page counts here. only if the count is less than 30
iTemp = vRetResult.size() / 11;
//iTemp = 56;
for(int i = 0 ; i < iPageCount; ++i){
	if(i == 0) {
		iRowsToShow[i] = iFirstPageCount;
		iRowStartFrom[i] = 0;
		iTemp -= iFirstPageCount; 
		if(iTemp <= 0) {
			iRowsToShow[i] = iTemp + iFirstPageCount;
			break;
		}//System.out.println(iRowsToShow[i]);System.out.println(iRowStartFrom[i]);
		continue;			
	}
	if(bolComputePerPage) {
		iRowsPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("rows_per_pg_"+(i + 1)),Integer.toString(iRowsPerPage)));
	}
	iRowsToShow[i] = iRowsPerPage;
	//iRowStartFrom[i] = iFirstPageCount + iRowsPerPage * (i-1);
	iRowStartFrom[i] = iRowStartFrom[i - 1]  + iRowsToShow[i - 1];
	
	
	iTemp -= iRowsPerPage;
	if(iTemp <= 0) {
		iTemp += iRowsPerPage;
		iRowsToShow[i] = iTemp;//end page.
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

//get here line numbers if already set.. 
if(strUserIndex != null) {
	vTORLineNumber = entranceGradData.getTORLineNumber(dbOP, strUserIndex, "1", null, request);	
}

if(!bolIsEACCOG && !strSchCode.startsWith("UB")){
for(int i = 1; i <= iPageCount; ++i){
if(i == iPageCount) {
	strTemp = "Print Last Page";
	iLastPage = 1;
	iMaxRowToDisplay = iRowsPerPage;
	if(i == 1){ // special case scenario..  1 Page TOR ONLY!!!
		if(strSchCode.startsWith("VMU")){
			iFirstPageCount = 21;
		}
		
		if(strSchCode.startsWith("AUF")){
			iFirstPageCount = 28 ;
		}
		
		iMaxRowToDisplay = iFirstPageCount;
	}
}
else {	
	strTemp = "Print Page "+i;
	iMaxRowToDisplay = iFirstPageCount;
}
//Print page(start pt, no of rows, is last page.

//row_start_fr,row_count,last_page,page_number,max_page_to_disp,
//this stores all print values passed in javascript PrintPg method call.. csv values are
if(strPrintValueCSV.length() > 0) 
	strPrintValueCSV = strPrintValueCSV+",";
	
strPrintValueCSV +=	Integer.toString(iRowStartFrom[i - 1]) + ","+//row_start_fr
					Integer.toString(iRowsToShow[i - 1])   + ","+//row_count
					Integer.toString(iLastPage)            + ","+//last_page
					Integer.toString(i)                    + ","+//page_number
					Integer.toString(iMaxRowToDisplay);//max_page_to_disp

//System.out.println(strPrintValueCSV);%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td> 
<%//System.out.println(iRowStartFrom[2]);System.out.println(iRowsToShow[2]);
if(!bolBlockPrinting && !bolIsEACCOG) {
if(dOutStandingBalance < 1d || true){%>
	  <table width="645">
          <tr> 
            <td width="252"> <b><font size="3">  <a href='javascript:PrintPg("<%=iRowStartFrom[i - 1]%>","<%=iRowsToShow[i - 1]%>","<%=iLastPage%>","1","<%=i%>",<%=iMaxRowToDisplay%>);'> 
              <%=strTemp%></a></font></b></td>
            <td width="381"><b><font size="3"> <a href='javascript:PrintPg("<%=iRowStartFrom[i - 1]%>","<%=iRowsToShow[i - 1]%>","<%=iLastPage%>","0","<%=i%>",<%=iMaxRowToDisplay%>);'> 
              View</a></font></b> 
			  <%
			  strTemp = WI.fillTextValue("rows_per_pg_"+i);//System.out.println(i);
			  if(strTemp.length() == 0) {
			  	if(i == 1)
					strTemp = Integer.toString(iFirstPageCount);
				else	
					strTemp = Integer.toString(iRowsPerPage);
				if(vTORLineNumber != null && vTORLineNumber.size() > (i - 1) && vTORLineNumber.elementAt(i - 1) != null)
					strTemp = (String)vTORLineNumber.elementAt(i - 1);
					
			  }%>
			  <input name="rows_per_pg_<%=i%>" type="text" class="textbox"	value="<%=strTemp%>" 
	    onfocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','rows_per_pg_<%=i%>'); ajaxUpdateRow('<%=i%>',document.form_.rows_per_pg_<%=i%>)" 
		onKeyUp="AllowOnlyInteger('form_','rows_per_pg_<%=i%>')" size="2" maxlength="2">
			  <font style="font-size:9px;">- Rows/Page</font>		    </td>
          </tr>
        </table>
<%}
}%>		</td>
    </tr>
<%}
}
if(!bolBlockPrinting && !bolIsEACCOG && !strSchCode.startsWith("UB")) {%>
    <tr bgcolor="#FEEBEB"> 
      <td height="25" colspan="3">
	  	<table width="99%" border="0" align="center" cellpadding="0" cellspacing="0">
          <tr>
            <td width="63%"><strong>Rows in First Page</strong> :
        <input name="rows_1st_page" type="text" class="textbox"	value="<%=iFirstPageCount%>" 
	    onfocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','rows_1st_page')" 
		onKeyUp="AllowOnlyInteger('form_','rows_1st_page')" size="2" maxlength="2">
		
  &nbsp;&nbsp;&nbsp;<strong>Succeding Page(s)</strong> :
  <input name="rows_per_page" type="text" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" size="2" maxlength="2"
	  onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','rows_per_page')" 
	  value="<%=iRowsPerPage%>"	onKeyUp="AllowOnlyInteger('form_','rows_per_page')">
  &nbsp;&nbsp;&nbsp;
  
  <%
  if(strSchCode.startsWith("AUF") || strSchCode.startsWith("WNU") || 
		strSchCode.startsWith("FATIMA") || strSchCode.startsWith("UL")  
		|| strSchCode.startsWith("VMA") || strSchCode.startsWith("UC") || strSchCode.startsWith("SPC")){%>
			<a href="javascript:PrintAllPages('1');">Print All Pages</a>
  <%}%>  
  &nbsp;&nbsp;&nbsp;&nbsp;
  <!--
  <a href='javascript:PrintPg("0","<%=iRowStartFrom[iRowStartFrom.length - 1]+iRowsToShow[iRowsToShow.length - 1]%>","<%=1%>","0","1",<%=iRowStartFrom[iRowStartFrom.length - 1]+iRowsToShow[iRowsToShow.length - 1]%>);'>View All Pages</a>  
  -->
  <a href="javascript:PrintAllPages('0');">View All Pages</a>
  </td>
            <td width="37%"><a href="javascript:RemovePrintPg()"><img src="../../../../images/refresh.gif" width="71" height="23" border="1"></a><font size="1">&nbsp;&nbsp;(click to recompute number of pages)</font></td>
          </tr>
        </table></td>
    </tr>
<%}//do nto print if blocked printing
if(strSchCode.startsWith("UB")){
	
%>
	<tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>
	  <%//if(bolAllowOTRPrinting && !bolBlockPrinting)
	  if(!bolBlockPrinting){
	  %>
	  	<a href="javascript:PrintAllPages('1');"><img src="../../../../images/print.gif" border="0"></a>
					  <font size="1">Click to print All Pages</font>
		&nbsp; &nbsp;
		<%}%>
		<a href="javascript:PrintAllPages('0');"><img src="../../../../images/view.gif" border="0"></a>
					  <font size="1">Click to view OTR Pages</font>		</td>
    </tr>
<%}%>

    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>	
    <%}%>
  </table>
<%}//only if vEntrance Data info is not null
}//only if vStud info is not null and vStud Info.size () > 0
%>
	 
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
<%
	if(vEntranceData == null && vGraduationData == null && vStudInfo != null && vAdditionalInfo != null && !bolIsEACCOG){%>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="9%">&nbsp;</td>
      <td width="89%" colspan="3"><font color="blue"> Please enter Entrace Data to View or Print OTR </font></td>
    </tr>
<%}

if((WI.fillTextValue("is_eac_cog").length()  >0 || WI.fillTextValue("is_swu_gpa").length() > 0) && vStudInfo != null && vStudInfo.size() > 0){
%>	
<tr>
	<td>&nbsp;</td>	
	<td colspan="3" valign="top">
		<table  width="100%" border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td>
				<%if(WI.fillTextValue("is_eac_cog").length()  >0){%>
				School Year &nbsp; &nbsp;
					<input name="print_per_school_year_from" type="text" class="textbox" id="sy_from"
					  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';
					  	DisplaySYTo('form_','print_per_school_year_from','print_per_school_year_to')"
					  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
					  onKeyUp='DisplaySYTo("form_","print_per_school_year_from","print_per_school_year_to")' value="<%=WI.fillTextValue("print_per_school_year_from")%>" 
					  size="4" maxlength="4">
					  
					  &nbsp; &nbsp;
					  
					  <input name="print_per_school_year_to" type="text" class="textbox" id="sy_to"
					  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
					  value="<%=WI.fillTextValue("print_per_school_year_to")%>" size="4" maxlength="4"
					  readonly="yes">
					  &nbsp; &nbsp;
					  Term : 
        <select name="print_per_school_year_semester" onChange="ResetPage();">
        	<option value="">Select Any</option>		  
		<%
		strTemp = WI.fillTextValue("print_per_school_year_semester");
		if(strTemp.equals("1"))
			strErrMsg= "selected";
		else
			strErrMsg = "";		
		%><option value="1" <%=strErrMsg%>>1st Sem</option>
		<%
		if(strTemp.equals("2"))
			strErrMsg= "selected";
		else
			strErrMsg = "";		
		%><option value="2" <%=strErrMsg%>>2nd Sem</option>
		<%
		if(strTemp.equals("3"))
			strErrMsg= "selected";
		else
			strErrMsg = "";		
		%><option value="3" <%=strErrMsg%>>3rd Sem</option>
		<%
		if(strTemp.equals("0"))
			strErrMsg= "selected";
		else
			strErrMsg = "";		
		%><option value="0" <%=strErrMsg%>>Summer</option>
		
		  
        </select>
		<%}%>
		&nbsp;
					  
					  <a href="javascript:PrintAllPages('1');"><img src="../../../../images/print.gif" border="0"></a>
					  <%if(WI.fillTextValue("is_eac_cog").length()  >0){%><font size="1">Click to print Cerfificate of Grade</font><%}else{%>
					  <font size="1">Click to print Grades Point Average<%}%>
					  <!--function PrintPg(strRowStartFr,strRowCount,strLastPage, strPrintStatus,strPageNumber,strMaxRowsToDisp) {-->
				</td>
			</tr>
		</table>
	</td>
</tr>

<%}%>
  </table>

  <table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
  </tr>
  <tr>
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>

	<input type="hidden" name="row_start_fr">
	<input type="hidden" name="row_count">
	<input type="hidden" name="last_page">
	<input type="hidden" name="honor_point" value="<%=WI.fillTextValue("honor_point")%>">

	<input type="hidden" name="add_record">
	<input type="hidden" name="print_pg" value="">
	<input type="hidden" name="print_">
	<input type="hidden" name="page_number">
	<input type="hidden" name="total_page" value="<%=iPageCount%>">
	<input type="hidden" name="max_page_to_disp">
	<input type="hidden" name="curr_stud_id" value="<%=WI.fillTextValue("stud_id")%>">
	
	<input type="hidden" name="print_value_csv" value="<%=strPrintValueCSV%>">
	<input type="hidden" name="print_all_pages" value="">
	<input type="hidden" name="stud_i" value="<%=strUserIndex%>">
<%if(bolNewStudentID) {%>
	<input type="hidden" name="tf_sel_list" value="">
<%}else{%>
	<input type="hidden" name="tf_sel_list" value="<%=WI.fillTextValue("tf_sel_list")%>">
<%}%>
	
	<input type="hidden" name="is_eac_cog" value="<%=WI.fillTextValue("is_eac_cog")%>">	
	<input type="hidden" name="is_swu_gpa" value="<%=WI.fillTextValue("is_swu_gpa")%>">	
	<input type="hidden" name="img_ext" value="<%=strImgFileExt%>">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
