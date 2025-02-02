<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"><HTML><HEAD><TITLE>Untitled Document</TITLE>
<META name=GENERATOR content="Evrsoft First Page">
<META content="text/html; charset=us-ascii" http-equiv=Content-Type>
<STYLE type=text/css>BODY {
	FONT-FAMILY: Calibri; FONT-SIZE: 12px
}
TD {
	FONT-FAMILY: Calibri; FONT-SIZE: 12px
}
TH {
	FONT-FAMILY: Calibri; FONT-SIZE: 12px
}
.fontsize9 {
	FONT-FAMILY: Calibri; FONT-SIZE: 9px
}
TABLE.thinborder {
	FONT-FAMILY: Calibri; FONT-SIZE: 12px; BORDER-TOP: #000000 1px solid; BORDER-RIGHT: #000000 1px solid
}
TD.thinborder {
	BORDER-BOTTOM: #000000 1px solid; BORDER-LEFT: #000000 1px solid; FONT-FAMILY: Calibri; FONT-SIZE: 12px
}
.thinborderALL {
	BORDER-BOTTOM: #000000 1px solid; BORDER-LEFT: #000000 1px solid; FONT-FAMILY: Calibri; FONT-SIZE: 12px; BORDER-TOP: #000000 1px solid; BORDER-RIGHT: #000000 1px solid
}
TD.thinborderLEFT {
	BORDER-LEFT: #000000 1px solid; FONT-FAMILY: Calibri; FONT-SIZE: 12px
}
TD.thinborderRIGHT {
	FONT-FAMILY: Calibri; FONT-SIZE: 12px; BORDER-RIGHT: #000000 1px solid
}
TD.thinborderLEFTRIGHT {
	BORDER-LEFT: #000000 1px solid; FONT-FAMILY: Calibri; FONT-SIZE: 12px; BORDER-RIGHT: #000000 1px solid
}
TD.thinborderTOP {
	FONT-FAMILY: Calibri; FONT-SIZE: 12px; BORDER-TOP: #000000 1px solid
}
TD.thinborderBOTTOM {
	BORDER-BOTTOM: #000000 1px solid; FONT-FAMILY: Calibri; FONT-SIZE: 12px
}
TD.thinborderRIGHTBOTTOM {
	BORDER-BOTTOM: #000000 1px solid; FONT-FAMILY: Calibri; FONT-SIZE: 12px; BORDER-RIGHT: #000000 1px solid
}
TD.thinborderTOPRIGHTBOTTOM {
	BORDER-BOTTOM: #000000 1px solid; FONT-FAMILY: Calibri; FONT-SIZE: 12px; BORDER-TOP: #000000 1px solid; BORDER-RIGHT: #000000 1px solid
}
TD.thinborderTOPLEFTBOTTOM {
	BORDER-BOTTOM: #000000 1px solid; BORDER-LEFT: #000000 1px solid; FONT-FAMILY: Calibri; FONT-SIZE: 12px; BORDER-TOP: #000000 2px solid
}
TD.thinborderTOPLEFT {
	BORDER-LEFT: #000000 1px solid; FONT-FAMILY: Calibri; FONT-SIZE: 12px; BORDER-TOP: #000000 2px solid
}
TD.thinborderLEFTBOTTOM {
	BORDER-BOTTOM: #000000 1px solid; BORDER-LEFT: #000000 1px solid; FONT-FAMILY: Calibri; FONT-SIZE: 12px
}
TD.thinborderTOPBOTTOM {
	BORDER-BOTTOM: #000000 1px solid; FONT-FAMILY: Calibri; FONT-SIZE: 12px; BORDER-TOP: #000000 1px solid
}
TD.thinborderLEFTRIGHTBOTTOM {
	BORDER-BOTTOM: #000000 1px solid; BORDER-LEFT: #000000 1px solid; FONT-FAMILY: Calibri; FONT-SIZE: 12px; BORDER-RIGHT: #000000 1px solid
}
</STYLE>
<%@ page language="java" import="utility.*,java.util.Vector" %><%
            DBOperation dbOP = null;
            String strErrMsg = null;
            String strTemp = null;
            WebInterface WI = new WebInterface(request);
            String strDegreeType = null;
      
           String strCollegeName = null;//I have to find the college offering course.
      
           int iRowStartFr = Integer.parseInt(WI.getStrValue(WI.fillTextValue("row_start_fr"),"0"));
            int iRowCount   = Integer.parseInt(WI.getStrValue(WI.fillTextValue("row_count"),"0"));
            int iRowEndsAt  = iRowStartFr + iRowCount;
            int iLastPage   = Integer.parseInt(WI.getStrValue(WI.fillTextValue("last_page"),"0"));
      
           int iRowsPrinted = 0;
            int iMaxRowToDisp = Integer.parseInt(WI.getStrValue(WI.fillTextValue("max_page_to_disp"),"0"));
      
           int iLastIndex = -1;
      
           int iPageNumber = Integer.parseInt(WI.getStrValue(WI.fillTextValue("page_number"),"0"));
            String strTotalPageNumber = WI.fillTextValue("total_page");
      
    
         String strImgFileExt = null;
            String strRootPath  = null;
      
    //add security here.
            try
            {
                   dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
                                                                   "Admin/staff-Registrar Management-REPORTS-OTR","otr_print.jsp");
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
                   %></HEAD>
<BODY>
<P align=center><FONT size=3 face="Verdana, Arial, Helvetica, sans-serif">Error 
in opening connection</FONT></P><%
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
      Vector vCompliedRequirement = null;
      Vector vStudRequirements = null;
      String strAdmissionStatus = null;
      
    Vector vMulRemark = null;
      int iMulRemarkIndex = -1;
      
    
    boolean bolShowLabel = false;
      
    
    String[] astrConvertSem = {"Summer","First Semester","Second Semester","Third Semester",""};
      
    enrollment.ReportRegistrar repRegistrar  = new enrollment.ReportRegistrar();
      enrollment.OfflineAdmission offlineAdm = new enrollment.OfflineAdmission();
      enrollment.CourseRequirement cRequirement = new enrollment.CourseRequirement();
      
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
      
           Vector vFirstEnrl = cRequirement.getFirstEnrollment(dbOP,request.getParameter("stud_id"),
                                                                                                                   (String)vStudInfo.elementAt(7),
                                                                                                           (String)vStudInfo.elementAt(8));
                   if (vFirstEnrl != null) {
                           vStudRequirements = cRequirement.getStudentPendingCompliedList(dbOP,(String)vStudInfo.elementAt(12),
                                                                                           (String)vFirstEnrl.elementAt(0),(String)vFirstEnrl.elementAt(1),
                                                                                           (String)vFirstEnrl.elementAt(2),false,false,true,true);
      
                           if(vStudRequirements == null) {
                                   if(strErrMsg == null)
                                           strErrMsg = cRequirement.getErrMsg();//System.out.println(strErrMsg);
                           }
                           else {
                                   vCompliedRequirement = (Vector)vStudRequirements.elementAt(1);
                           }
      
                   strAdmissionStatus = (String)vFirstEnrl.elementAt(3);
                   if (strAdmissionStatus == null)
                           strAdmissionStatus = "";
                   else {
                           strAdmissionStatus = strAdmissionStatus.toLowerCase();
                           if (strAdmissionStatus.equals("new"))
                                   strAdmissionStatus = "High School Graduate";
                           else if (strAdmissionStatus.startsWith("trans"))
                                   strAdmissionStatus = "College Undergraduate";
                           else if (strAdmissionStatus.startsWith("second"))
                                   strAdmissionStatus = "College Graduate";
      
                           // insert other status here!!
                   }
      
             }else strErrMsg = cRequirement.getErrMsg();
      }
      
    //save encoded information if save is clicked.
      Vector vForm17Info = null;
      vForm17Info = repRegistrar.operateOnForm17Form18EncodedInfo(dbOP, request,2,true);
      if(vForm17Info != null && vForm17Info.size() ==0)
            vForm17Info = null;
      String[] astrConvertToDocType = {"Form 137-A","Transcript of Record","C.E.A No."};
      
    if(vStudInfo != null && vStudInfo.size() > 0) {
            strDegreeType = (String)vStudInfo.elementAt(15);
            vRetResult = repRegistrar.getOTROfCanForGrad(dbOP, WI.fillTextValue("stud_id"), strDegreeType, true);
            if(vRetResult == null)
                   strErrMsg = repRegistrar.getErrMsg();
            else {
                   vMulRemark = (Vector)vRetResult.remove(0);
                   for(int i = 0; i < vRetResult.size(); i += 11) {//remove credited subject from TOR.
                           if(vRetResult.elementAt(i + 1) != null)
                                   break;
                           vRetResult.remove(i);vRetResult.remove(i);vRetResult.remove(i);vRetResult.remove(i);
                           vRetResult.remove(i);vRetResult.remove(i);vRetResult.remove(i);vRetResult.remove(i);
                           vRetResult.remove(i);vRetResult.remove(i);vRetResult.remove(i);
                           i -= 11;
                   }
            }
      }
      String strCurrentSchoolName = SchoolInformation.getSchoolName(dbOP,false,false);
      
    String[] astrLecLabHr = null;//gets lec/lab hour information.
      String strRLEHrs    = null;
      String strCE        = null;
      
    
    //System.out.println(vMulRemark);
      %>
<SCRIPT language=javascript type=text/javascript>
function UpdateLastRemark() {
	obj = document.getElementById('last_remark');
	var strRemark = prompt("Please enter new remark",obj.innerHTML);
	if(strRemark == null)
	       return;
	obj.innerHTML = strRemark;
}
function UpdateInfo(labelID) {
	obj = document.getElementById(labelID);
	var strNewVal = prompt("Please enter new value :",obj.innerHTML);
	if(strNewVal == null)
	       return;
	obj.innerHTML = strNewVal;
}
</SCRIPT>

<TABLE border=0 cellSpacing=0 cellPadding=0 width="100%" align=center>
  <TBODY>
  <TR>
    <TD height=150>&nbsp;</TD></TR></TBODY></TABLE><%if(iPageNumber == 1){%>
<TABLE border=0 cellSpacing=0 cellPadding=0 width="100%">
  <TBODY>
  <TR>
    <TD height=16 width="12%"><FONT size=2>Name</FONT></TD>
    <TD width="38%"><FONT size=2>: <%=((String)vStudInfo.elementAt(2)).toUpperCase()%>, <%=WI.getStrValue((String)vStudInfo.elementAt(0)).toUpperCase()%> <%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%></FONT></TD>
    <TD width="11%"><FONT size=2>Date of Birth</FONT></TD>
    <TD width="39%"><FONT size=2>:</FONT> <%=WI.getStrValue(vAdditionalInfo.elementAt(1))%></TD></TR>
  <TR>
    <TD height=16><FONT size=2>Student No.</FONT></TD>
    <TD><FONT size=2>:</FONT> 
<%=WI.fillTextValue("stud_id").toUpperCase()%></TD>
    <TD><FONT size=2>Place of Birth</FONT></TD>
    <TD><FONT size=2>:</FONT> <%
                                if (vAdditionalInfo != null && vAdditionalInfo.size() > 0){
                                       strTemp = WI.getStrValue((String)vAdditionalInfo.elementAt(2));
                                }else{
                                       strTemp = "&nbsp;";
                                }
                        %><%=strTemp%></TD></TR>
  <TR>
    <TD height=16><FONT size=2>Gender</FONT></TD>
    <TD><FONT size=2>:</FONT> <%
                        strTemp = (String)vStudInfo.elementAt(16);
                        if(strTemp.equals("M"))
                                strTemp = "Male";
                        else
                                strTemp = "Female";
                        %><%=strTemp%></TD>
    <TD><FONT size=2>Citizenship</FONT></TD>
    <TD><FONT size=2>: </FONT><%=WI.getStrValue((String)vStudInfo.elementAt(23))%></TD></TR>
  <TR>
    <TD height=16><FONT size=2>Address</FONT></TD>
    <TD colSpan=3><FONT size=2>:</FONT> <%=WI.fillTextValue("address")%></TD></TR>
  <TR>
    <TD height=2 colSpan=4>
      <DIV style="BORDER-TOP: #000000 1px solid"></DIV></TD></TR></TBODY></TABLE>
<TABLE border=0 cellSpacing=0 cellPadding=0 width="100%">
  <TBODY>
  <TR>
    <TD height=16 colSpan=2><FONT size=2>ENTRANCE DATA</FONT></TD></TR>
  <TR>
    <TD><FONT size=2>Date of Admission</FONT></TD><%
                if(vEntranceData != null)
                        strTemp = WI.getStrValue(vEntranceData.elementAt(23),"&nbsp;");
                else
                        strTemp = "&nbsp;";
                %>
    <TD><FONT size=2>:</FONT> <%=strTemp%></TD></TR>
  <TR>
    <TD height=16><FONT size=2>Admission Status</FONT></TD>
    <TD onDblClick="UpdateInfo('_admission_stat');"><FONT size=2>:</FONT> <label id="_admission_stat"><%=WI.getStrValue(strAdmissionStatus)%></label></TD></TR>
  <TR>
    <TD height=16><FONT size=2>Diploma/Title/Degree</FONT></TD>
<%
strTemp = (String)vStudInfo.elementAt(7);
if(strAdmissionStatus.equals("High School Graduate"))
	strTemp = "N/A";
%>
    <TD onDblClick="UpdateInfo('_diploma_degree');"><FONT size=2>:</FONT> <label id="_diploma_degree"><%=strTemp%></label></TD></TR>
  <TR>
    <TD height=16><FONT size=2>School Last Attended</FONT></TD><%
                //System.out.println("vEntranceData : " + vEntranceData);
                if(vEntranceData != null)
                        strTemp = WI.getStrValue(vEntranceData.elementAt(7));
                else
                        strTemp = "";
                
               if (strTemp.length() == 0) {
                               strTemp = WI.getStrValue(vEntranceData.elementAt(5),"&nbsp;");
                               if(vEntranceData.elementAt(22) != null )
                                       strTemp = strTemp + " ("+(String)vEntranceData.elementAt(22)+")";
                        }
                
        %>
    <TD><FONT size=2>:</FONT> <%=WI.getStrValue(strTemp)%></TD></TR>
  <TR>
    <TD height=2 colSpan=2>
      <DIV style="BORDER-TOP: #000000 1px solid"></DIV></TD></TR>
  <TR>
    <TD height=16 colSpan=2><FONT size=2>COMPLETION AND GRADUATION 
    DATA</FONT></TD></TR>
  <TR>
    <TD height=16 width="20%"><FONT size=2>Date of Completion</FONT></TD>
    <TD width="80%"><FONT size=2>:</FONT> <%=WI.getStrValue(WI.fillTextValue("date_of_completion"), "N/A")%></TD></TR>
  <TR>
    <TD height=16><FONT size=2>Date of Graduation</FONT></TD><%if(vGraduationData != null)
                        strTemp = (String)vGraduationData.elementAt(8);
                  else
                        strTemp = "";                            
                %>
    <TD><FONT size=2>:</FONT> <%=WI.getStrValue(WI.formatDate(strTemp,6), "N/A")%></TD><%
                if(vGraduationData != null && vGraduationData.size()!=0)
                        strTemp = WI.getStrValue(vGraduationData.elementAt(6));
                else    
                        strTemp = "";
                %></TR>
  <TR>
    <TD height=16><FONT size=2>Program/Degree</FONT></TD>
    <TD><FONT size=2>:</FONT> <%=((String)vStudInfo.elementAt(7))%></TD></TR>
  <TR>
    <TD height=16><FONT size=2>Special Order (S.O.) No.</FONT></TD><%
                if(vGraduationData != null && vGraduationData.size()!=0)
                        strTemp = WI.getStrValue(vGraduationData.elementAt(6));
                else    
                        strTemp = "";
                %>
    <TD><FONT size=2>:</FONT> <%=WI.getStrValue(strTemp, "N/A")%></TD></TR></TBODY></TABLE><%}else{%>
<TABLE border=0 cellSpacing=0 cellPadding=0 width="100%" align=center>
  <TBODY>
  <TR>
    <TD height=16 width="12%"><FONT size=2>Name</FONT></TD>
    <TD width="88%"><FONT size=2>: <%=((String)vStudInfo.elementAt(2)).toUpperCase()%>, <%=WI.getStrValue((String)vStudInfo.elementAt(0)).toUpperCase()%> <%=WI.getStrValue(vStudInfo.elementAt(1)," ").toUpperCase()%></FONT></TD></TR>
  <TR>
    <TD height=16><FONT size=2>Student No.</FONT></TD>
    <TD><FONT size=2>: 
  </FONT><%=WI.fillTextValue("stud_id").toUpperCase()%></TD></TR></TBODY></TABLE><%}

if(vRetResult != null && vRetResult.size() > 0){
     
   if(iPageNumber == 1)
		   strTemp = "470";
   else
		   strTemp = "685";
                                       
                                      
    %>
<TABLE border=0 cellSpacing=0 cellPadding=0 width="100%" align=center>
	<tr>
		<td valign="top" height="<%=strTemp%>">
			<TABLE border=0 cellSpacing=0 cellPadding=0 width="100%" align=center>
  <TBODY>
  <TR>
    <TD vAlign=top>
      <TABLE border=0 cellSpacing=0 cellPadding=0 width="100%" align=center>
        <TBODY>
        <TR>
          <TD height=2 colSpan=10>
            <DIV style="BORDER-TOP: #000000 1px solid"></DIV></TD></TR>
        <TR>
          <TD height=2 colSpan=10>
            <DIV style="BORDER-TOP: #000000 1px solid"></DIV></TD></TR>
        <TR>
          <TD class=thinborderBOTTOM rowSpan=2 width="13%" 
            align=center><STRONG>COURSE CODE</STRONG></TD>
          <TD class=thinborderBOTTOM rowSpan=2 width="49%" 
            align=center><STRONG>DESCRIPTIVE TITLE</STRONG></TD>
          <TD colSpan=2 align=center><STRONG>GRADES</STRONG></TD>
          <TD align=center><STRONG>CREDIT</STRONG></TD></TR>
        <TR>
          <TD class=thinborderBOTTOM width="10%" 
            align=center><STRONG>FINAL</STRONG></TD>
          <TD class=thinborderBOTTOM width="10%" 
            align=center><STRONG>COMPLETION</STRONG></TD>
          <TD class=thinborderBOTTOM width="6%" 
            align=center><STRONG>UNITS</STRONG></TD></TR><%
                                                           int iIndexOfSubGroup = 0; //to get index of group compare the vRetResult with the group info vector
                                                           String strSchoolName = null;
                                                           String strPrevSchName = "";
                                                           String strSchNameToDisp = null;
                                                           
                                                           String strSYSemToDisp   = null;
                                                           String strCurSYSem      = null;
                                                           String strPrevSYSem     = null;
                                                           
                                                           boolean bolIsSchNameNull    = false;
                                                           boolean  bolCrossEnrolled   = false;//i have to set it to true if school name is null - if information has
                                                           //school name after it is null, it is encoded as cross enrollee.
                                                           
                                                           String strHideRowLHS = "<!--";
                                                           String strHideRowRHS = "-->";
                                                           int iCurrentRow = 0;//System.out.println(vRetResult);
                                                           
                                                           String strCrossEnrolleeSchPrev   = null;
                                                           String strCrossEnrolleeSch       = null;
                                                           
                                                           //for Math / english enrichment - i have to put parenthesis.
                                                           boolean bolPutParanthesis  = false;
                                                           Vector vMathEnglEnrichment = new enrollment.GradeSystem().getMathEngEnrichmentInfo(dbOP, request);
                                                           String strGradeValue = null;
                                                           String strSubCode    = null;
                                                           int iIndexOf         = 0;
                                                           for(int i = 0 ; i < vRetResult.size(); i += 11, ++iCurrentRow){
                                                                   bolPutParanthesis = false;
                                                                   //check here NSTP(CWTS) must be converted to NSTP only.. 
                                                                   strSubCode = (String)vRetResult.elementAt(i + 6);
                                                                   if(strSubCode.startsWith("NSTP") && (iIndexOf = strSubCode.indexOf("(")) > -1)
                                                                           strSubCode = strSubCode.substring(0, iIndexOf);
                                                                   if(vMathEnglEnrichment != null && vMathEnglEnrichment.indexOf(strSubCode) != -1) {
                                                                           try {
                                                                                   double dGrade = Double.parseDouble((String)vRetResult.elementAt(i + 8));
                                                                                   //System.out.println(dGrade);
                                                                                   bolPutParanthesis = true; //System.out.println(bolPutParanthesis);
                                                                                   if(dGrade < 5d)
                                                                                           vRetResult.setElementAt("(3.0)",i + 9);
                                                                                   else 
                                                                                           vRetResult.setElementAt("(0.0)",i + 9);
                                                                                   
                                                                           }
                                                                           catch(Exception e){vRetResult.setElementAt("(0.0)",i + 9);}
                                                                   }
                                                           
                                                           //I have to now check if this subject is having RLE hours.
                                                           //String strRLEHrs    = null;
                                                           //String strCE        = null;
                                                           
                                                           
                                                                   if(vRetResult.size() > (i + 16) && vRetResult.elementAt(i + 8) != null && ((String)vRetResult.elementAt(i + 8)).toLowerCase().indexOf("inc") != -1 && vRetResult.elementAt(i + 6 + 11) != null && vRetResult.elementAt(i + 6 + 11) != null &&
                                                                           ((String)vRetResult.elementAt(i + 6)).equals((String)vRetResult.elementAt(i + 6 + 11)) && //sub code,
                                                                           ((String)vRetResult.elementAt(i + 1)).equals((String)vRetResult.elementAt(i + 1 + 11))  && //sy_from
                                                                           ((String)vRetResult.elementAt(i + 2)).equals((String)vRetResult.elementAt(i + 2 + 11)) && //sy_to
                                                                           WI.getStrValue(vRetResult.elementAt(i + 3),"1").equals(WI.getStrValue(vRetResult.elementAt(i + 3 + 11),"1"))) {   //semester
                                                                                   
                                                                                   //I have to take care of the paranthesis for inc. 
                                                                           if(vMathEnglEnrichment != null && vMathEnglEnrichment.indexOf(strSubCode) != -1) {
                                                                                   try {
                                                                                           double dGrade = Double.parseDouble((String)vRetResult.elementAt(i +11+ 8));
                                                                                           //System.out.println(dGrade);
                                                                                           bolPutParanthesis = true; //System.out.println(bolPutParanthesis);
                                                                                           if(dGrade < 5d)
                                                                                                   vRetResult.setElementAt("(3.0)",i +11+ 9);
                                                                                           else 
                                                                                                   vRetResult.setElementAt("(0.0)",i +11+ 9);
                                                                                   
                                                                                   }
                                                                                   catch(Exception e){vRetResult.setElementAt("(0.0)",i +11+ 9);}
                                                                           }
                                                           
                                                           
                                                                           

                                                                           
                                                                                   strTemp = (String)vRetResult.elementAt(i + 9 + 11);
                                                                   }
                                                                   else {
                                                                           strTemp = (String)vRetResult.elementAt(i + 9);
                                                                   }
                                                                   strCE        = strTemp;
                                                                   if(strTemp != null && strTemp.indexOf("hrs") > 0) {
                                                                           strRLEHrs = CommonUtil.formatGrade(strTemp.substring(strTemp.indexOf("(") + 1, strTemp.indexOf("hrs")),0f);
                                                                           strCE     = strTemp.substring(0,strTemp.indexOf("("));
                                                                   }
                                                                   else {
                                                                           strRLEHrs    = null;
                                                                   }
                                                                   
                                                                   //strTemp is subject code.. 
                                                                   
                                                           
                                                           
                                                           
                                                                   strSchoolName = (String)vRetResult.elementAt(i);
                                                           
                                                                   if(vRetResult.elementAt(i) == null)
                                                                           bolIsSchNameNull = true;
                                                           
                                                                   if(vRetResult.elementAt(i) != null && bolIsSchNameNull) //cross enrolled.
                                                                           strSchoolName += " (CROSS ENROLLED)";
                                                           
                                                           /** uncomment this if school name apprears once. */
                                                                   if(i == 0 && strSchoolName == null) {//I have to get the current school name
                                                                           strSchNameToDisp = SchoolInformation.getSchoolName(dbOP,false,false);
                                                                           strSchoolName = strSchNameToDisp;
                                                                   }
                                                           
                                                                   if (WI.getStrValue(strSchoolName).length() == 0)
                                                                           strSchoolName = strCurrentSchoolName;
                                                           
                                                                   if(strPrevSchName.equals(WI.getStrValue(strSchoolName))) {
                                                                           strSchNameToDisp = null;
                                                                   } else {//itis having a new school name.
                                                                           strPrevSchName = strSchoolName;
                                                                           strSchNameToDisp = strPrevSchName;
                                                                   }
                                                           
                                                           
                                                           //strCurSYSem =
                                                           if(vRetResult.elementAt(i+ 3) != null) {//null only if accredited subject - foreign stud.
                                                                   if(((String)vRetResult.elementAt(i+ 3)) != null && ((String)vRetResult.elementAt(i+ 3)).length() == 1) {
                                                                           strCurSYSem = astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(i+ 3))];
                                                                   } else {
                                                                           strCurSYSem = (String)vRetResult.elementAt(i+ 3);
                                                                   }
                                                           
                                                                   if (strCurSYSem != null && strCurSYSem.length() > 0){
                                                           //              if (strCurSYSem.toLowerCase().startsWith("sum")){
                                                           //                      strCurSYSem += " " +  (String)vRetResult.elementAt(i+ 2);
                                                           //              }else{
                                                                                   strCurSYSem += ", AY " + (String)vRetResult.elementAt(i+ 1)+ " - " +
                                                                                                                   (String)vRetResult.elementAt(i+ 2);
                                                           //              }
                                                                   }
                                                           
                                                                   if(strCurSYSem != null) {
                                                                           if(strPrevSYSem == null) {
                                                                                   strPrevSYSem = strCurSYSem ;
                                                                                   strSYSemToDisp = strCurSYSem;
                                                                           }
                                                                           else if(strPrevSYSem.equals(strCurSYSem)) {
                                                                                   strSYSemToDisp = null;
                                                                           }
                                                                           else {//itis having a new school name.
                                                                                   strPrevSYSem = strCurSYSem;
                                                                                   strSYSemToDisp = strPrevSYSem;
                                                                           }
                                                                   }
                                                           }
                                                           
                                                                   if(vRetResult.elementAt(i) != null && bolIsSchNameNull) {//cross enrolled.
                                                                           if(strCrossEnrolleeSchPrev == null || strCrossEnrolleeSchPrev.compareTo(strSchoolName) != 0)  {
                                                                                   strCrossEnrolleeSchPrev = strSchoolName;
                                                                                   strCrossEnrolleeSch     = strSchoolName;
                                                                                   strSYSemToDisp = strCurSYSem;
                                                                           }
                                                                   }
                                                           
                                                           
                                                            //Very important here, it print <!-- if it is not to be shown.
                                                            if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){strHideRowLHS = "<!--";//I have to do this so i will know if I am priting data or not%><%=strHideRowLHS%><%}else {++iRowsPrinted;strHideRowLHS = "";}//actual number of rows printed.
                                                           
                                                           if(vMulRemark != null && vMulRemark.size() > 0) {
                                                                   iMulRemarkIndex = ((Integer)vMulRemark.elementAt(0)).intValue();
                                                                   if(iMulRemarkIndex == i){
                                                                           vMulRemark.removeElementAt(0);
                                                           %>
        <TR bgColor=#ffffff>
          <TD height=20 colSpan=5><STRONG><%=ConversionTable.replaceString((String)vMulRemark.remove(0),"\n","<br>")%></STRONG></TD></TR><%}//end of if
                                                           }//end of vMulRemark.
                                                           
                                                           ///if nothing is printed and it is chinese gen, then do not print
                                                                   
                                                            if (strSchNameToDisp != null && strSchNameToDisp.length() > 0 && (i > 0 || (i == 0 && !strSchNameToDisp.toUpperCase().startsWith("CHINESE"))) ) { %>
        <TR bgColor=#ffffff>
          <TD height=17 colSpan=5><STRONG>&nbsp;<%=WI.getStrValue(strSchNameToDisp).toUpperCase()%></STRONG></TD></TR><%}if(strSYSemToDisp != null){%>
        <TR bgColor=#ffffff>
          <TD height=17 
          colSpan=5><STRONG><I><%=strSYSemToDisp%></I></STRONG></TD></TR><%}
                                                             
                                                             strGradeValue = null;
                                                           %>
        <TR bgColor=#ffffff>
          <TD><%=strSubCode%></TD>
          <TD><%=((String)vRetResult.elementAt(i + 7)).toUpperCase()%></TD><%
                                                                                       strGradeValue = WI.getStrValue(vRetResult.elementAt(i + 8), "&nbsp;");
                                                                                       if(strGradeValue.compareTo("on going") == 0)
                                                                                               strGradeValue = "&nbsp;&nbsp;Grade not ready";
                                                                                       else{
                                                                                               if( (strGradeValue.endsWith(".0") || strGradeValue.length() == 3) && strGradeValue.indexOf(".") > -1)
                                                                                                       strGradeValue = strGradeValue+"0";
                                                                                               if(bolPutParanthesis && !strGradeValue.equals("INC"))
                                                                                                       strGradeValue = "("+strGradeValue+")";
                                                                                       }               
                                                                               %>
          <TD width="2%" align=center><%=WI.getStrValue(strGradeValue, "&nbsp;")%>&nbsp;</TD>
          <TD width="3%" align=center><%
                                                                               //it is re-exam if student has INC and cleared in same semester,
                                                                               strTemp = null;
                                                                               if(vRetResult.size() > (i + 16) && vRetResult.elementAt(i + 8) != null &&
                                                                                       ((String)vRetResult.elementAt(i + 8)).toLowerCase().indexOf("inc") != -1 &&
                                                                                       vRetResult.elementAt(i + 6) != null  && vRetResult.elementAt(i + 6 + 11) != null &&
                                                                                       ((String)vRetResult.elementAt(i + 6)).equals((String)vRetResult.elementAt(i + 6 + 11)) && //sub code,
                                                                                       ((String)vRetResult.elementAt(i + 1)).equals((String)vRetResult.elementAt(i + 1 + 11)) && //sy_from
                                                                                       ((String)vRetResult.elementAt(i + 2)).equals((String)vRetResult.elementAt(i + 2 + 11)) && //sy_to
                                                                                       WI.getStrValue(vRetResult.elementAt(i + 3),"1").equals(WI.getStrValue(vRetResult.elementAt(i + 3 + 11),"1"))) { //semester
                                                                       
                                                                                       if(vMathEnglEnrichment != null && vMathEnglEnrichment.indexOf(strSubCode) != -1) {
                                                                                               try {
                                                                                                       double dGrade = Double.parseDouble((String)vRetResult.elementAt(i +11+ 8));
                                                                                                       //System.out.println(dGrade);
                                                                                                       bolPutParanthesis = true; //System.out.println(bolPutParanthesis);
                                                                                                       if(dGrade < 5d)
                                                                                                               vRetResult.setElementAt("(3.0)",i +11+ 9);
                                                                                                       else 
                                                                                                               vRetResult.setElementAt("(0.0)",i +11+ 9);
                                                                                               
                                                                                               }
                                                                                               catch(Exception e){vRetResult.setElementAt("(0.0)",i +11+ 9);}
                                                                                       }
                                                                                       
                                                                                               strTemp = (String)vRetResult.elementAt(i + 9 + 11);
                                                                                       
                                                                                       strGradeValue = (String)vRetResult.elementAt(i + 8 + 11);
                                                                                       if( (strGradeValue.endsWith(".0") || strGradeValue.length() == 3) && strGradeValue.indexOf(".") > -1)
                                                                                               strGradeValue = strGradeValue+"0";
                                                                                       if(bolPutParanthesis)
                                                                                               strGradeValue = "("+strGradeValue+")";
                                                                                       
                                                                                       %><%=strGradeValue%>&nbsp; 
<%i += 11;}else{%>&nbsp; <%}
                                                                                       strCE = strCE.trim();
                                                                                       if(!strCE.endsWith(")") && strCE.indexOf(".") == -1)
                                                                                               strCE = strCE + ".0";
                                                                                       %></TD>
          <TD width="7%" align=center><%=strCE%>&nbsp;</TD></TR><%
                                                              if(iCurrentRow < iRowStartFr || iCurrentRow >= iRowEndsAt){%><%=strHideRowRHS%><%}
                                                              }//end of for loop
                                                                   
                                                           %>
        
		<%if(iLastPage == 1){%>
			<TR>
          <TD colSpan=5>
            <DIV 
            align=center>********** ENTRY BELOW NOT VALID **********
            </DIV></TD></TR>
		<%}else{%>
		<TR>
          <TD colSpan=5>
            <DIV 
            align=center>More on next page...
            </DIV></TD></TR>
		<%}%>
        </TBODY></TABLE></TD></TR></TBODY></TABLE>
		</td>
	</tr>
</TABLE>
<%}//only if student is having grade infromation.%>
<table width="100%" cellpadding="0" cellspacing="0">
        <TR>
          <TD height=2 colSpan=5>
            <DIV style="BORDER-BOTTOM: #000000 1px solid"></DIV></TD></TR>
        <TR>
          <TD height=2 colSpan=5>
            <DIV 
      style="BORDER-BOTTOM: #000000 1px solid"></DIV></TD></TR></TBODY></TABLE></TD></TR></TBODY></TABLE>
		</td>
	</tr>
</table>
<TABLE style="WIDTH: 896px; HEIGHT: 75px" border=0 cellSpacing=0 cellPadding=0 width=896>
  <TBODY>
  <TR vAlign=top>
    <TD vAlign=top width="10%">REMARKS :</TD>
    <TD vAlign=top 
  width="90%"><%=WI.fillTextValue("addl_remark")%></TD></TR></TBODY></TABLE>
<TABLE border=0 cellSpacing=0 cellPadding=0 width="100%" align=center>
  <TBODY>
  <TR>
    <TD>GRADING SYSTEM:</TD></TR>
  <TR>
    <TD vAlign=top>
      <TABLE class=thinborder border=0 cellSpacing=0 cellPadding=0 width="100%" 
      align=center height=60>
        <TBODY>
        <TR>
          <TD style="FONT-SIZE: 10px" class=thinborderLEFT width="12%" 
          align=center>Percentage</TD>
          <TD style="FONT-SIZE: 10px" width="12%" align=center>Numeric</TD>
          <TD style="FONT-SIZE: 10px" width="12%" align=center>Description</TD>
          <TD style="FONT-SIZE: 10px" class=thinborderLEFT width="12%" 
          align=center>Percentage</TD>
          <TD style="FONT-SIZE: 10px" width="12%" align=center>Numeric</TD>
          <TD style="FONT-SIZE: 10px" width="12%" align=center>Description</TD>
          <TD style="PADDING-LEFT: 30px; FONT-SIZE: 10px" class=thinborder 
          rowSpan=6 width="28%">INC &#8211; Incomplete<BR>AW &#8211; Authorized 
            Withdrawal<BR>FA &#8211; Failed due to Absences</TD></TR>
        <TR>
          <TD style="FONT-SIZE: 10px" class=thinborderLEFT 
          align=center>98-100</TD>
          <TD style="FONT-SIZE: 10px" align=center>1.00</TD>
          <TD style="FONT-SIZE: 10px" align=center>Excellent</TD>
          <TD style="FONT-SIZE: 10px" class=thinborderLEFT 
          align=center>83-85</TD>
          <TD style="FONT-SIZE: 10px" align=center>2.25</TD>
          <TD style="FONT-SIZE: 10px" align=center>Good</TD></TR>
        <TR>
          <TD style="FONT-SIZE: 10px" class=thinborderLEFT 
          align=center>96-97</TD>
          <TD style="FONT-SIZE: 10px" align=center>1.25</TD>
          <TD style="FONT-SIZE: 10px" align=center>Outstanding</TD>
          <TD style="FONT-SIZE: 10px" class=thinborderLEFT 
          align=center>80-82</TD>
          <TD style="FONT-SIZE: 10px" align=center>2.50</TD>
          <TD style="FONT-SIZE: 10px" align=center>Satisfactory</TD></TR>
        <TR>
          <TD style="FONT-SIZE: 10px" class=thinborderLEFT 
          align=center>92-94</TD>
          <TD style="FONT-SIZE: 10px" align=center>1.50</TD>
          <TD style="FONT-SIZE: 10px" align=center>Very Good</TD>
          <TD style="FONT-SIZE: 10px" class=thinborderLEFT 
          align=center>77-79</TD>
          <TD style="FONT-SIZE: 10px" align=center>2.75</TD>
          <TD style="FONT-SIZE: 10px" align=center>Satisfactory</TD></TR>
        <TR>
          <TD style="FONT-SIZE: 10px" class=thinborderLEFT 
          align=center>89-91</TD>
          <TD style="FONT-SIZE: 10px" align=center>1.75</TD>
          <TD style="FONT-SIZE: 10px" align=center>Very Good</TD>
          <TD style="FONT-SIZE: 10px" class=thinborderLEFT 
          align=center>75-76</TD>
          <TD style="FONT-SIZE: 10px" align=center>3.00</TD>
          <TD style="FONT-SIZE: 10px" align=center>Passed</TD></TR>
        <TR>
          <TD style="FONT-SIZE: 10px" class=thinborder align=center>86-88</TD>
          <TD style="FONT-SIZE: 10px" class=thinborderBOTTOM 
          align=center>2.00</TD>
          <TD style="FONT-SIZE: 10px" class=thinborderBOTTOM 
          align=center>Good</TD>
          <TD style="FONT-SIZE: 10px" class=thinborder align=center>0-74</TD>
          <TD style="FONT-SIZE: 10px" class=thinborderBOTTOM 
          align=center>5.00</TD>
          <TD style="FONT-SIZE: 10px" class=thinborderBOTTOM 
            align=center>Failed</TD></TR></TBODY></TABLE></TD></TR>
  <TR>
    <TD vAlign=top>
      <TABLE border=0 cellSpacing=0 cellPadding=0 width="100%" align=center>
        <TBODY>
        <TR>
          <TD colSpan=2>&nbsp;</TD></TR>
        <TR>
          <TD vAlign=top width="6%">NOTE:</TD>
          <TD width="94%">Unless otherwise specified, one unit of credit is 
            one hour of lecture or three hours of laboratory work each week for 
            a period of 18 weeks in a semester. This transcript is valid only 
            when it bears the seal/hologram of the College and the original 
            signature of the Registrar. Any erasure or alteration made on this 
            copy renders the whole transcript invalid.</TD></TR>
        <TR>
          <TD colSpan=2>&nbsp;</TD></TR></TBODY></TABLE></TD></TR>
  <TR>
    <TD vAlign=top>
      <TABLE class=thinborder border=0 cellSpacing=0 cellPadding=0 width="100%" 
      align=center height=80>
        <TBODY>
        <TR>
          <TD style="PADDING-LEFT: 15px" class=thinborderLEFT 
            width="22%">Prepared by:</TD>
          <TD style="PADDING-LEFT: 15px" class=thinborderLEFT 
            width="27%">Checked by:</TD>
          <TD style="PADDING-LEFT: 15px" class=thinborderLEFT width="22%">Date 
            Issued:</TD>
          <TD style="PADDING-LEFT: 15px" class=thinborderLEFT 
            width="22%">Certified by:</TD></TR>
        <TR>
          <TD class=thinborder vAlign=bottom>
            <DIV align=center><%=WI.fillTextValue("prep_by1")%></DIV></TD>
          <TD class=thinborder vAlign=bottom>
            <DIV align=center><%=WI.fillTextValue("check_by1")%></DIV></TD>
          <TD class=thinborder vAlign=top>
            <DIV align=center><BR>
<%
strTemp = WI.fillTextValue("date_prepared");
if(strTemp.length() > 0) 
	strTemp = WI.formatDate(strTemp, 6);
%>
			<%=strTemp%></DIV></TD>
          <TD class=thinborder vAlign=bottom>
            <DIV 
            align=center><%=WI.fillTextValue("registrar_name")%><BR><I>Registrar</I> 
            </DIV></TD></TR></TBODY></TABLE></TD></TR>
  <TR>
    <TD vAlign=top>
      <TABLE border=0 cellSpacing=0 cellPadding=0 width="100%" align=center>
        <TBODY>
        <TR>
          <TD><I>Revised: March 2013</I></TD>
          <TD align=right>Page <%=iPageNumber%>of 
        <%=strTotalPageNumber%></TD></TR></TBODY></TABLE></TD></TR></TBODY></TABLE><%//System.out.println(WI.fillTextValue("print_"));
      if(WI.fillTextValue("print_").compareTo("1") == 0){%>
<SCRIPT language=javascript type=text/javascript>
 window.print();
</SCRIPT>
<%}%><%
      dbOP.cleanUP();
      %></BODY></HTML>

