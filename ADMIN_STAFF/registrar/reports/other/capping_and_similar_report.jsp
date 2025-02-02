<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/td.js"></script>
<script language="JavaScript">
function PrintPage() {
	document.bgColor = "#FFFFFF";
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);

	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);

	document.getElementById('myADTable4').deleteRow(0);
	document.getElementById('myADTable4').deleteRow(0);
	
	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
}
function setReportName() {
	document.form_.report_name.value = document.form_.report[document.form_.report.selectedIndex].text;
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.ReportRegistrarExtn,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String[] astrConvertToSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};
	String[] astrConvertToYear = {"","1st Year","2nd Year","3rd Year","4th Year","5th Year","6th Year"};

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-Reports-Others","capping_and_similar_report.jsp");
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
//end of authenticaion code.
boolean bolShowGWA = false;

Vector vRetResult = null; Vector vSubHeading = null;
ReportRegistrarExtn rR = new ReportRegistrarExtn(); 
if(WI.fillTextValue("ShowResult").length() > 0)
	vRetResult = rR.viewCappingAndOtherReport(dbOP, request);
//System.out.println(rR.getErrMsg());
if(vRetResult != null)  {
	bolShowGWA = ((Boolean)vRetResult.remove(0)).booleanValue();
	vSubHeading = (Vector)vRetResult.remove(0);
}
else
	strErrMsg = rR.getErrMsg();		
	
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>

<form name="form_" action="./capping_and_similar_report.jsp" method="post" onSubmit="SubmitOnceButton(this);">
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="4" align="center"><font color="#FFFFFF"><strong>:::: 
        OTHER REPORTS PAGE ::::</strong></font></td>
    </tr>
    <tr> 
      <td width="3%" height="25" >&nbsp;</td>
      <td height="25" colspan="3" >&nbsp;&nbsp;&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr> 
      <td width="3%" height="25" >&nbsp;</td>
      <td width="7%" height="25" >SY/Term </td>
      <td width="41%" >
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
if(strTemp == null)
	strTemp = "";
%>
		  <input name="sy_from" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','sy_from');style.backgroundColor='white'"
	  onKeyUp='AllowOnlyInteger("form_","sy_from");DisplaySYTo("form_","sy_from","sy_to")'>
        to 
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
if(strTemp == null)
	strTemp = "";
%>        <input name="sy_to" type="text" size="4" value="<%=strTemp%>" class="textbox"
		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		readonly="yes">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<select name="semester" onChange="document.form_.submit();">
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
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
      </select></td>
      <td width="49%" >&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td >Report</td>
      <td colspan="2" >
	  <select name="report" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 11; color:#0000FF"
	  	onChange="document.form_.submit();">
<%
Vector vTemp = rR.operateOnCappingConfig(dbOP, request, 4);	
strTemp = WI.fillTextValue("report");	
if(vTemp != null && vTemp.size() > 0) {
	for(int i = 0; i < vTemp.size(); i += 8){
		if( !((String)vTemp.elementAt(i + 7)).startsWith("<"))
			continue;
		if(strTemp.equals(vTemp.elementAt(i)))
			strErrMsg = " selected";
		else
			strErrMsg = "";
		%>
		<option value="<%=vTemp.elementAt(i)%>"<%=strErrMsg%>><%=vTemp.elementAt(i + 1)%></option>
<%}//end of for loop
}//end of if condition.
%>	
      </select>
	  &nbsp;&nbsp; &nbsp;&nbsp; 
	  <a href="./capping_and_similar_config.jsp">Click to create Report Type</a>	  </td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td >&nbsp;</td>
      <td colspan="2" >NOTE : Report names are shown here only if complete subject equivalence is created. </td>
    </tr>
<%if(strSchCode.startsWith("CGH")){%>
    <tr>
      <td height="25" >&nbsp;</td>
      <td >Section</td>
      <td colspan="2" >
      <input name="section_name" type="text" size="12" value="<%=WI.fillTextValue("section_name")%>" class="textbox"
		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      <font size="1">(Optional - to list students belong to this section 
	  		during above SY/Term) </font>      </td>
    </tr>
<%}%>
    <tr>
      <td height="25" >&nbsp;</td>
      <td colspan="3" style="font-size:9px; color:#0000FF; font-weight:bold">
<%
strTemp = WI.fillTextValue("orderby_id");
if(strTemp.length() == 0 || strTemp.equals("1")) {
	strTemp   = " checked";
	strErrMsg = "";
}
else {
	strErrMsg = " checked";
	strTemp   = "";
}
%>
	  <input type="radio" name="orderby_id" value="1"<%=strTemp%>> Order by ID Number 
	  <input type="radio" name="orderby_id" value="0"<%=strErrMsg%>> Order by last name, first name 
<%
if(WI.fillTextValue("orderby_id").equals("2"))
	strErrMsg = " checked";
else
	strErrMsg = "";
%>	
	  <input type="radio" name="orderby_id" value="2"<%=strErrMsg%>> Order by GWA 
	  
	  
	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <input type="submit" name="1" value="Show Report" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="setReportName();document.form_.ShowResult.value=1">
      </td>
    </tr>
    
    <tr> 
      <td colspan="4" height="10" >&nbsp;</td>
    </tr>
  </table>
  <%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable3">
    <tr >
      <td width="100%" height="25">&nbsp;</td>
    </tr>
    <tr >
      <td height="25"><div align="right"><strong>
          <a href="javascript:PrintPage();"><img src="../../../../images/print.gif" border="0"></a>
          </strong><font size="1"> click to print list</font></div></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr >
      <td height="25" colspan="2" align="center"><font size="2">
      <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong></font></td>
    </tr>
    <tr >
      <td height="20" colspan="2" class="thinborderBOTTOM"><div align="center"><strong>
<%
strTemp = WI.fillTextValue("report_name").toUpperCase();
if(strTemp.length() == 0 || strTemp.equals("<<For example. Dean's lister/ Top student>>".toUpperCase()))
	strTemp = WI.fillTextValue("report_name")+" REPORT LIST";
%>
	  <%=strTemp%></strong><br>
	  	<%=astrConvertToSem[Integer.parseInt(request.getParameter("semester"))]%> ,
		AY <%=request.getParameter("sy_from")+"-"+request.getParameter("sy_to")%>        </div></td>
    </tr>
    
    <tr >
      <td width="34%" class="thinborderNONE">&nbsp;</td>
      <td width="66%" height="20" align="right" class="thinborderNONE">Date &amp; time printed: <%=WI.getTodaysDateTime()%>&nbsp;</td>
    </tr>
  </table>

  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">    
    <tr>
      <td height="25" colspan="3" class="thinborderNONE"><strong>
		Total Count : <%=vRetResult.size()/5%></strong></td>
      <td width="30%" style="font-size:11px; font-weight:bold">
	  <%if(WI.fillTextValue("section_name").length() > 0) {%>
	  	Section : <%=WI.fillTextValue("section_name")%>
	  <%}%>
	  </td>
    </tr>
  </table>

  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr style="font-weight:bold">
      <td width="2%" align="center" class="thinborder" style="font-size:9px">#</td>
      <td width="13%" height="25" align="center" class="thinborder" style="font-size:9px">STUDENT ID</td>
      <td width="20%" align="center" class="thinborder" style="font-size:9px">STUDENT NAME</td>
<%for(int i = 0; i < vSubHeading.size(); ++i){%>
      <td width="5%" align="center" class="thinborder" style="font-size:9px"><%=vSubHeading.elementAt(i)%></td>
<%}if(bolShowGWA){%>      
      <td width="5%" align="center" class="thinborder" style="font-size:9px">GWA</td>
<%}//do not show if gwa is not to be shown.%>
    </tr>
<%

for(int i=0,j = 0; i< vRetResult.size();){
vTemp = (Vector)vRetResult.remove(4);///remove subject with grade.. 
vRetResult.removeElementAt(0);//remove user index. 
%>
    <tr>
      <td class="thinborder"><%=++j%>.</td>
      <td height="25" class="thinborder"><%=(String)vRetResult.remove(0)%></td>
      <td class="thinborder"><%=(String)vRetResult.remove(0)%></td>
<%for(int p = 0; p < vTemp.size(); p += 2){
	strTemp = (String)vTemp.elementAt(p + 1);
	if(strTemp != null && strTemp.length() == 3)
		strTemp = strTemp + "0";%>
      <td width="5%" align="center" class="thinborder" style="font-size:9px"><%=strTemp%></td>
<%}if(bolShowGWA){%>      
      <td align="center" class="thinborder"><%=(String)vRetResult.remove(0)%></td>
<%}else
	vRetResult.removeElementAt(0);%>
    </tr>
<%} //end for loop%>
  </table>
<%
	}//vRetResult is not null
%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable4">
    <tr>
      <td colspan="8" height="25">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="8" height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="ShowResult">
  <input type="hidden" name="report_name">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
