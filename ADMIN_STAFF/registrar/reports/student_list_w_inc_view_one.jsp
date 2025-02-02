<%@ page language="java" import="utility.*,enrollment.ReportRegistrarExtn,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>
<script language="javascript" src="../../../jscript/td.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg()
{
 	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	var sT = "#";
	var SYFromCon = "";
	if(vProceed) {
		if(!document.form_.view_all.checked) {//must enter SY/term info.
			if(document.form_.sy_from.value.length == 0) {
				alert("Please enter SY/Term Information.");
				return;
			}
			SYFromCon = "&sy_from="+document.form_.sy_from.value+"&semester="+
						document.form_.semester[document.form_.semester.selectedIndex].value;
		}
		sT = "./student_list_w_inc_view_one_print.jsp?stud_id="+escape("<%=WI.fillTextValue("stud_id")%>")+
				"&report_type=<%=WI.fillTextValue("report_type")%>&report_type_name="+
				escape("<%=WI.fillTextValue("report_type_name")%>")+SYFromCon;
		var win=window.open(sT,"myfile",'dependent=no,width=850,height=550,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
}
function showHideSYInfo() {
	if(document.form_.view_all.checked)
		hideLayer('sy_info');
	else
		showLayer('sy_info');
}
</script>

<body bgcolor="#D2AE72" onLoad="showHideSYInfo();">
<%
	String strErrMsg = null;
	String strTemp = null;
	String strImgFileExt = null;
	
	String[] astrConvertYear ={"","1st Year","2nd Year","3rd Year","4th Year","5th Year","6th Year","7th Year"};
	String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};
	String[] astrConvertRegStat = {"Regular","Irregular"};

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-REPORTS-Student list with INC","student_list_w_inc_view_one.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");
		
		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening connection";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = 2;//comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
						//								"Registrar Management","REPORTS",request.getRemoteAddr(),
							//							"student_list_w_inc_view_one.jsp");
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
ReportRegistrarExtn RR = new ReportRegistrarExtn();
enrollment.GradeSystem GS = new enrollment.GradeSystem();

Vector vRetResult      = null;
Vector vStudInfo       = GS.getResidencySummary(dbOP, request.getParameter("stud_id"));
if(vStudInfo == null)
	strErrMsg = GS.getErrMsg();
else {
	strImgFileExt = "<img src=\"../../../upload_img/"+request.getParameter("stud_id")+"."+strImgFileExt+"\" width=150 height=150>";
	vRetResult  = RR.getListOfSubOfAStudWithINC(dbOP, (String)vStudInfo.elementAt(0),
					request.getParameter("report_type"),null,null);
	if(vRetResult == null)
		strErrMsg = RR.getErrMsg();
}
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
dbOP.cleanUP();
%>
<form name="form_" action="./student_list_w_inc_view_one.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
        STUDENT DETAILS OF GRADE STATUS (<%=request.getParameter("report_type_name")%>) 
        ::::</strong></font></div></td>
    </tr>
</table>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr bgcolor="#FFFFFF"> 
    <td width="5%" height="25">&nbsp;</td>
    <td width="95%">
	<a href="./student_list_w_inc.jsp"><img src="../../../images/go_back.gif" border="0"></a> &nbsp;&nbsp;&nbsp;
	<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
  </tr>
</table>

<%
if(vStudInfo != null) {%>

  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td height="25">&nbsp;</td>
    <td>Student ID</td>
    <td><strong><%=request.getParameter("stud_id")%></strong></td>
    <td width="37%" rowspan="6" valign="top"><%=strImgFileExt%></td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td width="12%">Name</td>
    <td width="46%"><strong><%=WebInterface.formatName((String)vStudInfo.elementAt(1),(String)vStudInfo.elementAt(2),(String)vStudInfo.elementAt(3),1)%></strong></td>
  </tr>
  <tr> 
    <td width="5%" height="25">&nbsp;</td>
    <td>Course/Major</td>
    <td><strong><%=(String)vStudInfo.elementAt(6)%> 
      <%if(vStudInfo.elementAt(7) != null){%>
      /<%=(String)vStudInfo.elementAt(6)%> 
      <%}%>
      </strong></td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25">Year</td>
    <td height="25"><strong><%=WI.getStrValue(vStudInfo.elementAt(10),"N/A")%></strong></td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25"  colspan="2">Total units required for this course : <strong><%=WI.getStrValue(vStudInfo.elementAt(12),"0")%></strong></td>
  </tr>
  <tr> 
    <td height="25">&nbsp;</td>
    <td height="25" colspan="2">Total units completed : <strong><%=WI.getStrValue(vStudInfo.elementAt(13),"0")%></strong></td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td height="25" colspan="2">
      <input type="checkbox" name="view_all" value="1" onClick="showHideSYInfo();" checked>
      Print All 
	  &nbsp;&nbsp;&nbsp;
	  <label id="sy_info">
	  SY-Term : 
	  <%
strTemp = WI.fillTextValue("sy_from");
if(request.getParameter("sy_from") == null)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");	  
%>
      <input name="sy_from" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
to
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");	  
%>
<input name="sy_to" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
-
<select name="semester">
  <option value="1">1st Sem</option>
  <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
	
if(strTemp == null) 
	strTemp = "";
if(strTemp.compareTo("2") ==0){%>
  <option value="2" selected>2nd Sem</option>
  <%}else{%>
  <option value="2">2nd Sem</option>
  <%}if(strTemp.compareTo("3") ==0){%>
  <option value="3" selected>3rd Sem</option>
  <%}else{%>
  <option value="3">3rd Sem</option>
  <%}if(strTemp.compareTo("4") ==0){%>
  <option value="4" selected>4th Sem</option>
  <%}else{%>
  <option value="4">4th Sem</option>
  <%}if(strTemp.compareTo("0") ==0){%>
  <option value="0" selected>Summer</option>
  <%}else{%>
  <option value="0">Summer</option>
  <%}%>
</select>
</label>
</td>
    <td valign="top">&nbsp;</td>
  </tr>
</table>
<%//System.out.println(vStudInfo);
}//if stud info not null

if(vRetResult != null && vRetResult.size() > 0) { %>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
   		 <TD align="right"><a href='javascript:PrintPg();'><img src="../../../images/print.gif" border="0"></a> 
      		<font size="1">click to print report</font></TD>
        </tr>
    <tr bgcolor="#B9B292"> 
      <td height="25"><div align="center"><font color="#FFFFFF"><strong>LIST OF 
        SUBJECTS WITH GRADE STATUS :(<%=request.getParameter("report_type_name")%>) 
        </strong></font></div></td>
    </tr>
</table>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td width="2%" height="25">&nbsp;</td>
    <td width="21%"><font size="1"><strong>SUBJECT CODE</strong></font></td>
    <td width="44%"><font size="1"><strong>SUBJECT TITLE</strong></font></td>
<!--    <td width="13%"><font size="1"><strong>TOTAL UNITS</strong></font></td>
-->
    <td width="13%"><font size="1"><strong>FACULTY NAME</strong></font></td>

<%if(strSchCode.startsWith("VMUF")){%>
    <td width="12%"><div align="center"><strong><font size="1">SIGNATURE</font></strong></div></td>
    <td width="10%"><div align="center"><strong><font size="1">DATE</font></strong></div></td>
    <td width="10%"><div align="center"><strong><font size="1">OR NUMBER</font></strong></div></td>
<%}%>
  </tr>
  <%
int iSYFrom = 0; 
int iSYTo   = 0 ; 
int iSem    = 0;

String strDispSYInfo = null;

for(int i = 0 ; i< vRetResult.size() ; i += 7){
if(iSYFrom == 0 || Integer.parseInt((String)vRetResult.elementAt(i + 2)) != iSYFrom || 
	iSem != Integer.parseInt((String)vRetResult.elementAt(i + 4))) {
iSYFrom = Integer.parseInt((String)vRetResult.elementAt(i + 2));
iSYTo   = Integer.parseInt((String)vRetResult.elementAt(i + 3));
iSem    = Integer.parseInt((String)vRetResult.elementAt(i + 4));
strDispSYInfo = "<b> SY ("+(String)vRetResult.elementAt(i + 2)+" - "+(String)vRetResult.elementAt(i + 3)+"),"+ astrConvertSem[iSem];
}
else 
	strDispSYInfo = null;

if(strDispSYInfo != null){%>
  <tr> 
    <td width="2%" height="25">&nbsp;</td>
    <td colspan="2"><%=strDispSYInfo%></td>
    <td>&nbsp;</td>
<%if(strSchCode.startsWith("VMUF")){%>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
<%}%>
  </tr>
  <%}%>
  <tr> 
    <td width="2%" height="25">&nbsp;</td>
    <td><%=(String)vRetResult.elementAt(i)%></td>
    <td><%=(String)vRetResult.elementAt(i + 1)%></td>
<!--    <td><%=(String)vRetResult.elementAt(i + 5)%></td>
-->    <td><%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"N/F")%></td>
<%if(strSchCode.startsWith("VMUF")){%>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
<%}%>
  </tr>
  <%}//end of for loop%>
</table>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td height="22">&nbsp;</td>
  </tr>
  <tr> 
    <td><div align="right"><a href='javascript:PrintPg();'> <img src="../../../images/print.gif" border="0"></a> 
        <font size="1">click to print report</font></div></td>
  </tr>
</table>
<%}//only if vRetResult not null
%>


<table  bgcolor="#ffffff" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>
</form>
</body>
</html>
