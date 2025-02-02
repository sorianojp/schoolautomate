<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
	
	.thinborderALL {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
-->
</style>
</head>
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	String strDegreeType = null;
	
	String strCollegeName = null;//I have to find the college offering course.

	int iRowStartFr = Integer.parseInt(WI.fillTextValue("row_start_fr"));
	int iRowCount   = Integer.parseInt(WI.fillTextValue("row_count"));
	int iRowEndsAt  = iRowStartFr + iRowCount;
	int iLastPage   = Integer.parseInt(WI.fillTextValue("last_page"));

	int iPageNumber = Integer.parseInt(WI.fillTextValue("page_number"));
	String strTotalPageNumber = WI.fillTextValue("total_page");

	String strImgFileExt = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-REPORTS-OTR","otr_print.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Imange file extension is missing. Please contact school admin.";
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
														"otr_print.jsp");
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
Vector vStudInfo = null;
Vector vAdditionalInfo = null;
Vector vEntranceData = null;
Vector vGraduationData = null;
Vector vRetResult  = null;

String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};

enrollment.ReportRegistrar repRegistrar  = new enrollment.ReportRegistrar();
enrollment.OfflineAdmission offlineAdm = new enrollment.OfflineAdmission();

if(WI.fillTextValue("stud_id").length() > 0) {
	vStudInfo = offlineAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"));
	if(vStudInfo == null || vStudInfo.size() ==0)
		strErrMsg = offlineAdm.getErrMsg();
	else {
		strCollegeName = new enrollment.CurriculumMaintenance().getCollegeName(dbOP,(String)vStudInfo.elementAt(5));
		if(strCollegeName != null)
			strCollegeName = strCollegeName.toUpperCase();
			
		student.StudentInfo studInfo = new student.StudentInfo();
		vAdditionalInfo = studInfo.getStudInfoOTRCanForGradForm17(dbOP,
			(String)vStudInfo.elementAt(12));
		if(vAdditionalInfo == null || vAdditionalInfo.size() ==0)
			strErrMsg = studInfo.getErrMsg();
	}
}
if(vStudInfo != null && vStudInfo.size() > 0) {
	enrollment.EntranceNGraduationData entranceGradData = new enrollment.EntranceNGraduationData();
	vEntranceData = entranceGradData.operateOnEntranceData(dbOP,request,4);
	vGraduationData = entranceGradData.operateOnGraduationData(dbOP,request,4);
	if(vEntranceData == null || vGraduationData == null)
		strErrMsg = entranceGradData.getErrMsg();
}

//save encoded information if save is clicked.
Vector vForm17Info = null;
vForm17Info = repRegistrar.operateOnForm17Form18EncodedInfo(dbOP, request,2,true);
if(vForm17Info != null && vForm17Info.size() ==0)
	vForm17Info = null;
String[] astrConvertToDocType = {"Form 137-A","Transcript of Record","C.E.A No."};

if(vStudInfo != null && vStudInfo.size() > 0) {
	strDegreeType = (String)vStudInfo.elementAt(15);
	vRetResult = repRegistrar.getOTROfCanForGrad(dbOP, WI.fillTextValue("stud_id"), strDegreeType);
	if(vRetResult == null)
		strErrMsg = repRegistrar.getErrMsg();
}

String strCurrentSchoolName = SchoolInformation.getSchoolName(dbOP,true,false);
%>

<body topmargin="5">
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="15%" height="25"><div align="right">Sheet No. <%=iPageNumber%> of <%=strTotalPageNumber%></div></td>
  </tr>
</table>
<%
if(iPageNumber != 1){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="13%">&nbsp;</td>
    <td width="68%" height="9">&nbsp;</td>
    <td width="19%" rowspan="4"> <table cellpadding="0" cellspacing="0">
        <tr>
          <td ><img src="../../../upload_img/<%=WI.fillTextValue("stud_id").toUpperCase()+"."+strImgFileExt%>" height="130" width="130" border="1"></td>
        </tr>
      </table></td>
  </tr>
  <tr>
    <td width="13%">&nbsp;</td>
    <td height="29" valign="bottom">Name &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;<strong><%=((String)vStudInfo.elementAt(2)).toUpperCase()%>,<%=WI.getStrValue((String)vStudInfo.elementAt(0)).toUpperCase()%>
      <%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%></strong></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td height="25" valign="bottom">Address <strong> &nbsp;&nbsp;&nbsp;<%=WI.getStrValue((String)vAdditionalInfo.elementAt(3))%>
      <%=WI.getStrValue((String)vAdditionalInfo.elementAt(4),",","","")%> <%=WI.getStrValue((String)vAdditionalInfo.elementAt(5),",","","")%>
      <%=WI.getStrValue((String)vAdditionalInfo.elementAt(7),"-","","")%> <%=WI.getStrValue((String)vAdditionalInfo.elementAt(6),",","","")%>
      </strong></td>
  </tr>
  <tr>
    <td width="13%">&nbsp;</td>
    <td height="9" valign="bottom">&nbsp;</td>
  </tr>
  <tr>
    <td height="10">&nbsp;</td>
    <td height="10" colspan="2"><div align="right"></div></td>
  </tr>
</table>
<%}else{%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td width="164">&nbsp;</td>
    <td width="587">&nbsp;</td>
    <td width="177" height="23"><strong><%=WI.getTodaysDate(1)%></strong>&nbsp;&nbsp;</td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborderALL">
  <tr> 
    <td width="111" height="25"><strong>Name</strong> </td>
    <td><strong><%=((String)vStudInfo.elementAt(2)).toUpperCase()%>,<%=((String)vStudInfo.elementAt(0)).toUpperCase()%> <%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%></strong></td>
    <td width="406"><strong>Address : <%=WI.getStrValue((String)vAdditionalInfo.elementAt(3))%> <%=WI.getStrValue((String)vAdditionalInfo.elementAt(4),",","","")%> <%=WI.getStrValue((String)vAdditionalInfo.elementAt(5),",","","")%> <%=WI.getStrValue((String)vAdditionalInfo.elementAt(7),"-","","")%> <%=WI.getStrValue((String)vAdditionalInfo.elementAt(6),",","","")%> </strong></td>
  </tr>
  <tr> 
    <td height="25"><strong>Date of Birth</strong></td>
    <td width="253"><strong><%=WI.getStrValue(vAdditionalInfo.elementAt(1))%></strong></td>
    <td><strong>Place of Birth : <%=WI.getStrValue(vAdditionalInfo.elementAt(2))%></strong></td>
  </tr>
  <tr> 
    <td height="25"><strong>College:</strong></td>
    <td><strong>of <%=strCollegeName%></strong></td>
    <td><strong>Date of Admission: &nbsp; 
      <%
if(vEntranceData != null)
	strTemp = WI.getStrValue(vEntranceData.elementAt(23),"&nbsp;");
else	
	strTemp = "&nbsp;";
%>
      <strong><%=strTemp%></strong></strong></td>
  </tr>
  <tr> 
    <td height="25" colspan="3"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr> 
          <td height="30">&nbsp;</td>
          <td><div align="center"><strong>PRELIMINARY EDUCATION</strong></div></td>
          <td>&nbsp;</td>
        </tr>
        <tr> 
          <td width="14%" height="19">&nbsp;</td>
          <td width="67%"><strong> </strong></td>
          <td width="19%"><div align="center">SCHOOL YEAR</div></td>
        </tr>
        <tr> 
          <td height="25"><div align="left"><strong>Primary</strong></div></td>
          <td> &nbsp; 
            <%
if(vEntranceData != null)
	strTemp = WI.getStrValue(vEntranceData.elementAt(14),"&nbsp;");
else	
	strTemp = "&nbsp;";
%>
            <strong><%=strTemp%></strong></td>
          <td><div align="center">&nbsp; 
              <%
if(vEntranceData != null)
	strTemp = WI.getStrValue(vEntranceData.elementAt(18),"&nbsp;");
else	
	strTemp = "&nbsp;";
%>
              <strong><%=strTemp%></strong></div></td>
        </tr>
        <tr> 
          <td height="25"><div align="left"><strong>Intermediate</strong></div></td>
          <td> &nbsp; 
            <%
if(vEntranceData != null)
	strTemp = WI.getStrValue(vEntranceData.elementAt(14),"&nbsp;");
else	
	strTemp = "&nbsp;";
%>
            <strong><%=strTemp%></strong></td>
          <td><div align="center">&nbsp; 
              <%
if(vEntranceData != null)
	strTemp = WI.getStrValue(vEntranceData.elementAt(20),"&nbsp;");
else	
	strTemp = "&nbsp;";
%>
              <strong><%=strTemp%></strong></div></td>
        </tr>
        <tr> 
          <td height="25"><div align="left"><strong>High School&nbsp;&nbsp;&nbsp;</strong></div></td>
          <td> &nbsp; 
            <%
if(vEntranceData != null)
	strTemp = WI.getStrValue(vEntranceData.elementAt(5),"&nbsp;");
else	
	strTemp = "&nbsp;";
%>
            <strong><%=strTemp%></strong></td>
          <td><div align="center">&nbsp; 
              <%
if(vEntranceData != null)
	strTemp = WI.getStrValue(vEntranceData.elementAt(22),"&nbsp;");
else	
	strTemp = "&nbsp;";
%>
              <strong><%=strTemp%></strong></div></td>
        </tr>
      </table></td>
  </tr>
</table>
<br>
<%}//if iPage number = 1
if(vRetResult != null && vRetResult.size() > 0){%>
<table  width="100%" border="0" cellpadding="1" cellspacing="0" bgcolor="#E2E2E2" class="thinborderALL">
  <tr bgcolor="#FFFFFF"> 
    <td height="13"><div align="center">TERM</div></td>
    <td><div align="center">NAME OF COURSE</div></td>
    <td><div align="center">DESCRIPTION</div></td>
    <td colspan="2"><div align="center">GRADE</div></td>
    <td width="10%" rowspan="2"><div align="center">Credits Earned</div></td>
  </tr>
  <tr bgcolor="#FFFFFF"> 
    <td width="9%" height="25"><div align="center"></div></td>
    <td width="20%"><div align="center"></div></td>
    <td width="46%"><div align="center"></div></td>
    <td width="7%"><div align="center">Final </div></td>
    <td width="8%"><div align="center">Re-Exams </div></td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="1" bgcolor="#E2E2E2">
  <%
int iIndexOfSubGroup = 0; //to get index of group compare the vRetResult with the group info vector
String strSchoolName = null;
String strPrevSchName = null;
String strSchNameToDisp = null;

String strSYSemToDisp   = null;
String strCurSYSem      = null;
String strPrevSYSem     = null;

String strHideRowLHS = "<!--";
String strHideRowRHS = "-->";
int iCurrentRow = 0;//System.out.println(vRetResult);
for(int i = 0 ; i < vRetResult.size(); i += 11, ++iCurrentRow){
	strSchoolName = (String)vRetResult.elementAt(i);
	if(strSchoolName != null) {
		if(strPrevSchName == null) {
			strPrevSchName = strSchoolName ;
			strSchNameToDisp = strSchoolName;
		}
		else if(strPrevSchName.compareTo(strSchoolName) ==0) {
			strSchNameToDisp = null;
		}
		else {//itis having a new school name.
			strPrevSchName = strSchoolName;
			strSchNameToDisp = strPrevSchName;
		}
	}
 	//if prev school name is not not null, show the current shcool name.
	if(strSchoolName == null && strPrevSchName != null) {
		strSchNameToDisp = strCurrentSchoolName;
		strPrevSchName = null;
	}

//strCurSYSem =
if(vRetResult.elementAt(i+ 3) != null) {//null only if accredited subject - foreign stud.
	if(((String)vRetResult.elementAt(i+ 3)) != null && ((String)vRetResult.elementAt(i+ 3)).length() == 1) {
		strCurSYSem = astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(i+ 3))]+" ,"+
					(String)vRetResult.elementAt(i+ 1)+" - "+(String)vRetResult.elementAt(i+ 2);
	}
	else {
		strCurSYSem = (String)vRetResult.elementAt(i+ 3)+" ,"+(String)vRetResult.elementAt(i+ 1)+" - "+
							(String)vRetResult.elementAt(i+ 2);
	}
	if(strCurSYSem != null) {
		if(strPrevSYSem == null) {
			strPrevSYSem = strCurSYSem ;
			strSYSemToDisp = strCurSYSem;
		}
		else if(strPrevSYSem.compareTo(strCurSYSem) ==0) {
			strSYSemToDisp = null;
		}
		else {//itis having a new school name.
			strPrevSYSem = strCurSYSem;
			strSYSemToDisp = strPrevSYSem;
		}
	}
}


 //Very important here, it print <!-- if it is not to be shown.
 if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){%>
  <%=strHideRowLHS%> 
  <%}

if(strSchNameToDisp != null){%>
  <tr bgcolor="#FFFFFF"> 
    <td height="20" colspan="6"><div align="center"><strong><u><%=strSchNameToDisp.toUpperCase()%></u></strong></div></td>
  </tr>
  <%strSchNameToDisp = null;}

if(strSYSemToDisp != null){%>
  <tr bgcolor="#FFFFFF"> 
    <td colspan="6"><strong><%=strSYSemToDisp%></strong></td>
  </tr>
  <%}
%>
  <tr bgcolor="#FFFFFF"> 
    <td width="9%" height="20">&nbsp;</td>
    <td width="20%"><%=vRetResult.elementAt(i + 6)%></td>
    <td width="46%"><%=vRetResult.elementAt(i + 7)%></td>
    <td width="7%"><div align="center"><%=WI.getStrValue(vRetResult.elementAt(i + 8), "&nbsp;")%></div></td>
    <td width="8%"><div align="center"> 
        <%
	//it is re-exam if student has INC and cleared in same semester,
	strTemp = null;
	if(vRetResult.size() > (i + 16) && vRetResult.elementAt(i + 8) != null && ((String)vRetResult.elementAt(i + 8)).toLowerCase().indexOf("inc") != -1 &&
		((String)vRetResult.elementAt(i + 6)).compareTo((String)vRetResult.elementAt(i + 6 + 11)) == 0 && //sub code,
	    ((String)vRetResult.elementAt(i + 1)).compareTo((String)vRetResult.elementAt(i + 1 + 11)) == 0 && //sy_from
		((String)vRetResult.elementAt(i + 2)).compareTo((String)vRetResult.elementAt(i + 2 + 11)) == 0 && //sy_to
		WI.getStrValue(vRetResult.elementAt(i + 3),"1").compareTo(WI.getStrValue(vRetResult.elementAt(i + 3 + 11),"1")) == 0) { //semester
			strTemp = (String)vRetResult.elementAt(i + 9 + 11);
			%>
        <%=(String)vRetResult.elementAt(i + 8 + 11)%> 
        <% i += 11;}%>
      </div></td>
    <td width="10%"><div align="center"> 
        <%if(strTemp != null) {%>
        <%=strTemp%> 
        <%}else{%>
        <%=WI.getStrValue(vRetResult.elementAt(i + 9))%> 
        <%}%>
      </div></td>
  </tr>
  <%
   if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){%>
  <%=strHideRowRHS%> 
  <%}
   }//end of for loop
   %>
</table>
<%}//only if student is having grade infromation.%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<%if(WI.fillTextValue("last_page").compareTo("1") != 0){%>
  <tr>
    <td height="25" colspan="2">
	<font size="2">REMARKS : </font><font size="1">
	continued on sheet no. <%=iPageNumber+1%></font></td>
  </tr>
<%}else{
 if(vEntranceData != null &&  (String)vEntranceData.elementAt(12) != null){//if last page, i have to show the remark.%>  
  <tr>
    <td height="25" colspan="2" class="thinborderALL" align="center">&nbsp; <%=(String)vEntranceData.elementAt(12)%></td>
  </tr>
<%}%>
  <tr>
    <td height="25" colspan="2" class="thinborderALL" align="center">LNULNULNULNULNULNULNULNULNULNULNULNULNULNULNULNULNULNULNULNULNULNULNULNULNULNULNULNULNU</td>
  </tr>

<%}//end of last page.%>
<tr>
    <td height="10" colspan="2">&nbsp;</td>
  </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td height="25" colspan="4"><strong>Grading System</strong></td>
    <td width="38%">&nbsp;</td>
    <td width="33%">&nbsp;</td>
  </tr>
  <tr> 
    <td width="4%" height="15">1.0</td>
    <td width="9%">98 - 100</td>
    <td width="4%">2.25</td>
    <td width="12%">83 - 85</td>
    <td width="38%">&nbsp;</td>
    <td width="33%"><strong>ENDORSEMENT</strong></td>
  </tr>
  <tr> 
    <td height="15">1.25</td>
    <td>95 - 97</td>
    <td>2.5</td>
    <td>80 - 82</td>
    <td width="38%">Prepared by : <strong><%=WI.fillTextValue("prep_by1")%></strong></td>
    <td width="33%">Correct Transcript of Record</td>
  </tr>
  <tr> 
    <td height="15">1.5</td>
    <td>92 - 94</td>
    <td>2.75</td>
    <td>77 - 79</td>
    <td width="38%">&nbsp;</td>
    <td width="33%">&nbsp;</td>
  </tr>
  <tr> 
    <td height="15">1.75</td>
    <td>89 - 91</td>
    <td>3.0</td>
    <td>75 - 76</td>
    <td width="38%">&nbsp;</td>
    <td width="33%"><div align="center">_____________________________</div></td>
  </tr>
  <tr> 
    <td height="15">2.0</td>
    <td>86 - 88</td>
    <td>5.0</td>
    <td>70 - 74</td>
    <td width="38%">Checked by : <strong><%=WI.fillTextValue("check_by1")%></strong></td>
    <td width="33%"><div align="center"><strong><%=WI.fillTextValue("registrar_name").toUpperCase()%></strong></div></td>
  </tr>
  <tr>
    <td height="15">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td><div align="center">University Registrar</div></td>
  </tr>
</table>

<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td width="100%" height="20" valign="bottom"><strong>Not Valid Without University 
      Seal</strong></td>
  </tr>
</table>

<%//System.out.println(WI.fillTextValue("print_"));
if(WI.fillTextValue("print_").compareTo("1") == 0){%>
<script language="javascript">
 window.print();
</script>
<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>
