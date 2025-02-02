<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;	
    }

    TABLE.thinborderall {
    border: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;	
    }
	
	TD.thinborderall {
    border: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }
	
	TD.thinborderBottom{
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
	}

    TD.thinborderGrade {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }

    TD.thinborderLegend {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 8px;
    }

-->
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
var imgWnd;
function PrintPg() {
	document.gsheet.print_page.value = "1";
	document.gsheet.submit();
}
function CopyAll()
{
	document.gsheet.print_page.value = "";
	if(document.gsheet.copy_all.checked)
	{
		if(document.gsheet.date0.value.length == 0 || document.gsheet.time0.value.length ==0) {
			alert("Please enter first Date and time field input.");
			document.gsheet.copy_all.checked = false;
			return;
		}
		ReloadPage();
	}
}
function PageAction(strAction)
{
	document.gsheet.print_page.value = "";
	document.gsheet.page_action.value=strAction;
		
	if(document.gsheet.show_save.value == "1") 
		document.gsheet.hide_save.src = "../../../images/blank.gif";
	if(document.gsheet.show_delete.value == "1")
		document.gsheet.hide_delete.src = "../../../images/blank.gif";
	if(strAction ==0) 
		document.gsheet.delete_text.value = "deleting in progress....";
	if(strAction ==1)
		document.gsheet.save_text.value = "Saving in progress....";
	
	this.ShowProcessing();
}
function ReloadPage()
{
	document.gsheet.print_page.value = "";
	document.gsheet.page_action.value="";
	if(document.gsheet.show_save.value == "1")
		document.gsheet.hide_save.src = "../../../images/blank.gif";
	if(document.gsheet.show_delete.value == "1")
		document.gsheet.hide_delete.src = "../../../images/blank.gif";
	this.ShowProcessing();
}

function ChangeInfo(strLabelID) {
	
	var strNewInfo = prompt('Please enter new Value.',document.getElementById(strLabelID).innerHTML);
	if(strNewInfo == null || strNewInfo.legth == 0)
		return;
	document.getElementById(strLabelID).innerHTML = strNewInfo;
}
</script>


<body topmargin="0" bottommargin="0" onLoad="window.print();">
<form name="gsheet" method="post">
<%@ page language="java" import="utility.*,enrollment.GradeSystemExtn,java.util.Vector " %>
<%
	WebInterface WI   = new WebInterface(request);
	DBOperation dbOP  = null;
	String strErrMsg  = null;
	String strTemp    = null;
	Vector vSecDetail = null;
	boolean bolPageBreak = false;
	int j = 0;
	int iIndexOf = 0;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-GRADES-Grade Sheets","grade_sheet.jsp");
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
/**
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),"Registrar Management","GRADES",request.getRemoteAddr(),null);
//if iAccessLevel == 0, i have to check if user is set for sub module.
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),"Registrar Management","GRADES-Grade Sheets",request.getRemoteAddr(),null);

}**/
int iAccessLevel = 2;

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
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
enrollment.ReportEnrollment reportEnrl= new enrollment.ReportEnrollment();
enrollment.GradeSystem  GS = new enrollment.GradeSystem();
GradeSystemExtn gsExtn     = new GradeSystemExtn();
String[] astrConvSemester = {"SUMMER", "FIRST SEMESTER", "SECOND SEMESTER", "THIRD SEMESTER"};


String strSubSecIndex   = null;
String strOfferedByCollege = null;

Vector vRetResult = null;
Vector vEncodedGrade = new Vector();
Vector vPMTSchedule = new Vector(); 
Vector vDateEncoded = new Vector();
String strDateEncoded = null;

String strStudSectionQuery = "select section_name from stud_curriculum_hist join user_Table on (user_Table.user_index = stud_curriculum_hist.user_index) where stud_curriculum_hist.is_valid = 1 and sy_from = "+WI.fillTextValue("sy_from")+" and semester = "+
							WI.fillTextValue("offering_sem")+" and id_number = ";
	

String strSchCode = (String)request.getSession(false).getAttribute("school_code");//strSchCode = "AUF";
if(strSchCode == null)
	strSchCode = "";

//get here necessary information.
if(WI.fillTextValue("section_name").length() > 0 && WI.fillTextValue("subject").length() > 0) {
	strSubSecIndex = dbOP.mapOneToOther("E_SUB_SECTION join faculty_load on (faculty_load.sub_sec_index = e_sub_section.sub_sec_index) ",
						"section","'" + WI.fillTextValue("section_name")+ "'"," e_sub_section.sub_sec_index", 
						" and e_sub_section.sub_index = " + WI.fillTextValue("subject") +
						" and faculty_load.is_valid = 1 and e_sub_section.offering_sy_from = "+
						WI.fillTextValue("sy_from")+
						" and e_sub_section.offering_sem="+ WI.fillTextValue("offering_sem")+" and is_lec=0");
}
if(strSubSecIndex != null) {//get here subject section detail. 
	
	strOfferedByCollege = dbOP.mapOneToOther("e_sub_section","sub_sec_index", strSubSecIndex, "OFFERED_BY_COLLEGE", "");
	
	
	if(!strSchCode.startsWith("AUF"))
		vSecDetail = reportEnrl.getSubSecSchDetail(dbOP,strSubSecIndex);
	else
		vSecDetail = reportEnrl.getSubSecSchDetail(dbOP,strSubSecIndex,true);
	if(vSecDetail == null)
		strErrMsg = reportEnrl.getErrMsg();
}

boolean bolSeparateMixedSection = false;
String strDateEncodedPrelim  = null;
String strDateEncodedMidterm = null;
String strDateEncodedFinal   = null;

if(strSubSecIndex != null) {
	if(WI.fillTextValue("recompute").length() > 0) 
		gsExtn.convertToFinalGradeWNU(dbOP, strSubSecIndex, request);
		
	vRetResult = gsExtn.getAllGradesEncoded(dbOP,request,strSubSecIndex,bolSeparateMixedSection);
//	System.out.println(vRetResult);
	if(vRetResult == null)
		strErrMsg = gsExtn.getErrMsg();
	else{
		strTemp = 
			" select MAX(G_SHEET_FINAL.CREATE_DATE) from G_SHEET_FINAL "+
			" join USER_TABLE on (USER_TABLE.USER_INDEX = G_SHEET_FINAL.user_index_) "+
			" where G_SHEET_FINAL.IS_VALID =1 "+
			" and SUB_SEC_INDEX = "+strSubSecIndex;
		java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
		if(rs.next()){						
			strDateEncodedFinal = ConversionTable.convertMMDDYYYY(rs.getDate(1));					
		}rs.close();
	
		strTemp = 
			" select MAX(GRADE_SHEET.CREATE_DATE),GRADE_NAME from GRADE_SHEET "+
			" join USER_TABLE on (USER_TABLE.USER_INDEX = GRADE_SHEET.user_index_) "+
			" where GRADE_SHEET.IS_VALID =1 "+
			" and SUB_SEC_INDEX = "+strSubSecIndex+
			" and (GRADE_NAME like 'prelim%' or GRADE_NAME like 'midterm%') "+
			" group by GRADE_NAME ";
		rs = dbOP.executeQuery(strTemp);
		while(rs.next()){
			if(rs.getString(2).toLowerCase().startsWith("p"))
				strDateEncodedPrelim = ConversionTable.convertMMDDYYYY(rs.getDate(1));			
			else
				strDateEncodedMidterm = ConversionTable.convertMMDDYYYY(rs.getDate(1));		
		}rs.close();
	}
	
	
}

    Vector vEmpRec = new enrollment.Authentication().operateOnBasicInfo(dbOP,request,"0");
	
	if (vRetResult != null) { 
//		System.out.println(vRetResult);
	
		int i = 0; int k = 0; int iNumGrading = 0; int iCount = 0;

			
		vPMTSchedule = (Vector)vRetResult.elementAt(0); 
	  	iNumGrading = vPMTSchedule.size()/2;	


		String strCurrentSubIndex = null;
		int iNumStud = 1;
		int iIncr    = 1; // student count
		
		int iIncKvalue = 1; // add to to accomodate sub_index inserted in element[8]
		
		//if (bolSeparateMixedSection)
		//	iIncKvalue = 1;
		
		
		String strCollegeName = null;
		String strDeptName = null;
		
		String strDeanName = null;
		String strDeptHeadName = null;
		
		String strRegistrarName = null;

if ((vEmpRec!=null || vEmpRec.size()>0) && !strSchCode.startsWith("AUF")) {
		strCollegeName = (String)vEmpRec.elementAt(13);
		strDeptName = WI.getStrValue((String)vEmpRec.elementAt(14),"&nbsp");
		if (strSchCode.startsWith("UI") &&  strSubSecIndex != null && strSubSecIndex.length() > 0) {
			strCollegeName = dbOP.mapOneToOther("COLLEGE","c_index",strOfferedByCollege,"c_name",null);
			strTemp = dbOP.mapOneToOther("E_SUB_SECTION","SUB_SEC_INDEX",strSubSecIndex,"OFFERED_BY_DEPT",null);
			if (strTemp != null)
				strDeptName = dbOP.mapOneToOther("department","d_index",strTemp,"d_name",null);
			else
				strDeptName = "&nbsp;";
		}
		
}else{
		strCollegeName = "&nbsp;";
		strDeptName = "&nbsp;";
}




double[] adAvgRoundOff = null;
Vector vInfoAvgRoundOff = new Vector();
String strFinalGrade = null;


int iRowCount = 1;
int iNoOfStudPerPage = 35;

boolean bolMalePrinted = false;
boolean bolFemalePrinted = false;


if(WI.fillTextValue("num_stud_page").length() > 0)
	iNoOfStudPerPage = Integer.parseInt(WI.fillTextValue("num_stud_page"));

int iStudCount = 1;
int iPageCount = 1;

int iTotalStud = (vRetResult.size()/(9+(iNumGrading-1)+iIncKvalue));

int iTotalPageCount = iTotalStud/iNoOfStudPerPage;
if(iTotalStud % iNoOfStudPerPage > 0)
	++iTotalPageCount;
	



for (;iNumStud < vRetResult.size()-1;){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
  
	<tr>			       
	  <td align="right">Page &nbsp;<%=iPageCount++%> of&nbsp;<%=iTotalPageCount%> </td>
	</tr>
	<tr> 
	  <td><div align="center"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong></div></td>			
	</tr>
	<tr> 
	  <td><div align="center"><strong><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></strong></div></td>
	</tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <!--  college and department group -->
    <tr> 
      <td colspan="3"> <% 
 	if (!strSchCode.startsWith("SPC")) 
  		strTemp = "OFFICIAL GRADING SHEET";
  	else
		strTemp = "REPORT OF GRADES"; 
%> <div align="center"><strong><%=strTemp%></strong></div></td>
    </tr>
    <tr> 
      <td colspan="3" align="center"><%=astrConvSemester[Integer.parseInt(WI.fillTextValue("offering_sem"))]%>:<%=WI.fillTextValue("sy_from")%>-<%=WI.fillTextValue("sy_to")%></td>
    </tr>
    <% if (!strSchCode.startsWith("AUF")) {%>
    <tr> 
      <td width="50%">&nbsp;&nbsp;</td>
      <td width="25%">	  </td>
      <td width="25%">&nbsp;</td>
    </tr>
    <tr> 
        <td>&nbsp;</td>
      <td><div align="center"></div></td>
    </tr>
    <%} //!strSchCode.startsWith("AUF") %>
  </table>
<%if(vSecDetail != null){
		strCurrentSubIndex = WI.fillTextValue("subject");
%>
  <table width="100%" border="0" cellspacing="1" cellpadding="1">
   
    <tr >
      <td width="12%">Schedule:</td> 
      <td width="56%" >&nbsp;&nbsp;
	  <%=WI.fillTextValue("section_name")%>	  </td>
      <td width="5%" >Room:</td>
	  
      <td width="27%">
	  <%
		for( i = 1; i<vSecDetail.size(); i+=3){
	  	if(i >1){%>
        , 
        <%}%>
        <%=(String)vSecDetail.elementAt(i)%> 
        <%}%>	  </td>
    </tr>
    <tr>
      <td>Description:</td> 
      <td>&nbsp;&nbsp; 
	<%		
	strTemp = "&nbsp;";
	if(strCurrentSubIndex != null && strCurrentSubIndex.length() > 0 ) 
		strTemp = dbOP.mapOneToOther("SUBJECT","SUB_INDEX",strCurrentSubIndex,"sub_code +' (' + sub_name+')'"," and is_del=0");
		
	%><%=(String)WI.getStrValue(strTemp).toUpperCase()%>      </td>
      <td>Time:</td>
      <td>
        <%
		for( i = 1; i<vSecDetail.size(); i+=3){
	  	if(i >1){%>
        , 
        <%}%>
        <%=((String)vSecDetail.elementAt(i+2)).substring(0, ((String)vSecDetail.elementAt(i+2)).indexOf(" "))%> 
        <%}%>	  </td>
    </tr>
    <tr>
      <td>Instructor:</td>
      <td>&nbsp;&nbsp;
        <%if(vSecDetail != null){%>
        	<%=WI.getStrValue(vSecDetail.elementAt(0)).toUpperCase()%>
      	<%}%>	  </td>
      <td>Day:</td>
      <td>
        <%
		for( i = 1; i<vSecDetail.size(); i+=3){
	  	if(i >1){%>
        <br> 
        <%}%>
        <%=((String)vSecDetail.elementAt(i+2)).substring(((String)vSecDetail.elementAt(i+2)).indexOf(" "))%> 
        <%}%>      </td>
    </tr>
   
    <tr>
      <td align="center">&nbsp;</td> 
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td align="center">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="60%"><div align="center"></div></td>
      <td width="40%">&nbsp;</td>
    </tr>
    <tr> 
      <td><div align="center"></div></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  
<%
	if (vRetResult != null && vRetResult.size() > 0){ 
	i = 0;
%>
<table width="100%" cellpadding="1" cellspacing="0" class="">
  <tr>
    <td width="13%" rowspan="2" class="" >&nbsp;</td>
    <td width="36%" rowspan="2"  class=""><font color="#000000" size="1"><strong>Student Name</strong></font></td>
    <td width="19%" rowspan="2"  class=""><div align="center"><font color="#000000" size="1"><strong>Section</strong></font></div></td>
    <td align="center" class="" colspan="<%=iNumGrading%>" >-GRADES-</td>
    <td align="center" class="" colspan="<%=iNumGrading + 1%>">-ABSENCES-</td>
    <td width="12%" rowspan="2" class="" align="center"><font color="#000000" size="1"><strong>REMARKS</strong></font></td>
  </tr>
  <tr style="font-weight:bold" >
    <% 
		iIndexOf = 0;
	
		for (i = 0; i < iNumGrading; ++i){
			strTemp = ((String)vPMTSchedule.elementAt((i*2)+1)).toLowerCase();
			
			if(strTemp.startsWith("prelim"))
				strTemp = "P";
			else if(strTemp.startsWith("midterm"))
				strTemp= "M";
			else if(strTemp.startsWith("semi"))
				strTemp= "PF";
			else if(strTemp.startsWith("final"))
				strTemp= "F";
				
		%>
    <td  class="" align="center"  width="6%"><font color="#000000" size="1"><%=strTemp%></font></td>
    <%} // end for loop
	  
		for (i = 0; i < iNumGrading; ++i){
			strTemp = ((String)vPMTSchedule.elementAt((i*2)+1)).toLowerCase();
			
			if(strTemp.startsWith("prelim"))
				strTemp = "P";
			else if(strTemp.startsWith("midterm"))
				strTemp= "M";
			else if(strTemp.startsWith("semi"))
				strTemp= "PF";
			else if(strTemp.startsWith("final"))
				strTemp= "F";
				
		%>
    <td  class="" align="center" width="8%"><font color="#000000" size="1"><%=strTemp%></font></td>
    <%} // end for loop%>
    <td class="" align="center" width="6%"><font color="#000000" size="1">TOT</font></td>
  </tr>
  <%	String strFontColor = null;//red if failed.
		String strGrade     = null;	
		
		for(iCount = 1; iNumStud<vRetResult.size(); iNumStud+=9+(iNumGrading-1)+iIncKvalue,++iIncr, ++iCount){
		i = iNumStud;
		if (iCount > iNoOfStudPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;
		
	if (bolSeparateMixedSection && (!((String)vRetResult.elementAt(i+8)).equals(strCurrentSubIndex))) {
		iIncr = 1;  // reset student number count
		bolPageBreak = true;		
		break;
	}

	if( ((String)vRetResult.elementAt(i+7)).toLowerCase().startsWith("f"))
		strFontColor = " color=red";
	else	
		strFontColor = "";

if(!bolMalePrinted) {
	if(((String)vRetResult.elementAt(i+8)).equals("M")){	
	bolMalePrinted = true;%>
  <tr>
    <td height="18"><strong>Male</strong></td>
    <td  class="">&nbsp;</td>
    <td  class="">&nbsp;</td>
    <td align="center"  class="">&nbsp;</td>
    <td  class="" align="center">&nbsp;</td>
    <td align="center"  class="">&nbsp;</td>
    <td align="center"  class="">&nbsp;</td>
  </tr>
<%}
}if(!bolFemalePrinted) {
	if(((String)vRetResult.elementAt(i+8)).equals("F")){	
		bolFemalePrinted = true;%>
  <tr>
    <td height="18"><strong>Female</strong></td>
    <td  class="">&nbsp;</td>
    <td  class="">&nbsp;</td>
    <td align="center"  class="">&nbsp;</td>
    <td  class="" align="center">&nbsp;</td>
    <td align="center"  class="">&nbsp;</td>
    <td align="center"  class="">&nbsp;</td>
  </tr>
<%}
}

strTemp = strStudSectionQuery+"'"+(String)vRetResult.elementAt(i+1)+"'";
strTemp = dbOP.getResultOfAQuery(strTemp, 0);
if(strTemp == null)
	strTemp = WI.fillTextValue("section_name");

%>
  <tr>
    <td height="22"  class=""<%=strFontColor%>><font size="1">&nbsp;<%=iIncr%></font></td>
    <td  class=""><font size="1"<%=strFontColor%>>&nbsp;<%=(String)vRetResult.elementAt(i+2)%></font></td>
    <td  class="" align="center"><font size="1"<%=strFontColor%>>&nbsp;<%=strTemp%></font></td>
    <% for (k = 0; k < iNumGrading; ++k) {
			strGrade = (String)vRetResult.elementAt(i+8+k+iIncKvalue);
			if(strGrade == null)
				strGrade = "";
				
	  iIndexOf = strGrade.indexOf("/");
	  if(iIndexOf > -1) {
	  	strFinalGrade = strGrade.substring(iIndexOf + 1);
		strGrade = strGrade.substring(0, iIndexOf);	  
	  }
	  else
	  	strFinalGrade = "";

		if(strGrade != null) {
			try {
				Double.parseDouble(strGrade);
				if(strGrade.length() == 4)
					strGrade += "0";
			}
			catch(Exception e) {
			
			}
		}
		if(strFinalGrade != null) {
			try {
				Double.parseDouble(strFinalGrade);
				if(strFinalGrade.length() == 4)
					strFinalGrade = strFinalGrade.substring(0,3);
			}
			catch(Exception e) {
			
			}
		}


	  //vInfoAvgRoundOff.addElement(strGrade);
	  %>
    <td align="center"  class=""<%=strFontColor%>><font size="1"<%=strFontColor%>><strong> <%=WI.getStrValue(strGrade,"-")%></strong></font></td>
    <%} //end for loop k = 0; k < iNumGrading; ++k%>
    <%//I have to find here round off and avg.. 
	  //adAvgRoundOff  = gsExtn.getAvgAndRoundOff(vInfoAvgRoundOff);
	  //vInfoAvgRoundOff = new Vector();
	  
	
		
	  for (int xx = 0; xx < iNumGrading; ++xx){
	%>
    <td  class="" align="center"><font size="1"<%=strFontColor%>>&nbsp;</font></td>
    <%} // end for loop%>
    <td align="center"  class=""><font size="1"<%=strFontColor%>>&nbsp;</font></td>	
    <td align="center"  class=""><font size="1"<%=strFontColor%>><%=(String)vRetResult.elementAt(i+7)%></font></td>
  </tr>
  <%} //end for loop i = iNumStud, iCount = 1; i<vRetResult.size(); i+=9+(iNumGrading-1), iCount++ 
		strTemp = Integer.toString(8+iNumGrading) + 1;
	
	if ( iNumStud > vRetResult.size()-1 || iIncr == 1) {%>
  <tr>
    <td colspan="<%=strTemp%>"  class=""><div align="center">************** 
      NOTHING FOLLOWS ****************</div></td>
    <%//=iPagectr%>
  </tr>
  <%}else{// end iNumStud >= vRetResult.size()%>
  <tr>
    <td colspan="<%=strTemp%>"  class=""><div align="center">************** 
      CONTINUED ON NEXT PAGE ****************</div></td>
    <%//=iPagectr++%>
  </tr>
  <%}%>
</table>

 <%
  } //end vRetResult size  == 0
} // vSecDetail != null
//INSERT PAGE BREAK ONLY IF IT IS NOT LAST PAGE. -- TO AVOID BLANK PAGE AT THE END.
if (bolPageBreak){%>
  <DIV style="page-break-before:always" >&nbsp;</DIV>
    <%}//page break ony if it is not last page.
	} //end for (iNumStud < vRetResult.size()%>
	
	
	
<br>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
  	<tr>
	  <Td width="40%" valign="top" class="thinborderall"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td colspan="3">REMINDERS:</td>
        </tr>
        <tr>
          <td width="6%" align="right" valign="top">1.&nbsp; </td>
          <td width="94%">SPC's final grading remarks are Passed, Failed, 
            Failure Debarred(FD), &amp; Withdrawn(W).<strong><br>
            NO other remarks are allowed</strong>.</td>
        </tr>
        <tr>
          <td valign="top" align="right">2.&nbsp; </td>
          <td>Use <strong>black ink</strong> for Passing Grades and <strong>red ink</strong> for Failures, FD, W. </td>
        </tr>
        <tr>
         
          <td valign="top" align="right">3.&nbsp; </td>
          <td>Entries in the Grading Sheet <strong>must always</strong> correspond to the entries in Schoolautomate and Class Record. </td>
        </tr>
        <tr>
         
          <td valign="top" align="right">4.&nbsp;</td>
          <td>If there are students not included in the Grading Sheet, 
            please verify with the Registrar's Office immediately.</td>
        </tr>
        
      </table></Td>
		<td width="2%">&nbsp;</td>
		<td valign="top">
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr>					
					<td colspan="4" align="justify">I hereby certify that the above entries are true and 
					correct and such entries correspond to the entries in my Class Record 
					and those which I have encoded in the automated grading sheet.</td>
				</tr>
				<tr><td colspan="4" height="30">&nbsp;</td></tr>
				<tr>
					<td colspan="4" height="25" valign="bottom" align="center"><%//=WI.getTodaysDate(1)%><br>Date Encoded</td>
				</tr>
				<tr><td colspan="4" height="30">&nbsp;</td></tr>
				<tr>
				  <td width="33%" height="15" align="center" valign="bottom">
		  		  <div style="border-bottom:solid 1px #000000; width:90%"><%=WI.getStrValue(strDateEncodedPrelim)%></div></td>
					<td width="33%" align="center" valign="bottom">
					<div style="border-bottom:solid 1px #000000; width:90%"><%=WI.getStrValue(strDateEncodedMidterm)%></div></td>
					<td width="34%" align="center" valign="bottom">
					<div style="border-bottom:solid 1px #000000; width:90%"><%=WI.getStrValue(strDateEncodedFinal)%></div></td>
			  </tr>
				  <tr>
					<td align="center">Prelim</td>
					<td align="center">Midterm</td>
					<td align="center">Finals</td>
				  </tr>
				  
				 <tr>
					<td align="center">&nbsp;</td>
					<td align="center" height="30" valign="bottom">
						<div style="border-bottom:solid 1px #000000; width:90%"></div></td>
					<td align="center">&nbsp;</td>
			  </tr>
				  <tr>
					<td align="center">&nbsp;</td>
					<td align="center">Signature</td>
					<td align="center">&nbsp;</td>
				  </tr> 
				
				
				  <tr>
					<td align="center">&nbsp;</td>
					<td align="center" height="30" valign="bottom">Date Submitted</td>
					<td align="center">&nbsp;</td>
				  </tr> 	
				 <tr>
					<td align="center">&nbsp;</td>
					<td align="center" height="30" valign="bottom">
						<div style="border-bottom:solid 1px #000000; width:90%"></div></td>
					<td align="center">&nbsp;</td>
			  </tr>
			</table>		
			</td>
	</tr>
  </table>	
	
	
	
<%} //end end upper most if (vRetResult !=null)%>
    <input type="hidden" name="page_action">
    <input type="hidden" name="print_page">
</form>
</body>
</html>
<% dbOP.cleanUP(); %>