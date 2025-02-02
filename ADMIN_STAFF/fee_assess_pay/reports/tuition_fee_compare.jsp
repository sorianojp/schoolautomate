<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg() {
 	document.bgColor = "#FFFFFF";
    document.getElementById('myADTable1').deleteRow(0);
	
    document.getElementById('myADTable2').deleteRow(0);
    document.getElementById('myADTable2').deleteRow(0);
    document.getElementById('myADTable2').deleteRow(0);
    document.getElementById('myADTable2').deleteRow(0);
    document.getElementById('myADTable2').deleteRow(0);
    document.getElementById('myADTable2').deleteRow(0);
    document.getElementById('myADTable2').deleteRow(0);
	
    document.getElementById('myADTable3').deleteRow(0);
    document.getElementById('myADTable3').deleteRow(0);
	
    alert("Click OK to print this page");
 	window.print();//called to remove rows, make bk white and call print.
}
function SetCourseName() {
	document.form_.course_name.value = document.form_.course_index[document.form_.course_index.selectedIndex].text;
}
///ajax here to load major..
function loadYrLevel() {
		var objCOA=document.getElementById("gs_yr");
 		var objInput = document.form_.edu_level[document.form_.edu_level.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=113&edu_level="+objInput+"&sel_name=yr_level&all=1";
		//alert(strURL);
		this.processRequest(strURL);
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp   = null;

//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS"),"0"));
		}
	}
	if(iAccessLevel == -1) {//for fatal error.
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0) {//NOT AUTHORIZED.
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}	
//end of authenticaion code.
	if(WI.fillTextValue("grade_").length() > 0 && WI.fillTextValue("sy_from").length() >  0 && WI.fillTextValue("sy_to").length() > 0 &&
		WI.fillTextValue("edu_level").length() > 0) {
		%><jsp:forward page="./tuition_fee_compare_grade.jsp"></jsp:forward>
		<%
		return;
	}

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments - Admission slip","admission_slip.jsp");
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

Vector vRetResult = null;
if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("sy_to").length() > 0 && 
	WI.fillTextValue("sy_from2").length() > 0 && WI.fillTextValue("sy_to2").length() > 0 && WI.fillTextValue("grade_").length() == 0 && WI.fillTextValue("course_index").length() > 0) {//this is time to call tuition comparison
	enrollment.ReportFeeAssessment rfa = new enrollment.ReportFeeAssessment();
	vRetResult  = rfa.compareTuitionFee(dbOP, request);
	if(vRetResult == null)
		strErrMsg = rfa.getErrMsg();	
}
String[] astrConvertToSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};
%>
<form action="./tuition_fee_compare.jsp" method="post" name="form_">
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable2">
    <tr>
      <td height="25" colspan="3" align="center" bgcolor="#A49A6A" ><font color="#FFFFFF"><strong>:::: 
          TUITION FEE COMPARISION PAGE ::::</strong></font></td>
    </tr>
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp; <font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font> </td>
    </tr>
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="10%">AY:Term</td>
      <td> 
<%
String strSYFrom = WI.fillTextValue("sy_from");
String strSemester = WI.fillTextValue("offering_sem");
if(strSYFrom.length() ==0)
	strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strSYFrom%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
<%
if(strSYFrom != null)
	strTemp = Integer.toString(Integer.parseInt(strSYFrom) + 1);
else	
	strTemp = "";
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> <select name="offering_sem">
          <option value="0">Summer</option>
          <%
if(strSemester.length() ==0)
	strSemester = (String)request.getSession(false).getAttribute("cur_sem");
if(strSemester.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
<%}else{%>
          <option value="1">1st Sem</option>
<%}if(strSemester.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
<%}else{%>
          <option value="2">2nd Sem</option>
<%}if(strSemester.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
<%}else{%>
          <option value="3">3rd Sem</option>
<%}%>
        </select> <font color="#0000FF" size="1"><strong>(Current semester. Always enter higher SY/Term than SY/Term below)</strong></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"><div align="center">(and)</div></td>
      <td height="25"> 
<%
strTemp = WI.fillTextValue("sy_from2");
if(strTemp.length() == 0) 
	strTemp = Integer.toString(Integer.parseInt(strSYFrom) - 1);
%> <input name="sy_from2" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from2","sy_to2")'>
        to 
<%
strTemp = WI.fillTextValue("sy_to2");
if(strTemp.length() == 0) 
	strTemp = strSYFrom;
%> <input name="sy_to2" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> <select name="offering_sem2">
          <option value="0">Summer</option>
<%
strTemp = WI.fillTextValue("offering_sem2");
if(strTemp.length() == 0) 
	strTemp = strSemester;
	
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select> &nbsp;&nbsp; Number of rows per page. &nbsp;&nbsp; <select name="rows_pg" style="font-weight:bold;">
          <%
int iDef = Integer.parseInt( WI.getStrValue(WI.fillTextValue("rows_pg"),"30"));
		for(int i = 24; i < 75; i += 2){
			if( i == iDef)
				strTemp = " selected";
			else	
				strTemp = "";
		%>
          <option value="<%=i%>"<%=strTemp%>><%=i%></option>
          <%}%>
        </select> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td style="font-weight:bold;color:#0000FF; font-size:11px;">
	  <input type="checkbox" name="grade_" value="checked" <%=WI.fillTextValue("grade_")%> onClick="document.form_.submit();">
	  Grade School 
<%if(WI.fillTextValue("grade_").length() > 0) {%>
	  &nbsp;&nbsp;&nbsp;
		<select name="edu_level" onChange="loadYrLevel();">
          <%=dbOP.loadCombo("distinct edu_level","EDU_LEVEL_NAME"," from BED_LEVEL_INFO order by edu_level",WI.fillTextValue("edu_level"),false)%> 
        </select>		
	  &nbsp;&nbsp;&nbsp;
	  <label id="gs_yr">
	  	<select name="yr_level">
		<option value="">All</option>
<%
if(WI.fillTextValue("edu_level").length() > 0) 
	strTemp = " from bed_level_info where edu_level_name = '"+WI.fillTextValue("edu_level")+"' order by g_level";
else	
	strTemp = " from bed_level_info where g_level < 4";
%>
          <%=dbOP.loadCombo("g_level","level_name",strTemp,WI.fillTextValue("yr_level"),false)%> 
		</select>
	  </label>
	  &nbsp;&nbsp;&nbsp;
	  <input name="image" type="image" src="../../../images/form_proceed.gif">
<%}%>	  
	  
	  </td>
    </tr>
<%if(WI.fillTextValue("grade_").length() == 0) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Year Level </td>
      <td height="25"><select name="yr_level">
	  <option value=""></option>
<%
strTemp = WI.fillTextValue("yr_level");
if(strTemp.equals("1"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
		<option value="1" <%=strErrMsg%>>1st Year</option>	  
<%
if(strTemp.equals("2"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
		<option value="2" <%=strErrMsg%>>2nd Year</option>	  		
<%
if(strTemp.equals("3"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
		<option value="3" <%=strErrMsg%>>3rd Year</option>	  		
<%
if(strTemp.equals("4"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
		<option value="4" <%=strErrMsg%>>4th Year</option>	  		
<%
if(strTemp.equals("5"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
		<option value="5" <%=strErrMsg%>>5th Year</option>	  		
<%
if(strTemp.equals("6"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
		<option value="6" <%=strErrMsg%>>6th Year</option>	  		
	  </select>	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Course</td>
      <td height="25"> <font size="1"> 
        <input type="text" name="scroll_course" size="16" style="font-size:9px" 
	  onKeyUp="AutoScrollList('form_.scroll_course','form_.course_index',true);">
        (enter course code to scroll course list)</font> <input name="image" type="image" src="../../../images/form_proceed.gif" onClick="SetCourseName();">      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25"><select name="course_index" style="font-size:11px;">
          <%
	strTemp = " from course_offered where IS_DEL=0 AND IS_VALID=1 order by course_code asc";
%>
          <%=dbOP.loadCombo("course_index","course_code+' ::: '+course_name",strTemp,WI.fillTextValue("course_index"), false)%> </select></td>
    </tr>
<%}//do not show if this is for grade school. %>
    <tr> 
      <td height="18" colspan="3"><hr size="1" color="#0000FF"></td>
    </tr>
  </table>
<%
int iSLNo = 0; 
int iPgCount = 0; 
double dTotalCur = 0d; double dTotalPrev = 0d; double dTotalDiff = 0d; double dCurPerPg = 0d; double dPrevPerPg = 0d; double dDiffPerPg =0d;
if(vRetResult != null && vRetResult.size() > 0) {%>
	  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable1">
		<tr > 
		  <td height="20" align="right">
		  <a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>
		  <font size="1">Click to print report.</font></td>
		</tr>
	  </table>
<%
	for(int i = 0; i < vRetResult.size();) {
	iPgCount = 0; dCurPerPg = 0d; dPrevPerPg = 0d; dDiffPerPg =0d;
	%>
	  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr> 
		  <td width="5%" height="20"><div align="center"><font size="1">DIFFERENCE 
			  OF TUITION FEE INCREASE<br>
			  <%=WI.fillTextValue("sy_from") + " ("+astrConvertToSem[Integer.parseInt(WI.fillTextValue("offering_sem"))]+")"%> v/s <%=WI.fillTextValue("sy_from2") + " ("+astrConvertToSem[Integer.parseInt(WI.fillTextValue("offering_sem2"))]+")"%><br>
			  <strong><%=WI.fillTextValue("course_name").substring(WI.fillTextValue("course_name").indexOf("::: ") + 4)%>
			  <%=WI.getStrValue(WI.fillTextValue("yr_level"), ", Year Level : ", "","")%>
			  
			  </strong><br>
			  </font> </div></td>
		</tr>
		<tr> 
		  <td height="20">&nbsp;</td>
		</tr>
	  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder" bgcolor="#FFFFFF">
    <tr bgcolor="#cccccc"> 
      <td width="5%" height="19" class="thinborder"><div align="center"><font size="1"><strong>SL. 
          NO</strong></font></div></td>
      <td width="20%" class="thinborder"><div align="center"><font size="1"><strong>STUDENT 
          ID</strong></font></div></td>
      <td width="25%" class="thinborder"><div align="center"><font size="1"><strong>STUDENT 
          NAME</strong></font></div></td>
      <td width="5%" class="thinborder"><div align="center"><font size="1"><strong>YEAR</strong></font></div></td>
      <td width="5%" class="thinborder"><div align="center"><font size="1"><strong>UNIT/HOUR</strong></font></div></td>
      <td width="14%" class="thinborder"><div align="center"><font size="1"><strong>CURRENT</strong></font></div></td>
      <td width="14%" class="thinborder"><div align="center"><font size="1"><strong>PREVIOUS</strong></font></div></td>
      <td width="12%" class="thinborder"><div align="center"><font size="1"><strong>DIFFERENCE</strong></font></div></td>
    </tr>
    <%
	for(; i < vRetResult.size(); i += 9){%>
    <tr> 
      <td height="20" class="thinborder">&nbsp;<%=++iSLNo%></td>
      <td height="20" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 3),"N/A")%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 4)%>/<%=(String)vRetResult.elementAt(i + 5)%></td>
      <td class="thinborder"><div align="right"><%=CommonUtil.formatFloat(((Double)vRetResult.elementAt(i + 6)).doubleValue(), true)%></div></td>
      <td class="thinborder"><div align="right"><%=CommonUtil.formatFloat(((Double)vRetResult.elementAt(i + 7)).doubleValue(), true)%></div></td>
      <td class="thinborder"><div align="right"><%=CommonUtil.formatFloat(((Double)vRetResult.elementAt(i + 8)).doubleValue(), true)%></div></td>
    </tr>
    <%
		dCurPerPg  += ((Double)vRetResult.elementAt(i + 6)).doubleValue(); 
		dPrevPerPg += ((Double)vRetResult.elementAt(i + 7)).doubleValue(); 
		dDiffPerPg += ((Double)vRetResult.elementAt(i + 8)).doubleValue();
		
		++iPgCount; 
		if(iPgCount == iDef) {
			i += 9;
			break;
		}
	}
	dTotalCur += dCurPerPg; dTotalPrev += dPrevPerPg;  dTotalDiff += dDiffPerPg;
	%>
    <tr> 
      <td height="20" colspan="5" class="thinborder"><div align="right">Sub total(per pg) : &nbsp;</div></td>
      <td class="thinborder"><div align="right"><%=CommonUtil.formatFloat(dCurPerPg, true)%></div></td>
      <td class="thinborder"><div align="right"><%=CommonUtil.formatFloat(dPrevPerPg, true)%></div></td>
      <td class="thinborder"><div align="right"><%=CommonUtil.formatFloat(dDiffPerPg, true)%></div></td>
    </tr>
  </table>
<%if(iPgCount == iDef){%>
<DIV style="page-break-after:always">&nbsp;</DIV>
<%}//break only if it is not last page.

}//for condition to display header of each page.%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="60%" height="19" class="thinborderBOTTOMLEFT">
        <div align="right"><font size="1">TOTAL : &nbsp;</font></div></td>
      <td width="14%" class="thinborderBOTTOM"><div align="right"><font size="1"><%=CommonUtil.formatFloat(dTotalCur, true)%></font></div></td>
      <td width="14%" class="thinborderBOTTOM"><div align="right"><font size="1"><%=CommonUtil.formatFloat(dTotalPrev, true)%></font></div></td>
      <td width="12%" class="thinborderBOTTOMRIGHT"><div align="right"><font size="1"><%=CommonUtil.formatFloat(dTotalDiff, true)%></font></div></td>
    </tr>
  </table>
<%}//if(vRetResult != null && vRetResult.size() > 0)%>
  
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable3">
    <tr> 
      <td width="3%" height="18">&nbsp;</td>
      <td width="71%" valign="top">&nbsp;</td>
      <td width="26%" valign="top">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="course_name" value="<%=WI.fillTextValue("course_name")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>