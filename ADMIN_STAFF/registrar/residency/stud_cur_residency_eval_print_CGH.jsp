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
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}
    TABLE.thinborderALL {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;	
    }
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }

-->
</style>
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
function ShowResult() {
	if(document.form_.stud_id.value == "") {
		alert("Please enter student ID.");
		return;
	}
//	if(document.form_.sy_from.value == "") {
//		alert("Please enter SY Information.");
//		return;	
//	}
	document.form_.show_result.value = "1";
}
function PrintPg() {
	document.getElementById('myADTable1').deleteRow(0);
	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<body topmargin="0">
<%@ page language="java" import="utility.*,enrollment.GradeSystem,student.StudentEvaluation,java.util.Vector" %>
<%

	DBOperation dbOP = null; 
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

	String[] astrConvertYear ={"","LEVEL I","LEVEL II","LEVEL III","LEVEL IV","LEVEL V",};
	String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem","","","",""};
	String[] astrConvertResStatus = {"Regular","Irregular"};

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-STUDENT CURRICULUM EVALUATION","stud_cur_residency_eval.jsp");
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
														"Registrar Management","STUDENT COURSE EVALUATION",request.getRemoteAddr(),
														null);
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
					"FACULTY/ACAD. ADMIN","STUDENTS PERFORMANCE",request.getRemoteAddr(),
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
	//adviser are allowed to check. 
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","ADVISING & SCHEDULING",request.getRemoteAddr(),
														"stud_cur_residency_eval_print.jsp");
	if(iAccessLevel == 0) {
		dbOP.cleanUP();
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
}

//end of authenticaion code.
GradeSystem GS = new GradeSystem();
StudentEvaluation SE = new StudentEvaluation();
Vector vRetResult = null;
Vector vTemp = null;

if(WI.fillTextValue("show_result").length() > 0) {
	vTemp = GS.getResidencySummary(dbOP, WI.fillTextValue("stud_id"));
	if(vTemp == null)
		strErrMsg = GS.getErrMsg();
	else {
		vRetResult = SE.getCurriculumResidencyEval(dbOP,(String)vTemp.elementAt(0),(String)vTemp.elementAt(15),
                                           (String)vTemp.elementAt(16),(String)vTemp.elementAt(8),(String)vTemp.elementAt(9),
                                           (String)vTemp.elementAt(11));
		if(vRetResult == null || vRetResult.size() ==0)
			strErrMsg = SE.getErrMsg();
	}
}

String strEffectiveCY = null;
if(WI.fillTextValue("sy_from").length() > 0) 
	strEffectiveCY = WI.fillTextValue("sy_from")+" - "+Integer.toString(Integer.parseInt(WI.fillTextValue("sy_from")) + 1);
else if(vTemp != null && vTemp.size() > 0) 
	strEffectiveCY = (String)vTemp.elementAt(8)+" - "+(String)vTemp.elementAt(9);

Vector vMathEnglEnrichment = GS.getMathEngEnrichmentInfo(dbOP, request);
if(vMathEnglEnrichment == null)
	vMathEnglEnrichment = new Vector();
%>
<form method="post" action="./stud_cur_residency_eval_print_CGH.jsp" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr>
      <td width="12%" height="20">Student ID </td>
      <td width="43%">
        <input type="text" class="textbox" style="font-size:11px;" value="<%=WI.fillTextValue("stud_id")%>" size="16" name="stud_id"
		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        &nbsp;&nbsp;
		<a href="javascript:OpenSearch();">Search</a> &nbsp;&nbsp;
	  <input name="Submit" type="submit" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="ShowResult()" value="Proceed"></td>
      <td width="5%" align="right">SY &nbsp;&nbsp;</td>
      <td width="20%">
      <input type="text" class="textbox" style="font-size:11px;" 
	  		value="<%=WI.fillTextValue("sy_from")%>" size="4" maxlength="4" name="sy_from" onKeyUp="AllowOnlyInteger('form_','sy_from');"
			onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','sy_from');style.backgroundColor='white'">      </td>
      <td width="20%"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>
	  <font size="1">Print Report</font></td>
    </tr>
</table>
<%if(vTemp != null && vTemp.size()>0){%>  
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="20" colspan="4"><div align="center">
	  <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
        COURSE CURRICULUM<br>
		EFFECTIVE SY <%=strEffectiveCY%>
        </strong></div></td>
    </tr>
    <tr>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
    </tr>
    <tr>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
    </tr>
    <tr>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
    </tr>
</table>
<%}if(strErrMsg != null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td width="2%" height="20">&nbsp;</td>
      <td width="98%" height="20" colspan="2"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
  </table>
<%}if(vTemp != null && vTemp.size()>0)
{%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr> 
    <td height="20">&nbsp;</td>
    <td width="15%">Student name</td>
    <td width="45%"><%=WI.formatName((String)vTemp.elementAt(1),(String)vTemp.elementAt(2),(String)vTemp.elementAt(3),1)%></td>
    <td width="10%">Student No.</td>
    <td width="28%"><%=WI.fillTextValue("stud_id")%></td>
  </tr>
  <tr> 
    <td height="20">&nbsp;</td>
    <td width="15%"></td>
    <td width="45%"></td>
    <td width="10%"></td>
    <td width="28%"></td>
  </tr>
</table>
<%}//only vTemp is not null -- having residency summary.
if(vRetResult != null){ 
String strPrevYr  = null;
String strCurYr   = null;
int iPrevSem = 0;
int iCurSem  = 0;

int i = 0;
double dTotalUnit = 0d;


//move the math and english a to bottom of the semester.
int iIndexOf = -1;
iIndexOf     = vRetResult.indexOf("ENGL A");


if(iIndexOf > -1) {
	//I have to find out what is the last index of 1st year and 1st sem.
	int iIndexOf2ndSem = 0;
	while(true) {
		if(!WI.getStrValue(vRetResult.elementAt(iIndexOf2ndSem+1),"6").equals("1"))
			break;
		iIndexOf2ndSem += 16;
	} 
	--iIndexOf2ndSem;
	iIndexOf = iIndexOf - 4;
	vRetResult.insertElementAt(vRetResult.remove(iIndexOf),iIndexOf2ndSem);	vRetResult.insertElementAt(vRetResult.remove(iIndexOf),iIndexOf2ndSem);
	vRetResult.insertElementAt(vRetResult.remove(iIndexOf),iIndexOf2ndSem);	vRetResult.insertElementAt(vRetResult.remove(iIndexOf),iIndexOf2ndSem);
	vRetResult.insertElementAt(vRetResult.remove(iIndexOf),iIndexOf2ndSem);	vRetResult.insertElementAt(vRetResult.remove(iIndexOf),iIndexOf2ndSem);
	vRetResult.insertElementAt(vRetResult.remove(iIndexOf),iIndexOf2ndSem);	vRetResult.insertElementAt(vRetResult.remove(iIndexOf),iIndexOf2ndSem);
	vRetResult.insertElementAt(vRetResult.remove(iIndexOf),iIndexOf2ndSem);	vRetResult.insertElementAt(vRetResult.remove(iIndexOf),iIndexOf2ndSem);
	vRetResult.insertElementAt(vRetResult.remove(iIndexOf),iIndexOf2ndSem);	vRetResult.insertElementAt(vRetResult.remove(iIndexOf),iIndexOf2ndSem);
	vRetResult.insertElementAt(vRetResult.remove(iIndexOf),iIndexOf2ndSem);	vRetResult.insertElementAt(vRetResult.remove(iIndexOf),iIndexOf2ndSem);
	vRetResult.insertElementAt(vRetResult.remove(iIndexOf),iIndexOf2ndSem);	vRetResult.insertElementAt(vRetResult.remove(iIndexOf),iIndexOf2ndSem);
	
	//math enrichment - move to bottom of 1st year/1st sem.
	iIndexOf2ndSem = 0;
	while(true) {
		if(!WI.getStrValue(vRetResult.elementAt(iIndexOf2ndSem+1),"6").equals("1"))
			break;
		iIndexOf2ndSem += 16;
	} 
	--iIndexOf2ndSem;
	iIndexOf = vRetResult.indexOf("MATH A") - 4;
	vRetResult.insertElementAt(vRetResult.remove(iIndexOf),iIndexOf2ndSem);	vRetResult.insertElementAt(vRetResult.remove(iIndexOf),iIndexOf2ndSem);
	vRetResult.insertElementAt(vRetResult.remove(iIndexOf),iIndexOf2ndSem);	vRetResult.insertElementAt(vRetResult.remove(iIndexOf),iIndexOf2ndSem);
	vRetResult.insertElementAt(vRetResult.remove(iIndexOf),iIndexOf2ndSem);	vRetResult.insertElementAt(vRetResult.remove(iIndexOf),iIndexOf2ndSem);
	vRetResult.insertElementAt(vRetResult.remove(iIndexOf),iIndexOf2ndSem);	vRetResult.insertElementAt(vRetResult.remove(iIndexOf),iIndexOf2ndSem);
	vRetResult.insertElementAt(vRetResult.remove(iIndexOf),iIndexOf2ndSem);	vRetResult.insertElementAt(vRetResult.remove(iIndexOf),iIndexOf2ndSem);
	vRetResult.insertElementAt(vRetResult.remove(iIndexOf),iIndexOf2ndSem);	vRetResult.insertElementAt(vRetResult.remove(iIndexOf),iIndexOf2ndSem);
	vRetResult.insertElementAt(vRetResult.remove(iIndexOf),iIndexOf2ndSem);	vRetResult.insertElementAt(vRetResult.remove(iIndexOf),iIndexOf2ndSem);
	vRetResult.insertElementAt(vRetResult.remove(iIndexOf),iIndexOf2ndSem);	vRetResult.insertElementAt(vRetResult.remove(iIndexOf),iIndexOf2ndSem);

	
	//vRetResult.remove(iIndexOf - 4);
}


%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr><td colspan="2">&nbsp;</td></tr>
  <%boolean bolEnrichment = false;
  for(; i< vRetResult.size();){%>
  <tr> 
    <td width="50%" valign="top"> <%
	iCurSem = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"6"));
	if(iCurSem == 1){dTotalUnit =0d;
	%> <table width="100%" cellpadding="0" cellspacing="4px" border="0">
        <tr> 
          <td align="center" style="font-size:11px;"><strong><%=astrConvertYear[Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i),"0"))]%></strong></td>
          <td align="center"><strong>First Semester</strong></td>
          <td align="center"><label id="<%=(String)vRetResult.elementAt(i)+"1"%>"></label></td>
          </tr>
        <%
		for(; i< vRetResult.size();){//1st semester only.
		//if(vRetResult.elementAt(i+4).equals("ENGL A"))
		//	System.out.println(vRetResult.elementAt(i+10));
		iCurSem = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"6"));
		if(iCurSem != 1)
			break;
		//if(!vRetResult.elementAt(i+4).equals("MATH A") && !vRetResult.elementAt(i+4).equals("ENGL A")) {
		if(vMathEnglEnrichment.indexOf(vRetResult.elementAt(i+4)) == -1) {
			bolEnrichment = false;
			dTotalUnit += Double.parseDouble((String)vRetResult.elementAt(i + 10));
		}
		else	
			bolEnrichment = true;
		
		//grade in 2 decimal
		strTemp = WI.getStrValue(vRetResult.elementAt(i+14),"&nbsp; -- &nbsp;");//&nbsp;&nbsp;&nbsp;&nbsp; -> Changed to --
		if(strTemp.indexOf(".") != -1 && strTemp.length() == 3)
			strTemp = strTemp+"0";
		
		%>
        <tr> 
          <td width="20%" align="right"><u><%=strTemp%></u>&nbsp;&nbsp;&nbsp;&nbsp;</td>
          <td width="69%"><%=(String)vRetResult.elementAt(i+5)%></td>
          <td width="11%" align="center">
		  	<%if(bolEnrichment){%>(<%}%><%=WI.getStrValue((String)vRetResult.elementAt(i+10), "--").charAt(0)%><%if(bolEnrichment){%>)<%}%></td>
          </tr>
        <%i += 16;}//prints only 1st semester. - Inner for loop%>
		<tr><td colspan="3">&nbsp;</td></tr> 
<!--
        <tr> 
          <td>&nbsp;</td>
          <td><div align="right"><strong>TOTAL</strong></div></td>
          <td align="center"><strong><%=CommonUtil.formatFloat(dTotalUnit, false)%></strong></td>
          </tr>
-->
<script language="javascript">
//get total unit.. 
document.getElementById("<%=(String)vRetResult.elementAt(i - 16)+"1"%>").innerHTML = "<b><%=CommonUtil.formatFloat(dTotalUnit, false)%></b>";
</script>
      </table>
      <%}//only for 1st year.%> </td>
    <td width="50%" valign="top"> <%dTotalUnit =0d;
	iCurSem = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"6"));
	if(iCurSem == 2){%> <table width="100%" cellpadding="0" cellspacing="4px" border="0">
        <tr> 
          <td align="center">&nbsp;</td>
          <td align="center">&nbsp;</td>
          <td align="center"><strong>Second Semester</strong></td>
          <td align="center"><label id="<%=(String)vRetResult.elementAt(i)+"2"%>"></label></td>
        </tr>
        
        <%for(; i< vRetResult.size();){//1st semester only.
		iCurSem = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"6"));
		if(iCurSem != 2)
			break;
		//if(!vRetResult.elementAt(i+4).equals("MATH A") && !vRetResult.elementAt(i+4).equals("ENGL A")) {
		if(vMathEnglEnrichment.indexOf(vRetResult.elementAt(i+4)) == -1) {
			bolEnrichment = false;
			dTotalUnit += Double.parseDouble((String)vRetResult.elementAt(i + 10));
		}
		else	
			bolEnrichment = true;
//		dTotalUnit += Double.parseDouble((String)vRetResult.elementAt(i + 10));
		
		//grade in 2 decimal
		strTemp = WI.getStrValue(vRetResult.elementAt(i+14),"&nbsp; -- &nbsp;");//&nbsp;&nbsp;&nbsp;&nbsp; -> Changed to --
		if(strTemp.indexOf(".") != -1 && strTemp.length() == 3)
			strTemp = strTemp+"0";
		
		%>
        <tr>
          <td width="3%">&nbsp;</td> 
          <td width="17%" align="right"><u><%=strTemp%></u>&nbsp;&nbsp;&nbsp;&nbsp;</td>
          <td width="69%"><%=(String)vRetResult.elementAt(i+5)%></td>
          <td width="11%" align="center"><%if(bolEnrichment){%>(<%}%><%=((String)vRetResult.elementAt(i+10)).charAt(0)%><%if(bolEnrichment){%>)<%}%></td>
          </tr>
        <%i += 16;}//prints only 1st semester. - Inner for loop%>
		<tr><td colspan="3">&nbsp;</td></tr> 
<!--
        <tr>
          <td>&nbsp;</td> 
          <td>&nbsp;</td>
          <td><div align="right"><strong>TOTAL</strong></div></td>
          <td align="center"><strong><%=CommonUtil.formatFloat(dTotalUnit, false)%></strong></td>
          </tr>
-->
<script language="javascript">
//get total unit.. 
document.getElementById("<%=(String)vRetResult.elementAt(i - 16)+"2"%>").innerHTML = "<b><%=CommonUtil.formatFloat(dTotalUnit, false)%></b>";
</script>
      </table>
      <%}//only for 1st year.%> </td>
  </tr>
  <%
iCurSem = 1;dTotalUnit = 0d;
if(i< vRetResult.size())
	iCurSem = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"6"));
if(iCurSem == 0) {%>
  <tr> 
    <td align="center"> 
		<table width="100%" cellpadding="0" cellspacing="4px" border="0">
        <tr> 
          <td align="center" width="20%">&nbsp;</td>
          <td align="center" width="69%"><strong>Summer</strong></td>
          <td align="center" width="11%"><label id="<%=(String)vRetResult.elementAt(i)+"0"%>"></label></td>
        </tr>
        <%for(; i< vRetResult.size();){//1st semester only.
		iCurSem = Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+1),"6"));
		if(iCurSem != 0)
			break;
		dTotalUnit += Double.parseDouble((String)vRetResult.elementAt(i + 10));
		
		//grade in 2 decimal
		strTemp = WI.getStrValue(vRetResult.elementAt(i+14),"&nbsp; -- &nbsp;");//&nbsp;&nbsp;&nbsp;&nbsp; -> Changed to --
		if(strTemp.indexOf(".") != -1 && strTemp.length() == 3)
			strTemp = strTemp+"0";
		
		%>
        <tr> 
          <td align="right"><u><%=strTemp%></u>&nbsp;&nbsp;&nbsp;&nbsp;</td>
          <td><%=(String)vRetResult.elementAt(i+5)%></td>
          <td align="center"><%=((String)vRetResult.elementAt(i+10)).charAt(0)%></td>
          </tr>
        <%i += 16;}//prints only 1st semester. - Inner for loop%>
		<tr><td colspan="3">&nbsp;</td></tr> 
<!--
        <tr> 
          <td align="center">&nbsp;</td>
          <td><div align="right"><strong>TOTAL</strong></div></td>
          <td><div align="center"><strong><%=CommonUtil.formatFloat(dTotalUnit, false)%></strong></div></td>
          </tr>
-->
<script language="javascript">
//get total unit.. 
document.getElementById("<%=(String)vRetResult.elementAt(i - 16)+"0"%>").innerHTML = "<b><%=CommonUtil.formatFloat(dTotalUnit, false)%></b>";
</script>
      </table></td>
	 <td>&nbsp;</td>
  </tr>


  <%}//end of display summer.

}//end of for loop to display grade/course evaluation
%>
  <tr> 
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
</table>
<%}%>
<input type="hidden" name="show_result">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
