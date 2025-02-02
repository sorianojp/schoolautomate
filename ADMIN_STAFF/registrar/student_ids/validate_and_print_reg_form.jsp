<%@ page language="java" import="utility.*,enrollment.RegAssignID,enrollment.FAPaymentUtil,java.util.Vector"%>
<%
WebInterface WI = new WebInterface(request);
String strTemp = null;

String strAuthType = (String)request.getSession(false).getAttribute("userIndex");
boolean bolIsAuthorized = true;
if(strAuthType == null)
	bolIsAuthorized = false;
else {
	strAuthType = (String)request.getSession(false).getAttribute("authTypeIndex");
	if(strAuthType != null && strAuthType.equals("4")) {
		//allow if called from online advising.
		strTemp = (String)request.getSession(false).getAttribute("userId");
		if(strTemp != null && strTemp.equals(WI.fillTextValue("stud_id")))
			bolIsAuthorized = true;
		else
			bolIsAuthorized = false;
	}
}
if(!bolIsAuthorized) {%>
	<p style="font-size:14px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif">
		You are not authorized to view this page. Please login again. 
	</p>
<%return;
}%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function AddRecord()
{
	document.new_id.addRecord.value = "1";
}
function printClassCard(strORNumber,strSchRef) {
	var pgLoc;
	if(strSchRef == '1')
		pgLoc = "../../fee_assess_pay/payment/class_card.jsp?font_size="+document.new_id.font_size[document.new_id.font_size.selectedIndex].value+"&or_number="+strORNumber;
		//sy_from="+document.new_id.sy_.value+"&semester="+document.new_id.sem_.value+"&stud_id="+document.new_id.stud_.value;
	
	
	if(document.new_id.print_subcode) {
		if(document.new_id.print_subcode.selectedIndex > 0) 
			pgLoc += "&sub_c="+escape(document.new_id.print_subcode[document.new_id.print_subcode.selectedIndex].value);
	}
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function printRegForm(strORNumber, strSchRef, strCourse) {
	var pgLoc;
	if(strSchRef == '1') {
		if(strCourse == 'null')
		pgLoc = "../../fee_assess_pay/payment/enrollment_receipt_print_2Copies_PHILCST.jsp?font_size="+document.new_id.font_size[document.new_id.font_size.selectedIndex].value+"&or_number="+strORNumber;
		else	
			pgLoc = "../../fee_assess_pay/payment/enrollment_receipt_print_3Copies_PHILCST.jsp?font_size="+document.new_id.font_size[document.new_id.font_size.selectedIndex].value+"&or_number="+strORNumber;
	}
	else
		pgLoc = "../../fee_assess_pay/payment/enrollment_receipt_print.jsp?or_number="+strORNumber;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function focusID() {
	if(document.new_id.stud_id)
		document.new_id.stud_id.focus();
}


var calledRef;
//all about ajax - to display student list with same name.
function AjaxMapName(strRef) {
	var strSearchCon = "&search_temp=2";

		calledRef = strRef;
		var strCompleteName;
		if(strRef == "0")
			strSearchCon = "";

		strCompleteName = document.new_id.stud_id.value;
		if(strCompleteName.length == 0)
			return;

		/// this is the point i must check if i should call ajax or not..
		if(this.bolReturnStrEmpty && this.startsWith(this.strPrevEntry,strCompleteName, false) == 0)
			return;
		this.strPrevEntry = strCompleteName;

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
	document.new_id.stud_id.value = strID;
	document.getElementById("coa_info").innerHTML = "";
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}</script>
<body bgcolor="#D2AE72" onLoad="focusID();">
<%
	DBOperation dbOP = null;

	String strErrMsg = null;
	String strPermStudID = null; String strORNumber = null;
	boolean bolConfirmEnrollment = false;
	Vector vStudInfo = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-STUDENT IDs - New","new_id.jsp");
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

	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
	//strSchCode = "PHILCST";
	
	boolean bolIsSWU      = strSchCode.startsWith("SWU");
	String strSQLQuery    = null;
	java.sql.ResultSet rs = null;
	String strStudID      =  WI.fillTextValue("stud_id");
	Vector vSubjectDtls   = null;
	Vector vPaymentDtls   = new Vector();//date paid, or_number, amount.. 

//end of authenticaion code.
String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester","4th Semester","",""};

boolean bolIsEnrolled = false;//for SWU.. 
boolean bolIsTempStud = false;
String strStudIndex = null;

if(bolIsSWU && strStudID.length() > 0 && !WI.fillTextValue("addRecord").equals("1")) {
	strStudIndex = dbOP.mapUIDToUIndex(strStudID);
	vStudInfo = new Vector();
	if(strStudIndex == null) {
		strSQLQuery = "select new_application.APPLICATION_INDEX,fname, mname, lname, sy_from, sy_to, schyr_from, schyr_to, semester, year_level, Appl_catg, "+
						"course_offered.course_code, major.course_code,DEGREE_TYPE from NEW_APPLICATION "+
						"join APPL_FORM_SCHEDULE on (APPL_FORM_SCHEDULE.APPL_SCH_INDEX = NEW_APPLICATION.APPL_SCH_INDEX) "+
						"join NA_PERSONAL_INFO on (NA_PERSONAL_INFO.APPLICATION_INDEX = NEW_APPLICATION.APPLICATION_INDEX) "+
						"join COURSE_OFFERED on (course_offered.course_index = APPL_FORM_SCHEDULE.course_index) "+
						"left join major on (major.major_index = APPL_FORM_SCHEDULE.major_index) "+
						"where new_application.is_valid = 1 and temp_id = '"+strStudID+"'";
		rs = dbOP.executeQuery(strSQLQuery);
		if(rs.next()) {
			strStudIndex = rs.getString(1);
			vStudInfo.addElement(strStudIndex);//[0] Application_index
			vStudInfo.addElement(WebInterface.formatName(rs.getString(2), rs.getString(3), rs.getString(4), 4));//[1] Name
			vStudInfo.addElement(rs.getString(5));//[2] CY_from
			vStudInfo.addElement(rs.getString(6));//[3] CY_To
			vStudInfo.addElement(rs.getString(7));//[4] sy_from
			vStudInfo.addElement(rs.getString(8));//[5] sy_to
			vStudInfo.addElement(rs.getString(9));//[6] semester
			vStudInfo.addElement(rs.getString(10));//[7] year_level
			vStudInfo.addElement(rs.getString(11));//[8] Appl_catg.
			vStudInfo.addElement(rs.getString(12));//[9] course_code
			vStudInfo.addElement(rs.getString(13));//[10] major_code.
			vStudInfo.addElement(rs.getString(14));//[11] degree_type
		}
		rs.close();
		bolIsTempStud = true;
		if(vStudInfo.size() > 0) {//get downpayment
			strSQLQuery = "select or_number, date_paid, amount from fa_stud_payment where user_index = "+strStudIndex+" and is_valid = 1 and is_stud_temp = 1 and "+
							" sy_from = "+(String)vStudInfo.elementAt(4)+" and semester = "+(String)vStudInfo.elementAt(6)+" and payment_for = 0";
			rs = dbOP.executeQuery(strSQLQuery);
			while(rs.next()) {
				vPaymentDtls.addElement(rs.getString(1));
				vPaymentDtls.addElement(ConversionTable.convertMMDDYYYY(rs.getDate(2)));
				vPaymentDtls.addElement(CommonUtil.formatFloat(rs.getDouble(3), true));
			}
			rs.close();
		}
	}
	else {//get from na_old_stud.
		strSQLQuery = "select NA_OLD_STUD.user_index,fname, mname, lname, cy_from, cy_to, sy_from, sy_to, semester, year_level, Appl_catg, "+
						"course_offered.course_code, major.course_code,DEGREE_TYPE from NA_OLD_STUD "+
						"join user_table on (user_table.user_index = NA_OLD_STUD.user_index) "+
						"join COURSE_OFFERED on (course_offered.course_index = NA_OLD_STUD.course_index) "+
						"left join major on (major.major_index = NA_OLD_STUD.major_index) "+
						"where na_old_stud.is_valid =1 and na_old_stud.user_index = "+strStudIndex;
		rs = dbOP.executeQuery(strSQLQuery);
		if(rs.next()) {
			vStudInfo.addElement(rs.getString(1));//[0] Application_index
			vStudInfo.addElement(WebInterface.formatName(rs.getString(2), rs.getString(3), rs.getString(4), 4));//[1] Name
			vStudInfo.addElement(rs.getString(5));//[2] CY_from
			vStudInfo.addElement(rs.getString(6));//[3] CY_To
			vStudInfo.addElement(rs.getString(7));//[4] sy_from
			vStudInfo.addElement(rs.getString(8));//[5] sy_to
			vStudInfo.addElement(rs.getString(9));//[6] semester
			vStudInfo.addElement(rs.getString(10));//[7] year_level
			vStudInfo.addElement(rs.getString(11));//[8] Appl_catg.
			vStudInfo.addElement(rs.getString(12));//[9] course_code
			vStudInfo.addElement(rs.getString(13));//[10] major_code.
			vStudInfo.addElement(rs.getString(14));//[11] degree_type
		}
		rs.close();
		if(vStudInfo.size() > 0) {//get downpayment
			strSQLQuery = "select or_number, date_paid, amount from fa_stud_payment where user_index = "+strStudIndex+" and is_valid = 1 and is_stud_temp = 0 and "+
							" sy_from = "+(String)vStudInfo.elementAt(4)+" and semester = "+(String)vStudInfo.elementAt(6)+" and payment_for = 0";
			rs = dbOP.executeQuery(strSQLQuery);
			while(rs.next()) {
				vPaymentDtls.addElement(rs.getString(1));
				vPaymentDtls.addElement(ConversionTable.convertMMDDYYYY(rs.getDate(2)));
				vPaymentDtls.addElement(CommonUtil.formatFloat(rs.getDouble(3), true));
			}
			rs.close();
		}
	}
	if(vStudInfo.size() == 0) {
		strErrMsg = "Enrolling information not found.";
		bolIsEnrolled = true;
	}
	else {//I have to now get the subjects advised.. 
		enrollment.FAAssessment FA = new enrollment.FAAssessment();
		vSubjectDtls = FA.getAssessedSubDetail(dbOP,strStudIndex,bolIsTempStud,(String)vStudInfo.elementAt(4),(String)vStudInfo.elementAt(5),(String)vStudInfo.elementAt(7),
						(String)vStudInfo.elementAt(6),(String)vStudInfo.elementAt(11));
		if(vSubjectDtls == null) {
			strErrMsg = FA.getErrMsg();
		}
	}
}

	if((bolIsEnrolled || WI.fillTextValue("addRecord").equals("1")) && strStudID.length() > 0) {
		RegAssignID regAssignID = new RegAssignID();
		
		//I have to auto ins d/p if this is called from phil cst.. 
		if(strSchCode.startsWith("PHILCST")) {
			enrollment.FAPayment faPmt = new enrollment.FAPayment();
			if(!faPmt.autoInsDPPHILCST(dbOP, request, WI.fillTextValue("stud_id"))) {
				dbOP.rollbackOP();
				strErrMsg = faPmt.getErrMsg();
			}
			else
				dbOP.commitOP();
			dbOP.forceAutoCommitToTrue();
			//System.out.println("Err Msg : "+faPmt.getErrMsg());
		}
		
		//System.out.println("here I am : "+strSchCode);
		//I have to find out if this is temp user.. 
		
		if(dbOP.mapUIDToUIndex(strStudID) == null) {
			strPermStudID = regAssignID.confirmTempStudEnrollment(dbOP, strStudID, (String)request.getSession(false).getAttribute("userId"));
			//System.out.println("I am here: Student ID: "+strPermStudID);
		}
		else {
			if(!regAssignID.confirmOldStudEnrollment(dbOP, strStudID,(String)request.getSession(false).getAttribute("userId")))
				strPermStudID = null; 
			else	
				strPermStudID = strStudID;
			if(strPermStudID == null) {//can't validate, just proceed to printing.. 
				strTemp = "select user_index from na_old_stud where exists (select * from user_table where id_number = '"+strStudID+"' and is_valid = 1 and user_index = "+
					"na_old_stud.user_index) and is_valid = 1";
				strTemp = dbOP.getResultOfAQuery(strTemp, 0);
				if(strTemp == null)
					strPermStudID = strStudID;
					
			}
		}
		
		if(strPermStudID == null)
			strErrMsg = regAssignID.getErrMsg();
		else {//get here student information
			bolConfirmEnrollment = true;
			FAPaymentUtil paymentUtil = new FAPaymentUtil();
			
			///check if this is basic student ID :: 
			strSQLQuery = "select course_index from stud_curriculum_hist "+
				"join user_table on (user_table.user_index = stud_curriculum_hist.user_index) "+
				"join semester_sequence on (semester_val = semester) where id_number = '"+strPermStudID+
				"' and stud_curriculum_hist.is_valid = 1 order by sy_from desc, sem_order desc";
			strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
			if(strSQLQuery != null && strSQLQuery.equals("0"))
				paymentUtil.setIsBasic(true);
			///added to validate temp student...  
			
			vStudInfo = paymentUtil.getStudBasicInfoOLD(dbOP, strPermStudID);
			if(vStudInfo == null) {
				strErrMsg = "Student is enrolled successfully. But Error in getting enrollment information. <br> Description : "+
					paymentUtil.getErrMsg();
			}
			else {
				enrollment.FAAssessment faAssessment = new enrollment.FAAssessment();
				strORNumber = faAssessment.getORToReprintAssessment(dbOP, strPermStudID, (String)vStudInfo.elementAt(8),(String)vStudInfo.elementAt(5));
				if(strORNumber == null)
					strErrMsg = faAssessment.getErrMsg();
				else	
					strErrMsg = "Click Link below to print COR for SY/Term : "+(String)vStudInfo.elementAt(8)+ " - "+(String)vStudInfo.elementAt(9)+", "+
						astrConvertSem[Integer.parseInt((String)vStudInfo.elementAt(5))];
			}
		}
	}



if(strErrMsg == null) 
	strErrMsg = "";

if(WI.fillTextValue("forward_").length() > 0 && bolConfirmEnrollment) {
	dbOP.cleanUP();
	response.sendRedirect("../../fee_assess_pay/payment/re_print_assessment.jsp?temp_sl="+WI.fillTextValue("temp_sl")+"&sy_from="+(String)vStudInfo.elementAt(8)+"&sy_to="+
							(String)vStudInfo.elementAt(9)+"&semester="+(String)vStudInfo.elementAt(5)+"&stud_id="+strPermStudID);
	return;
}

String strBatchNumber = null;///used for SWU.. 
if(strSchCode.startsWith("SWU")) {
	if(strStudIndex != null) {//System.out.println("I am here.");
		if(bolIsTempStud)
			strBatchNumber = "select section_name_ from new_application where application_index = "+strStudIndex;
		else
			strBatchNumber = "select section_name from stud_curriculum_hist where user_index = "+strStudIndex+" and section_name is not null and sy_from = "+vStudInfo.elementAt(8);
	}
	else if(vStudInfo != null) {
		strBatchNumber = "select section_name from stud_curriculum_hist where user_index = "+(String)vStudInfo.elementAt(0)+" and section_name is not null and sy_from = "+(String)vStudInfo.elementAt(8);
	}
	//System.out.println(strBatchNumber);
	strBatchNumber = dbOP.getResultOfAQuery(strBatchNumber, 0) ;
}
if(strBatchNumber != null) {
	astrConvertSem[1] = "1st Term";
	astrConvertSem[2] = "2nd Term";
	astrConvertSem[3] = "3rd Term";
	astrConvertSem[4] = "4th Term";
	astrConvertSem[5] = "5th Term";
}

%>

<form name="new_id" action="./validate_and_print_reg_form.jsp" method="post">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF"><strong>::::
          Enrollment confirmation and Printing of Registration Form ::::</strong></font></div></td>
    </tr>
    <tr>
      <td width="4%" height="25" >&nbsp;</td>
	  <td height="25" colspan="3" ><font size="3"><strong><%=strErrMsg%></strong></font></td>
    </tr>
	<tr>
	  <td height="25" >&nbsp;</td>
	  <td height="25" colspan="3" >
	  <a href="../../fee_assess_pay/payment/re_print_assessment.jsp">
	  <font style="font-size:11px; color:#FF0000; font-weight:bold">Click if student already validated or print for previous sy/term	  </font></a>	  </td>
	 </tr>
<%
if(!bolConfirmEnrollment){%>    
<tr>
      <td width="4%" height="25" >&nbsp;</td>
      <td width="19%" height="25" >Temporary/Old Student ID </td>
      <td width="14%" > <input type="text" name="stud_id" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16" onKeyUp="AjaxMapName('1');">      </td>
      <td width="63%" >
	<%if(!bolIsSWU){%>
	  &nbsp; <input type="image" src="../../../images/form_proceed.gif" onClick="AddRecord();">
        <font size="1" style="font-weight:bold; color:#0000FF">click to  confirm enrollment (enrollment can't be confirmed if d/p or advising is not yet done) </font>      
	<%}else{%>
		<input type="button" name="122" id="12" value=" View Advising/Payment Detail >> " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.new_id.addRecord.value='';document.new_id.submit()">
	<%}%>
		</td>
    </tr>
	<tr>
  		<td height="25" >&nbsp;</td>
  		<td height="25" colspan="3" ><label id="coa_info" style="position:absolute; width:400px;"></label></td>
  	</tr>
  	<tr>
  		<td colspan="4"><hr size="1"></td>
  	</tr>
	
	<%if(vSubjectDtls != null && vSubjectDtls.size() > 0) {
		String strSchedule = null;
		String strRoomAndSection = null;//System.out.println(FO.vTuitionFeeDtls);
		String strOfferingDur    = null;
		
		double dTotalLoad = 0d;double dUnitsTaken = 0d;
		double dTotalUnit = 0d;
		
		String strSubSecIndex  = null;
		int iIndex = 0;
		Vector vSubSecDtls = null;
		Vector vLabSched   = null;
		enrollment.SubjectSection SS = new enrollment.SubjectSection();
		
	%>
  	<tr>
  		<td colspan="4" style="font-size:16px; font-weight:bold"><u>Student Information ::</u></td>
  	</tr>
  	<tr>
  		<td colspan="4">
		  	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
			    <tr>
				  <td width="4%" height="20" >&nbsp;</td>
				  <td width="11%">Student name:</td>
				  <td width="51%" ><strong><%=(String)vStudInfo.elementAt(1)%></strong></td>
				  <td width="34%" height="22" style="font-size:18px; font-weight:bold"><%=vStudInfo.elementAt(4)%>-<%=vStudInfo.elementAt(5)%>, <%=astrConvertSem[Integer.parseInt((String)vStudInfo.elementAt(6))]%></td>
			    </tr>
				<tr>
				  <td height="20" >&nbsp;</td>
				  <td>Course /Major: </td>
				  <td><strong><%=(String)vStudInfo.elementAt(9)%>
				  <%
				  if(vStudInfo.elementAt(10) != null){%>
				  / <%=WI.getStrValue(vStudInfo.elementAt(10))%>
				  <%}%>
				  
				  <%=WI.getStrValue((String)vStudInfo.elementAt(7)," - ","","N/A")%>
				  
				  </strong></td>
				  <td height="20" style="font-weight:bold; font-size:22px;"><%if(strBatchNumber != null) {%>Batch: <%=strBatchNumber%><%}%></td>
				</tr>
				<tr>
				  <td height="20" >&nbsp;</td>
				  <td >Curriculum Year: </td>
			      <td ><strong><%=vStudInfo.elementAt(2)%> - <%=vStudInfo.elementAt(3)%></strong></td>
			      <td style="font-size:18px; font-weight:bold"><%=(String)vStudInfo.elementAt(8)%></td>
				</tr>
			</table>
		</td>
  	</tr>
  	<tr><td colspan="4">
		  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
			<tr>
			  <td width="12%" class="thinborder"><div align="center"><font size="1"><strong>SUBJECT CODE </strong></font></div></td>
			  <td width="35%" class="thinborder"><div align="center"><font size="1"><strong>SUBJECT TITLE</strong></font></div></td>
			  <td width="30%" class="thinborder"><div align="center"><font size="1"><strong>SCHEDULE</strong></font></div></td>
			  <td width="18%" class="thinborder"><div align="center"><font size="1"><strong>SECTION &amp; ROOM #</strong></font></div></td>
			  <td width="5%" class="thinborder"><div align="center"><font size="1"><strong> UNITS TAKEN</strong></font></div></td>
		    </tr>
			<%
			for(int i = 0; i< vSubjectDtls.size() ; ++i) {
				dTotalUnit   = Double.parseDouble((String)vSubjectDtls.elementAt(i+3))+Double.parseDouble((String)vSubjectDtls.elementAt(i+4));
				dUnitsTaken += Double.parseDouble((String)vSubjectDtls.elementAt(i+9));
				dTotalLoad  += dTotalUnit;
				strSubSecIndex = (String)vSubjectDtls.elementAt(i);
				//GET THE INFORMATION FROM TUITION FEE FAFeeOperation.vTuitionFeeDtls;
				strTemp = (String)vSubjectDtls.elementAt(i+1);
				if(strTemp.indexOf("NSTP") != -1){
				  iIndex = strTemp.indexOf("(");
				  if(iIndex != -1){
					strTemp = strTemp.substring(0,iIndex);
					strTemp = strTemp.trim();
				  }
				}
		
				//get schedule here.
				vSubSecDtls    = SS.getRoomScheduleDetailInMWF(dbOP, strSubSecIndex);//System.out.println(vSubSecDtls);
				vLabSched      = SS.getLabSched(dbOP,strSubSecIndex);
				strOfferingDur = WI.getStrValue(dbOP.mapOneToOther("E_SUB_SECTION","SUB_SEC_INDEX",strSubSecIndex,"offering_dur",null));
				if(strOfferingDur.length()> 0)
					strOfferingDur += "<br>";
		
				if(vSubSecDtls == null || vSubSecDtls.size() ==0)
				{
					strErrMsg = SS.getErrMsg();
					break;
				}
				for(int b=0; b<vSubSecDtls.size(); ++b)
				{
					if(strRoomAndSection == null)
					{
						strRoomAndSection = (String)vSubSecDtls.elementAt(b)+"/"+(String)vSubSecDtls.elementAt(b+1);
						strSchedule = (String)vSubSecDtls.elementAt(b+2);
					}
					else
					{
						strRoomAndSection += "<br>"+(String)vSubSecDtls.elementAt(b+1);
						strSchedule += "<br>"+(String)vSubSecDtls.elementAt(b+2);
					}
					b = b+2;
				}
				if(vLabSched != null)
				{
				  for (int p = 0; p < vLabSched.size(); ++p)
				  {
					strSchedule += "<br>"+(String)vLabSched.elementAt(p+2) + "(lab)";
					strRoomAndSection += "<br>" + (String) vLabSched.elementAt(p + 1) + "(lab)";
					p = p+ 2;
				  }
				}
				%>
				<tr>
				  <td height="25" class="thinborder"><%=(String)vSubjectDtls.elementAt(i+1)%></td>
				  <td class="thinborder"><%=(String)vSubjectDtls.elementAt(i+2)%></td>
				  <td class="thinborder"><%=strOfferingDur+strSchedule%></td>
				  <td class="thinborder"><%=strRoomAndSection%></td>
				  <td class="thinborder"><%=(String)vSubjectDtls.elementAt(i+9)%></td>
				</tr>
		<% i = i+9;
		strRoomAndSection = null;
		strSchedule = null;
		}%>
		  </table>
		  <table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
  			<tr>
			  <td colspan="2" height="25"><div align="center">TOTAL UNITS TAKEN: <strong><%=dUnitsTaken%></strong></div></td>
			</tr>
			<%if(vPaymentDtls == null || vPaymentDtls.size() == 0) {%>
  			<tr>
			  <td height="25" style="font-size:18px; font-weight:bold;">No Payment Details found.</td>
			  <td valign="top" align="right">
				<input type="button" name="122" id="12" value=" Confirm Enrollment >> " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.new_id.addRecord.value='1';document.new_id.submit()">
			  </td>
			</tr>
			<%}else{%>
  			<tr>
			  <td width="50%">
			  		<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
						<tr bgcolor="#CCCCCC">
							<td class="thinborder" height="18">OR Number</td>
							<td class="thinborder">Date Paid</td>
							<td class="thinborder">Amount</td>
						</tr>
						<%for(int i = 0; i < vPaymentDtls.size(); i += 3) {%>
						<tr>
							<td class="thinborder" height="18"><%=vPaymentDtls.elementAt(i)%></td>
							<td class="thinborder"><%=vPaymentDtls.elementAt(i + 1)%></td>
							<td class="thinborder"><%=vPaymentDtls.elementAt(i + 2)%></td>
						</tr>
						<%}%>
					</table>
			  </td>
			  <td valign="top" align="right">
				<input type="button" name="122" id="12" value=" Confirm Enrollment >> " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.new_id.addRecord.value='1';document.new_id.submit()">
			  </td>
			</tr>
			<%}%>

		  </table>		
		
		
		</td>
  	</tr>
	<%}%>
	
	
	
<%}else if(vStudInfo != null && vStudInfo.size() > 0){%>
    <tr>
      <td height="25" >&nbsp;</td>
      <td colspan="3" height="25" >Student name : <strong><%=(String)vStudInfo.elementAt(1)%></strong></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td colspan="3" height="25" >Course /Major: <strong><%=(String)vStudInfo.elementAt(2)%>
	  <%
	  if(vStudInfo.elementAt(3) != null){%>
	  / <%=WI.getStrValue(vStudInfo.elementAt(3))%>
	  <%}%>
	  </strong></td>
    </tr>
    <tr>
      <td height="26" >&nbsp;</td>
      <td height="26" colspan="2" >Year : <strong><%=WI.getStrValue(vStudInfo.elementAt(4),"N/A")%></strong></td>
      <td height="26" >&nbsp;</td>
    </tr>
    <tr>
      <td height="26" >&nbsp;</td>
      <td height="26" colspan="2" >SY-Term : <strong><%=vStudInfo.elementAt(8)%> - <%=vStudInfo.elementAt(9)%>,<%=astrConvertSem[Integer.parseInt((String)vStudInfo.elementAt(5))]%></strong>
	  <input type="hidden" name="sy_" value="<%=vStudInfo.elementAt(8)%>">
	  <input type="hidden" name="sem_" value="<%=vStudInfo.elementAt(5)%>">
	  <input type="hidden" name="stud_" value="<%=strPermStudID%>">	  </td>
      <td height="26" style="font-weight:bold; font-size:22px;"><%if(strBatchNumber != null) {%>Batch: <%=strBatchNumber%><%}%></td>
    </tr>
    <tr>
      <td colspan="4" height="25" ><hr size="1"></td>
    </tr>
<%if(strSchCode.startsWith("PHILCST")){%>
    <tr>
      <td height="25" >&nbsp;</td>
      <td  colspan="3" height="25" >Confirmed Student ID :<strong> <u><%=strPermStudID%></u></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td  colspan="3" height="25" style="font-weight:bold; font-size:14px;">Font size to print class card and reg form : 
		<select name="font_size">
<%
int iDef = 11;
for(int i = 10; i < 15; ++i){
if(i == iDef)
	strTemp = " selected";
else	
	strTemp = "";
%>
			<option value="<%=i%>"<%=strTemp%>><%=i%> px</option>
<%}%>
	  </select>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td  colspan="3" height="25" style="font-weight:bold; font-size:14px;">
	  	<a href="javascript:printRegForm('<%=strORNumber%>','1','<%=vStudInfo.elementAt(2)%>');">Click to print Official Registration Form</a>
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  	<a href="javascript:printClassCard('<%=strORNumber%>','1');">Click to print class card</a>	  </td>
    </tr>
<%}else if(strSchCode.startsWith("CIT")){%>
    <tr>
      <td height="25" >&nbsp;</td>
      <td  colspan="3" height="25" >Confirmed Student ID :<strong> <u><%=strPermStudID%></u> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  	<a href="../../fee_assess_pay/payment/enrollment_receipt_print.jsp?or_number=<%=strORNumber%>">Click to print Official Study Load</a>
		</strong></td>
    </tr>
<%}else{%>
    <tr>
      <td height="25" >&nbsp;</td>
      <td  colspan="3" height="25" >Confirmed Student ID :<strong> <u><%=strPermStudID%></u> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  	<a href="../../fee_assess_pay/payment/enrollment_receipt_print.jsp?or_number=<%=strORNumber%>">Click to print Official Registration Form</a>
		</strong></td>
    </tr>
<%if(strSchCode.startsWith("CDD")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td  colspan="3" height="25" style="font-weight:bold; font-size:14px;">Font size to print class card : 
		<select name="font_size">
<%
int iDef = 11;
for(int i = 10; i < 15; ++i){
if(i == iDef)
	strTemp = " selected";
else	
	strTemp = "";
%>
			<option value="<%=i%>"<%=strTemp%>><%=i%> px</option>
<%}%>
	  </select>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td  colspan="3" height="25" style="font-weight:bold; font-size:14px;">
<%
//get here student schedule.. 
enrollment.ReportEnrollment RE = new enrollment.ReportEnrollment();
Vector vStudSched = RE.getStudentLoad(dbOP, strPermStudID,(String)vStudInfo.elementAt(8),(String)vStudInfo.elementAt(9),
											(String)vStudInfo.elementAt(5));
if(vStudSched != null && vStudSched.size() > 0) {%>
	<select name="print_subcode">
		<option value="">ALL</option>
<%for(int i =1; i < vStudSched.size(); i +=11){%>
		<option value="<%=(String)vStudSched.elementAt(i)%>"><%=(String)vStudSched.elementAt(i)%></option>
<%}%>	
	</select>
<%}%>



	  	<a href="javascript:printClassCard('<%=strORNumber%>','1');">Click to print class card</a>	  </td>
    </tr>
<%}%>
<%}//end of different reg form pages.%>

<%}%>
  </table>

  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td colspan="8" height="25" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="8" height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="addRecord" value="0">
<input type="hidden" name="forward_" value="<%=WI.fillTextValue("forward_")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>