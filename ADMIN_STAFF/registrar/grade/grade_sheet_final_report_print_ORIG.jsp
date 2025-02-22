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

</script>


<body>
<form name="gsheet" method="post">
<%@ page language="java" import="utility.*,enrollment.GradeSystemExtn,java.util.Vector " %>
<%
	WebInterface WI   = new WebInterface(request);
	DBOperation dbOP  = null;
	String strErrMsg  = null;
	String strTemp    = null;
	Vector vSecDetail = null;
	int j = 0;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-GRADES-Grade Releasing","grade_sheet.jsp");
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
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),"Registrar Management","GRADES",request.getRemoteAddr(),null);
//if iAccessLevel == 0, i have to check if user is set for sub module.
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),"Registrar Management","GRADES-Grade Sheets",request.getRemoteAddr(),null);

}
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
enrollment.ReportEnrollment reportEnrl= new enrollment.ReportEnrollment();
enrollment.GradeSystem  GS = new enrollment.GradeSystem();
GradeSystemExtn gsExtn     = new GradeSystemExtn();
String[] astrConvSemester = {"SUMMER", "FIRST SEMESTER", "SECOND SEMESTER", "THIRD SEMESTER"};

String strEmployeeID = (String)request.getSession(false).getAttribute("userId");
String strEmployeeIndex = dbOP.mapUIDToUIndex(strEmployeeID);
String strSubSecIndex   = null;

Vector vRetResult = null;
Vector vEncodedGrade = new Vector();

//get here necessary information.
if(WI.fillTextValue("section_name").length() > 0 && WI.fillTextValue("subject").length() > 0) {
	strSubSecIndex = dbOP.mapOneToOther("E_SUB_SECTION join faculty_load on (faculty_load.sub_sec_index = e_sub_section.sub_sec_index) ",
						"section","'"+WI.fillTextValue("section_name")+"'"," e_sub_section.sub_sec_index", 
						" and e_sub_section.sub_index = "+WI.fillTextValue("subject")+
						" and faculty_load.is_valid = 1 and e_sub_section.offering_sy_from = "+
						WI.fillTextValue("sy_from")+" and e_sub_section.offering_sy_to = "+WI.fillTextValue("sy_to")+
						" and e_sub_section.offering_sem="+
						WI.fillTextValue("offering_sem")+" and is_lec=0");
						
}
if(strSubSecIndex != null) {//get here subject section detail. 
	vSecDetail = reportEnrl.getSubSecSchDetail(dbOP,strSubSecIndex);
	if(vSecDetail == null)
		strErrMsg = reportEnrl.getErrMsg();
}


if(strSubSecIndex != null) {
	vRetResult = gsExtn.getAllGradesEncoded(dbOP,request,strSubSecIndex);
	if(vRetResult == null)
		strErrMsg = gsExtn.getErrMsg();
}

	enrollment.Authentication authentication = new enrollment.Authentication();
    Vector vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
	
	String strSchCode = dbOP.getSchoolIndex();
%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
<%
if(strSchCode.startsWith("LNU")){%>
    <tr>
      <td colspan="3">L-NU REG # 12</td>
    </tr>
<%}%>
    <tr> 
      <td colspan="3"><div align="center"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong></div></td>
    </tr>
    <tr> 
      <td colspan="3"><div align="center"><strong><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></strong></div></td>
    </tr>
<% if (vEmpRec!=null || vEmpRec.size()>0) {%>
    <tr> 
      <td colspan="3"><div align="center"><%=(String)vEmpRec.elementAt(13)%></div></td>
    </tr>
    <tr> 
      <td colspan="3"><div align="center"><%=WI.getStrValue((String)vEmpRec.elementAt(14),"&nbsp")%></div></td>
    </tr>
<%}%>
    <tr> 
      <td colspan="3"><div align="center"><strong>REPORT ON FINAL GRADES</strong></div></td>
    </tr>
    <tr> 
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td width="50%">&nbsp;&nbsp;SEMESTER : <strong><%=astrConvSemester[Integer.parseInt(WI.fillTextValue("offering_sem"))]%></strong></td>
      <td width="25%">&nbsp;</td>
      <td width="25%"><div align="center"><u>________________________</u></div></td>
    </tr>
    <tr> 
      <td>&nbsp;&nbsp;ACADEMIC YEAR: <strong><%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%></strong></td>
      <td>&nbsp;</td>
      <td><div align="center"><font size="1">DATE SUBMITTED</font></div></td>
    </tr>
  </table>
  

<%if(vSecDetail != null){%>
  <table width="100%" border="0" cellspacing="1" cellpadding="1" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="2"><div align="center"> <strong> </strong></div></td>
    </tr>
    <tr> 
      <td width="94%"><br>
        &nbsp;&nbsp;SUBJECT: <strong> 
        <%
if(WI.fillTextValue("subject").length() > 0) {
	strTemp = dbOP.mapOneToOther("SUBJECT","SUB_INDEX",request.getParameter("subject"),"sub_code +' (' + sub_name+')'"," and is_del=0");
%>
        <%=(WI.getStrValue(strTemp)).toUpperCase()%> 
        <%}%>
        </strong> </td>
      <td><div align="center"></div></td>
    </tr>
    <tr> 
      <td>&nbsp;&nbsp;CLASS SECTION/SCHEDULE: <strong><%=WI.fillTextValue("section_name")%>/ 
        <%for(int i = 1; i<vSecDetail.size(); i+=3){
	  if(i >1){%>
        , 
        <%}%>
        <%=(String)vSecDetail.elementAt(i+2)%> 
        <%}%>
        </strong></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td align="center">&nbsp;</td>
      <td width="4%">&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="2">&nbsp; </td>
    </tr>
  </table>
<%
if(!strSchCode.startsWith("UI")){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="49%"><div align="center"> <strong> 
          <%if(vSecDetail != null){%>
          <%=WI.getStrValue(vSecDetail.elementAt(0)).toUpperCase()%> 
          <%}%>
          </strong></div></td>
      <td width="51%">&nbsp;</td>
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
  <% }//do not show the top if UI 
	if (vRetResult != null && vRetResult.size() > 0){ 
	int i = 0;
%>
  <table width="100%" cellpadding="1" cellspacing="1" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="3%" class="thinborder"><font color="#000099" size="1" face="Verdana, Arial, Helvetica, sans-serif">
	  <strong>Count</strong></font></td>
      <td width="15%" class="thinborder"><font color="#000099" size="1" face="Verdana, Arial, Helvetica, sans-serif"><strong>ID. 
        Number</strong></font></td>
      <td width="25%"  class="thinborder"><div align="center"><font color="#000099" size="1"><strong>NAME 
          OF STUDENT</strong></font></div></td>
      <td width="25%"  class="thinborder"><div align="center"><font color="#000099" size="1"><strong>COURSE</strong></font></div></td>
      <% Vector vPMTSchedule = (Vector)vRetResult.elementAt(0); 
	  	int iNumGrading = vPMTSchedule.size()/2;
	int k =  0; int iCount = 0;
	for (i = 0; i < iNumGrading; ++i){ %>
      <td  class="thinborder"><div align="center"><font color="#000099" size="1"><%=i+1%></font></div></td>
      <%} // end for loop%>
      <td width="12%"  class="thinborder"><div align="center"><font color="#000099" size="1"><strong>REMARKS</strong></font></div></td>
    </tr>
    <%String strFontColor = null;//red if failed.	
	for(iCount=1, i = 1 ; i<vRetResult.size(); i+=9+(iNumGrading-1), ++iCount){
	if( ((String)vRetResult.elementAt(i+7)).toLowerCase().startsWith("f"))
		strFontColor = " color=red";
	else	
		strFontColor = "";
	%>
    <tr> 
      <td height="25"  class="thinborder"><font size="1"<%=strFontColor%>><%=iCount%></font></td>
      <td height="25"  class="thinborder"><font size="1"<%=strFontColor%>><%=(String)vRetResult.elementAt(i+1)%></font></td>
      <td  class="thinborder"><font size="1"<%=strFontColor%>><%=(String)vRetResult.elementAt(i+2)%></font></td>
      <td  class="thinborder"><font size="1"<%=strFontColor%>><%=(String)vRetResult.elementAt(i+3)+WI.getStrValue((String)vRetResult.elementAt(i+4),"/","","&nbsp")%></font></td>
      <% for (k = 0; k < iNumGrading; ++k) {%>
      <td align="center"  class="thinborder"><font size="1"<%=strFontColor%>><%=(String)vRetResult.elementAt(i+8+k)%></font></td>
      <%}%>
      <td align="center"  class="thinborder"><font size="1"<%=strFontColor%>><%=(String)vRetResult.elementAt(i+7)%></font></td>
    </tr>
    <%}%>
    <tr> 
      <td colspan="<%=5+iNumGrading%>"  class="thinborder"><div align="center">***************** 
          NOTHING FOLLOWS *******************</div></td>
      <%	for (i = 0; i < iNumGrading; ++i){ %>
      <%} // end for loop%>
    </tr>
  </table>

  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="50%">&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td>SUBMITTED BY:</td>
      <td width="24%" rowspan="5" valign="top"> <% if (vPMTSchedule!= null && vPMTSchedule.size()>0){ %> <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
          <% for (i = 0,iCount = 1; i < vPMTSchedule.size() ; i+=2, iCount++) {%>
          <tr> 
            <td width="19%" class="thinborder"><%=iCount%></td>
            <td width="81%" class="thinborder"><%=(String)vPMTSchedule.elementAt(i+1)%></td>
          </tr>
          <%}%>
        </table>
        <%}%> </td>
      <td width="1%" rowspan="5" valign="top">&nbsp; </td>
      <td width="24%" rowspan="5" valign="top"> <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
          <tr> 
            <td width="50%" class="thinborder">No Final Exam</td>
            <td width="50%" class="thinborder"> (NFE)</td>
          </tr>
          <tr> 
            <td class="thinborder">Incomplete</td>
            <td class="thinborder">(INC)</td>
          </tr>
          <tr> 
            <td class="thinborder">Dropped</td>
            <td class="thinborder">(DRP)</td>
          </tr>
        </table></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td width="50%" valign="bottom"><div align="center"> <strong> 
	  <u>&nbsp;&nbsp;&nbsp;
<%
if(!strSchCode.startsWith("UI")){%>
	  <%=WebInterface.formatName((String)vEmpRec.elementAt(1),(String)vEmpRec.elementAt(2),(String)vEmpRec.elementAt(3),4).toUpperCase()%>
<%}else if(vSecDetail != null){%>
          <%=WI.getStrValue(vSecDetail.elementAt(0)).toUpperCase()%> 
<%}%>	  
	  &nbsp;&nbsp;&nbsp;</u>
	  </strong></div></td>
    </tr>
    <tr> 
      <td><div align="center"><font size="1">INSTRUCTOR'S NAME AND SIGNATURE</font></div></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="4">
	  <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr> 
            <td width="32%">APPROVED BY:</td>
            <td width="36%">&nbsp;</td>
            <td width="32%">RECEIVED BY:</td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
          <tr valign="bottom"> 
            <td height="30"><div align="center">&nbsp;___________________________</div></td>
            <td height="30"><div align="center">
			<%
			strTemp = dbOP.mapOneToOther("E_SUB_SECTION","SUB_SEC_INDEX",strSubSecIndex,"OFFERED_BY_COLLEGE",null);
			if(strTemp == null) 
				strTemp = (String)vEmpRec.elementAt(11);
			%>
			<u>&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(dbOP.mapOneToOther("COLLEGE","C_INDEX",strTemp,"DEAN_NAME"," and is_del = 0")).toUpperCase()%>&nbsp;&nbsp;&nbsp;</u></div></td>
            <td height="30"><div align="center">
			<u><%=CommonUtil.getNameForAMemberType(dbOP, "university registrar",1)%></u></div></td>
          </tr>
          <tr> 
            <td height="25"><div align="center">DEPARTMENT HEAD</div></td>
            <td><div align="center">DEAN</div></td>
            <td><div align="center">UNIVERSITY REGISTRAR</div></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
          <tr> 
<%
if(strSchCode.startsWith("LNU")) {%>
            <td colspan="3"><table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborderall">
                <tr> 
                  <td width="18%"><div align="center">Issue Status</div></td>
                  <td width="19%"><div align="center">Revision</div></td>
                  <td width="21%"> <div align="center">Date </div></td>
                  <td width="42%"><div align="center">Approved by: (SGD.) DR. 
                      GONZALO T. DUQUE</div></td>
                </tr>
                <tr> 
                  <td><div align="center">3</div></td>
                  <td><div align="center">3</div></td>
                  <td><div align="center">DEC. 12, 2004</div></td>
                  <td><div align="center">President</div></td>
                </tr>
<%}%>				
              </table></td>
          </tr>
        </table></td>
    </tr>
  </table>
  <%} //end vRetResult size  == 0
} // vSecDetail != null
%>
<script language="JavaScript">
window.print();
</script>
  <input type="hidden" name="page_action">
<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
