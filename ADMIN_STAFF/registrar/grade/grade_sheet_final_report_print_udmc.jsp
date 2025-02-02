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

    TABLE.thinborderall {
    border: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
	
	TD.thinborderBottom{
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
	}

    TD.thinborderGrade {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
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
	String strTemp2   = null;
	Vector vSecDetail = null;
	boolean bolPageBreak = false;
	int j = 0;

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


String strEmployeeID = (String)request.getSession(false).getAttribute("userId");
String strSchCode = (String)request.getSession(false).getAttribute("school_code");//strSchCode = "AUF";
String strEmployeeIndex = (String)request.getSession(false).getAttribute("userIndex");
String strSubSecIndex   = null;
String strOfferedByCollege = null;

Vector vEncodedGrade = new Vector();
Vector vRetResult    = new Vector();

//get here necessary information.
if(WI.fillTextValue("section_name").length() > 0 && WI.fillTextValue("subject").length() > 0) {
	strSubSecIndex = dbOP.mapOneToOther("E_SUB_SECTION join faculty_load on (faculty_load.sub_sec_index = e_sub_section.sub_sec_index) ",
						"section","'" + WI.fillTextValue("section_name")+ "'"," e_sub_section.sub_sec_index", 
						" and e_sub_section.sub_index = " + WI.fillTextValue("subject") +
						" and faculty_load.is_valid = 1 and e_sub_section.offering_sy_from = "+
						WI.fillTextValue("sy_from")+" and e_sub_section.offering_sy_to = "+ WI.fillTextValue("sy_to") +
						" and e_sub_section.offering_sem="+ WI.fillTextValue("offering_sem")+" and is_lec=0");
}
if(strSubSecIndex != null) {//get here subject section detail. 
	
	strOfferedByCollege = dbOP.mapOneToOther("e_sub_section","sub_sec_index", strSubSecIndex, 
											"OFFERED_BY_COLLEGE", "");
	vSecDetail = reportEnrl.getSubSecSchDetail(dbOP,strSubSecIndex);
	if(vSecDetail == null)
		strErrMsg = reportEnrl.getErrMsg();
}

boolean bolSeparateMixedSection = WI.fillTextValue("separate_grades").equals("1");

if(strSubSecIndex != null) {
	strTemp = dbOP.getResultOfAQuery("select pmt_sch_index from fa_pmt_schedule where exam_name like 'final%'",0);
	vRetResult = gsExtn.getStudListForGradeSheetEncoding(dbOP, strTemp,
												strSubSecIndex,false);
	if(vRetResult == null)
		strErrMsg = gsExtn.getErrMsg();
	else
		vEncodedGrade = (Vector)vRetResult.elementAt(0);
}

    Vector vEmpRec = new enrollment.Authentication().operateOnBasicInfo(dbOP,request,"0");
	
	
		int i = 0; int k = 0; int iNumGrading = 0; int iCount = 0;
		int iMaxStudPerPage = 40; 

		if (WI.fillTextValue("num_stud_page").length() > 0)
			iMaxStudPerPage = Integer.parseInt(WI.fillTextValue("num_stud_page"));


		String strCurrentSubIndex = WI.fillTextValue("subject");
		int iStudCount    = 1; // student count
		int iPrintIncr    = 0; //must print equals to max # of student per page.
		
		int iIncKvalue = 0; // add to to accomodate sub_index inserted in element[8]
		
		if (bolSeparateMixedSection){
			iIncKvalue = 1;
		}
		
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

		astrConvSemester[0] = "SUMMER";
		astrConvSemester[1] = "FIRST SEMESTER";
		astrConvSemester[2] = "SECOND SEMESTER";
		astrConvSemester[3] = "THIRD SEMESTER";


while (vEncodedGrade.size()>0){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="100%" colspan="3" align="center"><%=astrConvSemester[Integer.parseInt(WI.fillTextValue("offering_sem"))]%> &nbsp;
	  <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%></td>
    </tr>
  </table>
  <table border=0 cellpadding="0" cellspacing="0" width="100%">
    <tr>
<% if(WI.fillTextValue("subject").length() > 0)
		strTemp = dbOP.mapOneToOther("SUBJECT","SUB_INDEX",strCurrentSubIndex,"sub_code"," and is_del<>1");
	else
		strTemp = "";
%>
      <td width="12%" height="25" valign="bottom">Subject Code:</td>
      <td width="16%" valign="bottom" class="thinborderBottom"><strong>&nbsp;<%=strTemp%></strong></td>
      <%
if(WI.fillTextValue("subject").length() > 0)
	strTemp = dbOP.mapOneToOther("SUBJECT","SUB_INDEX",strCurrentSubIndex,"sub_name"," and is_del<>1");
else
	strTemp = "";
 %>
      <td width="13%" valign="bottom"><div align="right">Subject Title: </div></td>
      <td width="41%" valign="bottom" class="thinborderBottom"><strong>&nbsp;<%=strTemp%></strong></td>
      <td width="18%" valign="bottom">&nbsp;&nbsp;Units: <u><strong><%=GS.getLoadingForSubject(dbOP, request.getParameter("subject"))%></strong></u></td>
    </tr>
    <tr>
      <td height="25" valign="bottom">Schedule:</td>
      <td colspan="2" valign="bottom" class="thinborderNone">
	  <%if(vSecDetail != null){%>
          <%=WI.getStrValue(vSecDetail.elementAt(3)).toUpperCase()%> 
      <%}%>      <div align="right"></div></td>
      <td valign="bottom" class="thinborderNone" align="right">Section :</td>
      <td valign="bottom"><span class="thinborderNone"><strong><%=WI.fillTextValue("section_name")%></strong></span></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td width="60%"><div align="center"> <strong> 
          <%if(vSecDetail != null){%>
          <%=WI.getStrValue(vSecDetail.elementAt(0)).toUpperCase()%> 
          <%}%>
          </strong></div></td>
      <td width="40%">&nbsp;</td>
    </tr>
    <tr> 
      <td><div align="center">NAME OF INSTRUCTOR(S)</div></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
  <td width="48%" valign="top">
  	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
		<tr>
			<td width="5%" class="thinborder" height="22">SL #.</td>
			<td width="20%" class="thinborder">ID Number</td>
			<td width="60%" align="center" class="thinborder">Last Name, First Name, MI</td>
			<td width="15%" class="thinborder">Final Rating</td>
		</tr>
	 <%for(iPrintIncr = 1; vEncodedGrade.size() > 0; ++iStudCount){%>
	 	<tr>
			<td class="thinborder" height="22"><%=iStudCount%></td>
			<td class="thinborder"><%=(String)vEncodedGrade.elementAt(1)%></td>
			<td class="thinborder"><%=(String)vEncodedGrade.elementAt(2)%></td>
			<td class="thinborder"><%=(String)vEncodedGrade.elementAt(7)%></td>
		</tr>
	  <%
	  vEncodedGrade.removeElementAt(0);vEncodedGrade.removeElementAt(0);vEncodedGrade.removeElementAt(0);
	  vEncodedGrade.removeElementAt(0);vEncodedGrade.removeElementAt(0);vEncodedGrade.removeElementAt(0);
	  vEncodedGrade.removeElementAt(0);vEncodedGrade.removeElementAt(0);vEncodedGrade.removeElementAt(0); 
	  ++iPrintIncr; if(iPrintIncr > iMaxStudPerPage){++iStudCount; break;}
	  }%>
	 	<tr>
			<td class="thinborder" height="22" colspan="4" align="center">
				<%if(vEncodedGrade.size() > 0){%><b>Continued next column .. </b><%}else{%><b>Nothing Follows ..</b><%}%>
			</td>
		</tr>
	</table> 
   </td>
   <td width="4%">&nbsp;</td>
  <td width="48%" valign="top">
  <%if(vEncodedGrade.size() > 0){%>
  	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
		<tr>
			<td width="5%" class="thinborder" height="22">SL #.</td>
			<td width="20%" class="thinborder">ID Number</td>
			<td width="60%" align="center" class="thinborder">Last Name, First Name, MI</td>
			<td width="15%" class="thinborder">Final Rating</td>
		</tr>
	 <%for(iPrintIncr = 1; vEncodedGrade.size() > 0; ++iStudCount){%>
	 	<tr>
			<td class="thinborder" height="22"><%=iStudCount%></td>
			<td class="thinborder"><%=(String)vEncodedGrade.elementAt(1)%></td>
			<td class="thinborder"><%=(String)vEncodedGrade.elementAt(2)%></td>
			<td class="thinborder"><%=(String)vEncodedGrade.elementAt(7)%></td>
		</tr>
	  <%
	  vEncodedGrade.removeElementAt(0);vEncodedGrade.removeElementAt(0);vEncodedGrade.removeElementAt(0);
	  vEncodedGrade.removeElementAt(0);vEncodedGrade.removeElementAt(0);vEncodedGrade.removeElementAt(0);
	  vEncodedGrade.removeElementAt(0);vEncodedGrade.removeElementAt(0);vEncodedGrade.removeElementAt(0); 
	  ++iPrintIncr; if(iPrintIncr > iMaxStudPerPage){++iStudCount; break;}
	  }%>
	 	<tr>
			<td class="thinborder" height="22" colspan="4" align="center">
				<%if(vEncodedGrade.size() > 0){%><b>Continued next page .. </b><%}else{%><b>Nothing Follows ..</b><%}%>
			</td>
		</tr>
	  
	</table><%}else{%>&nbsp;<%}%>   
	</td>
   </tr>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  </table>	   
			 
  
  
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td colspan="2">Certified Correct: </td>
      <td width="29%" rowspan="7" valign="top">
	  <strong><u>Grading Sheet :</u></strong> <br>
	  <table width="98%" border="0" align="center" cellpadding="0" cellspacing="0">
        <tr>
          <td width="6%">1.00 </td>
          <td width="11%">99 - 100 </td>
          <td>2.25</td>
          <td>84 - 86 </td>
          </tr>
        <tr>
          <td>1.25</td>
          <td>96 - 98 </td>
          <td>2.50</td>
          <td>81 - 83 </td>
          </tr>
        <tr>
          <td>1.50</td>
          <td>93 - 95</td>
          <td width="6%">2.75</td>
          <td width="11%">78 - 81 </td>
          </tr>
        <tr>
          <td>1.75</td>
          <td>90 - 92 </td>
          <td>3.00 </td>
          <td>75 - 77 </td>
          </tr>
        <tr>
          <td height="17">2.00 </td>
          <td>87 - 89 </td>
          <td>5.00</td>
          <td>70</td>
          </tr>
      </table></td>
    </tr>
    <tr> 
      <td height="17" colspan="2" valign="bottom">&nbsp;</td>
    </tr>
    <tr> 
      <td height="23" colspan="2" valign="bottom"><div align="center"> 
          <table width="90%" border="0" cellspacing="0" cellpadding="0">
            <tr> 
              <td class="thinborderBottom"><div align="center"><%=WebInterface.formatName((String)vEmpRec.elementAt(1),(String)vEmpRec.elementAt(2),(String)vEmpRec.elementAt(3),4).toUpperCase()%></div></td>
            </tr>
          </table>
        </div></td>
    </tr>
    <tr> 
      <td colspan="2"><div align="center">Signature over Printed Name of Instructor/Professor</div></td>
    </tr>
    <tr> 
      <td colspan="2" valign="bottom"> <table width="98%" border="0" cellpadding="0" cellspacing="0">
          <tr> 
            <td width="15%" height="39" valign="bottom">Noted: </td>
            <td width="85%" valign="bottom" class="thinborderBottom"><div align="center"> 
            <label id="L_1" onClick="ChangeInfo('L_1')">
                <%=WI.getStrValue(dbOP.mapOneToOther("COLLEGE","C_INDEX",strOfferedByCollege,"DEAN_NAME"," and is_del = 0")).toUpperCase()%>
			</label>				
				</div></td>
          </tr>
          <tr> 
            <td height="18" valign="bottom">&nbsp;</td>
            <td valign="top"><div align="center"><font size="1">DEAN / HEAD</font></div></td>
          </tr>
        </table></td>
    </tr>
    <tr> 
      <td height="30" colspan="2" valign="bottom">Received: _____________________ 
        Date : ___________</td>
    </tr>
  </table>
<% 
//INSERT PAGE BREAK ONLY IF IT IS NOT LAST PAGE. -- TO AVOID BLANK PAGE AT THE END.
if (bolPageBreak){%>
  <DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.

}//end of while.%>

    <input type="hidden" name="page_action">
    <input type="hidden" name="print_page">
</form>
</body>
</html>
<% dbOP.cleanUP(); %>