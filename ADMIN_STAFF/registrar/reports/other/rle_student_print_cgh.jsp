<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript">
function UpdateGrade(strLabelID) {
	var objLabel = document.getElementById(strLabelID);
	var strNewVal = prompt("Please enter new value.");
	if(strNewVal == null || strNewVal.length == 0) 
		return;
	objLabel.innerHTML = strNewVal;
}
function RemoveTD() {
	if(!confirm('Are you sure you want to remove the GWA from printing?'))
		return;
	document.getElementById('myADTable1').deleteRow(0);
}
function HideClass() {
	document.getElementById("_header").innerHTML = "";
}
</script>
<body onLoad="window.print();">
<%@ page language="java" import="utility.*,enrollment.RLEInformation,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	
	String strErrMsg = null;
	String strTemp = null;
	
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));

//add security here.
	try
	{
		dbOP = new DBOperation();
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

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

enrollment.RLEInformation rle = new enrollment.RLEInformation();
enrollment.OfflineAdmission oa = new enrollment.OfflineAdmission();
Vector vAffHospitals =null;
Vector vGrades = null;
Vector vClinicExp = null;
Vector vRetResult = null;
Vector vStudInfo = new enrollment.OfflineAdmission().getStudentBasicInfo(dbOP, 
												request.getParameter("stud_id"));
int iIndexOf = 0;
int iRowsPrinted = 0;
int iRowsPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("rows_per_page"),"5"));
int iTotalHours = 0;
double dTotal = 0d;


if (strSchCode.startsWith("CGH")){
	

	vRetResult = rle.getStudentAffiliationRecord(dbOP, request);
												
	if (vRetResult == null) 
		strErrMsg = rle.getErrMsg();
	else{
		vClinicExp = (Vector)vRetResult.elementAt(0);
		vGrades = (Vector)vRetResult.elementAt(1);
		vAffHospitals = (Vector)vRetResult.elementAt(2);
		
		if(WI.fillTextValue("sub_exclude").length() > 0) {
			Vector vCSV = CommonUtil.convertCSVToVector(WI.fillTextValue("sub_exclude"));
			for (int p = 0; p < vClinicExp.size() ;  p+= 11){
				if(vCSV.indexOf((String)vClinicExp.elementAt(p + 3)) > -1) {
					vClinicExp.remove(p);vClinicExp.remove(p);vClinicExp.remove(p);vClinicExp.remove(p);
					vClinicExp.remove(p);vClinicExp.remove(p);vClinicExp.remove(p);vClinicExp.remove(p);
					vClinicExp.remove(p);vClinicExp.remove(p);vClinicExp.remove(p);
					p -= 11;	
				}
			}
		}
	}
	
}

if (vClinicExp != null) { %>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" >
	<tr>
		<td align="center"> <strong><!--CHINESE GENERAL HOSPITAL COLLEGE OF NURSING AND LIBERAL ARTS<br>
	    MANILA<br>
	    <br>-->
	    CLINICAL EXPERIENCE RECORD</strong> <br>
	    BACHELOR OF SCIENCE IN NURSING <label id="_header" onDblClick="HideClass();">CLASS  <%=WI.fillTextValue("batch_no")%></label></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
	</tr>
	</table>
		
<%for (int i = 0; i < vClinicExp.size();)  { 
	iRowsPrinted = 0;
%>

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" >
	  <tr>
	  <% if (vStudInfo!=null)
	  		strTemp = WI.formatName((String)vStudInfo.elementAt(0),
								(String)vStudInfo.elementAt(1),
								(String)vStudInfo.elementAt(2),4);
		 else
		 	strTemp = "";
	  %>
		<td width="71%" height="25"><strong>&nbsp;Name : <%=strTemp%></strong></td>
		<td width="29%"><strong>Student No : <%=WI.fillTextValue("stud_id")%></strong></td>
	  </tr>
</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder" id="myADTable4">
	  <tr>
		<td width="30%" class="thinborder" align="center"><strong>RLE Focus </strong></td>
		<td width="41%" class="thinborder" align="center"><strong>Clinical Area </strong></td>
		<td width="12%" class="thinborder"><div align="center"><strong>No. of <br>
		  Weeks </strong></div></td>
		<td width="9%" class="thinborder" align="center"><strong>No. of Hours </strong></td>
		<td align="center" class="thinborder"><strong>Grade</strong></td>
	  </tr>
 <%  for (; i < vClinicExp.size() ;  i+= 11, iRowsPrinted++){
		if (iRowsPrinted == iRowsPerPage)
			 break;
		iTotalHours += Integer.parseInt(WI.getStrValue((String)vClinicExp.elementAt(i+10),"0"));
		iIndexOf = vGrades.indexOf(new Integer((String)vClinicExp.elementAt(i+2)));
		
		
  %>
	  <tr>
		<td class="thinborder">
			<strong><%=(String)vClinicExp.elementAt(i+3) + " :: " + 
					(String)vClinicExp.elementAt(i+4)%></strong>
			<br>
			<%=WI.getStrValue((String)vClinicExp.elementAt(i+5),"&nbsp;")%>			</td>
		<td class="thinborder" valign="top"><%=WI.getStrValue((String)vClinicExp.elementAt(i+7),"&nbsp;")%></td>
		<td align="center" class="thinborder" valign="middle">&nbsp;(<%=WI.getStrValue((String)vClinicExp.elementAt(i+6),"&nbsp;")%> hrs/wk)<br>
		<%=WI.getStrValue((String)vClinicExp.elementAt(i+8),"&nbsp;")%>		</td>
		<td class="thinborder" valign="middle" align="center"><%=WI.getStrValue((String)vClinicExp.elementAt(i+10),"&nbsp;")%></td>
		<td width="8%" class="thinborder" valign="middle" align="center">
		<% 
			if (iIndexOf != -1){
				dTotal += 
					Integer.parseInt(WI.getStrValue((String)vClinicExp.elementAt(i+10),"0")) *
					Double.parseDouble(WI.getStrValue((String)vGrades.elementAt(iIndexOf + 1),"0"));	
			
				strTemp = WI.getStrValue((String)vGrades.elementAt(iIndexOf + 1));
				if(strTemp != null && strTemp.length() == 3)
					strTemp = strTemp + "0";
			}
			else {	
				strTemp = " -- ";
				iTotalHours -= Integer.parseInt(WI.getStrValue((String)vClinicExp.elementAt(i+10),"0"));
			}
		%>
			<label id="change_grade<%=i%>" onDblClick="UpdateGrade('change_grade<%=i%>');"><%=strTemp%></label>
			<%//=strTemp%>		</td>
	  </tr>
	  

<%}

if (i == vClinicExp.size()){
	strTemp = Integer.toString(iTotalHours);
	if(strTemp.length() > 3)
		strTemp = strTemp.substring(0,1)+","+strTemp.substring(1);%>  
	  <tr >
	    <td height="25" class="thinborder">&nbsp;Total</td>
	    <td class="thinborder">&nbsp;</td>
	    <td class="thinborder">&nbsp;</td>
	    <td align="center" class="thinborder"><%=strTemp%></td>
	    <td class="thinborder">&nbsp;</td>
      </tr>  
<%}%>   
</table>
<%if (WI.fillTextValue("remarks_").length() > 0){%>  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	  <tr>
	    <td>Remark: <%=WI.fillTextValue("remarks_")%></td>
      </tr>  
</table>
<%}%>   


<%if (i == vClinicExp.size()){%>  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable1">
	  <tr onDblClick="RemoveTD();">
	    <td width="92%" height="20" align="right" valign="bottom"><em>General Average: &nbsp;</em></td>
	    <td width="8%" align="center" valign="bottom"><em>
		<label id="change_gwa" onDblClick="UpdateGrade('change_gwa');"><%=CommonUtil.formatFloat((double)(dTotal / iTotalHours),true)%></label>
		</em></td>
      </tr>  
</table>
<%}%>   





<% if (iRowsPrinted == iRowsPerPage && i < vClinicExp.size()){%>
<%if(WI.fillTextValue("show_dean").length() > 0 || WI.fillTextValue("show_other_1").length() > 0) {%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" >
	  <tr>
		<td width="71%" height="40">&nbsp;</td>
		<td width="29%" valign="bottom" align="center"><strong><br><br><br><br>
		<%if(WI.fillTextValue("show_other_1").length() > 0) {%>
			<%=WI.fillTextValue("show_other_1")%>
		<%}else{%>
			IRIS CHUA-SO, RN, MAN
		<%}%>
		</strong> </td>
      </tr>
	  <tr>
	    <td height="25">&nbsp;</td>
	    <td valign="top" align="center">
		<%if(WI.fillTextValue("show_other_2").length() > 0) {%>
			<!--&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;--><%=WI.fillTextValue("show_other_2")%>
		<%}else{%>
			<!--&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-->Dean
		<%}%>
		</td>
  </tr>
</table>
<%}if(false){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" >
	  <tr>
		<td height="100" align="center" valign="bottom">We are committed to training life long learners
		for effectiveness in contemporary life</td>
	  </tr>
</table><%}//do not print remark%>
	<div  style="page-break-before:always">&nbsp;</div>
<% }
  } // end of biggest loop
 } 
 %> 
		<br>
		
		
<table width="60%" border="0" align="center" cellpadding="0" cellspacing="0" 
				bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="20" colspan="2" align="center" class="thinborder" style="font-size:11px; font-weight:bold"><strong>AREAS OF CLINICAL AFFILIATION </strong></td>
      <td width="23%" class="thinborder" align="center" style="font-size:11px; font-weight:bold">BED CAPACITY </td>
    </tr>
    <%
	String[] astrBaseName = {"Institutions of Affiliation","Base Hospital"};
	String strBaseHospital = "";
	for(int i = 0; i < vAffHospitals.size(); i += 8) {
	  if (!strBaseHospital.equals((String)vAffHospitals.elementAt(i+7))){
	  	strBaseHospital = (String)vAffHospitals.elementAt(i+7);
%>
    <tr>
      <td height="18" colspan="2" class="thinborderLEFT" style="font-size:11px;"><em> &nbsp;<%=astrBaseName[Integer.parseInt(strBaseHospital)]%> : </em></td>
      <td height="18" class="thinborderLEFT" style="font-size:11px;">&nbsp;</td>
    </tr>
    <% }%>
    <tr>
      <td width="10%" height="19" valign="top" class="thinborder" style="font-size:11px;">&nbsp;</td>
      <td width="67%" class="thinborderBOTTOM" style="font-size:11px;"><span class="thinborderBOTTOM" style="font-size:11px;"><%=vAffHospitals.elementAt(i + 1)%></span></td>
      <td class="thinborder" style="font-size:9px;" align="center"><%=WI.getStrValue((String)vAffHospitals.elementAt(i + 6),"---")%></td>
    </tr>
    <%}//end of ret result.%>
</table>
  
<%if(WI.fillTextValue("show_dean").length() > 0 || WI.fillTextValue("show_other_1").length() > 0) {%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" >
	  <tr>
		<td width="66%" height="40">&nbsp;</td>
		<td width="34%" valign="bottom" align="center"><strong><br><br><br><br>
		<%if(WI.fillTextValue("show_other_1").length() > 0) {%>
			<%=WI.fillTextValue("show_other_1")%>
		<%}else{%>
			IRIS CHUA-SO, RN, MAN
		<%}%>
		</strong> </td>
      </tr>
	  <tr>
	    <td height="25">&nbsp;</td>
	    <td valign="top" align="center">
		<%if(WI.fillTextValue("show_other_2").length() > 0) {%>
			<%=WI.fillTextValue("show_other_2")%>
		<%}else{%>
			<!--&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;-->Dean
		<%}%>
	</td>
  </tr>
</table>  
<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>
