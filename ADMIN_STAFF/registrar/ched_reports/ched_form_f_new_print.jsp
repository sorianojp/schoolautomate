<%@ page language="java" import="utility.*,java.util.Vector,chedReport.FNew"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;

//authenticate this user.
	int iAccessLevel = 0;
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
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
//end of authenticaion code.

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
							"Admin/staff-CHED REPORTS-CHED FORM F","ched_form_f_new.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
	
Vector vRetResult = null;
if(WI.fillTextValue("sy_from").length() > 0) {
	FNew fNew = new FNew();
	vRetResult = fNew.getFInfo(dbOP, request);
	if(vRetResult == null) 
		strErrMsg = fNew.getErrMsg();
}
	
chedReport.CHEDInstProfile cip = new chedReport.CHEDInstProfile();
Vector vInstProfile = cip.operateOnChedInstProfile(dbOP,request,3);
if(vInstProfile == null || vInstProfile.size() == 0) {
	strErrMsg = cip.getErrMsg();
	if(strErrMsg == null)
		strErrMsg = "Institution profile not found.";
}	


double dTemp = 0d;%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>CHED E-FORM B/C</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
.body_font{
	font-size:11px;
}
</style>
</head>
<body onLoad="window.print();">
<form name="form_">
<%if(strErrMsg!= null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="2">&nbsp; <%=WI.getStrValue(strErrMsg,"<font size=\"3\" color=\"#FF0000\">","</font>", "")%></td>
    </tr>
  </table>
<%dbOP.cleanUP();
return;}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="2">
    <tr>
      <td height="25" colspan="2" class="body_font" style="font-weight:bold">CHED FORM F 2004</td>
    </tr>
    <tr>
      <td height="25" colspan="2" class="body_font" style="font-weight:bold">INDICATORS</td>
    </tr>
    <tr>
      <td width="50%" height="25" class="body_font">Code : &nbsp;&nbsp;&nbsp;<u>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</u></td>
      <td width="50%" class="body_font">Region: <%=vInstProfile.elementAt(8)%></td>
    </tr>
    <tr>
      <td height="25" class="body_font">Name of Institution: <%=SchoolInformation.getSchoolName(dbOP,false,false)%><br></td>
      <td class="body_font">Type : <%=vInstProfile.elementAt(4)%></td>
    </tr>
    <tr>
      <td height="25" class="body_font">Program Mode: 
	  <select style="border:hidden">
	  <option>Semestral</option>
	  <option>Trimester</option>
	  </select>
	  
	  </td>
      <td class="body_font">&nbsp;</td>
    </tr>
  </table>
<br>
<br>
<%if(vRetResult != null && vRetResult.size() > 0) {
int iSYFrom = Integer.parseInt(WI.getStrValue(WI.fillTextValue("sy_from"), "0"));%>

	<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
		  <td width="100%" height="25" class="body_font" style="font-weight:bold">A. STUDENT's SELECTIVITY</td>
		</tr>
		<tr>
		  <td height="25" class="body_font">1. Do you have Qualifying Examination in choosing your freshmen students?
<%
strTemp = (String)vRetResult.elementAt(0);
if(strTemp != null && strTemp.equals("1"))
	strTemp = " Yes";
else	
	strTemp = "No";
%>	  			<%=strTemp%>
		  </td>
	  </tr>
		<tr>
		  <td height="25" class="body_font">
		  	<table width="100%" cellpadding="0" cellspacing="0" class="thinborder">
				 <tr bgcolor="#99CCCC">
				 	<td width="2%" class="thinborder">&nbsp;</td>
					<td width="48%" class="thinborder">Student's Selectivity</td>
					<td width="8%" align="center" class="thinborder">Pre-bacc <br>(a)</td>
					<td width="12%" align="center" class="thinborder">Undergraduate <br>(b)</td>
					<td width="8%" align="center" class="thinborder">Post-bacc <br>(c)</td>
					<td width="7%" align="center" class="thinborder">Master's <br>(d)</td>
					<td width="8%" align="center" class="thinborder">Doctorate <br>(e)</td>
				    <td width="7%" align="center" class="thinborder">Total <br>(f)</td>
				 </tr>
				 <tr>
				   <td class="thinborder">2.</td>
				   <td class="thinborder">How many students applied for first year undergraduate, master's,
			       doctorate in your institutions for AY <%=iSYFrom%>-<%=iSYFrom + 1%>?</td>
				   <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(1), "0");
dTemp = Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
				   <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(2), "0");
dTemp += Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
				   <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(3), "0");
dTemp += Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
				   <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(4), "0");
dTemp += Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
				   <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(5), "0");
dTemp += Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
		           <td align="center" class="thinborder"><%=CommonUtil.formatFloat(dTemp, false)%></td>
			  </tr>
				 <tr>
				   <td class="thinborder">3.</td>
				   <td class="thinborder">How many qualified in the examination?</td>
				   <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(6), "0");
dTemp = Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
				   <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(7), "0");
dTemp += Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
				   <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(8), "0");
dTemp += Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
				   <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(9), "0");
dTemp += Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
				   <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(10), "0");
dTemp += Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
		           <td align="center" class="thinborder"><%=CommonUtil.formatFloat(dTemp, false)%></td>
			  </tr>
				 <tr>
				   <td class="thinborder">4.</td>
				   <td class="thinborder">How many of those who qualified actually enrolled for the first semester
			       for AY <%=iSYFrom%>-<%=iSYFrom + 1%>?</td>
				   <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(11), "0");
dTemp = Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
				   <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(12), "0");
dTemp += Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
				   <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(13), "0");
dTemp += Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
				   <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(14), "0");
dTemp += Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
				   <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(15), "0");
dTemp += Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
		           <td align="center" class="thinborder"><%=CommonUtil.formatFloat(dTemp, false)%></td>
			  </tr>
			</table>		  </td>
	  </tr>
		<tr>
		  <td height="25" class="body_font">5. Do you have Qualifying Examination for transferee?
<%
strTemp = (String)vRetResult.elementAt(16);
if(strTemp != null && strTemp.equals("1"))
	strTemp = " Yes";
else	
	strTemp = "No";
%>	  			<%=strTemp%>
		</td>
	  </tr>
		<tr>
		  <td height="25" class="body_font">6. If NO, but still accepting transferees kindly state the other criteria in accepting transferees:</td>
	  </tr>
		<tr>
		  <td height="25" class="body_font">
		  <table width="100%" cellpadding="0" cellspacing="0">
            <tr>
              <td width="2%">&nbsp;</td>
              <td width="48%">
<%
strTemp = (String)vRetResult.elementAt(17);
if(strTemp != null && strTemp.equals("1"))
	strTemp = " checked";
else	
	strTemp = "";
%>			  <input type="checkbox" name="TRANSFEREE_REQ_TOR" value="1"<%=strTemp%> onClick="AjaxUpdateChkBox('TRANSFEREE_REQ_TOR',document.form_.TRANSFEREE_REQ_TOR,'lbl_18')"><label id="lbl_18"></label> Transcript of Records w/ qualitfied grades</td>
              <td width="50%">
<%
strTemp = (String)vRetResult.elementAt(19);
if(strTemp != null && strTemp.equals("1"))
	strTemp = " checked";
else	
	strTemp = "";
%>			  <input type="checkbox" name="TRANSFEREE_REQ_GMC" value="1"<%=strTemp%> onClick="AjaxUpdateChkBox('TRANSFEREE_REQ_GMC',document.form_.TRANSFEREE_REQ_GMC,'lbl_19')"><label id="lbl_19"></label> Good Moral Character</td>
            </tr>
            <tr>
              <td>&nbsp;</td>
              <td valign="top">
<%
strTemp = (String)vRetResult.elementAt(18);
if(strTemp != null && strTemp.equals("1"))
	strTemp = " checked";
else	
	strTemp = "";
%>			  <input type="checkbox" name="TRANSFEREE_REQ_HD" value="1"<%=strTemp%> onClick="AjaxUpdateChkBox('TRANSFEREE_REQ_HD',document.form_.TRANSFEREE_REQ_HD,'lbl_20')"><label id="lbl_20"></label> Honorable Dismissal</td>
              <td valign="top">Others Specify
<%
strTemp = WI.getStrValue((String)vRetResult.elementAt(20));
%>			  
			<pre class="body_font"><%=strTemp%></pre>
			</td>
            </tr>
          </table></td>
	  </tr>
		<tr>
		  <td height="25" class="body_font">7. How many transferees for AY <%=WI.fillTextValue("sy_from")%> - <%=Integer.parseInt(WI.fillTextValue("sy_from")) + 1%>? (Kindly fill-up the table below.)</td>
	  </tr>
		<tr>
		  <td height="25" class="body_font" align="center">
		  	<table width="40%" cellpadding="0" cellspacing="0" class="thinborder">
            <tr bgcolor="#99CCCC">
              <td width="49%" rowspan="2" class="thinborder">Program Level </td>
              <td colspan="2" align="center" class="thinborder">Coming From </td>
              </tr>
            <tr bgcolor="#99CCCC">
              <td width="8%" align="center" class="thinborder">Private</td>
              <td width="12%" align="center" class="thinborder">Public</td>
              </tr>
            <tr>
              <td class="thinborder">Pre-baccalaureate</td>
              <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(21), "0");
%>				   <%=strTemp%>				   </td>
              <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(26), "0");
%>				   <%=strTemp%>				   </td>
              </tr>
            <tr>
              <td class="thinborder">Baccalaureate</td>
              <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(22), "0");
%>				   <%=strTemp%>				   </td>
              <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(27), "0");
%>				   <%=strTemp%>				   </td>
              </tr>
            <tr>
              <td class="thinborder">Post-baccalaureate</td>
              <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(23), "0");
%>				   <%=strTemp%>				   </td>
              <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(28), "0");
%>				   <%=strTemp%>				   </td>
              </tr>
            <tr>
              <td class="thinborder">Master's</td>
              <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(24), "0");
%>				   <%=strTemp%>				   </td>
              <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(29), "0");
%>				   <%=strTemp%>				   </td>
            </tr>
            <tr>
              <td class="thinborder">Doctorate</td>
              <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(25), "0");
%>				   <%=strTemp%>				   </td>
              <td align="center" class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(30), "0");
%>				   <%=strTemp%>				   </td>
            </tr>
          </table></td>
	  </tr>
		<tr>
		  <td height="25" class="body_font">8. Do you accept foreign students to study in your institution?
<%
strTemp = (String)vRetResult.elementAt(31);
if(strTemp != null && strTemp.equals("1"))
	strTemp = " Yes";
else	
	strTemp = "No";
%>	  			<%=strTemp%>	  </td>
	  </tr>
		<tr>
		  <td height="25" class="body_font">9. If YES, how many foreign students enrolled for AY <%=WI.fillTextValue("sy_from")%> - <%=Integer.parseInt(WI.fillTextValue("sy_from")) + 1%>? 
<%
strTemp = WI.getStrValue(vRetResult.elementAt(32), "0");
%>				   <u><%=strTemp%></u>				   </td>
	  </tr>
		<tr>
		  <td height="25" class="body_font" style="font-weight:bold">B. DISTRIBUTION OF STUDENTS by AGE, PROGRAM LEVEL AND GENDER</td>
	  </tr>
		<tr>
		  <td height="25" class="body_font"><table width="100%" cellpadding="0" cellspacing="0" class="thinborder">
            <tr bgcolor="#99CCCC" align="center">
              <td width="7%" rowspan="2" class="thinborder">Age</td>
              <td colspan="2" class="thinborder">Pre-baccalaureate</td>
              <td colspan="2" class="thinborder">Baccalaureate</td>
              <td colspan="2" class="thinborder">Post-baccalaureate</td>
              <td colspan="2" class="thinborder">Master's</td>
              <td colspan="2" class="thinborder">Doctorate</td>
              <td colspan="3" class="thinborder">Total</td>
            </tr>
            <tr bgcolor="#99CCCC" align="center">
              <td width="7%" class="thinborder">Male</td>
              <td width="7%" class="thinborder">Female</td>
              <td width="7%" class="thinborder">Male</td>
              <td width="7%" class="thinborder">Female</td>
              <td width="7%" class="thinborder">Male</td>
              <td width="7%" class="thinborder">Female</td>
              <td width="7%" class="thinborder">Male</td>
              <td width="7%" class="thinborder">Female</td>
              <td width="7%" class="thinborder">Male</td>
              <td width="7%" class="thinborder">Female</td>
              <td width="7%" class="thinborder">Male</td>
              <td width="7%" class="thinborder">Female</td>
              <td width="7%" class="thinborder">Both</td>
            </tr>
            <tr align="center">
              <td class="thinborder">down - 16</td>
              <td class="thinborder">
<%
double dMale = 0d;
double dFemale = 0d;

double dMaleTotal1 = 0d; double dMaleTotal2 = 0d; double dMaleTotal3 = 0d; double dMaleTotal4 = 0d; double dMaleTotal5 = 0d; double dMaleTotal6 = 0d; 
double dFemaleTotal1 = 0d; double dFemaleTotal2 = 0d; double dFemaleTotal3 = 0d; double dFemaleTotal4 = 0d; double dFemaleTotal5 = 0d; double dFemaleTotal6 = 0d; 

double dMaleTotal = 0d; double dFemaleTotal = 0d;

strTemp = WI.getStrValue(vRetResult.elementAt(41), "0");
dMale = Double.parseDouble(strTemp);
dMaleTotal1  = Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(42), "0");
dFemale = Double.parseDouble(strTemp);
dFemaleTotal1  = Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(43), "0");
dMale += Double.parseDouble(strTemp);
dMaleTotal2  = Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(44), "0");
dFemale += Double.parseDouble(strTemp);
dFemaleTotal2  = Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
			  
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(45), "0");
dMale += Double.parseDouble(strTemp);
dMaleTotal3  = Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(46), "0");
dFemale += Double.parseDouble(strTemp);
dFemaleTotal3  = Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(47), "0");
dMale += Double.parseDouble(strTemp);
dMaleTotal4  = Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(48), "0");
dFemale += Double.parseDouble(strTemp);
dFemaleTotal4  = Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(49), "0");
dMale += Double.parseDouble(strTemp);
dMaleTotal5  = Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(50), "0");
dFemale += Double.parseDouble(strTemp);
dFemaleTotal5  = Double.parseDouble(strTemp);

dMaleTotal = dMale;
dFemaleTotal = dFemale;
%>				   <%=strTemp%>				   </td>
              <td class="thinborder"><%=CommonUtil.formatFloat(dMale,false)%></td>
              <td class="thinborder"><%=CommonUtil.formatFloat(dFemale,false)%></td>
              <td class="thinborder"><%=CommonUtil.formatFloat(dMale + dFemale,false)%></td>
            </tr>
            <tr align="center">
              <td class="thinborder">17 - 20</td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(51), "0");
dMale = Double.parseDouble(strTemp);
dMaleTotal1  += Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(52), "0");
dFemale = Double.parseDouble(strTemp);
dFemaleTotal1  += Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(53), "0");
dMale += Double.parseDouble(strTemp);
dMaleTotal2  += Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(54), "0");
dFemale += Double.parseDouble(strTemp);
dFemaleTotal2  += Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
			  
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(55), "0");
dMale += Double.parseDouble(strTemp);
dMaleTotal3  += Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(56), "0");
dFemale += Double.parseDouble(strTemp);
dFemaleTotal3  += Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(57), "0");
dMale += Double.parseDouble(strTemp);
dMaleTotal4  += Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(58), "0");
dFemale += Double.parseDouble(strTemp);
dFemaleTotal4  += Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(59), "0");
dMale += Double.parseDouble(strTemp);
dMaleTotal5  += Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(60), "0");
dFemale += Double.parseDouble(strTemp);
dFemaleTotal5  += Double.parseDouble(strTemp);

dMaleTotal += dMale;
dFemaleTotal += dFemale;
%>				   <%=strTemp%>				   </td>
              <td class="thinborder"><%=CommonUtil.formatFloat(dMale,false)%></td>
              <td class="thinborder"><%=CommonUtil.formatFloat(dFemale,false)%></td>
              <td class="thinborder"><%=CommonUtil.formatFloat(dMale + dFemale,false)%></td>
            </tr>
			<tr align="center">
              <td class="thinborder">21 - 24</td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(61), "0");
dMale = Double.parseDouble(strTemp);
dMaleTotal1  += Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(62), "0");
dFemale = Double.parseDouble(strTemp);
dFemaleTotal1  += Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(63), "0");
dMale += Double.parseDouble(strTemp);
dMaleTotal2  += Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(64), "0");
dFemale += Double.parseDouble(strTemp);
dFemaleTotal2  += Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
			  
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(65), "0");
dMale += Double.parseDouble(strTemp);
dMaleTotal3  += Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(66), "0");
dFemale += Double.parseDouble(strTemp);
dFemaleTotal3  += Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(67), "0");
dMale += Double.parseDouble(strTemp);
dMaleTotal4  += Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(68), "0");
dFemale += Double.parseDouble(strTemp);
dFemaleTotal4  += Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(69), "0");
dMale += Double.parseDouble(strTemp);
dMaleTotal5  += Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(70), "0");
dFemale += Double.parseDouble(strTemp);
dFemaleTotal5  += Double.parseDouble(strTemp);

dMaleTotal += dMale;
dFemaleTotal += dFemale;
%>				   <%=strTemp%>				   </td>
              <td class="thinborder"><%=CommonUtil.formatFloat(dMale,false)%></td>
              <td class="thinborder"><%=CommonUtil.formatFloat(dFemale,false)%></td>
              <td class="thinborder"><%=CommonUtil.formatFloat(dMale + dFemale,false)%></td>
			</tr>
            <tr align="center">
              <td class="thinborder">25 - 29</td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(71), "0");
dMale = Double.parseDouble(strTemp);
dMaleTotal1  += Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(72), "0");
dFemale = Double.parseDouble(strTemp);
dFemaleTotal1  += Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(73), "0");
dMale += Double.parseDouble(strTemp);
dMaleTotal2  += Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(74), "0");
dFemale += Double.parseDouble(strTemp);
dFemaleTotal2  += Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
			  
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(75), "0");
dMale += Double.parseDouble(strTemp);
dMaleTotal3  += Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(76), "0");
dFemale += Double.parseDouble(strTemp);
dFemaleTotal3  += Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(77), "0");
dMale += Double.parseDouble(strTemp);
dMaleTotal4  += Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(78), "0");
dFemale += Double.parseDouble(strTemp);
dFemaleTotal4  += Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(79), "0");
dMale += Double.parseDouble(strTemp);
dMaleTotal5  += Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(80), "0");
dFemale += Double.parseDouble(strTemp);
dFemaleTotal5  += Double.parseDouble(strTemp);

dMaleTotal += dMale;
dFemaleTotal += dFemale;
%>				   <%=strTemp%>				   </td>
              <td class="thinborder"><%=CommonUtil.formatFloat(dMale,false)%></td>
              <td class="thinborder"><%=CommonUtil.formatFloat(dFemale,false)%></td>
              <td class="thinborder"><%=CommonUtil.formatFloat(dMale + dFemale,false)%></td>
            </tr>
            <tr align="center">
              <td class="thinborder">30 - up</td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(81), "0");
dMale = Double.parseDouble(strTemp);
dMaleTotal1  += Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(82), "0");
dFemale = Double.parseDouble(strTemp);
dFemaleTotal1  += Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(83), "0");
dMale += Double.parseDouble(strTemp);
dMaleTotal2  += Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(84), "0");
dFemaleTotal2  += Double.parseDouble(strTemp);
dFemale += Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
			  
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(85), "0");
dMale += Double.parseDouble(strTemp);
dMaleTotal3  += Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(86), "0");
dFemale += Double.parseDouble(strTemp);
dFemaleTotal3  += Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(87), "0");
dMale += Double.parseDouble(strTemp);
dMaleTotal4  += Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(88), "0");
dFemale += Double.parseDouble(strTemp);
dFemaleTotal4  += Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(89), "0");
dMale += Double.parseDouble(strTemp);
dMaleTotal5  += Double.parseDouble(strTemp);
%>				   <%=strTemp%>				   </td>
              <td class="thinborder">
<%
strTemp = WI.getStrValue(vRetResult.elementAt(90), "0");
dFemale += Double.parseDouble(strTemp);
dFemaleTotal5  += Double.parseDouble(strTemp);

dMaleTotal += dMale;
dFemaleTotal += dFemale;
%>				   <%=strTemp%>				   </td>
              <td class="thinborder"><%=CommonUtil.formatFloat(dMale,false)%></td>
              <td class="thinborder"><%=CommonUtil.formatFloat(dFemale,false)%></td>
              <td class="thinborder"><%=CommonUtil.formatFloat(dMale + dFemale,false)%></td>
            </tr>
            <tr align="center">
              <td class="thinborder">Total</td>
              <td class="thinborder"><%=CommonUtil.formatFloat(dMaleTotal1, false)%></td>
              <td class="thinborder"><%=CommonUtil.formatFloat(dFemaleTotal1, false)%></td>
              <td class="thinborder"><%=CommonUtil.formatFloat(dMaleTotal2, false)%></td>
              <td class="thinborder"><%=CommonUtil.formatFloat(dFemaleTotal2, false)%></td>
              <td class="thinborder"><%=CommonUtil.formatFloat(dMaleTotal3, false)%></td>
              <td class="thinborder"><%=CommonUtil.formatFloat(dFemaleTotal3, false)%></td>
              <td class="thinborder"><%=CommonUtil.formatFloat(dMaleTotal4, false)%></td>
              <td class="thinborder"><%=CommonUtil.formatFloat(dFemaleTotal4, false)%></td>
              <td class="thinborder"><%=CommonUtil.formatFloat(dMaleTotal5, false)%></td>
              <td class="thinborder"><%=CommonUtil.formatFloat(dFemaleTotal5, false)%></td>
              <td class="thinborder"><%=CommonUtil.formatFloat(dMaleTotal, false)%></td>
              <td class="thinborder"><%=CommonUtil.formatFloat(dMaleTotal, false)%></td>
              <td class="thinborder"><%=CommonUtil.formatFloat(dMaleTotal + dFemaleTotal, false)%></td>
            </tr>
            

          </table></td>
	  </tr>
		<tr>
		  <td height="25" class="body_font" style="font-weight:bold">C. LINKAGES</td>
	  </tr>
		<tr>
		  <td height="25" class="body_font">10. Do you have an International Institution Linkages? 
<%
strTemp = (String)vRetResult.elementAt(33);
if(strTemp != null && strTemp.equals("1"))
	strTemp = " Yes";
else	
	strTemp = "No";
%>	  			<%=strTemp%>
		  </td>
	  </tr>
		<tr>
		  <td height="25" class="body_font">11. If YES, please write the institutional name and country: (insert row if needed)</td>
	  </tr>
		<tr>
		  <td height="25" class="body_font">
<%
strTemp = WI.getStrValue((String)vRetResult.elementAt(34));
Vector vTemp = CommonUtil.convertCSVToVector(strTemp, "#", true);
if(vTemp != null && vTemp.size() > 0){%>
				<table width="70%" align="center" cellpadding="0" cellspacing="0" class="thinborder">
					<tr bgcolor="#99CCCC" align="center">
						<td height="22" width="50%" class="thinborder">Name</td>
						<td class="thinborder">Country</td>
					</tr>
					<%while(vTemp.size() > 0) {%>
					<tr align="center">
						<td height="22" width="50%" class="thinborder"><%=vTemp.remove(0)%></td>
						<td class="thinborder"><%if(vTemp.size()> 0){%><%=vTemp.remove(0)%><%}else{%>&nbsp;<%}%></td>
					</tr>
					<%}%>
				</table>

<%}%>
		  </td>
	  </tr>
		<tr>
		  <td height="25" class="body_font">12. Do you have an Industrial Linkages?
<%
strTemp = (String)vRetResult.elementAt(33);
if(strTemp != null && strTemp.equals("1"))
	strTemp = " selected";
else	
	strTemp = "";
%>	  			<%=strTemp%>
		  </td>
	  </tr>
		<tr>
		  <td height="25" class="body_font">13. If YES, please write the company name and country: (insert row if needed)</td>
	  </tr>
		<tr>
		  <td height="25" class="body_font">
<%
strTemp = WI.getStrValue((String)vRetResult.elementAt(36));
vTemp = CommonUtil.convertCSVToVector(strTemp, "#", true);
if(vTemp != null && vTemp.size() > 0){%>
				<table width="70%" align="center" cellpadding="0" cellspacing="0" class="thinborder">
					<tr bgcolor="#99CCCC" align="center">
						<td height="22" width="50%" class="thinborder">Company</td>
						<td class="thinborder">Country</td>
					</tr>
					<%while(vTemp.size() > 0) {%>
					<tr align="center">
						<td height="22" width="50%" class="thinborder"><%=vTemp.remove(0)%></td>
						<td class="thinborder"><%if(vTemp.size()> 0){%><%=vTemp.remove(0)%><%}else{%>&nbsp;<%}%></td>
					</tr>
					<%}%>
				</table>

<%}
double dUpperVal = Double.parseDouble(WI.getStrValue(vRetResult.elementAt(38), "0"));
double dLowerVal = Double.parseDouble(WI.getStrValue(vRetResult.elementAt(39), "0"));
%>
		  </td>
	  </tr>
		<tr>
		  <td height="25" class="body_font" style="font-weight:bold">D. STUDENT COST</td>
	  </tr>
		<tr>
		  <td height="25" class="body_font">14. How much is per student cost for AY <%=WI.fillTextValue("sy_from")%> - <%=Integer.parseInt(WI.fillTextValue("sy_from")) + 1%> 
		  &nbsp;&nbsp;&nbsp;P <%=CommonUtil.formatFloat(dUpperVal/dLowerVal, true)%>
		  
		  </td>
	  </tr>
		<tr>
		  <td height="25" class="body_font">Formula is:
		  <table width="75%" cellpadding="0" cellspacing="0">
		  	<tr>
				<td width="8%"></td>
				<td width="20%">Per student cost = </td>
				<td width="52%" class="body_font"><u>Maintenance and Other Operating Expenses + Personal Services</u></td>
				<td width="20%" class="body_font">
				   <%=CommonUtil.formatFloat(dUpperVal, true)%>				   </td>
			</tr>
		  	<tr>
		  	  <td></td>
		  	  <td>&nbsp;</td>
		  	  <td class="body_font" align="center">Number of Students</td>
		  	  <td class="body_font">
				  <%=CommonUtil.formatFloat(dLowerVal, true)%>   </td>
	  	    </tr>
		  </table>
		  
		  </td>
	  </tr>
		<tr>
		  <td height="25" class="body_font">15. How much is per unit cost for AY 2008-2009
		  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		  
<%
strTemp = WI.getStrValue(vRetResult.elementAt(37), "0");
strTemp = CommonUtil.formatFloat(strTemp, true);
%>				   P <%=strTemp%>				   </td>
	  </tr>
		<tr>
		  <td height="25" class="body_font">&nbsp;</td>
	  </tr>
		<tr>
		  <td height="25" class="body_font">&nbsp;</td>
	  </tr>
		<tr>
		  <td height="25" class="body_font">&nbsp;</td>
	  </tr>
	</table>
<%}//show only vRetResult is not null %>

  
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
