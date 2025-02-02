<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/common.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript"  src ="../../../Ajax/ajax.js" ></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ReloadPage()
{
	document.form_.print_page.value="";
	document.form_.submit();
}

function PrintPg(){
		document.form_.print_page.value="1";
		document.form_.submit();
}
function focusID() {
	document.form_.stud_id.focus();
}
function ChangeFontSize() {
	var vFontSize = document.form_.font_size[document.form_.font_size.selectedIndex].value;
	eval('document.form_.font_size_test.style.fontSize = '+vFontSize);
}

//// - all about ajax..
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
	document.form_.print_page.value="";
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}
</script>
<body bgcolor="#D2AE72" onLoad="focusID();">
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
	 if(WI.fillTextValue("print_page").compareTo("1") == 0) {%>
			<jsp:forward page="./grade_certificate_cross_enrollee_print.jsp" />
	<%} // if printPage = 1
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-GRADES-Grade Certification","grade_certificate_cross_enrollee_ul.jsp");
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
														"Registrar Management","GRADES",request.getRemoteAddr(),
														null);
//if iAccessLevel == 0, i have to check if user is set for sub module.
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
									"Registrar Management","GRADES-Grade Certification",request.getRemoteAddr(),
									null);
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

GradeSystem GS = new GradeSystem();
FAPaymentUtil pmtUtil = new FAPaymentUtil();
Vector vRetResult  = null;
Vector vSemester = new Vector();
String[] astrConvertSem={"SUMMER", "1ST SEM","2ND SEM","3RD SEM"};
ReportRegistrar rr = new ReportRegistrar();

//get student information first before getting grade details.
Vector vStudInfo =  pmtUtil.getStudBasicInfoOLD(dbOP, request.getParameter("stud_id"));
Vector vGradeDetail = null;
if(vStudInfo == null)
	strErrMsg = pmtUtil.getErrMsg();
else
	strDegreeType = (String)vStudInfo.elementAt(10);//1 = masteral, 2 = doctor of medicine.


boolean bolShowIP = false;//show grades not yet encoded..

String strLastPrintedDate = null;
if(strSchCode.startsWith("UDMC") && vStudInfo != null && vStudInfo.size() > 0 && WI.fillTextValue("sy_from").length() > 0) {
	String strSYFrom   = WI.fillTextValue("sy_from");

	String strSQLQuery = "select DATE_PRINTED,semester from TRACK_PRINTING where STUD_INDEX = "+(String)vStudInfo.elementAt(0)+
		" and PRINT_MODULE = 1 and SY_FROM = "+strSYFrom +" order by sy_from, semester, date_printed desc";
	java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		if(strLastPrintedDate == null)
			strLastPrintedDate = ConversionTable.convertMMDDYYYY(rs.getDate(1))+" , Semester : "+rs.getString(2);
		else
			strLastPrintedDate = strLastPrintedDate + "<br>"+ConversionTable.convertMMDDYYYY(rs.getDate(1))+" , Semester : "+rs.getString(2);
	}
	rs.close();
}
%>

<form name="form_" action="./grade_certificate_cross_enrollee_ul.jsp" method="post">
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="7" align="center"><font color="#FFFFFF"><strong>::::
        CROSS ENROLLEE RECORD PAGE ::::</strong></font></td>
    </tr>
    <tr>
      <td width="2%" height="25" >&nbsp;</td>
      <td height="25" colspan="6" >&nbsp;&nbsp;<strong><%=WI.getStrValue(strErrMsg,"")%></strong></td>
    </tr>
    <tr>
      <td width="2%" height="25" >&nbsp;</td>
      <td width="32%" height="25" >Student ID: &nbsp;
      <input name="stud_id" type="text" id="stud_id" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp="AjaxMapName('1');"> </td>
      <td width="5%" ><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td width="11%" ><a href="javascript:ReloadPage()"><img src="../../../images/form_proceed.gif" border="0"></a></td>
      <td width="2%" >&nbsp;</td>
      <td width="45%" ><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label></td>
      <td width="3%" >&nbsp;</td>
    </tr>
<%if(strLastPrintedDate != null) {%>
    <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" colspan="5" style="font-size:14px; color:#FF0000; font-weight:bold">
	  	<%=" <u>Grade Certification already printed on :</u> <br>"+strLastPrintedDate%></td>
      <td >&nbsp;</td>
    </tr>
<%}%>
    <tr>
      <td colspan="7" height="25" >

	  <hr size="1"></td>
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
      <td height="25" >&nbsp;</td>
      <td height="25" >Grades for : </td>
      <td height="25" >School year :</td>
      <td >&nbsp;</td>
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
        <% if (WI.fillTextValue("third_sem").compareTo("3") == 0)
	{strTemp = "checked";
	 vSemester.addElement("3");
	} else strTemp="";%>
        <input type="checkbox" name="third_sem" value="3" <%=strTemp%>>
        3rd Sem
        <% if (WI.fillTextValue("summer").compareTo("0") == 0)
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
      <td >&nbsp;</td>
    </tr>
<%if(strSchCode.startsWith("UL")){%>
    <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" >
        <% if (WI.fillTextValue("first_sem2").compareTo("1") == 0)
	{strTemp = "checked";
	 vSemester.addElement("1");
	}else strTemp="";%>
        <input type="checkbox" name="first_sem2" value="1" <%=strTemp%>>
        1st Sem
        <% if (WI.fillTextValue("second_sem2").compareTo("2") == 0)
	{strTemp = "checked";
	 vSemester.addElement("2");
	} else strTemp="";%>
        <input type="checkbox" name="second_sem2" value="2" <%=strTemp%>>
        2nd Sem
        <% if (WI.fillTextValue("third_sem2").compareTo("3") == 0)
	{strTemp = "checked";
	 vSemester.addElement("3");
	} else strTemp="";%>
        <input type="checkbox" name="third_sem2" value="3" <%=strTemp%>>
        3rd Sem
        <% if (WI.fillTextValue("summer2").compareTo("0") == 0)
	{strTemp = "checked";
	 vSemester.addElement("0");
	} else strTemp="";%>
        <input type="checkbox" name="summer2" value="0" <%=strTemp%>>
        Summer</td>
      <td height="25" >
<%
strTemp = WI.fillTextValue("sy_from2");
%>
        <input name="sy_from2" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from2","sy_to2")'>
        to
<%
strTemp = WI.fillTextValue("sy_to2");
%>
        <input name="sy_to2" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"></td>
      <td ><a href="javascript:ReloadPage()"><img src="../../../images/view.gif" width="40" height="31" border="0"></a></td>
    </tr>
<%}%>
    <tr>
      <td height="25" width="2%" >&nbsp;</td>
<% if (WI.fillTextValue("show_gwa").length() == 1)  strTemp = "checked";
	else strTemp = "";%>
      <td width="54%" height="25" ><input name="show_gwa" type="checkbox" id="show_gwa" value="1" <%=strTemp%>>
        <font color="#0000FF" size="1">Include GWA in print out
		<%strTemp = WI.fillTextValue("show_inprogress");
		if(strTemp.length() > 0 || request.getParameter("print_page") == null)  {
			strTemp = " checked";
			bolShowIP = true;
		}
		else
			strTemp = "";
		%>
        <input name="show_inprogress" type="checkbox" value="1" <%=strTemp%>>
        Show Grade not encoded. </font></td>
      <td width="19%" height="25" >&nbsp; </td>
      <td width="25%" >&nbsp;</td>
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
      <td height="25" colspan="4"><div align="center"><strong>FINAL GRADES FOR
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
						(String)vSemester.elementAt(i), true, bolShowIP, false, false);

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
		for(j=0; j< vGradeDetail.size(); j += 7){
			strTemp = (String)vGradeDetail.elementAt(j + 5);
		if(strTemp != null && strTemp.equals("Grade not encoded"))
			strTemp = "In Progress";
		%>
          <tr>
            <td width="25%" height="25"><%=(String)vGradeDetail.elementAt(j + 1)%>&nbsp;</td>
            <td width="21%"><div align="center"><%=strTemp%>&nbsp;</div></td>
            <td width="11%"><div align="center"><%=WI.getStrValue(vGradeDetail.elementAt(j + 3))%>&nbsp;</div></td>
            <td width="17%"><div align="center"><%=WI.getStrValue(vGradeDetail.elementAt(j + 6))%>&nbsp;</div></td>
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
      <td colspan="5" height="25">&nbsp;</td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="2%" height="25">&nbsp;</td>
      <td width="18%" height="25">
	  <%
	  strTemp = WI.fillTextValue("registrar_designation");
	  if(strTemp.length() == 0)
	  	strTemp = "University Registrar";
	  %>
	  <input name="registrar_designation" type="text" value="<%=strTemp%>" class="textbox_noborder" size="48" ></td>
      <td width="77%" height="25" colspan="2"><input name="registrar" type="text" value="<%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP,"University Registrar",1))%>" class="textbox_noborder" size="48" ></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td valign="top">Purpose of Certification (header) </td>
      <td height="25" colspan="2"><textarea rows="5" cols="75" style="font-size:11px;" name="purpose" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("purpose")%></textarea></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td valign="top">Purpose of Certification (footer) </td>
      <td height="25" colspan="2"><textarea rows="5" cols="75" style="font-size:11px;" name="purpose_footer" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("purpose_footer")%></textarea></td>
    </tr>
    <tr>
      <td colspan="5" height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">Printing Font Size : </td>
      <td height="25" colspan="2"> <select name="font_size" onChange="ChangeFontSize();" onkeyUp="ChangeFontSize();">
          <%
strTemp = request.getParameter("font_size");
if(strTemp == null)
	strTemp = "12";
if(strTemp.compareTo("7") == 0) {%>
          <option value="7" selected>7 px</option>
          <%}else{%>
          <option value="7">7 px</option>
          <%}if(strTemp.compareTo("8") == 0) {%>
          <option value="8" selected>8 px</option>
          <%}else{%>
          <option value="8">8 px</option>
          <%}if(strTemp.compareTo("9") == 0) {%>
          <option value="9" selected>9 px</option>
          <%}else{%>
          <option value="9">9 px</option>
          <%}if(strTemp.compareTo("10") == 0) {%>
          <option value="10" selected>10 px</option>
          <%}else{%>
          <option value="10">10 px</option>
          <%}if(strTemp.compareTo("11") == 0) {%>
          <option value="11" selected>11 px</option>
          <%}else{%>
          <option value="11">11 px</option>
          <%}if(strTemp.compareTo("12") == 0) {%>
          <option value="12" selected>12 px</option>
          <%}else{%>
          <option value="12">12 px</option>
          <%}if(strTemp.compareTo("14") == 0) {%>
          <option value="14" selected>14 px</option>
          <%}else{%>
          <option value="14">14 px</option>
          <%}if(strTemp.compareTo("15") == 0) {%>
          <option value="15" selected>15 px</option>
          <%}else{%>
          <option value="15">15 px</option>
          <%}if(strTemp.compareTo("16") == 0) {%>
          <option value="16" selected>16 px</option>
          <%}else{%>
          <option value="16">16 px</option>
          <%}%>
        </select> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <input type="text" name="font_size_test"
		style="border:0px;font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;" value="::: Actual size of Font :::" size="45"></td>
    </tr>

    <tr>
      <td colspan="5" height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3"><div align="center"><a href="javascript:PrintPg()">
          <img src="../../../images/print.gif" border="0"></a><font size="1">click
          to print Grade Certificate</font></div></td>
    </tr>
  </table>
<%} //end sy_from length == 4 and at least 1 sem selected
} // if vStudinfo == null%>
<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="5" height="25">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="5" height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
</table>

<input type="hidden" name="print_page" value="<%=strPrintPage%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       