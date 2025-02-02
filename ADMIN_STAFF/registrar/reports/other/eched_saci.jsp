<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="javascript">
function UpdateLabel(strLevelID) {
	
	var newVal = prompt('Please enter new Value',document.getElementById(strLevelID).innerHTML);
	if(newVal == null)
		return;
	document.getElementById(strLevelID).innerHTML = newVal;
}
function PrintPg() {
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);

   	alert("Click OK to print this page");
	window.print();
}	
</script>

<body topmargin="0">
<%@ page language="java" import="utility.*,enrollment.ReportRegistrar,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null; String strTemp = null;

//add security here.
	try {
		dbOP = new DBOperation();
	}
	catch(Exception exp) {
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT"),"0"));
		}
	}

if(iAccessLevel == -1){//for fatal error.
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0){//NOT AUTHORIZED.
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

Vector vRetResult = null;
ReportRegistrar RR = new ReportRegistrar();
if(WI.fillTextValue("sy_from").length() > 0) {
	vRetResult = RR.getSACIECHEDFormat(dbOP, request);
	if(vRetResult == null)
		strErrMsg = RR.getErrMsg();
}

int iCount = 0; //for editing the label.


%>

<form name="form_" action="./eched_saci.jsp" method="post" onSubmit="SubmitOnceButton(this);">
  <table  width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="4" align="center"><font color="#FFFFFF"><strong>:::: eCHED Form ::::</strong></font></td>
    </tr>
    <tr> 
      <td width="1%" height="25" >&nbsp;</td>
      <td height="25" colspan="3" style="font-size:14px; color:#FF0000; font-weight:bold"><a href="./rle_main.jsp"></a>&nbsp;&nbsp;&nbsp;
  	  <%=WI.getStrValue(strErrMsg)%></td>
    </tr>
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
    <tr>
      <td height="25" >&nbsp;</td>
      <td width="17%" style="font-size:11px;">SY/Term - FROM </td>
      <td width="82%" colspan="2" >
        <input type="text" name="sy_from" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress="AllowOnlyInteger('form_', 'sy_from');"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'> 
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
      <input type="text" name="sy_to" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly> 
        - 
        <select name="semester">
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}if(strTemp.equals("1")){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.equals("2")){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.equals("3")){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select></td>
    </tr>
    
    <tr>
      <td height="25" >&nbsp;</td>
      <td style="font-size:11px;">&nbsp;</td>
      <td colspan="2" style="font-size:11px;">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td style="font-size:11px;">&nbsp;</td>
      <td colspan="2">
	  	<input type="submit" name="122" value=" Generate e-Ched Report " style="font-size:11px; height:28px;border: 1px solid #FF0000;">
	  </td>
    </tr>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
    <tr>
	  <td height="25" align="center">&nbsp;</td>
		<td colspan="3" align="right" style="font-size:9px;"><a href="javascript:PrintPg();"><img src="../../../../images/print.gif" border="0"></a> Print report&nbsp;</td>   
	</tr>
<%}%>	
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
<p>
CHED E-FORM B/C 2004 <br>
<b>Curricular Program Profile/ Enrollment & Graduates<br><br>
Region: NCR <br>
Unique Institutional Identifier: 13200 <br>
Institution Name: Southeast Asian College, Inc. <br>
Address: 6 N Ramirez St., Quezon City.
</b>
</p>
<table width="100%" cellpadding="0" cellspacing="0" class="thinborder">
 <tr style="font-weight:bold">
	<td colspan="2" rowspan="3" align="center" class="thinborder">PROGRAM/COURSE</td>
	<td colspan="16" align="center" class="thinborder">E N R O L L M E N T  </td>
    <td colspan="3" align="center" class="thinborder">GRADUATES</td>
 </tr>
 <tr style="font-weight:bold">
   <td colspan="16" align="center" class="thinborder"><label id="<%=++iCount%>" onClick="UpdateLabel('<%=iCount%>')">1st Sem, AY 2005 - 2006 </label></td>
   <td colspan="3" class="thinborder"><label id="<%=++iCount%>" onClick="UpdateLabel('<%=iCount%>')">Total of 1st, 2nd AY 2006 &amp; Summer 2006 </label></td>
 </tr>
 <tr style="font-weight:bold" align="center">
   <td class="thinborder">NORMAL LENGTH</td>
   <td class="thinborder">PROGRAM CREDIT IN UNIT</td>
   <td class="thinborder">TUITION PER UNIT (in peso)</td>
   <td colspan="2" class="thinborder">NEW  (1st Yr)</td>
   <td colspan="2" class="thinborder">1ST YEAR</td>
   <td colspan="2" class="thinborder">2ND YEAR</td>
   <td colspan="2" class="thinborder">3RD YEAR</td>
   <td colspan="2" class="thinborder">4TH YEAR</td>
   <td colspan="2" class="thinborder">SUB-TOTAL</td>
   <td width="3%" rowspan="2" class="thinborder">TOTAL</td>
   <td width="4%" rowspan="2" class="thinborder">M</td>
   <td width="4%" rowspan="2" class="thinborder">F</td>
   <td width="4%" rowspan="2" class="thinborder">TOTAL</td>
 </tr>
 <tr style="font-weight:bold" align="center">
   <td width="12%" align="center" class="thinborder">Main Program/Profile</td>
   <td width="8%" align="center" class="thinborder">Major</td>
   <td width="8%" class="thinborder">&nbsp;</td>
   <td width="8%" class="thinborder">&nbsp;</td>
   <td width="8%" class="thinborder">&nbsp;</td>
   <td width="3%" class="thinborder">M</td>
   <td width="3%" class="thinborder">F</td>
   <td width="3%" class="thinborder">M</td>
   <td width="3%" class="thinborder">F</td>
   <td width="3%" class="thinborder">M</td>
   <td width="3%" class="thinborder">F</td>
   <td width="3%" class="thinborder">M</td>
   <td width="3%" class="thinborder">F</td>
   <td width="3%" class="thinborder">M</td>
   <td width="3%" class="thinborder">F</td>
   <td width="3%" class="thinborder">M</td>
   <td width="3%" class="thinborder">F</td>
   </tr>
 <tr>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
 </tr>
 <tr>
   <td class="thinborder">Doctoral</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
 </tr>
 <tr>
   <td class="thinborder">Master's</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
 </tr>
 <tr>
   <td class="thinborder">Post-Bacc.</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
 </tr>
 <tr>
   <td class="thinborder">Baccalaureate</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
 </tr>
<%
Vector vCourseInfo = (Vector)vRetResult.remove(0); 
Vector vNewStud    = (Vector)vRetResult.remove(0); 
Vector vGradStud   = (Vector)vRetResult.remove(0); 

String strNewStudM = null;
String strNewStudF = null;

int i1stM = 0; int i1stF = 0; int i1stMTot = 0; int i1stFTot = 0;
int i2ndM = 0; int i2ndF = 0; int i2ndMTot = 0; int i2ndFTot = 0;
int i3rdM = 0; int i3rdF = 0; int i3rdMTot = 0; int i3rdFTot = 0;
int i4thM = 0; int i4thF = 0; int i4thMTot = 0; int i4thFTot = 0;

int iIndexOf = 0;Integer iObj = null; String strTempGender = null; String strTempCount = null;
for(int i = 0; i < vCourseInfo.size(); i += 5) {

i1stM = 0; i1stF = 0; i2ndM = 0; i2ndF = 0; i3rdM = 0; i3rdF = 0; i4thM = 0; i4thF = 0;

iObj = (Integer)vCourseInfo.elementAt(i);
iIndexOf = vRetResult.indexOf(iObj);
while(iIndexOf > -1) {
	vRetResult.removeElementAt(iIndexOf);
	
	strTemp       = (String)vRetResult.remove(iIndexOf);
	strTempGender = (String)vRetResult.remove(iIndexOf);
	strTempCount  = (String)vRetResult.remove(iIndexOf);
	
	if(strTempGender == null)
		strTempGender = "M";
	if(strTemp.equals("1")) {
		if(strTempGender.equals("M"))
			i1stM = Integer.parseInt(strTempCount);
		else	
			i1stF = Integer.parseInt(strTempCount);
	}
	if(strTemp.equals("2")) {
		if(strTempGender.equals("M"))
			i2ndM = Integer.parseInt(strTempCount);
		else	
			i2ndF = Integer.parseInt(strTempCount);
	}
	if(strTemp.equals("3")) {
		if(strTempGender.equals("M"))
			i3rdM = Integer.parseInt(strTempCount);
		else	
			i3rdF = Integer.parseInt(strTempCount);
	}
	if(strTemp.equals("4")) {
		if(strTempGender.equals("M"))
			i4thM = Integer.parseInt(strTempCount);
		else	
			i4thF = Integer.parseInt(strTempCount);
	}
	iIndexOf = vRetResult.indexOf(iObj);
}
i1stMTot += i1stM; i1stFTot += i1stF;
i2ndMTot += i2ndM; i2ndFTot += i2ndF;
i3rdMTot += i3rdM; i3rdFTot += i3rdF;
i4thMTot += i4thM; i4thFTot += i4thF;


//get new student info. 
iIndexOf = vNewStud.indexOf(iObj); strNewStudM = "&nbsp;&nbsp;&nbsp;";strNewStudF = "&nbsp;&nbsp;&nbsp;";
if(iIndexOf != -1) {
	vNewStud.removeElementAt(iIndexOf);
	strTemp = (String)vNewStud.remove(iIndexOf);
	if(strTemp.equals("M"))
		strNewStudM = (String)vNewStud.remove(iIndexOf); 
	else
		strNewStudF = (String)vNewStud.remove(iIndexOf); 	
}
iIndexOf = vNewStud.indexOf(iObj); 
if(iIndexOf != -1) {//this is for female.
	vNewStud.removeElementAt(iIndexOf);
	strTemp = (String)vNewStud.remove(iIndexOf);
	if(strTemp.equals("M"))
		strNewStudM = (String)vNewStud.remove(iIndexOf); 
	else
		strNewStudF = (String)vNewStud.remove(iIndexOf); 	
}



strTemp = (String)vCourseInfo.elementAt(i + 1);
if(strTemp.startsWith("Bachelor of Science in"))
	strTemp = "BS "+strTemp.substring(22);
%>
 <tr>
   <td class="thinborder"><label id="<%=++iCount%>" onClick="UpdateLabel('<%=iCount%>')"><%=strTemp%></label></td>
   <td class="thinborder"><label id="<%=++iCount%>" onClick="UpdateLabel('<%=iCount%>')">&nbsp;&nbsp;&nbsp;&nbsp;</label></td>
   <td class="thinborder"><label id="<%=++iCount%>" onClick="UpdateLabel('<%=iCount%>')"><%=WI.getStrValue(vCourseInfo.elementAt(i + 2), "&nbsp;&nbsp;&nbsp;")%></label></td>
   <td class="thinborder"><label id="<%=++iCount%>" onClick="UpdateLabel('<%=iCount%>')"><%=WI.getStrValue(vCourseInfo.elementAt(i + 3), "&nbsp;&nbsp;&nbsp;")%></label></td>
   <td class="thinborder"><label id="<%=++iCount%>" onClick="UpdateLabel('<%=iCount%>')"><%=WI.getStrValue(vCourseInfo.elementAt(i + 4), "&nbsp;&nbsp;&nbsp;")%></label></td>
   <td class="thinborder"><label id="<%=++iCount%>" onClick="UpdateLabel('<%=iCount%>')"><%=strNewStudM%></label></td>
   <td class="thinborder"><label id="<%=++iCount%>" onClick="UpdateLabel('<%=iCount%>')"><%=strNewStudF%></label></td>
   <td class="thinborder"><label id="<%=++iCount%>" onClick="UpdateLabel('<%=iCount%>')"><%if(i1stM < 0){%>&nbsp;&nbsp;<%}else{%><%=i1stM%><%}%></label></td>
   <td class="thinborder"><label id="<%=++iCount%>" onClick="UpdateLabel('<%=iCount%>')"><%if(i1stF < 0){%>&nbsp;&nbsp;<%}else{%><%=i1stF%><%}%></label></td>
   <td class="thinborder"><label id="<%=++iCount%>" onClick="UpdateLabel('<%=iCount%>')"><%if(i2ndM < 0){%>&nbsp;&nbsp;<%}else{%><%=i2ndM%><%}%></label></td>
   <td class="thinborder"><label id="<%=++iCount%>" onClick="UpdateLabel('<%=iCount%>')"><%if(i2ndF < 0){%>&nbsp;&nbsp;<%}else{%><%=i2ndF%><%}%></label></td>
   <td class="thinborder"><label id="<%=++iCount%>" onClick="UpdateLabel('<%=iCount%>')"><%if(i3rdM < 0){%>&nbsp;&nbsp;<%}else{%><%=i3rdM%><%}%></label></td>
   <td class="thinborder"><label id="<%=++iCount%>" onClick="UpdateLabel('<%=iCount%>')"><%if(i3rdF < 0){%>&nbsp;&nbsp;<%}else{%><%=i3rdF%><%}%></label></td>
   <td class="thinborder"><label id="<%=++iCount%>" onClick="UpdateLabel('<%=iCount%>')"><%if(i4thM < 0){%>&nbsp;&nbsp;<%}else{%><%=i4thM%><%}%></label></td>
   <td class="thinborder"><label id="<%=++iCount%>" onClick="UpdateLabel('<%=iCount%>')"><%if(i4thF < 0){%>&nbsp;&nbsp;<%}else{%><%=i4thF%><%}%></label></td>
   <td class="thinborder"><label id="<%=++iCount%>" onClick="UpdateLabel('<%=iCount%>')"><%=i1stM+i2ndM+i3rdM+i4thM%></label></td>
   <td class="thinborder"><label id="<%=++iCount%>" onClick="UpdateLabel('<%=iCount%>')"><%=i1stF+i2ndF+i3rdF+i4thF%></label></td>
   <td class="thinborder"><label id="<%=++iCount%>" onClick="UpdateLabel('<%=iCount%>')"><%=i1stM+i2ndM+i3rdM+i4thM+i1stF+i2ndF+i3rdF+i4thF%></label></td>
   <td class="thinborder"><label id="<%=++iCount%>" onClick="UpdateLabel('<%=iCount%>')">&nbsp;&nbsp;</label></td>
   <td class="thinborder"><label id="<%=++iCount%>" onClick="UpdateLabel('<%=iCount%>')">&nbsp;&nbsp;</label></td>
   <td class="thinborder"><label id="<%=++iCount%>" onClick="UpdateLabel('<%=iCount%>')">&nbsp;&nbsp;</label></td>
 </tr>
<%}%>
 <tr>
   <td colspan="2" class="thinborder" align="right">Total&nbsp;&nbsp;&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder">&nbsp;</td>
   <td class="thinborder"><label id="<%=++iCount%>" onClick="UpdateLabel('<%=iCount%>')"><%if(i1stMTot < 0){%>&nbsp;&nbsp;<%}else{%><%=i1stMTot%><%}%></label></td>
   <td class="thinborder"><label id="<%=++iCount%>" onClick="UpdateLabel('<%=iCount%>')"><%if(i1stFTot < 0){%>&nbsp;&nbsp;<%}else{%><%=i1stFTot%><%}%></label></td>
   <td class="thinborder"><label id="<%=++iCount%>" onClick="UpdateLabel('<%=iCount%>')"><%if(i2ndMTot < 0){%>&nbsp;&nbsp;<%}else{%><%=i2ndMTot%><%}%></label></td>
   <td class="thinborder"><label id="<%=++iCount%>" onClick="UpdateLabel('<%=iCount%>')"><%if(i2ndFTot < 0){%>&nbsp;&nbsp;<%}else{%><%=i2ndFTot%><%}%></label></td>
   <td class="thinborder"><label id="<%=++iCount%>" onClick="UpdateLabel('<%=iCount%>')"><%if(i3rdMTot < 0){%>&nbsp;&nbsp;<%}else{%><%=i3rdMTot%><%}%></label></td>
   <td class="thinborder"><label id="<%=++iCount%>" onClick="UpdateLabel('<%=iCount%>')"><%if(i3rdFTot < 0){%>&nbsp;&nbsp;<%}else{%><%=i3rdFTot%><%}%></label></td>
   <td class="thinborder"><label id="<%=++iCount%>" onClick="UpdateLabel('<%=iCount%>')"><%if(i4thMTot < 0){%>&nbsp;&nbsp;<%}else{%><%=i4thMTot%><%}%></label></td>
   <td class="thinborder"><label id="<%=++iCount%>" onClick="UpdateLabel('<%=iCount%>')"><%if(i4thFTot < 0){%>&nbsp;&nbsp;<%}else{%><%=i4thFTot%><%}%></label></td>
   <td class="thinborder"><label id="<%=++iCount%>" onClick="UpdateLabel('<%=iCount%>')"><%=i1stMTot+i2ndMTot+i3rdMTot+i4thMTot%></label></td>
   <td class="thinborder"><label id="<%=++iCount%>" onClick="UpdateLabel('<%=iCount%>')"><%=i1stFTot+i2ndFTot+i3rdFTot+i4thFTot%></label></td>
   <td class="thinborder"><label id="<%=++iCount%>" onClick="UpdateLabel('<%=iCount%>')"><%=i1stMTot+i2ndMTot+i3rdMTot+i4thMTot+i1stFTot+i2ndFTot+i3rdFTot+i4thFTot%></label></td>
   <td class="thinborder"><label id="<%=++iCount%>" onClick="UpdateLabel('<%=iCount%>')">&nbsp;&nbsp;</label></td>
   <td class="thinborder"><label id="<%=++iCount%>" onClick="UpdateLabel('<%=iCount%>')">&nbsp;&nbsp;</label></td>
   <td class="thinborder"><label id="<%=++iCount%>" onClick="UpdateLabel('<%=iCount%>')">&nbsp;&nbsp;</label></td>
 </tr>
</table>
<%}%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
