<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/common.css" rel="stylesheet" type="text/css">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",-1);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%></head>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript">

function ReloadPage()
{
	document.form_.print_page.value="";
	document.form_.submit();
}


</script>
<body bgcolor="#9FBFD0" >
<%@ page language="java" import="utility.*,enrollment.GradeSystem,enrollment.ReportRegistrar, enrollment.FAPaymentUtil,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strPrintPage = "";

	String strDegreeType = null;// for doctoral , it should be HOURS not units.
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";

//add security here.
	 if(WI.fillTextValue("print_page").compareTo("1") == 0) {
	 	if (strSchCode.startsWith("UI")) {
			if (WI.fillTextValue("addressee").length() != 0 && WI.fillTextValue("addr1").length()!=0){ %>
			<jsp:forward page="./grade_certificate_print.jsp" />
	<%}else{
				strErrMsg = "Printing requires all data.";
				strPrintPage = "";
		    }
		}else{if (WI.fillTextValue("addressee").length() != 0 && WI.fillTextValue("addr1").length()!=0
		&& WI.fillTextValue("checker").length()!=0 && WI.fillTextValue("designation").length()!=0
		 && WI.fillTextValue("registrar").length()!=0) {
	%>
		<jsp:forward page="./grade_certificate_print.jsp" />
	<%	return;
		}else{
			strErrMsg = "Printing requires all data.";
			strPrintPage = "";
		} // end if addresse/addr1 length()!=0
	  } // if strSchCode
	} // if printPage = 1
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-GRADES-Grade Certification","grade_certificate.jsp");
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
int iAccessLevel = comUtil.isUserAuthorizedForParentStudLink(dbOP,(String)request.getSession(false).getAttribute("userId"),
							(String)request.getSession(false).getAttribute("authTypeIndex"),request.getRemoteAddr());
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../PARENTS_STUDENTS/main_files/parents_students_bottom_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}

//end of authenticaion code.

GradeSystem GS = new GradeSystem();
FAPaymentUtil pmtUtil = new FAPaymentUtil();
Vector vRetResult  = null;
Vector vSemester = new Vector();
String[] astrConvertSem={"SUMMER", "1ST SEM","2ND SEM","3RD SEM"};
ReportRegistrar rr = new ReportRegistrar();

//get student information first before getting grade details.
String strStudID = WI.fillTextValue("stud_id");
if (strStudID.length() == 0)
	strStudID = (String)request.getSession(false).getAttribute("userId");


Vector vStudInfo =  pmtUtil.getStudBasicInfoOLD(dbOP, strStudID);
Vector vGradeDetail = null;
if(vStudInfo == null)
	strErrMsg = pmtUtil.getErrMsg();
else
	strDegreeType = (String)vStudInfo.elementAt(10);//1 = masteral, 2 = doctor of medicine.
%>

<form name="form_" action="./grade_certificate.jsp" method="post">
<input name="stud_id" type="hidden" size="16" value="<%=strStudID%>">
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6" align="center" bgcolor="#47768F"><font color="#FFFFFF"><strong>::::
        GRADE CERTIFICATION PAGE ::::</strong></font></td>
    </tr>
    <tr>
      <td width="2%" height="25" >&nbsp;</td>
      <td height="25" colspan="5" >&nbsp;&nbsp;<strong><%=WI.getStrValue(strErrMsg,"")%></strong></td>
    </tr>
    <tr>
      <td colspan="6" height="25" ><hr size="1"></td>
    </tr>
  </table>
<% if(vStudInfo != null && vStudInfo.size() > 0){%>
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="2%" height="25" >&nbsp;</td>
      <td height="25" >Student name : <strong><%=(String)vStudInfo.elementAt(1)%></strong></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" >Course/Major : <strong><%=(String)vStudInfo.elementAt(2)%>
        <%=WI.getStrValue((String)vStudInfo.elementAt(3),"/","","")%></strong></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td width="98%" height="25" >Year : <strong><%=(String)vStudInfo.elementAt(4)%></strong></td>
    </tr>
    <tr>
      <td colspan="2" height="25" ><hr size="1"></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="2%" height="25" >&nbsp;</td>
      <td width="54%" height="25" >Grades for : </td>
      <td width="19%" height="25" >School year :</td>
      <td width="25%" >&nbsp;</td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" >
        <% if (WI.fillTextValue("first_sem").compareTo("1") == 0)
	{strTemp = "checked";
	 vSemester.addElement("1");
	}else strTemp="";%>
        <input type="checkbox" name="first_sem" value="1" <%=strTemp%>>
        1st Sem
        <% if (WI.fillTextValue("second_sem").compareTo("2") == 0)
	{strTemp = "checked";
	 vSemester.addElement("2");
	} else strTemp="";%>
        <input type="checkbox" name="second_sem" value="2" <%=strTemp%>>
        2nd Sem
        <% if (!strSchCode.startsWith("CPU")) {

		 if (WI.fillTextValue("third_sem").compareTo("3") == 0)
	{strTemp = "checked";
	 vSemester.addElement("3");
	} else strTemp="";%>
        <input type="checkbox" name="third_sem" value="3" <%=strTemp%>>
        3rd Sem
     <%} if (WI.fillTextValue("summer").compareTo("0") == 0)
	{strTemp = "checked";
	 vSemester.addElement("0");
	} else strTemp="";%>
        <input type="checkbox" name="summer" value="0" <%=strTemp%>>
        Summer</td>
      <td height="25" >
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"></td>
      <td ><a href="javascript:ReloadPage()"><img src="../../images/refresh.gif" width="71" height="23" border="0"></a></td>
    </tr>
    <tr >
      <td height="25" colspan="4"><hr size="1"></td>
    </tr>
  </table>
<% if (WI.fillTextValue("sy_from").length() == 4 && vSemester.size()!=0){ %>
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr >
      <td height="25" colspan="4"><div align="right"> </div></td>
    </tr>
    <tr bgcolor="#B9B292">
      <td height="25" colspan="4" bgcolor="#BECED3"><div align="center"><strong>FINAL GRADES FOR
          <%=astrConvertSem[Integer.parseInt((String)vSemester.elementAt(0))]%>
          <% for (int i = 1; i <vSemester.size() ; ++i) {%>
          <%=" & " + astrConvertSem[Integer.parseInt((String)vSemester.elementAt(i))]%>
      <%}%> , AY <%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%> </strong></div></td>
    </tr>
  </table>

  <table bgcolor="#FFFFFF"  width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr>
      <td width="25%" height="25" align="center" ><font size="1"><strong>SUBJECTS</strong></font></td>
      <td width="21%" align="center" ><font size="1"><strong>FINAL GRADES</strong></font></td>
      <td width="11%" align="center"><font size="1"><strong>
	  <%if(strDegreeType != null && strDegreeType.compareTo("2") == 0){%>HOURS
	  <%}else{%>UNITS<%}%></strong></font></td>
      <td width="17%" align="center"><font size="1"><strong>REMARKS</strong></font></td>
      <td width="26%" align="center"><font size="1"><strong>INSTRUCTOR</strong></font></td>
    </tr>
<%
	int j = 0;
	for(int i = 0; i < vSemester.size(); i++){
		vGradeDetail = GS.gradeReleaseForAStud(dbOP,(String)vStudInfo.elementAt(0),
						"final",request.getParameter("sy_from"),request.getParameter("sy_to"),
						(String)vSemester.elementAt(i));

		if(vGradeDetail == null)
			strErrMsg = GS.getErrMsg();

		if(strErrMsg == null) strErrMsg = "";
%>
    <tr>

      <td  height="25" colspan="5" >
        <table width="99%" border="0" align="center" cellpadding="0" cellspacing="0">
          <tr>
            <td height="25" colspan="5"><u><%=astrConvertSem[Integer.parseInt((String)vSemester.elementAt(i))]%> ,
			<%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%></u>
              <%
	if(WI.fillTextValue("show_gwa").compareTo("1") ==0)  {
	double dGWA = new student.GWA().getGWAForAStud(dbOP,(String)vStudInfo.elementAt(0),
									request.getParameter("sy_from"),request.getParameter("sy_to"),(String)vSemester.elementAt(i),
									(String)vStudInfo.elementAt(6),(String)vStudInfo.elementAt(7),null);
	if(dGWA > 0d){%>
              (GWA : <strong><%=CommonUtil.formatFloat(dGWA,true)%></strong>)
              <%}
	}%>
            </td>
          </tr>
          <%
	if (vGradeDetail !=null) {
		for(j=0; j< vGradeDetail.size(); j += 7){%>
          <tr>
            <td width="25%" height="25"><%=(String)vGradeDetail.elementAt(j + 1)%>&nbsp;</td>
            <td width="21%"><div align="center"><%=(String)vGradeDetail.elementAt(j + 5)%>&nbsp;</div></td>
            <td width="11%"><div align="center"><%=(String)vGradeDetail.elementAt(j + 3)%>&nbsp;</div></td>
            <td width="17%"><div align="center"><%=(String)vGradeDetail.elementAt(j + 6)%>&nbsp;</div></td>
            <td width="26%"><div align="center"><%=WI.getStrValue((String)vGradeDetail.elementAt(j+4),"NA")%></div></td>
          </tr>
          <%} //end inner for loop
}else{%>
          <td  height="25" colspan="5" > &nbsp; <%=WI.getStrValue(strErrMsg,"")%></td>
          <%}%>
          <tr>
            <td height="15">&nbsp;</td>
            <td><div align="center"></div></td>
            <td><div align="center"></div></td>
            <td><div align="center"></div></td>
            <td><div align="center"></div></td>
          </tr>
        </table> </td>

    </tr>
<%} // for (i <vSemester.size() %>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="100%" height="25">&nbsp;</td>
    </tr>
    <% vRetResult = rr.getAddrGradeCert(dbOP,request);
	if (vRetResult !=null  && vRetResult.size()!=0)
		strTemp = WI.getStrValue((String)vRetResult.elementAt(1));
	else
		strTemp = WI.fillTextValue("addressee");
%>
    <% 	if (vRetResult !=null  && vRetResult.size()!=0)
		strTemp = (String)vRetResult.elementAt(2);
	else
		strTemp = WI.fillTextValue("addr1");%>
    <% 	if (vRetResult !=null && vRetResult.size()!=0)
		strTemp = WI.getStrValue((String)vRetResult.elementAt(3),"");
	else
		strTemp = WI.fillTextValue("addr2");%>
    <% if (!strSchCode.startsWith("UI")){%>
    <%}%>
  </table>
<%} //end sy_from length == 4 and at least 1 sem selected
} // if vStudinfo == null%>
<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="5" height="25">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="5" height="25" bgcolor="#47768F">&nbsp;</td>
    </tr>
</table>

<input type="hidden" name="print_page" value="<%=strPrintPage%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
